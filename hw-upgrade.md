# Hardware Upgrade

This document should lay out a (possible) plan when upgrading the FreeBSD server's hardware. A couple of goals:

* No loss of data
* Restore all services
* No need to do a new FreeBSD install (implied)

## Server prep
1. Backup ALL data!
2. Stop/disable services in /etc/rc.conf
3. If `pf` continues to run, set a rule so traffic can flow freely
4. Prep ZFS pools by exporting all of them (except `zroot`)
5. Backup one more time!
6. `shutdown -p now`

If swap is on a different HDD, you may need to comment it out on `/etc/fstab`

## Affected services on ZFS pools
* poudriere
* jails (bastille)
* sabnzbd
* plexmediaserver
* samba4

## Map physical HDD to GELI keys

We store the encryption keys for our hard drives in `/boot/keys` that are generally named with the FreeBSD device (e.g. `ada0`) and the HDD serial number. It's simpler to physically mark which HDDs should be use which key and ideally use the same order of channels with the new motherboard hardware

## Optionally boot up one more time for final check
With all services that rely on existing zpools, you can boot up one more and the base system should be functionally normally. Again, all pools except for `zroot` should have ran `zpool export` on all non-`zroot` pools. 

Finally `sudo shutdown -p now` for the last time.

## Migrate hardware
Move all SSD/M.2/HDD over to the new motherboard. If possible, match the SATA channel ordering from the old motherboard to the new one.