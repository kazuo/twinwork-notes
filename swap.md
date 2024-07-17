# FreeBSD swap
By default, the FreeBSD's default swap is at 2GB. If you're doing the default installation, you may not realize it and may want to do a larger swap. By default, swap is setup as a partition, but it's possible to setup a swap file and have FreeBSD use that instead of a partition. In my case, I want to increase the swap partition since even if I were to migrate to a swap file, that swap partition will still be eating 2GB of space that I won't be able to get back. I figure I'll go through the exercise of resizing it.

This also assumes you setup ZFS when installing FreeBSD and in the case the name of the zpool is `zroot` (default)

Let's assume you have an external storage drive to backup `zroot` to a zpool called `zmigrate` and set its root mountpoint to `/zmigrate`

```
sudo zpool create zmigrate da1
sudo zpool export zmigrate
sudo zpool import -R /zmigrate zmigrate
```

Create a snapshot of `zroot`
```
zfs snapshot -r zroot@backup
```

Now send your snapshots to the `zmigrate` pool and don't automatically mount the dataset

```
sudo zfs send -R zroot@backup | sudo zfs receive -F -u zmigrate
```

If you need to reboot the system, make sure you export `zmigrate` so it won't get mounted on startup

```
sudo zpool export zmigrate
```

Run `gpart show` and you should see something like this if you used the default partition during FreeBSD install

```
=>       40  209715120  da0  GPT  (100G)
         40     532480    1  efi  (260M)
     532520       1024    2  freebsd-boot  (512K)
     533544        984       - free -  (492K)
     534528    4194304    3  freebsd-swap  (2.0G)
    4728832  204984320    4  freebsd-zfs  (98G)
  209713152       2008       - free -  (1.0M)
```

We can only delete and add our new partitions when we're not actually on the installed system, so bust out your FreeBSD USB stick (or CD/DVD), boot it up and start it in single-user mode (maybe multi-user mode so things are mounted and writable?)

We dont' want to destroy our partition, but just delete it
```
gpart delete -i 4 da0
gpart delete -i 3 da0
```

Recreate your swap and freebsd-zfs.

```
gpart add -s 4G -t freebsd-swap da0
gpart add -t freebsd-zfs -a 4k da0
geli init -b da0p4
geli attach da0p4
zpool create zroot da0p4.eli
zpool import zmigrate
zfs send -R zmigrate@backup | zfs receive -F -u zroot
zpool export zmigrate
```

See https://forums.freebsd.org/threads/zfs-backup-and-restore-of-zroot-my-way.80036/

```
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 da0
zpool import -o altroot=/mnt -f zroot
zpool set bootfs=zroot/ROOT/default zroot
```

We probably need to update freebsd-boot? Since it's geli, maybe it doesn't know to attach it on boot?