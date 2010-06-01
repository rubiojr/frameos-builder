require 'fileutils'
PKGLIST=ARGV[0]
PKGDIR=ARGV[1]
corepkgs = []
ARCH="x86_64"
IO.readlines(PKGLIST).each do |l|
  if not l.strip.chomp.empty?
    corepkgs << l.strip.chomp
  end
end

Dir["#{PKGDIR}/*.rpm"].each do |pkg|
  found = 0
  corepkgs.each do |cpkg|
    if pkg =~ /#{Regexp.escape(cpkg)}-\d.*\.x86_64\.rpm$/
      found = 1
      next
    end
  end
  if found == 0
    puts "pkg #{File.basename(pkg)} not in core, removing..."
    FileUtils.rm pkg
  end
end
