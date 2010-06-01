require 'pp'
module RPMDev

  #
  # receives an rpm filename
  # returns name, version, release, arch
  #
  class << self
    def parse_rpm_name(rpm)
      fname = rpm.strip.chomp.gsub /\.rpm$/, ''
      tokens = fname.split('-')
      arch_rel = tokens.pop.split('.')
      arch = arch_rel.pop
      release = arch_rel.join('.')
      version = tokens.pop
      name = tokens.join '-'
      return name, version, release, arch
    end

    def valid_rpm_name?(rpm)
      return false if rpm !~ /\.rpm$/
      parse_rpm_name(rpm).each do |c|
        return false if (c.nil? or c.empty?)
      end
      true
    end
  end
end
