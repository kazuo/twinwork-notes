#!/usr/bin/env sh
# Use for FreeBSD 13.x only.  Tested with FreeBSD 13.0-RELEASE
#

INSTALL_FROM=pkg
DIR=$(dirname "$0")
KERNEL_NAME=
POUDRIERE_JAIL_NAME=130amd64
POUDRIERE_JAIL_VERSION=13.0-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

PKGS=""
PKGS="${PKGS} security/ca_root_nss"
PKGS="${PKGS} devel/nasm"
PKGS="${PKGS} sysutils/screen"
PKGS="${PKGS} shells/bash"
PKGS="${PKGS} shells/zsh"
PKGS="${PKGS} misc/gnuls"
PKGS="${PKGS} security/sudo"
PKGS="${PKGS} editors/vim"
PKGS="${PKGS} net/svnup"
PKGS="${PKGS} devel/git"
PKGS="${PKGS} ftp/wget"
PKGS="${PKGS} net/rsync"

usage() {
    echo "usage: $0 [--use-pkg] [--use-ports] [--use-poudriere] [--kernel-name=NAME]
    [--poudriere-jail-name=NAME] [--poudriere-jail-version=VERSION]
    --help                      : usage
    --use-ports                 : use ports for post-install
    --use-poudriere             : use poudriere for post-install
    --use-pkg                   : use pkg for post-install (default)
                                    (ports tree will still be updated)
    --kernel-name               : custom kernel name
                                    (this will install/update FreeBSD source tree)
    --poudriere-jail-name       : sets the poudriere jail name
                                    default: ${POUDRIERE_JAIL_NAME}
    --poudriere-jail-version    : sets the poudriere jail version. default
                                    default: ${POUDRIERE_JAIL_VERSION}
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
            --use-poudriere)
                INSTALL_FROM=poudriere
                shift
                ;;
            --kernel-name=*)
                KERNEL_NAME="${arg#*=}"
                shift
                ;;
            --poudriere-jail-name=*)
                POUDRIERE_JAIL_NAME="${arg#*=}"
                shift
                ;;
            --poudriere-jail-version=*)
                POUDRIERE_JAIL_VERSION="${arg#*=}"
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

install_from_poudriere() {
    touch ${POUDRIERE_PKG_FILE}
    for PORT in ${PKGS}; do
        echo ${PORT} >> ${POUDRIERE_PKG_FILE}
    done
    poudriere bulk -j ${POUDRIERE_JAIL_NAME} -p default -f ${POUDRIERE_PKG_FILE} && \
    install_from_pkg
}

install_from_ports() {
    for PORT in ${PKGS}; do
        make -C /usr/ports/${PORT}/ -DBATCH install clean && \
    done

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    pkg update && \

    for PKG in ${PKGS}; do
        pkg install -y ${PKG} && \
    done

    pkg clean
}

setup_poudriere() {
    # defaults ports dir: /usr/local/poudriere/ports/default
    # to check for pkg update:
    # PORTSDIR=/usr/local/poudriere/ports/default pkg version -P -l "<"

    pkg install -y ports-mgmt/poudriere && \

    # need to set ZPOOL in /usr/local/etc/poudriere.conf
    sysrc -f /usr/local/etc/poudriere.conf ZPOOL=zroot && \
    poudriere jail -c -j ${POUDRIERE_JAIL_NAME} -v ${POUDRIERE_JAIL_VERSION} && \
    poudriere ports -c && \

    mkdir -p /usr/local/etc/pkg/repos && \
    # default DISTFILES_CACHE set in poudriere.conf
    mkdir -p /usr/ports/distfiles && \

#     cat > /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
# FreeBSD: {
#     enabled:	NO
# }
# EOF
    cat > /usr/local/etc/pkg/repos/Poudriere.conf <<EOF
Poudriere: {
    url: "file:///usr/local/poudriere/ports/default",
    enabled: yes,
    priority: 100,
}
EOF

}

copy_custom_kernel() {
    # assumes release, maybe in the future detect freebsd-version and choose
    svnup release -h svn.freebsd.org

    # BEGIN ORIGINAL MAX POWER SCRIPT
    mkdir -v /root/kernels
    mkdir -v /root/kernels/i386
    mkdir -v /root/kernels/amd64
    cp -v /usr/src/sys/i386/conf/GENERIC /root/kernels/i386/${KERNEL_NAME}
    (cd /usr/src/sys/i386/conf && ln -sv /root/kernels/i386/${KERNEL_NAME} ${KERNEL_NAME})
    cp -v /usr/src/sys/amd64/conf/GENERIC /root/kernels/amd64/${KERNEL_NAME}
    (cd /usr/src/sys/amd64/conf && ln -sv /root/kernels/amd64/${KERNEL_NAME} ${KERNEL_NAME})

    cp -v /usr/src/share/examples/etc/make.conf /etc/make.conf
}

main() {
    echo ""
    echo "Twinwork NOTES post-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    echo ""
    continue_prompt "This will run a post-install script for fresh installation of FreeBSD 13..."

    env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg bootstrap
    /usr/sbin/pkg update    

    if [ ${INSTALL_FROM} == "ports" ]; then
        install_from_ports
    elif [ ${INSTALL_FROM} == "poudriere" ]; then 
        setup_poudriere
        install_from_poudriere
    else
        install_from_pkg        
    fi

    echo ""
    echo "Finished installing ports and/or packages... changing shell to bash for root"

    /usr/bin/chsh -s /usr/local/bin/bash root
    mkdir -v /root/post-install
    cp -v ${DIR}/root.profile /root/post-install/root.profile
    cp -v /root/.profile /root/post-install/.profile.bak && rm -v /root/.profile
    cp -v /root/post-install/root.profile /root/.profile
    (cd /root && ln -sv .profile .bashrc)

    echo ""
    echo "Finished setting shell settings... now for skel"
    mkdir /etc/skel
    cp -v /usr/share/skel/* /etc/skel/
    cp -v /etc/skel/dot.profile /root/post-install/dot.profile.bak
    rm -v /etc/skel/dot.profile
    cp -v ${DIR}/skel.dot.profile /etc/skel/dot.profile
    cp -v ${DIR}/skel.dot.vimrc /etc/skel/dot.vimrc
    cp -v ${DIR}/skel.dot.screenrc /etc/skel/dot.screenrc
    cp -v ${DIR}/skel.dot.vimrc /root/.vimrc
    cp -v ${DIR}/skel.dot.screenrc /root/.screenrc
    cp -v ${DIR}/etc.adduser.conf /etc/adduser.conf

    if [ ! -z "${KERNEL_NAME}" ]; then
        copy_custom_kernel
    fi

    echo ""
    echo "All done!  Exit and come back in to see your changes."
    echo ""
    echo "All backup files located in /root/post-install"
    echo ""
    echo "Then run..."
    echo "freebsd-update fetch && freebsd-update install && reboot"        
    echo "Once the system is back up, run freebsd-update install again"
}

handle_args $@
main