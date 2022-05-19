#!/usr/bin/env sh
DIR=$(dirname "$0")
. ${DIR}/shared.sh

# override 
POUDRIERE_JAIL_NAME=131amd64
POUDRIERE_JAIL_VERSION=13.1-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

main() {
    setup_poudriere_base && \
    add_poudriere_pkg_file ${BASE_PKGS} && \
    add_poudriere_pkg_file ${FEPP_PKGS} && \
    add_poudriere_pkg_file ${ADD_PKGS} && \
    echo "" && \
    echo "Create default ports for poudriere by running: " && \
    echo "poudriere ports -c" && \
    echo "" && \
    echo "Bulk build all packages by running: " && \
    echo "poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default -f ${POUDRIERE_PKG_FILE}"
}

main