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