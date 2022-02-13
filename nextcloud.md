# Nextcloud

This guides you through an install of Nextcloud. It assumes you're using Bastille as your  jail manager.

## Create and configure your jail
sudo bastille create nextcloud 13.0-RELEASE 192.168.2.21
sudo bastille config nextcloud set sysvsem new
sudo bastille config nextcloud set sysvmsg new
sudo bastille config nextcloud set sysvshm new
sudo bastille config nextcloud set allow.raw_sockets
sudo bastille restart nextcloud

sudo bastille cmd nextcloud portsnap fetch auto

## Install PostgreSQL
Commands from this point on will be from within your jail, via
sudo bastille console nextcloud

Install vim, PostgreSQL, nginx

make -C /usr/ports/security/sudo/ -DBATCH install clean && \
    make -C /usr/ports/editors/vim/ -DBATCH install clean && \
    make -C /usr/ports/www/nginx/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-client/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-server/ -DBATCH install clean

Install PHP and required extensions
make -C /usr/ports/lang/php80/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-ctype/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-dom/ -DBATCH install clean && \
    make -C /usr/ports/security/php80-filter/ -DBATCH install clean && \
    make -C /usr/ports/converters/php80-iconv/ -DBATCH install clean && \
    make -C /usr/ports/www/php80-opcache/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-pdo/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-phar/ -DBATCH install clean && \
    make -C /usr/ports/sysutils/php80-posix/ -DBATCH install clean && \
    make -C /usr/ports/www/php80-session/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-simplexml/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-sqlite3/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-pdo_sqlite/ -DBATCH install clean && \
    make -C /usr/ports/devel/php80-tokenizer/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-xml/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-xmlreader/ -DBATCH install clean && \
    make -C /usr/ports/textproc/php80-xmlwriter/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-pgsql/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-pdo_pgsql/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-bz2/ -DBATCH install clean && \
    make -C /usr/ports/ftp/php80-curl/ -DBATCH install clean && \
    make -C /usr/ports/graphics/php80-exif/ -DBATCH install clean && \
    make -C /usr/ports/graphics/php80-gd/ -DBATCH install clean && \
    make -C /usr/ports/devel/php80-intl/ -DBATCH install clean && \
    make -C /usr/ports/converters/php80-mbstring/ -DBATCH install clean && \
    make -C /usr/ports/security/php80-openssl/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-zip/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-zlib/ -DBATCH install clean && \
    make -C /usr/ports/sysutils/php80-fileinfo/ -DBATCH install clean && \
    make -C /usr/ports/graphics/pecl-imagick/ -DBATCH install clean && \
    make -C /usr/ports/ftp/php80-ftp/ -DBATCH install clean && \
    make -C /usr/ports/math/php80-bcmath/ -DBATCH install clean && \
    make -C /usr/ports/math/php80-gmp/ -DBATCH install clean && \
    make -C /usr/ports/devel/php80-pcntl/ -DBATCH install clean

# Setup nginx
We'll need an SSL cert. Instead of using a self-signed cert, we'll use Let's Encrypt

make -C /usr/ports/security/py-certbot/ -DBATCH install clean

make -C /usr/ports/www/nextcloud/ install clean