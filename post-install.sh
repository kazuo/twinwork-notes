#!/bin/sh
# Use for FreeBSD 9.x only.  Tested with FreeBSD 9.1-RELEASE
#
echo "* Requires root.profile, skel.dot.profile, and skel.dot.vimrc"
echo "  otherwise it will fail!"
echo ""
echo "This will install bash, gnuls, sudo, screen, and nasm.  It"
echo "also replaces /usr/share/skel/dot.profile with a modified one "
echo "that incorporates bash and gnuls.  Be sure to edit those to your "
echo "desire.  The same goes for ~/.bashrc for root.  It also copies "
echo "the correct files which cvsup requires into /etc.  Please refer to "
echo "http://notes.twinwork.net/ for more information."
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

    echo
    echo "Enter a cvsup server closest to you"
    echo -n  "(default: cvsup.FreeBSD.org): " && read INPUTCVSUP
    if [ -z "${INPUTCVSUP}" ]
    then
      CVSUP="cvsup.FreeBSD.org"
    else
      CVSUP=${INPUTCVSUP}
    fi
    
    echo ""
    
    # BEGIN ORIGINAL MAX POWER SCRIPT
    mkdir -v /root/kernels
	mkdir -v /root/kernels/i386
	mkdir -v /root/kernels/amd64
    cp -v /usr/src/sys/i386/conf/GENERIC /root/kernels/i386/${KERNEL}
    (cd /usr/src/sys/i386/conf && ln -sv /root/kernels/i386/${KERNEL} ${KERNEL})
	cp -v /usr/src/sys/amd64/conf/GENERIC /root/kernels/amd64/${KERNEL}
	(cd /usr/src/sys/amd64/conf && ln -sv /root/kernels/amd64/${KERNEL} ${KERNEL})
    

    echo ""
    echo "Updating ports tree..."
    (/usr/sbin/portsnap fetch)
    (/usr/sbin/portsnap extract)

    echo ""
    echo "Make config for ports now..."
    (cd /usr/ports/ports-mgmt/portupgrade && make config-recursive)
    (cd /usr/ports/devel/nasm && make config-recursive)
    (cd /usr/ports/sysutils/screen && make config-recursive)
    (cd /usr/ports/shells/bash && make config-recrusve)
    (cd /usr/ports/shells/scponly && make config-recursive)    
    (cd /usr/ports/misc/gnuls && make config-recursive)
    (cd /usr/ports/security/sudo && make config-recursive)
    (cd /usr/ports/editors/vim-lite && make config-recursive)
    (cd /usr/ports/net/cvsup-without-gui && make config-recursive)
    (cd /usr/ports/ftp/wget && make config-recursive)
    (cd /usr/ports/converters/libiconv && make config-recursive)
    (cd /usr/ports/x11/libX11 && make config-recursive)

    echo ""
    echo "Installing portupgrade from ports..."
    (cd /usr/ports/ports-mgmt/portupgrade && make install && make clean)
    
    echo
    echo "Now installing from ports..."
    
    (cd /usr/ports/devel/nasm && make install clean)
    (cd /usr/ports/sysutils/screen && make install clean)
    (cd /usr/ports/shells/bash && make install clean)
    (cd /usr/ports/shells/scponly && make install clean)
    (cd /usr/ports/misc/gnuls && make install clean)
    (cd /usr/ports/security/sudo && make install clean)
    (cd /usr/ports/editors/vim-lite && make install clean)
    (cd /usr/ports/net/cvsup-without-gui && make install clean)
    (cd /usr/ports/ftp/wget && make install clean)
    rm -rf /usr/ports/distfiles/*
    
    echo ""
    echo "Finished installing from ports... changing shell to bash for root"
    
    /usr/bin/chsh -s /usr/local/bin/bash root
    mkdir -v /root/post-install 
    cp -v root.profile /root/post-install/root.profile
    cp -v /root/.profile /root/post-install/.profile.bak && rm -v /root/.profile
    cp -v /root/post-install/root.profile /root/.profile
    (cd /root && ln -sv .profile .bashrc)
    
    echo ""
    echo "Finished setting shell settings... now for skel"
    cp -v /usr/share/skel/* /etc/skel/
    cp -v /etc/skel/dot.profile /root/post-install/dot.profile.bak
    rm -v /etc/skel/dot.profile
    cp -v skel.dot.profile /etc/skel/dot.profile
    cp -v skel.dot.vimrc /etc/skel/dot.vimrc
    cp -v skel.dot.screenrc /etc/skel/dot.screenrc
    cp -v skel.dot.vimrc /root/.vimrc
    cp -v skel.dot.screenrc /root/.screenrc
    #(cd /etc/skel/ && ln -sv .profile .bashrc)
    cp -v etc.adduser.conf /etc/adduser.conf
    
    echo ""
    echo "Finished doing skel stuff... copying cvsup files into /etc"
    
    cp -v /usr/src/share/examples/cvsup/*-supfile /etc/
    cp -v /usr/src/share/examples/etc/make.conf /etc/make.conf
    
    echo
    echo "All done!  Exit and come back in to see your changes.  Be sure to check out"
    echo "http://notes.twinwork.net/ for more information!"
    echo
    echo "All backup files located in /root/post-install"
    
    # END ORIGINAL MAX POWER SCRIPT
    ;;
  *)
    echo "Script aborting..."
    ;;
esac
