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

```
# freebsd-update -r 14.3-RELEASE upgrade
# freebsd-update install
# reboot
# freebsd-update install
```

Update pkg repo to point back to FreeBSD's

When doing a major upgrade (i.e. 13 -> 14), force upgrade all packages using FreeBSD's repo. We don't ned to touch or jails' packages since they can live on the older version until we're ready to upgrade them

```
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf

# pkg-static install -f pkg
# pkg update
# pkg upgrade -f
```

Build your packages through poudriere. Update your repos config to point to the new URL.

Create a new jail then rebuild poudriere repo (your target sets and package list will vary)
```
# poudriere ports -u
# poudriere jail -c -j 143amd64 -v 14.3-RELEASE
# poudriere bulk -j 143amd64 -f /usr/local/etc/poudriere.d/pkglist
```

Switch back to your repo

```
# sed -e '/enabled: / s/no/yes/' -i '' /usr/local/etc/pkg/repos/Poudriere.conf
# sed -e '/enabled: / s/yes/no/' -i '' /usr/local/etc/pkg/repos/FreeBSD.conf
```

You can also force `pkg upgrade` to install all packages in your repro

```
# pkg update
# pkg upgrade -f
```

Upgrade jails to new release (see https://bastille.readthedocs.io/en/latest/chapters/upgrading.html#revert-upgrade-downgrade-process for major version)

```
# bastille upgrade 14.2-RELEASE 14.3-RELEASE
# bastille restart ALL
```

Check one of your jails if it actually upgraded
```
# bastille cmd myjail freebsd-version
```

For me it didn't upgrade, so I just ended up bootstrapping the new release and changing the jail's `fstab` (i.e. `/usr/local/bastille/jails/myjail/fstab`) and restart the container

```
# bastille bootstrap 14.3-RELEASE update
# bastille stop ALL
# bastille edit ALL fstab
```

Then update `fstab` to `14.3-RELEASE`. Then start your jails
```
# bastille start ALL
```

Update your `Poudriere.conf` in all your jails to point to the new repo

```
bastille cmd ALL vim /usr/local/etc/pkg/repos/Poudriere.conf
```

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