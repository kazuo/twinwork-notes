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
    portsnap fetch auto && \

    # nginx, pgsql, php80
    make -C /usr/ports/www/nginx/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-client/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-server/ -DBATCH install clean && \
    make -C /usr/ports/lang/php80/ -DBATCH install clean && \

    # default php80-extensions (i.e. /usr/ports/lang/php80-extensions/)
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

    # php80 pgsql extensions
    make -C /usr/ports/databases/php80-pgsql/ -DBATCH install clean && \
    make -C /usr/ports/databases/php80-pdo_pgsql/ -DBATCH install clean && \

    # other php80 extensions
    make -C /usr/ports/archivers/php80-bz2/ -DBATCH install clean && \
    make -C /usr/ports/ftp/php80-curl/ -DBATCH install clean && \    
    make -C /usr/ports/graphics/php80-exif/ -DBATCH install clean && \
    make -C /usr/ports/graphics/php80-gd/ -DBATCH install clean && \
    make -C /usr/ports/devel/php80-intl/ -DBATCH install clean && \
    make -C /usr/ports/converters/php80-mbstring/ -DBATCH install clean && \
    make -C /usr/ports/security/php80-openssl/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-zip/ -DBATCH install clean && \
    make -C /usr/ports/archivers/php80-zlib/ -DBATCH install clean && \

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    # pkg version
    pkg update && \

    pkg install --yes www/nginx && \
    pkg install --yes lang/php80 && \

    # default php80-extensions (i.e pkg install lang/php80-extensions)
    pkg install --yes textproc/php80-ctype && \
    pkg install --yes textproc/php80-dom && \    
    pkg install --yes security/php80-filter && \
    pkg install --yes converters/php80-iconv && \
    pkg install --yes www/php80-opcache && \
    pkg install --yes databases/php80-pdo && \
    pkg install --yes archivers/php80-phar && \
    pkg install --yes sysutils/php80-posix && \
    pkg install --yes www/php80-session && \
    pkg install --yes textproc/php80-simplexml && \
    pkg install --yes databases/php80-sqlite3 && \
    pkg install --yes databases/php80-pdo_sqlite && \
    pkg install --yes devel/php80-tokenizer && \
    pkg install --yes textproc/php80-xml && \
    pkg install --yes textproc/php80-xmlreader && \
    pkg install --yes textproc/php80-xmlwriter && \

    # php80 pgsql extensions
    pkg install --yes databases/php80-pgsql && \
    pkg install --yes databases/php80-pdo_pgsql && \

    # other php80 extensions
    pkg install --yes archivers/php80-bz2 && \
    pkg install --yes ftp/php80-curl && \    
    pkg install --yes graphics/php80-exif && \
    pkg install --yes graphics/php80-gd && \
    pkg install --yes devel/php80-intl && \
    pkg install --yes converters/php80-mbstring && \
    pkg install --yes security/php80-openssl && \
    pkg install --yes archivers/php80-zip && \
    pkg install --yes archivers/php80-zlib && \

    # pg80-pgsql installs pgsql 12, so we install pgsql 14 last
    pkg install --yes postgresql14-server && \

    pkg clean
}

main() {
    echo "Twinwork NOTES feapp-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    continue_prompt "This will install Nginx, PostgreSQL, and PHP..."

    if [ ${INSTALL_FROM} == "pkg" ]; then
        install_from_pkg
    else
        install_from_ports
    fi
}

handle_args $@
main