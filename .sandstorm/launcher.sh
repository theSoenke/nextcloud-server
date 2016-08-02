#!/bin/bash

# Create a bunch of folders under the clean /var that php, nginx, and mysql expect to exist
mkdir -p /var/lib/mysql
mkdir -p /var/lib/nginx
mkdir -p /var/lib/php5/sessions
mkdir -p /var/log
mkdir -p /var/log/mysql
mkdir -p /var/log/nginx
# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run
mkdir -p /var/run/mysqld

# Ensure mysql tables created
HOME=/etc/mysql /usr/bin/mysql_install_db --force

# Spawn mysqld, php
HOME=/etc/mysql /usr/sbin/mysqld &
/usr/sbin/php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf &
# Wait until mysql and php have bound their sockets, indicating readiness
while [ ! -e /var/run/mysqld/mysqld.sock ] ; do
    echo "waiting for mysql to be available at /var/run/mysqld/mysqld.sock"
    sleep .2
done
while [ ! -e /var/run/php5-fpm.sock ] ; do
    echo "waiting for php5-fpm to be available at /var/run/php5-fpm.sock"
    sleep .2
done


if [ ! -e /opt/app/config/config.php ]; then
  # create data, config and apps directory
  mkdir -p /var/data
  mkdir -p /var/config
  mkdir -p /var/apps
  mkdir -p /var/core/js
  touch /var/core/js/oc.js

  # install nextcloud
  cd /opt/app
  php occ maintenance:install --database "mysql" \
    --database-name "nextcloud" \
    --database-user "root" \
    --database-pass "" \
    --admin-pass "test" \
    --data-dir "/opt/app/data"
fi

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
