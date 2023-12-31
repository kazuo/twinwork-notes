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

## Point release and major upgrades

First, run a backup!

Update pkg repo to point back to FreeBSD's

```
# freebsd-update -r 14.0-RELEASE upgrade
# freebsd-update install
# reboot
# freebsd-update install
```

Force upgrade all packages using FreeBSD's repo. We don't ned to touch or jails' packages since they can live on the older version until we're ready to upgrade them

```
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf

# pkg-static install -f pkg
# pkg update
# pkg upgrade -f
# freebsd-update install
```

Create a new poudriere jail
```
# poudriere jail -c -j 140amd64 -v 14.0-RELEASE
```

Build your packages through poudriere. Update your repos config to point to the new URL.

Create a new jail then rebuild poudriere repo (your target sets and package list will vary)
```
# poudriere ports -u
# poudriere jail -c -j 140amd64 -v 14.0-RELEASE
# poudriere bulk -j 140amd64 -f /usr/local/etc/poudriere.d/pkglist
```

Switch back to your repo

```
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
```

Upgrade jails to new release (see https://bastille.readthedocs.io/en/latest/chapters/upgrading.html#revert-upgrade-downgrade-process for major version)

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

Force reinstall all packages on your system and in all your jails

```
# pkg upgrade -f
# bastille pkg ALL upgrade -f
# bastille restart ALL
```

## Major release upgrades

Most likely going to be pretty much the same as above