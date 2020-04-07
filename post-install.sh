#!/bin/sh
# Use for FreeBSD 12.x only.  Tested with FreeBSD 12.1-RELEASE
#
echo "* Requires root.profile, skel.dot.profile, and skel.dot.vimrc"
echo "  otherwise it will fail!"
echo ""
echo "This will install bash, gnuls, sudo, screen, and nasm.  It "
echo "also replaces /usr/share/skel/dot.profile with a modified one "
echo "that incorporates bash and gnuls.  Be sure to edit those to your "
echo "desire.  The same goes for ~/.bashrc for root.  It also copies "
echo "the correct files which cvsup requires into /etc."
echo ""
echo -n "Press 'Y' to continue... " && read CONTINUE
case ${CONTINUE} in
  y|Y)
    echo -n "Enter the name of your KERNEL (default: MYKERNEL): " && read INPUTKERNEL
    if [ -z "${INPUTKERNEL}" ]
    then
      KERNEL="MYKERNEL"
    else
      KERNEL=${INPUTKERNEL}
    fi

    echo ""

    # BEGIN ORIGINAL MAX POWER SCRIPT
    /bin/mkdir -v /root/kernels
    /bin/mkdir -v /root/kernels/i386
    /bin/mkdir -v /root/kernels/amd64
    /bin/cp -v /usr/src/sys/i386/conf/GENERIC /root/kernels/i386/${KERNEL}
    (/usr/bin/cd /usr/src/sys/i386/conf && /bin/ln -sv /root/kernels/i386/${KERNEL} ${KERNEL})
    /bin/cp -v /usr/src/sys/amd64/conf/GENERIC /root/kernels/amd64/${KERNEL}
    (/usr/bin/cd /usr/src/sys/amd64/conf && /bin/ln -sv /root/kernels/amd64/${KERNEL} ${KERNEL})


    echo ""
    echo "Updating ports tree..."
    (/usr/sbin/portsnap fetch)
    (/usr/sbin/portsnap extract)

    # echo ""
    # echo "Make config for ports now..."
    # (/usr/bin/cd /usr/ports/ports-mgmt/portupgrade && make config-recursive)
    # (/usr/bin/cd /usr/ports/devel/nasm && make config-recursive)
    # (/usr/bin/cd /usr/ports/sysutils/screen && make config-recursive)
    # (/usr/bin/cd /usr/ports/shells/bash && make config-recrusve)
    # (/usr/bin/cd /usr/ports/shells/zsh && make config-recrusve)
    # (/usr/bin/cd /usr/ports/misc/gnuls && make config-recursive)
    # (/usr/bin/cd /usr/ports/security/sudo && make config-recursive)
    # (/usr/bin/cd /usr/ports/editors/vim-console && make config-recursive)
    # (/usr/bin/cd /usr/ports/devel/subversion && make config-recursive)
    # (/usr/bin/cd /usr/ports/devel/git && make config-recursive)
    # (/usr/bin/cd /usr/ports/ftp/wget && make config-recursive)

    # echo ""
    # echo "Now installing from ports..."

    # (/usr/bin/cd /usr/ports/ports-mgmt/portupgrade && make install clean)
    # (/usr/bin/cd /usr/ports/devel/nasm && make install clean)
    # (/usr/bin/cd /usr/ports/sysutils/screen && make install clean)
    # (/usr/bin/cd /usr/ports/shells/bash && make install clean)
    # (/usr/bin/cd /usr/ports/shells/zsh && make install clean)
    # (/usr/bin/cd /usr/ports/misc/gnuls && make install clean)
    # (/usr/bin/cd /usr/ports/security/sudo && make install clean)
    # (/usr/bin/cd /usr/ports/editors/vim-console && make install clean)
    # (/usr/bin/cd /usr/ports/devel/subversion && make install clean)
    # (/usr/bin/cd /usr/ports/devel/git && make install clean)
    # (/usr/bin/cd /usr/ports/ftp/wget && make install clean)

    # /bin/rm -rf /usr/ports/distfiles/*

    echo ""
    echo "Now installing from pkg..."
    (/usr/sbin/pkg install portupgrade)
    (/usr/sbin/pkg install nasm)
    (/usr/sbin/pkg install screen)
    (/usr/sbin/pkg install bash)
    (/usr/sbin/pkg install zsh)
    (/usr/sbin/pkg install gnuls)
    (/usr/sbin/pkg install sudo)
    (/usr/sbin/pkg install vim-console)
    (/usr/sbin/pkg install wget)
    (/usr/sbin/pkg install subversion)
    (/usr/sbin/pkg install git)

    echo ""
    echo "Finished installing ports and packages... changing shell to bash for root"

    /usr/bin/chsh -s /usr/local/bin/bash root
    /bin/mkdir -v /root/post-install
    /bin/cp -v root.profile /root/post-install/root.profile
    /bin/cp -v /root/.profile /root/post-install/.profile.bak && /bin/rm -v /root/.profile
    /bin/cp -v /root/post-install/root.profile /root/.profile
    (/usr/bin/cd /root && /bin/ln -sv .profile .bashrc)

    echo ""
    echo "Finished setting shell settings... now for skel"
    /bin/mkdir /etc/skel
    /bin/cp -v /usr/share/skel/* /etc/skel/
    /bin/cp -v /etc/skel/dot.profile /root/post-install/dot.profile.bak
    /bin/rm -v /etc/skel/dot.profile
    /bin/cp -v skel.dot.profile /etc/skel/dot.profile
    /bin/cp -v skel.dot.vimrc /etc/skel/dot.vimrc
    /bin/cp -v skel.dot.screenrc /etc/skel/dot.screenrc
    /bin/cp -v skel.dot.vimrc /root/.vimrc
    /bin/cp -v skel.dot.screenrc /root/.screenrc
    #(/usr/bin/cd /etc/skel/ && /bin/ln -sv .profile .bashrc)
    /bin/cp -v etc.adduser.conf /etc/adduser.conf

    echo ""
    echo "Finished doing skel stuff... copying examples/etc/make.conf into /etc"

    /bin/cp -v /usr/src/share/examples/etc/make.conf /etc/make.conf

    echo ""
    echo "All done!  Exit and come back in to see your changes."
    echo ""
    echo "All backup files located in /root/post-install"

    # END ORIGINAL MAX POWER SCRIPT
    ;;
  *)
    echo "Script aborting..."
    ;;
esac