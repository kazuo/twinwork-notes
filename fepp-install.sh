#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

echo ""
echo "Install from ports?"
echo -n "Use ports to install? Choosing no will use pkg insead [Y/n]: " && read CONTINUE

case ${CONTINUE} in
y | Y)
    # ports version update
    portsnap fetch update

    # nginx, pgsql, php74
    (cd /usr/ports/www/nginx/ && make -DBATCH install clean)
    (cd /usr/ports/databases/postgresql12-server/ && make -DBATCH install clean)
    (cd /usr/ports/lang/php74/ && make -DBATCH install clean)

    # default php74-extensions
    (cd /usr/ports/textproc/php74-ctype/ && make -DBATCH install clean)
    (cd /usr/ports/security/php74-filter/ && make -DBATCH install clean)
    (cd /usr/ports/security/php74-hash/ && make -DBATCH install clean)
    (cd /usr/ports/converters/php74-iconv/ && make -DBATCH install clean)
    (cd /usr/ports/devel/php74-json/ && make -DBATCH install clean)
    (cd /usr/ports/www/php74-opcache/ && make -DBATCH install clean)
    (cd /usr/ports/databases/php74-pdo/ && make -DBATCH install clean)
    (cd /usr/ports/archivers/php74-phar/ && make -DBATCH install clean)
    (cd /usr/ports/sysutils/php74-posix/ && make -DBATCH install clean)
    (cd /usr/ports/www/php74-session/ && make -DBATCH install clean)
    (cd /usr/ports/textproc/php74-simplexml/ && make -DBATCH install clean)
    (cd /usr/ports/databases/php74-sqlite3/ && make -DBATCH install clean)
    (cd /usr/ports/databases/php74-pdo_sqlite/ && make -DBATCH install clean)
    (cd /usr/ports/devel/php74-tokenizer/ && make -DBATCH install clean)
    (cd /usr/ports/textproc/php74-xml/ && make -DBATCH install clean)
    (cd /usr/ports/textproc/php74-xmlreader/ && make -DBATCH install clean)
    (cd /usr/ports/textproc/php74-xmlwriter/ && make -DBATCH install clean)

    # php74 pgsql extensions
    (cd /usr/ports/databases/php74-pgsql/ && make -DBATCH install clean)
    (cd /usr/ports/databases/php74-pdo_pgsql/ && make -DBATCH install clean)

    # other php74 extensions
    (cd /usr/ports/archivers/php74-bz2/ && make -DBATCH install clean)
    (cd /usr/ports/ftp/php74-curl/ && make -DBATCH install clean)
    (cd /usr/ports/textproc/php74-dom/ && make -DBATCH install clean)
    (cd /usr/ports/graphics/php74-exif/ && make -DBATCH install clean)
    (cd /usr/ports/graphics/php74-gd/ && make -DBATCH install clean)
    (cd /usr/ports/converters/php74-mbstring/ && make -DBATCH install clean)
    (cd /usr/ports/archivers/php74-zip/ && make -DBATCH install clean)
    (cd /usr/ports/archivers/php74-zlib/ && make -DBATCH install clean)

    # pecl
    (cd /usr/ports/security/pecl-mcrypt/ && make -DBATCH install clean)
    ;;
*)
    # pkg version
    pkg update
    pkg install --yes nginx
    pkg install --yes php74

    # default php74-extensions
    pkg install --yes php74-ctype
    pkg install --yes php74-filter
    pkg install --yes php74-hash
    pkg install --yes php74-iconv
    pkg install --yes php74-json
    pkg install --yes php74-opcache
    pkg install --yes php74-pdo
    pkg install --yes php74-phar
    pkg install --yes php74-posix
    pkg install --yes php74-session
    pkg install --yes php74-simplexml
    pkg install --yes php74-sqlite3
    pkg install --yes php74-pdo_sqlite
    pkg install --yes php74-tokenizer
    pkg install --yes php74-xml
    pkg install --yes php74-xmlreader
    pkg install --yes php74-xmlwriter

    # php74 pgsql extensions
    pkg install --yes php74-pgsql
    pkg install --yes php74-pdo_pgsql

    # other php74 extensions
    pkg install --yes php74-bz2
    pkg install --yes php74-curl
    pkg install --yes php74-dom
    pkg install --yes php74-exif
    pkg install --yes php74-gd
    pkg install --yes php74-mbstring
    pkg install --yes php74-zip
    pkg install --yes php74-zlib

    # pecl
    pkg install --yes php74-pecl-mcrypt

    # installing pgsql last since php74 insists to install
    # postgresql 11 for its client despite postgresql 12
    # is installed...
    pkg install --yes postgresql12-server
    ;;
esac

sysrc nginx_enable=YES
service nginx start
service nginx status
/usr/local/etc/rc.d/postgresql initdb --data-checksums
/usr/local/etc/rc.d/postgresql start
sysrc postgresql_enable=YES