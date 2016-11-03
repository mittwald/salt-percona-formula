# -*- coding: utf-8 -*-
# vim: ft=yaml:ts=2:sw=2
#
# Not all values listed here are considered as default-variables
#
mysql:
  root_password: milch
  reload_on_change: True
  config:
    my.cnf:
      mysqld:
        thread_pool_size: 3
        table_open_cache: 4000
      append:
        '!includedir /etc/mysql/conf.d/': no_param
        '!includedir /etc/mysql/percona-server.conf.d/': no_param
    server.cnf:
      client:
        port: 3306
        socket: /var/run/mysqld/mysqld.sock
      mysqld_safe:
        socket: /var/run/mysqld/mysqld.sock
        nice: 0
      mysqld:
        user: mysql
        pid_file: /var/run/mysqld/mysqld.pid
        socket: /var/run/mysqld/mysqld.sock
        port: 3306
        basedir: /usr
        datadir: /var/lib/mysql
        tmpdir: /tmp
        lc_messages_dir:  /usr/share/mysql
        bind_address: 127.0.0.1
        symbolic_links: 0
        skip_external_locking: no_param
        thread_cache_size: -1
        thread_pool_size: 4
      mysqldump:
        quick: no_param
        quote_names: no_param
        max_allowed_packet: 16M
      isamchk:
        key_buffer_size: 16M
