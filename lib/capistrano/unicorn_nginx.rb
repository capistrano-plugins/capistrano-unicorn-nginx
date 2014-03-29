require 'capistrano/dsl/nginx_paths'
load File.expand_path("../tasks/nginx.rake", __FILE__)
load File.expand_path("../tasks/unicorn.rake", __FILE__)
