#!/usr/bin/env sh
DIR=$(dirname "$0")
. ${DIR}/shared.sh

USE_LOKI=0

# override 
POUDRIERE_JAIL_NAME=131amd64
POUDRIERE_JAIL_VERSION=13.1-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

usage() {
    echo "usage: $0 [--use-zsh]
    --help          : usage
    --use-loki      : uses Twinwork's LOKI pourdriere repo
    "
}

handle_args() {
    for arg in "$@"
    do
        case $arg in
            --use-loki)
                USE_LOKI=1
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

use_loki() {
    LOKI_DOMAIN=loki.twinwork.net
    LOKI_IP=$(host ${LOKI_DOMAIN} | awk '{ print $4 }')
    CURRENT_IP=$(host myip.opendns.com resolver1.opendns.com | tail -1 | awk '{ print $4 }')
    echo $LOKI_IP
    echo $CURRENT_IP
    
    if [ "${LOKI_IP}" == "$CURRENT_IP" ]; then
        # get around weird nginx reverse proxy 
        # issues while on the same network
        echo "Detected Loki on local network, adding ${LOKI_DOMAIN} to /etc/hosts"
        echo "192.168.1.201 loki.twinwork.net" >> /etc/hosts
    fi

    mkdir -vp /usr/local/etc/ssl/certs
    cp -v ${DIR}/loki-poudriere.cert /usr/local/etc/ssl/certs/
    sed -i -e '/enabled: / s/yes/no/' /usr/local/etc/pkg/repos/Poudriere.conf

    cat > /usr/local/etc/pkg/repos/Loki.conf <<EOF
Loki: {
    url: "pkg+https://${LOKI_DOMAIN}/poudriere/packages/${POUDRIERE_JAIL_NAME}-default",
    mirror_type: "srv",
    signature_type: "pubkey",
    pubkey: "/usr/local/etc/ssl/certs/loki-poudriere.cert",
    enabled: yes,
    priority: 1000,
}    
EOF

    echo "Added Loki repo in /usr/local/etc/pkg/repos/Loki.conf"
}

main() {
    setup_poudriere_base && \
    add_poudriere_pkg_file ${BASE_PKGS} && \
    add_poudriere_pkg_file ${FEPP_PKGS} && \
    add_poudriere_pkg_file ${ADD_PKGS}

    if test $USE_LOKI; then
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