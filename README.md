# Twinwork NOTES FreeBSD Post Installation script

This script will automate most of the post-installation install and configuration to set
up your FreeBSD environment found at ~~http://notes.twinwork.net/freebsd/~~.

The original NOTES website is no longer available. It was also extremely out of date. As a matter of fact, this script is mostly out of date as well, however from time to time I do need a FreeBSD server up and running and I still go back to my original NOTES from the early 2000s to bring it up. Since the original site is gone, the script still remains to quickly get the post-install of FreeBSD up and running. The other pages such as Apache, MySQL, PHP, and qmail are largely outdated and won't be ported over in its current form.

This is the abbreviated version of FreeBSD NOTES and assumes the following:
1. Completed the initial install for FreeBSD
2. Network is configured

Login locally as `root` and download the following

```sh
fetch --no-verify-peer https://github.com/kazuo/twinwork-notes/archive/master.zip
unzip master.zip
cd twinwork-notes-master
sh post-install.sh
```

Once the install finished, log back out and back in as `root`. You should see the new shell changes. Before adding a user, update the template for new users:

```sh
adduser -C -k /etc/skel
```

Follow the prompts for first time use. Use your own judgment. Be sure to set the user's default shell as bash. Remember to write file.

After the initial settings have been established, add your first user... yourself.

```sh
adduser
```

Answer the prompts accordingly. What this will do is have you configure `adduser` and set `/usr/share/skel` for the template directory for all new users. Now all you need to do is run `adduser` as normal to add a new user.

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

