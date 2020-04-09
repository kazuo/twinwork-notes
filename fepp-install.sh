#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

echo ""
echo "Install from ports?"
echo -n "'Y' will install from ports, otherwise it will install from pkg " && read CONTINUE

case ${CONTINUE} in
y | Y)
    # ports version update
    portsnap fetch update

    # nginx, pgsql, php74
    (cd /usr/ports/www/nginx/ && make config-recursive)
    (cd /usr/ports/databases/postgresql12-server/ && make config-recursive)
    (cd /usr/ports/lang/php74/ && make config-recursive)

    # default php74-extensions
    (cd /usr/ports/textproc/php74-ctype/ && make config-recursive)
    (cd /usr/ports/security/php74-filter/ && make config-recursive)
    (cd /usr/ports/security/php74-hash/ && make config-recursive)
    (cd /usr/ports/converters/php74-iconv/ && make config-recursive)
    (cd /usr/ports/devel/php74-json/ && make config-recursive)
    (cd /usr/ports/www/php74-opcache/ && make config-recursive)
    (cd /usr/ports/databases/php74-pdo/ && make config-recursive)
    (cd /usr/ports/archivers/php74-phar/ && make config-recursive)
    (cd /usr/ports/sysutils/php74-posix/ && make config-recursive)
    (cd /usr/ports/www/php74-session/ && make config-recursive)
    (cd /usr/ports/textproc/php74-simplexml/ && make config-recursive)
    (cd /usr/ports/databases/php74-sqlite3/ && make config-recursive)
    (cd /usr/ports/databases/php74-pdo_sqlite/ && make config-recursive)
    (cd /usr/ports/devel/php74-tokenizer/ && make config-recursive)
    (cd /usr/ports/textproc/php74-xml/ && make config-recursive)
    (cd /usr/ports/textproc/php74-xmlreader/ && make config-recursive)
    (cd /usr/ports/textproc/php74-xmlwriter/ && make config-recursive)

    # php74 pgsql extensions
    (cd /usr/ports/databases/php74-pgsql/ && make config-recursive)
    (cd /usr/ports/databases/php74-pdo_pgsql/ && make config-recursive)

    # other php74 extensions
    (cd /usr/ports/archivers/php74-bz2/ && make config-recursive)
    (cd /usr/ports/ftp/php74-curl/ && make config-recursive)
    (cd /usr/ports/textproc/php74-dom/ && make config-recursive)
    (cd /usr/ports/graphics/php74-exif/ && make config-recursive)
    (cd /usr/ports/graphics/php74-gd/ && make config-recursive)
    (cd /usr/ports/converters/php74-mbstring/ && make config-recursive)
    (cd /usr/ports/archivers/php74-zip/ && make config-recursive)
    (cd /usr/ports/archivers/php74-zlib/ && make config-recursive)

    # pecl
    (cd /usr/ports/security/pecl-mcrypt/ && make config-recursive)

    # nginx, pgsql, php74
    (cd /usr/ports/www/nginx/ && make install clean)
    (cd /usr/ports/databases/postgresql12-server/ && make install clean)
    (cd /usr/ports/lang/php74/ && make install clean)

    # default php74-extensions
    (cd /usr/ports/textproc/php74-ctype/ && make install clean)
    (cd /usr/ports/security/php74-filter/ && make install clean)
    (cd /usr/ports/security/php74-hash/ && make install clean)
    (cd /usr/ports/converters/php74-iconv/ && make install clean)
    (cd /usr/ports/devel/php74-json/ && make install clean)
    (cd /usr/ports/www/php74-opcache/ && make install clean)
    (cd /usr/ports/databases/php74-pdo/ && make install clean)
    (cd /usr/ports/archivers/php74-phar/ && make install clean)
    (cd /usr/ports/sysutils/php74-posix/ && make install clean)
    (cd /usr/ports/www/php74-session/ && make install clean)
    (cd /usr/ports/textproc/php74-simplexml/ && make install clean)
    (cd /usr/ports/databases/php74-sqlite3/ && make install clean)
    (cd /usr/ports/databases/php74-pdo_sqlite/ && make install clean)
    (cd /usr/ports/devel/php74-tokenizer/ && make install clean)
    (cd /usr/ports/textproc/php74-xml/ && make install clean)
    (cd /usr/ports/textproc/php74-xmlreader/ && make install clean)
    (cd /usr/ports/textproc/php74-xmlwriter/ && make install clean)

    # php74 pgsql extensions
    (cd /usr/ports/databases/php74-pgsql/ && make install clean)
    (cd /usr/ports/databases/php74-pdo_pgsql/ && make install clean)

    # other php74 extensions
    (cd /usr/ports/archivers/php74-bz2/ && make install clean)
    (cd /usr/ports/ftp/php74-curl/ && make install clean)
    (cd /usr/ports/textproc/php74-dom/ && make install clean)
    (cd /usr/ports/graphics/php74-exif/ && make install clean)
    (cd /usr/ports/graphics/php74-gd/ && make install clean)
    (cd /usr/ports/converters/php74-mbstring/ && make install clean)
    (cd /usr/ports/archivers/php74-zip/ && make install clean)
    (cd /usr/ports/archivers/php74-zlib/ && make install clean)

    # pecl
    (cd /usr/ports/security/pecl-mcrypt/ && make install clean)
    ;;
*)
    # pkg version
    pkg update
    pkg install --yes nginx
    pkg install --yes postgresql12-server
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
    ;;
esac

sysrc nginx_enable=yes
service nginx start
service nginx status
