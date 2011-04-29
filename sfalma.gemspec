# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sfalma/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = %q{sfalma}
  gem.version = Sfalma::VERSION
  gem.authors = ["Sfalma"]
  gem.summary = %q{ sfalma.com is a cloud-based error tracker with a social twist with a focus on mobile apps }
  gem.description = %q{Sfalma is the Ruby gem for communicating with http://sfalma.com (hosted error tracking service). Use it to find out about errors that happen in your live app. You can share the errors with members of the community and share solutions. It captures lots of helpful information to help you fix the errors.}
  gem.email = %q{info@sfalma.com}
  gem.files =  Dir['lib/**/*'] + Dir['spec/**/*'] + Dir['spec/**/*'] + Dir['rails/**/*'] + Dir['tasks/**/*'] + Dir['*.rb'] + ["sfalma.gemspec"]
  gem.homepage = %q{http://sfalma.com/}
  gem.require_paths = ["lib"]
  gem.executables << 'sfalma'
  gem.rubyforge_project = %q{sfalma}
  gem.requirements << "json_pure, json-jruby or json gem required"
  gem.add_dependency 'rack'
end
