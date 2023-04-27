# freebsd-update

The base of the commands are from the FreeBSD Handbook, but for point and major release upgrades, there's a couple of things we need to do in our jails and package (`poudriere`) is up to date

https://docs.freebsd.org/en/books/handbook/cutting-edge/

## Regular updates

Run

```
# freebsd-update fetch
# freebsd-update install
# reboot
```

## Point release upgrades

First, run a backup!

Update pkg repo to point back to FreeBSD's

```
# freebsd-update -r 13.2-RELEASE upgrade
# freebsd-update install
# reboot
# freebsd-update install
```

Force upgrade all packages using FreeBSD's repo. Upgrading your jails' packages is optional

```
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
# bastille cmd ALL sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# bastille cmd ALL sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf

# pkg-static upgrade -f
```

Upgrade jails to new release

```
# bastille upgrade 13.1-RELEASE 13.2-RELEASE
# bastille restart ALL
```

Check one of your jails if it actually upgraded
```
# bastille cmd myjail freebsd-version
```

For me it didn't upgrade, so I just ended up bootstrapping the new release and changing the jail's `fstab` (i.e. `/usr/local/bastille/jails/myjail/fstab`) and restart the container

Only run this if you want to upgrade your jails' packages to the latest release. This will be done anyway after you rebuild all your packages through poudriere

```
# bastille cmd ALL pkg-static upgrade -f
```

Create a new jail then rebuild poudriere repo (your target sets and package list will vary)
```
# poudriere ports -u
# poudriere jail -c -j 132amd64 -v 13.2-RELEASE
# poudriere bulk -j 132amd64 -f /usr/local/etc/poudriere.d/pkglist
```

Switch back to your repo

```
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
# bastille cmd ALL sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# bastille cmd ALL sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
```

Force reinstall all packages on your system and in all your jails

```
# pkg upgrade -f
# bastille pkg ALL upgrade -f
# bastille restart ALL
```

## Major release upgrades

Most likely going to be pretty much the same as above