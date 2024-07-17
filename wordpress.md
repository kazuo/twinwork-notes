# Creating a new jail just for Wordpress

## jail config
Wordpress tests for loopback, so ensure your domain is also set in `/etc/hosts` as part of `localhost`

## nginx config

Ensure the wordpress folder is owned by `www`

```
chown -R www:www /usr/local/www/wp-root
```

## MariaDB config
CREATE DATABASE IF NOT EXISTS `wp-db` CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

CREATE USER 'wp-user'@localhost IDENTIFIED BY 'myawesomepassword';
GRANT ALL PRIVILEGES ON `wp-db`.* TO 'wp-user'@localhost IDENTIFIED BY 'myawesomepassword';

sudo bastille sysrc

## PHP config

Copy php.ini for default (production)

Need to add mysql socket path for mysqli and mysql (PDO) if you want PHP to connect using `localhost`

/usr/local/etc/php/ext-20-mysqli.ini
mysqli.default_socket = /var/run/mysql/mysql.sock

/usr/local/etc/php/ext-30-pdo_mysql.ini
mysql.default_socket = /var/run/mysql/mysql.sock

Increase POST and file upload size in `/usr/local/etc/php.ini`
post_max_size = 500M
upload_max_filesize = 500M

Increase PHP memory
memory_limit = 512M