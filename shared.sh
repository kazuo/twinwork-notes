#!/usr/bin/env sh

POUDRIERE_JAIL_NAME=130amd64
POUDRIERE_JAIL_VERSION=13.0-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

BASE_PKGS=
BASE_PKGS="${BASE_PKGS} security/ca_root_nss"
BASE_PKGS="${BASE_PKGS} devel/nasm"
BASE_PKGS="${BASE_PKGS} sysutils/screen"
BASE_PKGS="${BASE_PKGS} shells/bash"
BASE_PKGS="${BASE_PKGS} shells/zsh"
BASE_PKGS="${BASE_PKGS} misc/gnuls"
BASE_PKGS="${BASE_PKGS} security/sudo"
BASE_PKGS="${BASE_PKGS} editors/vim"
BASE_PKGS="${BASE_PKGS} net/svnup"
BASE_PKGS="${BASE_PKGS} devel/git"
BASE_PKGS="${BASE_PKGS} ftp/wget"
BASE_PKGS="${BASE_PKGS} net/rsync"

FEPP_PKGS=""
# nginx, pgsql, php81
FEPP_PKGS="${FEPP_PKGS} www/nginx"
FEPP_PKGS="${FEPP_PKGS} databases/postgresql14-client"
FEPP_PKGS="${FEPP_PKGS} databases/postgresql14-server"
FEPP_PKGS="${FEPP_PKGS} lang/php81"

# default php81-extensions (i.e. /usr/ports/lang/php81-extensions/)
FEPP_PKGS="${FEPP_PKGS} textproc/php81-ctype"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-dom"
FEPP_PKGS="${FEPP_PKGS} security/php81-filter"
FEPP_PKGS="${FEPP_PKGS} converters/php81-iconv"
FEPP_PKGS="${FEPP_PKGS} www/php81-opcache"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-phar"
FEPP_PKGS="${FEPP_PKGS} sysutils/php81-posix"
FEPP_PKGS="${FEPP_PKGS} www/php81-session"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-simplexml"
FEPP_PKGS="${FEPP_PKGS} databases/php81-sqlite3"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo_sqlite"
FEPP_PKGS="${FEPP_PKGS} devel/php81-tokenizer"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xml"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xmlreader"
FEPP_PKGS="${FEPP_PKGS} textproc/php81-xmlwriter"

# php81 pgsql extensions
FEPP_PKGS="${FEPP_PKGS} databases/php81-pgsql"
FEPP_PKGS="${FEPP_PKGS} databases/php81-pdo_pgsql"

# other php81 extensions
FEPP_PKGS="${FEPP_PKGS} archivers/php81-bz2"
FEPP_PKGS="${FEPP_PKGS} ftp/php81-curl"
FEPP_PKGS="${FEPP_PKGS} graphics/php81-exif"
FEPP_PKGS="${FEPP_PKGS} graphics/php81-gd"
FEPP_PKGS="${FEPP_PKGS} devel/php81-intl"
FEPP_PKGS="${FEPP_PKGS} converters/php81-mbstring"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-zip"
FEPP_PKGS="${FEPP_PKGS} archivers/php81-zlib"

# other php81 extensions recommended for nextcloud
FEPP_PKGS="${FEPP_PKGS} sysutils/php81-fileinfo"
FEPP_PKGS="${FEPP_PKGS} graphics/pecl-imagick"
FEPP_PKGS="${FEPP_PKGS} ftp/php81-ftp"
FEPP_PKGS="${FEPP_PKGS} math/php81-bcmath"
FEPP_PKGS="${FEPP_PKGS} math/php81-gmp"
FEPP_PKGS="${FEPP_PKGS} devel/php81-pcntl"

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

add_poudriere_pkg_file() {
    local PKGS=$1
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi

    touch ${POUDRIERE_PKG_FILE}
    for PORT in ${PKGS}; do
        echo ${PORT} >> ${POUDRIERE_PKG_FILE}
    done    
}

install_from_poudriere() {
    local PKGS=$1
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi
    # poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default -f ${POUDRIERE_PKG_FILE}
    poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default ${PKGS}
}

install_from_ports() {
    local CMD_STATUS=
    local PKGS=$1
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi

    portsnap fetch auto
    CMD_STATUS=$?

    for PORT in ${PKGS}; do
        if [ ! -z ${CMD_STATUS} ]; then
            make -C /usr/ports/${PORT}/ -DBATCH install clean
            CMD_STATUS=$?
        fi
    done

    if [ ${CMD_STATUS} ]; then
        exit 1
    fi

    rm -rf /usr/ports/distfiles/*
}

setup_poudriere_base() {
    local CMD_STATUS=

    if command -v poudriere &> /dev/null && test -f /usr/local/etc/poudriere.d/make.conf; then
        echo "Detected poudriere has already been setup"
        exit
    fi 

    # defaults ports dir: /usr/local/poudriere/ports/default
    # to check for pkg update:
    # PORTSDIR=/usr/local/poudriere/ports/default pkg version -P -l "<"

    pkg install -y ports-mgmt/poudriere && \
    pkg install -y devel/git && \

    # need to set ZPOOL in /usr/local/etc/poudriere.conf
    sysrc -f /usr/local/etc/poudriere.conf ZPOOL=zroot && \
    poudriere jail -c -j ${POUDRIERE_JAIL_NAME} -v ${POUDRIERE_JAIL_VERSION} && \
    mkdir -p /usr/local/etc/pkg/repos

    # default DISTFILES_CACHE set in poudriere.conf
    mkdir -p /usr/ports/distfiles

    CMD_STATUS=$?

    if [ -z ${CMD_STATUS} ]; then
        exit 1
    fi

#     cat > /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
# FreeBSD: {
#     enabled:	NO
# }
# EOF
    cat > /usr/local/etc/pkg/repos/Poudriere.conf <<EOF
Poudriere: {
    url: "file:///usr/local/poudriere/data/packages/${POUDRIERE_JAIL_NAME}-default",
    enabled: yes,
    priority: 100,
}
EOF

    cat > /usr/local/etc/poudriere.d/make.conf <<EOF
# https://cgit.freebsd.org/ports/tree/Mk/bsd.default-versions.mk
#DEFAULT_VERSIONS+=python=3.10 python3=3.10 pgsql=14 php=8.1 samba=4.13

# MariaDB 10.5
#DEFAULT_VERSIONS+=mysql=10.5m

OPTIONS_UNSET=ALSA CUPS DEBUG DOCBOOK DOCS EXAMPLES FONTCONFIG HTMLDOCS PROFILE TESTS X11
EOF

}

setup_poudriere_ports() {
    if test -f /usr/local/poudriere/ports/default; then
        echo "Detected default poudriere ports already created"
        exit
    fi
    poudriere ports -c && \    
}