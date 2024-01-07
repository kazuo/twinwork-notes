#!/usr/bin/env bash

DIR=$(dirname "$0")
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
    install_from_pkg ${BASE_PKGS}
    install_from_pkg ${FEPP_PKGS}
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi
handle_args $@
main