#!/usr/bin/env bash

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

    # plex, sabnzbd
    (cd /usr/ports/multimedia/plexmediaserver/ && make -DBATCH install clean) && \
    (cd /usr/ports/news/sabnzbdplus/ && make -DBATCH install clean) && \    

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    # pkg version
    pkg update && \
    pkg install --yes multimedia/plexmediaserver && \
    pkg install --yes news/sabnzbdplus && \

    pkg clean
}

main() {
    echo "Twinwork NOTES media-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    continue_prompt "This will install Plex Media Server and SABnzbd..."

    if [ ${INSTALL_FROM} == "pkg" ]; then
        install_from_pkg
    else
        install_from_ports
    fi
}

handle_args $@
main