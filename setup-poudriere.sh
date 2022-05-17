#!/usr/bin/env sh
DIR=$(dirname "$0")
. ${DIR}/shared.sh

# override 
POUDRIERE_JAIL_NAME=130amd64
POUDRIERE_JAIL_VERSION=13.0-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

main() {
    setup_poudriere_base && \
    add_poudriere_pkg_file ${BASE_PKGS} && \
    add_poudriere_pkg_file ${FEPP_PKGS} && \
    add_poudriere_pkg_file "news/sabnzbdplus multimedia/plexmediaserver net/samba413" && \
    echo "" && \
    echo "Create default ports for poudriere by running: " && \
    echo "poudriere ports -c" && \
    echo "" && \
    echo "Bulk build all packages by running: " && \
    echo "poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default ${PKGS}"
}

main