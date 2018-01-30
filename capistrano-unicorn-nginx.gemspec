# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/unicorn_nginx/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-unicorn-nginx-ami"
  gem.version       = Capistrano::UnicornNginx::VERSION
  gem.authors       = ["Ruben Stranders", "Bruno Sutic", "Jesper Rønn-Jensen"]
  gem.email         = ["r.stranders@gmail.com", "bruno.sutic@gmail.com"]
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Capistrano tasks for automatic  and sensible unicorn + nginx configuraion.

    Enables zero downtime deployments of Rails applications. Configs can be
    copied to the application using generators and easily customized.

    This fork is customized for Redhat-based nginx systems. For example Amazon Linux.

    Works *only* with Capistrano 3+. For Capistrano 2 try version 0.0.8 of this
    gem: http://rubygems.org/gems/capistrano-nginx-unicorn
  EOF
  gem.summary       = "Capistrano tasks for automatic and sensible unicorn + nginx configuraion."
  gem.homepage      = "https://github.com/jesperronn/capistrano-unicorn-nginx-ami"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", ">= 3.1"
  gem.add_dependency "sshkit", ">= 1.2.0"

  gem.add_development_dependency "rake"
end
