# Twinwork NOTES FreeBSD Post Installation script

This script will automate most of the post-installation install and configuration to set
up your FreeBSD environment found at ~~http://notes.twinwork.net/freebsd/~~.

The original NOTES website is no longer available. It was also extremely out of date. As a matter of fact, this script is mostly out of date as well, however from time to time I do need a FreeBSD server up and running and I still go back to my original NOTES from the early 2000s to bring it up. Since the original site is gone, the script still remains to quickly get the post-install of FreeBSD up and running. The other pages such as Apache, MySQL, PHP, and qmail are largely outdated and won't be ported over in its current form.

This is the abbreviated version of FreeBSD NOTES and assumes the following:
1. Completed the initial install for FreeBSD
2. Created a normal user

Login locally as `root` and download the following

```sh
fetch --no-verify-peer https://github.com/kazuo/Twinwork-NOTES-FreeBSD-PostInstall/archive/master.zip
unzip master.zip
cd Twinwork-NOTES-FreeBSD-PostInstall-master
sh post-install.sh
```