# Capistrano::UnicornNginx

Capistrano tasks for automatic and sensible unicorn + nginx configuraion.

Goals of this plugin:

* automatic unicorn and nginx configuration for Rails apps
* **no manual ssh** to the server required
* zero downtime deployments enabled
* support for single node as well as cluster deployments

Specifics:

* generates nginx config file on the server (web role)
* generates unicorn initializer and config files (app role)<br/>
application is started automatically after server restart
* capistrano tasks for server management, example: `unicorn:restart`<br/>
see below for all available tasks
* automatic load balancing setup when there are multiple `app` nodes

`capistrano-unicorn-nginx` works only with Capistrano 3!

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.2.1'
      gem 'capistrano-unicorn-nginx', '~> 3.2.0'
    end

And then:

    $ bundle install

### Setup and usage

Depending on your needs 2 general scenarios are covered:

- [single server setup](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Single-server-setup)<br/>
  A scenario where you run the webserver (nginx) and application server
  (unicorn) on the same node.
- [multiple server setup](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Multiple-server-setup)<br/>
  Webserver (nginx) and application server (unicorn) run on different nodes.

### Default log file directories

- nginx: `/var/log/nginx/`
- unicorn: `#{shared_path}/log/`

### Configuration

See the
[full options list on the wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Configuration).
Feel free to skip this unless you're looking for something specific.

### How it works

[How it works wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/How-it-works)
contains the list of tasks that the plugin executes.

You do not have to know this unless you want to learn more about the plugin internals.

### Template customization

[On template customization wiki page](https://github.com/capistrano-plugins/capistrano-unicorn-nginx/wiki/Template-customization)
see how to inspect, tweak and override templates for `nginx` and `unicorn`
config files.

Do not do this unless you have a specific need.

### More Capistrano automation?

Check out [capistrano-plugins](https://github.com/capistrano-plugins) github org.

### Bug reports and pull requests

...are very welcome!

### Thanks

[@kalys](https://github.com/kalys) - for his
[capistrano-nginx-unicorn](https://github.com/kalys/capistrano-nginx-unicorn)
plugin.
