# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{choice}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Wanstrath"]
  s.autorequire = %q{choice}
  s.date = %q{2009-10-03}
  s.description = %q{Choice is a simple little gem for easily defining and parsing command line options with a friendly DSL.}
  s.email = %q{chris@ozmm.org}
  s.files = ["README", "CHANGELOG", "LICENSE", "lib/choice/lazyhash.rb", "lib/choice/option.rb", "lib/choice/parser.rb", "lib/choice/version.rb", "lib/choice/writer.rb", "lib/choice.rb", "test/test_choice.rb", "test/test_lazyhash.rb", "test/test_option.rb", "test/test_parser.rb", "test/test_writer.rb", "examples/ftpd.rb", "examples/gamble.rb"]
  s.homepage = %q{http://choice.rubyforge.org/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Choice is a command line option parser.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
