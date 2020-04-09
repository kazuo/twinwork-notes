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
y | Y)
  echo -n "Enter the name of your KERNEL (default: MYKERNEL): " && read INPUTKERNEL
  if [ -z "${INPUTKERNEL}" ]; then
    KERNEL="MYKERNEL"
  else
    KERNEL=${INPUTKERNEL}
  fi

  echo ""

  # BEGIN ORIGINAL MAX POWER SCRIPT
  mkdir -v /root/kernels
  mkdir -v /root/kernels/i386
  mkdir -v /root/kernels/amd64
  cp -v /usr/src/sys/i386/conf/GENERIC /root/kernels/i386/${KERNEL}
  (cd /usr/src/sys/i386/conf && ln -sv /root/kernels/i386/${KERNEL} ${KERNEL}).i386
  cp -v /usr/src/sys/amd64/conf/GENERIC /root/kernels/amd64/${KERNEL}
  (cd /usr/src/sys/amd64/conf && ln -sv /root/kernels/amd64/${KERNEL} ${KERNEL}).amd64

  echo -n "Use ports to install? Choosing no will use pkg instead [Y/n]: " && read INSTALL
  case ${INSTALL} in
  y | Y)
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
    (cd /usr/ports/shells/zsh && make config-recrusve)
    (cd /usr/ports/misc/gnuls && make config-recursive)
    (cd /usr/ports/security/sudo && make config-recursive)
    (cd /usr/ports/editors/vim-console && make config-recursive)
    (cd /usr/ports/devel/subversion && make config-recursive)
    (cd /usr/ports/devel/git && make config-recursive)
    (cd /usr/ports/ftp/wget && make config-recursive)

    echo ""
    echo "Now installing from ports..."

    (cd /usr/ports/ports-mgmt/portupgrade && make install clean)
    (cd /usr/ports/devel/nasm && make install clean)
    (cd /usr/ports/sysutils/screen && make install clean)
    (cd /usr/ports/shells/bash && make install clean)
    (cd /usr/ports/shells/zsh && make install clean)
    (cd /usr/ports/misc/gnuls && make install clean)
    (cd /usr/ports/security/sudo && make install clean)
    (cd /usr/ports/editors/vim-console && make install clean)
    (cd /usr/ports/devel/subversion && make install clean)
    (cd /usr/ports/devel/git && make install clean)
    (cd /usr/ports/ftp/wget && make install clean)

    rm -rf /usr/ports/distfiles/*
    ;;
  *)
    echo ""
    echo "Now installing from pkg..."
    (pkg update)
    (pkg install --yes portupgrade)
    (pkg install --yes nasm)
    (pkg install --yes screen)
    (pkg install --yes bash)
    (pkg install --yes zsh)
    (pkg install --yes gnuls)
    (pkg install --yes sudo)
    (pkg install --yes vim-console)
    (pkg install --yes wget)
    (pkg install --yes subversion)
    (pkg install --yes git)
    ;;
  esac

  echo ""
  echo "Finished installing ports and packages... changing shell to bash for root"

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
  #(cd /etc/skel/ && ln -sv .profile .bashrc)
  cp -v etc.adduser.conf /etc/adduser.conf

  echo ""
  echo "Finished doing skel stuff... copying examples/etc/make.conf into /etc"

  cp -v /usr/src/share/examples/etc/make.conf /etc/make.conf

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
