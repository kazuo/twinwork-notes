#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

INSTALL_FROM=ports

usage() {
    echo "usage: $0 [--use-pkg]
        --help          : usage
        --use-ports     : use ports for install (default)
        --use-pkg       : use pkg for install
    "
}

handle_args() {
    for arg in "$@"
    do
        case $arg in
            --use-ports)
                INSTALL_FROM=ports
                shift
                ;;
            --use-pkg)
                INSTALL_FROM=pkg
                shift
                ;;
            *)
                usage
                exit 1
                shift
                ;;
        esac
    done
}

continue_prompt() {
    local MESSAGE=$1

    echo "________________________________________________________________________________"
    echo ${MESSAGE}
    read -p "Continue? [y/N] " yn
    case $yn in
        [Yy]*)
            ;;
        *)
            echo "Canceling operation..."
            exit 1
            ;;
    esac
}

install_from_ports() {
    # ports version update
    portsnap fetch update

    # nginx, pgsql, php74
    (cd /usr/ports/www/nginx/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/postgresql12-client/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/postgresql12-server/ && make -DBATCH install clean) && \
    (cd /usr/ports/lang/php74/ && make -DBATCH install clean) && \

    # default php74-extensions
    (cd /usr/ports/textproc/php74-ctype/ && make -DBATCH install clean) && \
    (cd /usr/ports/security/php74-filter/ && make -DBATCH install clean) && \
    (cd /usr/ports/converters/php74-iconv/ && make -DBATCH install clean) && \
    (cd /usr/ports/devel/php74-json/ && make -DBATCH install clean) && \
    (cd /usr/ports/www/php74-opcache/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/php74-pdo/ && make -DBATCH install clean) && \
    (cd /usr/ports/archivers/php74-phar/ && make -DBATCH install clean) && \
    (cd /usr/ports/sysutils/php74-posix/ && make -DBATCH install clean) && \
    (cd /usr/ports/www/php74-session/ && make -DBATCH install clean) && \
    (cd /usr/ports/textproc/php74-simplexml/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/php74-sqlite3/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/php74-pdo_sqlite/ && make -DBATCH install clean) && \
    (cd /usr/ports/devel/php74-tokenizer/ && make -DBATCH install clean) && \
    (cd /usr/ports/textproc/php74-xml/ && make -DBATCH install clean) && \
    (cd /usr/ports/textproc/php74-xmlreader/ && make -DBATCH install clean) && \
    (cd /usr/ports/textproc/php74-xmlwriter/ && make -DBATCH install clean) && \

    # php74 pgsql extensions
    (cd /usr/ports/databases/php74-pgsql/ && make -DBATCH install clean) && \
    (cd /usr/ports/databases/php74-pdo_pgsql/ && make -DBATCH install clean) && \

    # other php74 extensions
    (cd /usr/ports/archivers/php74-bz2/ && make -DBATCH install clean) && \
    (cd /usr/ports/ftp/php74-curl/ && make -DBATCH install clean) && \
    (cd /usr/ports/textproc/php74-dom/ && make -DBATCH install clean) && \
    (cd /usr/ports/graphics/php74-exif/ && make -DBATCH install clean) && \
    (cd /usr/ports/graphics/php74-gd/ && make -DBATCH install clean) && \
    (cd /usr/ports/devel/php74-intl/ && make -DBATCH install clean) && \
    (cd /usr/ports/converters/php74-mbstring/ && make -DBATCH install clean) && \
    (cd /usr/ports/security/php74-openssl/ && make install clean) && \
    (cd /usr/ports/archivers/php74-zip/ && make -DBATCH install clean) && \
    (cd /usr/ports/archivers/php74-zlib/ && make -DBATCH install clean) && \

    # pecl
    (cd /usr/ports/security/pecl-mcrypt/ && make -DBATCH install clean) && \

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    # pkg version
    pkg update
    pkg install --yes nginx
    pkg install --yes php74

    # default php74-extensions
    pkg install --yes php74-ctype
    pkg install --yes php74-filter
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
    pkg install --yes php74-intl
    pkg install --yes php74-mbstring
    pkg install --yes php74-openssl
    pkg install --yes php74-zip
    pkg install --yes php74-zlib

    # pecl
    pkg install --yes php74-pecl-mcrypt

    # py74-pgsql installs pgsql 11, so we install pgsql 12 last
    pkg install --yes postgresql12-server
}

main() {
    echo "Twinwork NOTES post-install for FreeBSD 12"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    continue_prompt "This will install Nginx, PostgreSQL, and PHP..."

    if [ ${INSTALL_FROM} == "pkg" ]; then
        install_from_pkg
    else
        install_from_ports
    fi

    sysrc postgresql_enable=YES
}

handle_args $@
main