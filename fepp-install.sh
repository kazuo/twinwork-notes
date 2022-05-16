#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

INSTALL_FROM=ports
DIR=$(dirname "$0")
. ${DIR}/shared.sh


PKGS=""
# nginx, pgsql, php80
PKGS="${PKGS} www/nginx"
PKGS="${PKGS} databases/postgresql14-client"
PKGS="${PKGS} databases/postgresql14-server"
PKGS="${PKGS} lang/php80"

# default php80-extensions (i.e. /usr/ports/lang/php80-extensions/)
PKGS="${PKGS} textproc/php80-ctype"
PKGS="${PKGS} textproc/php80-dom"
PKGS="${PKGS} security/php80-filter"
PKGS="${PKGS} converters/php80-iconv"
PKGS="${PKGS} www/php80-opcache"
PKGS="${PKGS} databases/php80-pdo"
PKGS="${PKGS} archivers/php80-phar"
PKGS="${PKGS} sysutils/php80-posix"
PKGS="${PKGS} www/php80-session"
PKGS="${PKGS} textproc/php80-simplexml"
PKGS="${PKGS} databases/php80-sqlite3"
PKGS="${PKGS} databases/php80-pdo_sqlite"
PKGS="${PKGS} devel/php80-tokenizer"
PKGS="${PKGS} textproc/php80-xml"
PKGS="${PKGS} textproc/php80-xmlreader"
PKGS="${PKGS} textproc/php80-xmlwriter"

# php80 pgsql extensions
PKGS="${PKGS} databases/php80-pgsql"
PKGS="${PKGS} databases/php80-pdo_pgsql"

# other php80 extensions
PKGS="${PKGS} archivers/php80-bz2"
PKGS="${PKGS} ftp/php80-curl"
PKGS="${PKGS} graphics/php80-exif"
PKGS="${PKGS} graphics/php80-gd"
PKGS="${PKGS} devel/php80-intl"
PKGS="${PKGS} converters/php80-mbstring"
PKGS="${PKGS} archivers/php80-zip"
PKGS="${PKGS} archivers/php80-zlib"

# other php80 extensions recommended for nextcloud
PKGS="${PKGS} sysutils/php80-fileinfo"
PKGS="${PKGS} graphics/pecl-imagick"
PKGS="${PKGS} ftp/php80-ftp"
PKGS="${PKGS} math/php80-bcmath"
PKGS="${PKGS} math/php80-gmp"
PKGS="${PKGS} devel/php80-pcntl"

usage() {
    echo "usage: $0 [--use-pkg] [--use-ports] [--use-poudriere]
        --help          : usage
        --use-ports     : use ports for install (default)
        --use-poudriere : use poudriere for post-install
        --use-pkg       : use pkg for install
    "
}

handle_args() {
    for arg in "$@"
    do
        case $arg in
            --use-pkg)
                INSTALL_FROM=pkg
                shift
                ;;
            --use-ports)
                INSTALL_FROM=ports
                shift
                ;;
            --use-poudriere)
                INSTALL_FROM=poudriere
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

install_from_pkg() {
    pkg update

    for PKG in ${PKGS}; do
        pkg install -y ${PKG}
    done

    # php80-pgsql installs pgsql 12, so we install pgsql 14 last
    # pkg install -y databases/postgresql14-server && \

    pkg clean
}

main() {
    local CMD_STATUS=
    echo "Twinwork NOTES feapp-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    continue_prompt "This will install Nginx, PostgreSQL, and PHP..."

    if [ ${INSTALL_FROM} == "ports" ]; then
        install_from_ports
        CMD_STATUS=$?
    elif [ ${INSTALL_FROM} == "poudriere" ]; then 
        install_from_poudriere && install_from_pkg
        CMD_STATUS=$?
    else
        install_from_pkg
        CMD_STATUS=$?
    fi

    # if [ -z ${CMD_STATUS} ]; then
    #     echo "Install failed"
    # fi
}

handle_args $@
main