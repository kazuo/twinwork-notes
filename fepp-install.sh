#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

INSTALL_FROM=ports
DIR=$(dirname "$0")
. ${DIR}/shared.sh


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