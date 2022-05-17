#!/usr/bin/env sh
# Use for FreeBSD 13.x only
# Tested with FreeBSD 13.0-RELEASE
#

INSTALL_FROM="pkg"
DIR=$(dirname "$0")
KERNEL_NAME=

. ${DIR}/shared.sh

usage() {
    echo "usage: $0 [--use-pkg] [--use-ports] [--use-poudriere] [--kernel-name=NAME]
    [--poudriere-jail-name=NAME] [--poudriere-jail-version=VERSION]
    --help                      : usage
    --use-ports                 : use ports for post-install
    --use-poudriere             : use poudriere for post-install
                                    (experiemental, may fail during ports install)
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

prompt_root_copy() {
    local MESSAGE=$1

    echo "________________________________________________________________________________"
    echo ${MESSAGE}
    read -p "Change root shell to bash and copy profile template files? [y/N] " yn
    case $yn in
        [Yy]*)
            finish_setup
            ;;
        *)
            ;;
    esac
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

finish_setup() {
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

    echo ""
    echo "All done!  Exit and come back in to see your changes."
    echo ""
    echo "All backup files located in /root/post-install"
    echo ""
    echo "Then run..."
    echo "freebsd-update fetch && freebsd-update install && reboot"        
    echo "Once the system is back up, run freebsd-update install again"    
}

main() {
    local CMD_STATUS=
    echo ""
    echo "Twinwork NOTES post-install for FreeBSD 13"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    echo ""
    continue_prompt "This will run a post-install script for fresh installation of FreeBSD 13..."

    env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg bootstrap
    /usr/sbin/pkg update    

    if [ ${INSTALL_FROM} == "ports" ]; then
        echo "Installing from ports"
        install_from_ports ${BASE_PKGS}
        CMD_STATUS=$?
    elif [ ${INSTALL_FROM} == "poudriere" ]; then 
        echo "Installing from poudriere"
        setup_poudriere_base && \
        setup_poudriere_ports && \
        install_from_poudriere ${BASE_PKGS} && \
        install_from_pkg
        CMD_STATUS=$?
    else
        echo "Installing from pkg"
        install_from_pkg ${BASE_PKGS}
        CMD_STATUS=$?
    fi

    if [ ! -z "${KERNEL_NAME}" ]; then
        copy_custom_kernel
        CMD_STATUS=$?
    fi

    if [ ! -z ${CMD_STATUS} ]; then
        prompt_root_copy
    fi
}

handle_args $@
main