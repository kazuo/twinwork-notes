# Replacing FreeBSD defaults with OpenBSD ported alternatives
After reading this article https://vez.mrsk.me/freebsd-defaults.html, decided to make a couple of changes in twinwork-notes... primarily disabling the default NTPd, SSHd, and using libressl instead of FreeBSD's base OpenSSL.

The latter is probably the hardest to switch over. I'm not sure how to get the base system to always use libressl, but I know I can swap over my ports to use it. In poudriere, I added `DEFAULT_VERSIONS+=ssl=libressl` to my `make.conf` (specifically my `open-make.conf` since I'm testing this out on its own poudriere set for now).

Next up is a bunch of trial and error building out ports since some options might need an explicit configuration to not use FreeBSD's base OpenSSL.

(Assumes the name of my poudriere set is named `open`)
```
poudriere options -z open databases/mariadb105-server
poudriere options -z open net/samba416
poudriere options -z open ftp/curl
```

If you see any options related to GSSAPI, simply disable it if possible. Though, there are some ports that you might use that forces you to choose one (for some reason). In that case, I ended up going with `security/heimdal` and proceeded without build issues