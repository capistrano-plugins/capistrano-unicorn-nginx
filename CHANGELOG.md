# Changelog

### master

### v5.2.0, 2018-03-05
- Allow nginx_ssl_client_ca to be empty, otherwise the setting `optional_no_ca`
  does not seem to work correctly

### v5.1.0, 2018-02-08
- Remove raw certificate from nginx header. This can result in 400 errors in
  conjunction with unicorn (some versions). Use ssl_client_cert instead

### v5.0.0, 2018-02-08
- Remove `nginx_pass_ssl_client_cert` in favor of nginx_use_client_ssl
- Add `nginx_server_ssl_ports` to specify which ports nginx should listen on
- Remove `nginx_use_spdy`. Use `nginx_use_http2` instead.

### v4.2.0, 2018-02-08
- Add support for client authentication using a root CA. Inspired by
  http://www.pandurang-waghulde.com/2014/06/client-side-ssl-certificate.html

### v4.1.0, 2017-06-21
- Auto-generate dhparams.pem if missing
- Add support for http2
- Fix unicorn:restart

### v4.0.0, 2016-03-29
- Improves SSL security and performance. Breaking changes with 3.4.0. Please
  read README.md

### v3.4.0, 2015-09-17
- Allow customizing paths for SSL certificate and key
- Use sudo to restart services
- Remove whitespace in template ERB files

### v3.3.3, 2015-05-05
- add `unicorn_env` option for passing environmental variables to unicorn (@rhomeister)

### v3.3.2, 2015-02-16
- bug fix: replaced non-existent `log_dir` with `unicorn_log_dir` (@rhomeister)

### v3.3.1, 2015-02-16
- made nginx fail_timeout configurable (@rhomeister)
- added logrotate configuration for nginx logs (@rhomeister)

### v3.3.0, 2015-02-09
- added client SSL authentication (@rhomeister)
- make unicorn timeout configurable (@vicentllongo)

### v3.2.0, 2015-01-28
- allow 'PATCH' HTTP method in nginx_conf (@lonre)
- added SPDY support (@rhomeister)

### v3.1.2, 2014-12-14
- removed HTML 405 method from `nginx.conf`

### v3.1.1, 2014-10-09
- add `server_name` directive for the port 80 ssl block in nginx_conf

### v3.1.0, 2014-10-07
- setup nginx and unicorn to use TCP if web and app roles are using different
  servers
- update default nginx log dir location to `/var/log/nginx`

### v3.0.0, 2014-10-05
- enable setting unicorn app environment with `rails_env` option.
  If `rails_env` is not set, `stage` option is used as until now. (@bruno-)
- add load balancing support (@rhomeister)
- config files are updated each time `setup` task is run (@rhomeister)

### v2.1.0, 2014-08-05
- add `nginx_location` option that specifies nginx installation dir
  (@jordanyaker)

### v2.0.0, 2014-04-11
- all the work is moved to the `setup` task

### v1.0.2, 2014-03-30
- add `sudo_upload!` helper method for easier uploads
- improve the way how templates are handled

### v1.0.1, 2014-03-30
- refactor all unicorn and nginx paths to separate modules
- speed up `nginx:setup_ssl` task
- small README update

### v1.0.0, 2014-03-29
- @bruno- all the v1.0.0 features
