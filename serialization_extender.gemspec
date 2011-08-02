# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "serialization_extender/version"

Gem::Specification.new do |s|
  s.name        = "serialization_extender"
  s.version     = SerializationExtender::VERSION
  s.authors     = ["Andrew Rudenko", "Nick Recobra"]
  s.email       = ["ceo@prepor.ru"]
  s.homepage    = "http://github.com/Undev/serialization_extender"
  s.summary     = %q{JSON serialization profiles.}
  s.description = %q{Multiple JSON serialization profiles for your ActiveModel objects.}

  s.rubyforge_project = "serialization_extender"
  s.add_dependency 'ruby-interface', '>= 0.0.6'
  s.add_development_dependency 'rspec', '>= 2.6.0'
  s.add_development_dependency 'activemodel', '>= 3.0.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
