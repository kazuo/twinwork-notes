#!/usr/bin/env bash
# From https://kifarunix.com/install-nginx-mysql-php-femp-stack-on-freebsd-12/

DIR=$(dirname "$0")
. ${DIR}/shared.sh

main() {
    local CMD_STATUS=
    echo "Twinwork NOTES feapp-install for FreeBSD 14"
    echo "See https://github.com/kazuo/twinwork-notes"    
    echo ""
    echo "This assumes that all packages/ports dependencies are"
    echo "already built through poudriere"
    echo ""
    continue_prompt "This will install nginx, PostgreSQL, and PHP..."
    install_from_pkg ${FEPP_PKGS}
    local cmd_status=$?

    exit $cmd_status
}

main