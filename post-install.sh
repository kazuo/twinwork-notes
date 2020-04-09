#!/usr/bin/env sh
# Use for FreeBSD 12.x only.  Tested with FreeBSD 12.1-RELEASE
#

INSTALL_FROM=ports
KERNEL_NAME=

usage() {
    echo "usuage: $0 [--use-pkg]
        --help          : usage
        --use-ports     : use ports for post-install (default)
        --use-pkg       : use pkg for post-install (ports tree will still be updated)
        --kernel-name   : custom kernel name (this will install/update FreeBSD source tree)
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
            --kernel-name)
                KERNEL_NAME="${arg#*=}"
                shift
                ;;
            *)
                usage
                exit 1
                shift
        esac
    done
}

continue_prompt() {
    local MESSAGE=$1

    echo "________________________________________________________________________________

    $MESSAGE"
    read -p "Continue? [Y/n] " yn
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
    (cd /usr/ports/ports-mgmt/portupgrade && make -DBATCH install clean) && \
    (cd /usr/ports/devel/nasm && make -DBATCH install clean) && \
    (cd /usr/ports/sysutils/screen && make -DBATCH install clean) && \
    (cd /usr/ports/shells/bash && make -DBATCH install clean) && \
    (cd /usr/ports/shells/zsh && make -DBATCH install clean) && \
    (cd /usr/ports/misc/gnuls && make -DBATCH install clean) && \
    (cd /usr/ports/security/sudo && make -DBATCH install clean) && \
    (cd /usr/ports/editors/vim-console && make -DBATCH install clean) && \
    (cd /usr/ports/net/svnup && make -DBATCH install clean) && \
    (cd /usr/ports/devel/git && make -DBATCH install clean) && \
    (cd /usr/ports/ftp/wget && make -DBATCH install clean) && \

    rm -rf /usr/ports/distfiles/*
}

install_from_pkg() {
    pkg update
    pkg install --yes portupgrade
    pkg install --yes nasm
    pkg install --yes screen
    pkg install --yes bash
    pkg install --yes zsh
    pkg install --yes gnuls
    pkg install --yes sudo
    pkg install --yes vim-console
    pkg install --yes wget
    pkg install --yes svnup
    pkg install --yes git
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
    echo "Twinwork NOTES post-install for FreeBSD 12"
    echo "See https://github.com/kazuo/twinwork-notes"
    echo ""
    continue_prompt "Will run post-install script for fresh installation of FreeBSD 12..."

    (/usr/sbin/portsnap fetch && /usr/sbin/portsnap extract)

    if [[ $INSTALL_FROM == "pkg" ]]; then
        install_from_pkg
    else
        install_from_ports
    fi

    echo ""
    echo "Finished installing ports and/or packages... changing shell to bash for root"

    /usr/bin/chsh -s /usr/local/bin/bash root
    mkdir -v /root/post-install
    cp -v root.profile /root/post-install/root.profile
    cp -v /root/.profile /root/post-install/.profile.bak && rm -v /root/.profile
    cp -v /root/post-install/root.profile /root/.profile
    (cd /root && ln -sv .profile .bashrc)

    echo ""
    echo "Finished setting shell settings... now for skel"
    mkdir /etc/skel
    cp -v /usr/share/skel/* /etc/skel/
    cp -v /etc/skel/dot.profile /root/post-install/dot.profile.bak
    rm -v /etc/skel/dot.profile
    cp -v skel.dot.profile /etc/skel/dot.profile
    cp -v skel.dot.vimrc /etc/skel/dot.vimrc
    cp -v skel.dot.screenrc /etc/skel/dot.screenrc
    cp -v skel.dot.vimrc /root/.vimrc
    cp -v skel.dot.screenrc /root/.screenrc
    cp -v etc.adduser.conf /etc/adduser.conf

    if [ -z "${KERNEL_NAME}" ]; then
        copy_custom_kernel
    fi

    echo ""
    echo "All done!  Exit and come back in to see your changes."
    echo ""
    echo "All backup files located in /root/post-install"
}

handle_args $@
main