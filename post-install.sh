#!/usr/bin/env sh
# Use for FreeBSD 13.x only
# Tested with FreeBSD 13.1-RELEASE
#

INSTALL_FROM="pkg"
DIR=$(dirname "$0")
USE_ZSH=
USE_LOKI=

. ${DIR}/shared.sh

# todo override 
POUDRIERE_JAIL_BASE_NAME=131
POUDRIERE_JAIL_ARCH=`uname -m`
POUDRIERE_JAIL_NAME="${POUDRIERE_JAIL_BASE_NAME}${POUDRIERE_JAIL_ARCH}"
POUDRIERE_JAIL_VERSION=13.1-RELEASE
POUDRIERE_PKG_FILE="/usr/local/etc/poudriere.d/packages-default"

usage() {
    echo "usage: $0 [--use-zsh] [--use-loki]
    --help          : usage
    --use-zsh       : sets zsh as default shell and installs oh-my-zsh for root
    --use-loki      : uses Twinwork's LOKI poudriere repo
    "
}

handle_args() {
    for arg in "$@"
    do
        case $arg in
            --use-zsh)
                USE_ZSH=1
                shift
                ;;
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

prompt_root_copy() {
    local MESSAGE=$1

    echo ""
    read -p "Change default root shell and copy profile template files? [y/N] " yn
    case $yn in
        [Yy]*)
            finish_setup
            ;;
        *)
            ;;
    esac
}

finish_setup() {
    echo ""
    echo "Finished installing ports and/or packages... changing shell to bash for root"

    mkdir -v /root/post-install
    cp -v ${DIR}/root.profile /root/post-install/root.profile
    cp -v /root/.profile /root/post-install/.profile.bak && rm -v /root/.profile
    cp -v /root/post-install/root.profile /root/.profile

    if [ ${USE_ZSH} ]; then
        /usr/bin/chsh -s /usr/local/bin/zsh root
        sh ${DIR}/oh-my-zsh.sh
    else
        /usr/bin/chsh -s /usr/local/bin/bash root
        (cd /root && ln -sv .profile .bashrc)
    fi            

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

    if [ ${USE_LOKI} ]; then
        use_loki
    fi

    env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg bootstrap
    /usr/sbin/pkg update
    install_from_pkg ${BASE_PKGS}
    CMD_STATUS=$?

    if [ ! -z ${CMD_STATUS} ]; then
        prompt_root_copy
    fi
}

handle_args $@
main