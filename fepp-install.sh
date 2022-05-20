#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

INSTALL_FROM=ports
DIR=$(dirname "$0")
. ${DIR}/shared.sh

main() {
    local CMD_STATUS=
    echo "Twinwork NOTES feapp-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"    
    echo ""
    echo "This assumes that all packages/ports dependencies are"
    echo "already built through poudriere"
    echo ""
    continue_prompt "This will install nginx, PostgreSQL, and PHP..."
    install_from_pkg ${FEPP_PKGS}
    CMD_STATUS=$?

    # if [ -z ${CMD_STATUS} ]; then
    #     echo "Install failed"
    # fi
}

main