# Twinwork NOTES FreeBSD Post Installation script

This script will automate most of the post-installation install and configuration to set
up your FreeBSD environment found at ~~http://notes.twinwork.net/freebsd/~~.

The original NOTES website is no longer available. It was also extremely out of date. As a matter of fact, this script is mostly out of date as well, however from time to time I do need a FreeBSD server up and running and I still go back to my original NOTES from the early 2000s to bring it up. Since the original site is gone, the script still remains to quickly get the post-install of FreeBSD up and running. The other pages such as Apache, MySQL, PHP, and qmail are largely outdated and won't be ported over in its current form.

This is the abbreviated version of FreeBSD NOTES and assumes the following:
1. Completed the initial install for FreeBSD
3. Network is configured

Login locally as `root` and download the following

```sh
fetch --no-verify-peer https://github.com/kazuo/twinwork-notes/archive/master.zip
unzip master.zip
cd twinwork-notes-master
sh post-install.sh
```

The `post-install.sh` script has a couple of options:
```
    --help                        : usage
    --use-ports                   : use ports for post-install (default)
    --use-pkg                     : use pkg for post-install
                                    (ports tree will still be updated)
    --kernel-name=<custom_name>   : custom kernel name
                                    (this will install/update FreeBSD source tree)
```
The `--use-ports` flag is always implied unless you use `--use-pkg`. The latter is always faster but the former flag exists since this what this script originally installed through ports. The script will no longer prompt you for a kernel name if you choose to customize your kernel. Be aware if you choose to set `--kernel-name`, the FreeBSD source tree will first be updated using the `release` tag. And if you did not install the source tree during your initial setup, it will download the entire tree.

Once the install finishes, log back out and back in as `root`. You should see the new shell changes.

After the initial settings have been established, add your first user... yourself.

```sh
adduser
```

One more thing about `/etc/skel`. NOTES used to symlink `.profile` to `.bashrc.` This used to work in `/etc/skel` for 4.x-RELEASE, but any modern version of FreeBSD `adduser` does not copy over these symlinks. You will need to generate them yourself. I do not know what the work around is... and honestly, I don't care as much since I am the only user who logs into my machines. When you log in as your new user, create a symlink `.profile` to `.bashrc` :)

If you didn't already add yourself to the `wheel` group through the `adduser` prompts, you can do so manually by editing `/etc/group`.

```sh
vim /etc/group
```

Now add yourself to `wheel`.
```
wheel:*:0:root,rey
```

*`rey`* is my added self to `wheel`. This is important. By adding yourself to `wheel`, you do not need to login as `root` anymore. Just `su` to get `root` access and administer from there. Actually, `su` is outdated, use `sudo` instead, but first add yourself to the `sudoers` file

```
visudo
```

Go through the file until you see the following line to uncomment
```
## Same thing without a password
%wheel ALL=(ALL) NOPASSWD: ALL
```
Uncommenting that line allows you to use `sudo` without ever prompting for a password. This is convenient but proceed with caution
