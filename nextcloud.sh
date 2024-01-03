#!/usr/bin/env bash

DIR=$(dirname "$0")
INSTALL_FROM=ports
JAIL_NAME=
RELEASE=
IP=

handle_args() {
    core_args=$@
    JAIL_NAME=${core_args[0]}
    RELEASE=${core_args[1]}
    IP=${core_args[2]}

    if [ -z $JAIL_NAME ] || [ -z $RELEASE ] || [ -z $IP ]; then
        usage
        exit 1
    fi
}

usage() {
    echo "usage: $0 jail_name release ip
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
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/postgresql15-client/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/postgresql15-server/ -DBATCH install clean && \

    bastille cmd ${JAIL_NAME} make -C /usr/ports/lang/php83/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-ctype/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-dom/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/security/php83-filter/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/converters/php83-iconv/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/www/php83-opcache/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php83-pdo/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php83-phar/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/sysutils/php83-posix/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/www/php83-session/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-simplexml/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php83-sqlite3/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php83-pdo_sqlite/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php83-tokenizer/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-xml/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-xmlreader/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/textproc/php83-xmlwriter/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php83-pgsql/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/databases/php83-pdo_pgsql/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php83-bz2/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/ftp/php83-curl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/php83-exif/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/php83-gd/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php83-intl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/converters/php83-mbstring/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/security/php83-openssl/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php83-zip/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/archivers/php83-zlib/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/sysutils/php83-fileinfo/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/graphics/pecl-imagick/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/ftp/php83-ftp/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/math/php83-bcmath/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/math/php83-gmp/ -DBATCH install clean && \
    bastille cmd ${JAIL_NAME} make -C /usr/ports/devel/php83-pcntl/ -DBATCH install clean    
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