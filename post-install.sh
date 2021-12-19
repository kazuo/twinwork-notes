#!/usr/bin/env sh
# Use for FreeBSD 13.x only.  Tested with FreeBSD 13.0-RELEASE
#

INSTALL_FROM=ports
DIR=$(dirname "$0")
KERNEL_NAME=

usage() {
    echo "usage: $0 [--use-pkg]
    --help                      : usage
    --use-ports                 : use ports for post-install (default)
    --use-pkg                   : use pkg for post-install
                                    (ports tree will still be updated)
    --kernel-name=<custom_name> : custom kernel name
                                    (this will install/update FreeBSD source tree)
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
            --kernel-name=*)
                KERNEL_NAME="${arg#*=}"
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
    make -C /usr/ports/ports-mgmt/portupgrade/ -DBATCH install clean && \
    make -C /usr/ports/security/ca_root_nss/ -DBATCH install clean && \
    make -C /usr/ports/devel/nasm/ -DBATCH install clean && \
    make -C /usr/ports/sysutils/screen/ -DBATCH install clean && \
    make -C /usr/ports/shells/bash/ -DBATCH install clean && \
    make -C /usr/ports/shells/zsh/ -DBATCH install clean && \
    make -C /usr/ports/misc/gnuls/ -DBATCH install clean && \
    make -C /usr/ports/security/sudo/ -DBATCH install clean && \
    make -C /usr/ports/editors/vim/ -DBATCH install clean && \
    make -C /usr/ports/net/svnup/ -DBATCH install clean && \
    make -C /usr/ports/devel/git/ -DBATCH install clean && \
    make -C /usr/ports/ftp/wget/ -DBATCH install clean && \

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    pkg update && \

    pkg install --yes ports-mgmt/portupgrade && \
    pkg install --yes security/ca_root_nss && \
    pkg install --yes devel/nasm && \
    pkg install --yes sysutils/screen && \
    pkg install --yes shells/bash && \
    pkg install --yes shells/zsh && \
    pkg install --yes misc/gnuls && \
    pkg install --yes security/sudo && \
    pkg install --yes editors/vim && \
    pkg install --yes net/svnup && \
    pkg install --yes devel/git && \
    pkg install --yes ftp/wget && \

    pkg clean
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

    env ASSUME_ALWAYS_YES=YES pkg bootstrap
    pkg update
    (/usr/sbin/portsnap fetch && /usr/sbin/portsnap extract)

    if [ ${INSTALL_FROM} == "pkg" ]; then
        install_from_pkg
    else
        install_from_ports
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
    echo "Once the system is back up, run `freebsd-update install` again"
}

handle_args $@
main