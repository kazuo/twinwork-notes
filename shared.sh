#!/usr/bin/env sh

POUDRIERE_JAIL_NAME=130amd64
POUDRIERE_JAIL_VERSION=13.0-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

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

install_from_poudriere() {
    if [ -z ${PKGS+x} ] || [ "${PKGS}" == "" ]; then
        echo "PKGS not set"
        exit 1
    fi

    touch ${POUDRIERE_PKG_FILE}
    for PORT in ${PKGS}; do
        echo ${PORT} >> ${POUDRIERE_PKG_FILE}
    done
    # poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default -f ${POUDRIERE_PKG_FILE}
    poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default ${PKGS}
}

install_from_ports() {
    local CMD_STATUS=
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
    if command -v poudriere &> /dev/null && test -f /usr/local/etc/pkg/repos/Poudriere.conf; then
        echo "poudriere already setup!"
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
    mkdir -p /usr/local/etc/pkg/repos && \

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
EOF && \

    cat > /usr/local/etc/poudriere.d/make.conf <<EOF
# https://cgit.freebsd.org/ports/tree/Mk/bsd.default-versions.mk
#DEFAULT_VERSIONS+=python=3.10 python3=3.10 pgsql=14 php=8.1 samba=4.13

# MariaDB 10.5
#DEFAULT_VERSIONS+=mysql=10.5m

NO_PROFILE          = yes
WITHOUT_DEBUG       = yes
OPTIONS_UNSET       = ALSA CUPS DEBUG DOCBOOK DOCS EXAMPLES FONTCONFIG HTMLDOCS PROFILE TESTS X11
EOF

    exit $?
}

setup_poudriere_ports() {    
    poudriere ports -c && \

    # default DISTFILES_CACHE set in poudriere.conf
    mkdir -p /usr/ports/distfiles
    exit $?
}