#!/usr/bin/env bash

DIR=$(dirname "$0")
INSTALL_FROM=ports
JAIL_NAME=
RELEASE=
IP=

handle_args() {
    core_args=()
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
                core_args+=($arg)
                shift
                ;;
        esac
    done
    JAIL_NAME=${core_args[0]}
    RELEASE=${core_args[1]}
    IP=${core_args[2]}

    if [ -z $JAIL_NAME ] || [ -z $RELEASE ] || [ -z $IP ]; then
        usage
        exit 1
    fi
}

usage() {
    echo "usage: $0 [--use-pkg] jail_name release ip
    "
}

create_jail() {
    bastille create ${JAIL_NAME} ${RELEASE} ${IP} && \
    bastille config ${JAIL_NAME} set sysvsem new && \
    bastille config ${JAIL_NAME} set sysvmsg new && \
    bastille config ${JAIL_NAME} set sysvshm new && \
    bastille config ${JAIL_NAME} set allow.raw_sockets && \
    bastille restart ${JAIL_NAME}
}

install_from_ports() {
    bastille cmd ${JAIL_NAME} /usr/sbin/portsnap fetch auto && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/security/sudo/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/editors/vim/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/www/nginx/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/postgresql14-client/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/postgresql14-server/ -DBATCH install clean && \

    bastille cmd ${JAIL_NAME} make -C /usr/ports/lang/php80/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-ctype/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-dom/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/security/php80-filter/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/converters/php80-iconv/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/www/php80-opcache/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php80-pdo/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php80-phar/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/sysutils/php80-posix/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/www/php80-session/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-simplexml/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php80-sqlite3/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php80-pdo_sqlite/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php80-tokenizer/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-xml/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-xmlreader/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php80-xmlwriter/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php80-pgsql/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php80-pdo_pgsql/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php80-bz2/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/ftp/php80-curl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/php80-exif/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/php80-gd/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php80-intl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/converters/php80-mbstring/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/security/php80-openssl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php80-zip/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php80-zlib/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/sysutils/php80-fileinfo/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/pecl-imagick/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/ftp/php80-ftp/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/math/php80-bcmath/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/math/php80-gmp/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php80-pcntl/ -DBATCH install clean    
}

main() {    
    if ! command -v bastille &> /dev/null; then
        echo "
        bastille needs to be installed and configured: 
        i.e. pkg install sysutils/bastille
        see: https://bastillebsd.org/getting-started/
        "
        exit 1
    fi

    create_jail
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi
handle_args $@
main