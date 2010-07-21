#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'logger'
require 'fileutils'
require File.join(File.dirname(__FILE__), "rpmdev")

FRAMEOS_BUILDER_VERSION = '0.2'
TMPDIR = '/tmp/frameos-builder'
RESOURCES_DIR = File.join(File.dirname(__FILE__),'../resources')
IMAGES_DIR = File.join(File.dirname(__FILE__),'../images')
PACKAGES_DIR = File.join(File.dirname(__FILE__),'../packages')
#
# Exit codes
#
EXIT_NONROOT = 1
EXIT_MOUNTFAILED = 2
EXIT_UMOUNTFAILED = 3

def requirements_ok? 
  if not File.exist? "/usr/bin/which"
    error "which not found in /usr/bin/which"
    return false
  end
  if not File.exist? "/usr/bin/mkisofs"
    error "mkisofs not found in /usr/bin/mkisofs"
    return false
  end

  if not File.exist? "/sbin/mksquashfs"
    error "mksquashfs not found in /sbin/mksquashfs"
    return false
  end
  if not File.exist? "/usr/bin/createrepo"
    error "createrepo not found in /usr/bin/createrepo"
    return false
  end
  true
end

def supported_environment?
  return false if not File.exist?('/etc/redhat-release')
  return false if File.read('/etc/redhat-release') !~ /.*(CentOS|FrameOS) release 5.*/
  return true
end

def do_initrd_branding(initrd_file, product_name='FrameOS', 
                                    product_version = '1', 
                                    bugs_url = 'http://bugs.frameos.org')
  #TODO
  # check if gzip, find and cpio are present
  #
  Dir.mkdir "#{TMPDIR}/initrd.dir"
  `cd #{TMPDIR}/initrd.dir && gzip -dc #{initrd_file} | cpio -iud`
  File.open "#{TMPDIR}/initrd.dir/.buildstamp","w" do |f|
    f.puts "#{Time.now.strftime '%Y%m%d0001.x86_64'}"
    f.puts product_name
    f.puts product_version
    f.puts product_name
    f.puts bugs_url
  end
  `cd #{TMPDIR}/initrd.dir && find ./|cpio -H newc -o > #{TMPDIR}/initrd`
  `cd #{TMPDIR} && gzip initrd && mv initrd.gz initrd.img`
  `cd #{TMPDIR} && cp initrd.img newiso/isolinux/`
  if CLEANUP_ENV
    `rm -rf #{TMPDIR}/initrd.dir`
  end
end

def do_stage2_branding(stage2_file, 
                       product_name='FrameOS', 
                       product_version = '1', 
                       bugs_url = 'http://bugs.frameos.org', 
                       anaconda_pixmaps_dir = nil,
                       custom_anaconda_pkg = nil,
                       custom_redhat_logos_pkg = nil
                      )
  #TODO
  # check if mksquasfs and unsquashfs and rpm2cpio are present
  #
  s2dir = "#{TMPDIR}/stage2"
  Dir.mkdir "#{s2dir}"
  `cd #{s2dir} && unsquashfs #{stage2_file}`
  File.open "#{s2dir}/squashfs-root/.buildstamp","w" do |f|
    f.puts "#{Time.now.strftime '%Y%m%d0001.x86_64'}"
    f.puts product_name
    f.puts product_version
    f.puts product_name
    f.puts bugs_url
  end

  if custom_anaconda_pkg
    `rm -rf #{s2dir}/squashfs-root/usr/share/anaconda/pixmaps`
    `cd #{s2dir}/squashfs-root/ && rpm2cpio #{File.expand_path(custom_anaconda_pkg)} | cpio -iud`
  else
    if anaconda_pixmaps_dir and File.directory?(anaconda_pixmaps_dir)
      Dir["#{anaconda_pixmaps_dir}/*.png"].each do |img|
        FileUtils.cp File.expand_path(img), "#{s2dir}/squashfs-root/usr/share/anaconda/pixmaps/"
      end
      Dir["#{anaconda_pixmaps_dir}/rnotes/*.png"].each do |img|
        FileUtils.cp File.expand_path(img), "#{s2dir}/squashfs-root/usr/share/anaconda/pixmaps/rnotes/"
        %w(en es).each do |lang|
          FileUtils.cp File.expand_path(img), "#{s2dir}/squashfs-root/usr/share/anaconda/pixmaps/rnotes/#{lang}/"
        end
      end
    end
    # Replace language table, English only for now.
    FileUtils.cp File.expand_path("#{RESOURCES_DIR}/lang-table"), "#{s2dir}/squashfs-root/usr/lib/anaconda/lang-table"
    FileUtils.cp File.expand_path("#{RESOURCES_DIR}/lang-names"), "#{s2dir}/squashfs-root/usr/lib/anaconda/lang-names"
  end

  if custom_redhat_logos_pkg
    `cd #{s2dir}/squashfs-root/ && rpm2cpio #{File.expand_path(custom_redhat_logos_pkg)} | cpio -iud`
  end

  `cd #{s2dir} && mksquashfs squashfs-root stage2.img`
  `cd #{s2dir} && mv stage2.img #{TMPDIR}/newiso/images/`
  if CLEANUP_ENV
    `rm -rf #{s2dir}`
  end
end

def debug(msg)
  Log.debug msg
  puts msg if Log.level == Logger::DEBUG
end

def error(msg)
  Log.error msg
  $stderr.puts msg
end

def info(msg)
  Log.info msg
  puts msg
end

def trim_rpms(minlist, trimdir)
  arch = [ 'x86_64', 'noarch' ]
  core_pkg_list =  []

  IO.readlines(minlist).each do |l|
    if not RPMDev::valid_rpm_name?(l)
      puts "WARNING: invalid RPM #{l}" 
    else
      core_pkg_list << RPMDev.parse_rpm_name(l.chomp.strip)[0]
    end
  end

  removed_pkgs = 0
  core_pkgs = 0
  total_pkgs = 0

  Dir["#{trimdir}/*.rpm"].each do |rpm|
    total_pkgs += 1
    bn = File.basename rpm 
    n,v,r,a = RPMDev.parse_rpm_name(bn)
    if (not core_pkg_list.include?(n)) or (not arch.include?(a))
      debug "#{bn} not in core set, removing..."
      removed_pkgs += 1
      FileUtils.rm_f "#{trimdir}/#{bn}"
    else
      core_pkgs += 1
    end
  end

  return total_pkgs, core_pkgs, removed_pkgs
end

def gen_isolinux_file
  @boot_labels = ""
  Choice.choices[:ks_files].each do |ksfile|
    name = File.basename(ksfile, '.ks') 
    l = """
label #{name}
  kernel vmlinuz
  append ramdisk=8192 ks=cdrom:/#{name}.ks initrd=initrd.img ksdevice=link
"""
    @boot_labels << l
  end
  template = ERB.new(File.read(Choice.choices[:isolinux_config_template]))
                               
  File.open("#{TMPDIR}/newiso/isolinux/isolinux.cfg", 'w') do |f|
    f.puts template.result(binding)
  end
end
