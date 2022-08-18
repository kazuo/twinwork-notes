#!/usr/bin/env bash
DIR=$(dirname "$0")
. ${DIR}/shared.sh

USE_LOKI=no

# override 
POUDRIERE_JAIL_NAME=${POUDRIERE_JAIL_NAME:=131amd64}
POUDRIERE_JAIL_VERSION=${POUDRIERE_JAIL_VERSION:=13.1-RELEASE}
POUDRIERE_PKG_FILE=${POUDRIERE_PKG_FILE:="/usr/local/etc/poudriere.d/pkglist"}

usage() {
    echo "usage: $0 [--use-loki]
    --help          : usage
    --use-loki      : uses Twinwork's LOKI poudriere repo
    "
}

handle_args() {
    for arg in "$@"
    do
        case $arg in
            --use-loki)
                USE_LOKI=yes
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

main() {
    setup_poudriere_base && \
    add_poudriere_pkg_file ${BASE_PKGS} && \
    add_poudriere_pkg_file ${FEPP_PKGS} && \
    add_poudriere_pkg_file ${ADD_PKGS}

    if test "${USE_LOKI}" == "yes"; then
        use_loki
    fi

    echo "" && \
    echo "Create default ports for poudriere by running: " && \
    echo "poudriere ports -c" && \
    echo "" && \
    echo "Bulk build all packages by running: " && \
    echo "poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default -f ${POUDRIERE_PKG_FILE}"
}

handle_args $@
main