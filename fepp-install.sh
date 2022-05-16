#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

INSTALL_FROM=ports
DIR=$(dirname "$0")
. ${DIR}/shared.sh


PKGS=""
# nginx, pgsql, php81
PKGS="${PKGS} www/nginx"
PKGS="${PKGS} databases/postgresql14-client"
PKGS="${PKGS} databases/postgresql14-server"
PKGS="${PKGS} lang/php81"

# default php81-extensions (i.e. /usr/ports/lang/php81-extensions/)
PKGS="${PKGS} textproc/php81-ctype"
PKGS="${PKGS} textproc/php81-dom"
PKGS="${PKGS} security/php81-filter"
PKGS="${PKGS} converters/php81-iconv"
PKGS="${PKGS} www/php81-opcache"
PKGS="${PKGS} databases/php81-pdo"
PKGS="${PKGS} archivers/php81-phar"
PKGS="${PKGS} sysutils/php81-posix"
PKGS="${PKGS} www/php81-session"
PKGS="${PKGS} textproc/php81-simplexml"
PKGS="${PKGS} databases/php81-sqlite3"
PKGS="${PKGS} databases/php81-pdo_sqlite"
PKGS="${PKGS} devel/php81-tokenizer"
PKGS="${PKGS} textproc/php81-xml"
PKGS="${PKGS} textproc/php81-xmlreader"
PKGS="${PKGS} textproc/php81-xmlwriter"

# php81 pgsql extensions
PKGS="${PKGS} databases/php81-pgsql"
PKGS="${PKGS} databases/php81-pdo_pgsql"

# other php81 extensions
PKGS="${PKGS} archivers/php81-bz2"
PKGS="${PKGS} ftp/php81-curl"
PKGS="${PKGS} graphics/php81-exif"
PKGS="${PKGS} graphics/php81-gd"
PKGS="${PKGS} devel/php81-intl"
PKGS="${PKGS} converters/php81-mbstring"
PKGS="${PKGS} archivers/php81-zip"
PKGS="${PKGS} archivers/php81-zlib"

# other php81 extensions recommended for nextcloud
PKGS="${PKGS} sysutils/php81-fileinfo"
PKGS="${PKGS} graphics/pecl-imagick"
PKGS="${PKGS} ftp/php81-ftp"
PKGS="${PKGS} math/php81-bcmath"
PKGS="${PKGS} math/php81-gmp"
PKGS="${PKGS} devel/php81-pcntl"

usage() {
    echo "usage: $0 [--use-pkg] [--use-ports] [--use-poudriere]
        --help          : usage
        --use-ports     : use ports for install 
        --use-poudriere : use poudriere for post-install
        --use-pkg       : use pkg for install (default)
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

    # php81-pgsql installs pgsql 12, so we install pgsql 14 last
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