# -*- ruby -*-

require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = "0.1"
    gemspec.name = "frameos-builder"
    gemspec.summary = "FrameOS ISO image builder"
    gemspec.email = "sergio@rubio.name"
    gemspec.homepage = "http://frameos.org"
    gemspec.authors = ["Sergio Rubio"]
    gemspec.files.include %w(
      lib/frameos-builder.rb
      lib/rpmdev.rb
      resources/*
      vendor/**/*
    )
  end
rescue LoadError
  puts "Jeweler not available. Install it with gem install jeweler" 
end
