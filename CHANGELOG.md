# Changelog

### master

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
