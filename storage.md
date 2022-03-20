# Storage

Sets up additional storage (i.e. HDDs) using GELI for full-disk encryption and ZFS 
to setup pools and datasets. This assumes your FreeBSD (including boot and root) is
encrypted. (The default is easy to setup in `bsdinstall`)

```
sudo mkdir -m 750 /boot/keys
sudo gpart create -s gpt da1
sudo gpart create -s gpt da2
sudo dd if=/dev/random of=/dev/da1 bs=1m
sudo dd if=/dev/random of=/dev/da2 bs=1m
```

Create the keys for each drive. Ideally the key names should be identified with the 
drive itself so that if you need to move the drives anywhere, you know which key
belongs to what. (e.g. You can use `dmesg` and find the drive's serial number as part
of the key name)

```
sudo dd if=/dev/random of=/boot/keys/da1.key bs=128k count=1
sudo dd if=/dev/random of=/boot/keys/da2.key bs=128k count=1
```

Finally, initialize the drives with geli and the keys you just made

```
sudo geli init -b -P -K /boot/keys/da1.key da1
sudo geli init -b -P -K /boot/keys/da2.key da2
```

Update `/boot/loader.conf`
```
sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_load=YES
sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_type="da1:geli_keyfile0"
sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_name="/boot/keys/da1.key"

sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_load=YES
sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_type="da2:geli_keyfile0"
sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_name="/boot/keys/da2.key"
```

Now create your zpool. In this example, we're using /dev/da1.eli and /dev/da2.eli
as a mirror. `tank` is our pool name.

```
sudo zpool create tank mirror da1.eli da2.eli
```

Feel free to create a dataset.

```
sudo zfs create -o mountpoint=/usr/data tank/data
```

Don't forget to backup your keys!

## Migrate to GELI
I originally setup my zpool (mirror) without any at-rest encryption. I'll detatch each drive in the pool, add encryption, and re-attach it back to the pool.

```
kazuo@notes:~$ sudo zpool status tank
  pool: tank
 state: ONLINE
  scan: resilvered 144K in 00:00:00 with 0 errors on Wed Dec 29 12:03:18 2021
config:

        NAME        STATE     READ WRITE CKSUM
        tank        ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            da2     ONLINE       0     0     0
            da1     ONLINE       0     0     0

errors: No known data errors
```
Detach one drive from the pool
```
sudo zpool detach tank da1
```

Try to destroy first, but may get an error that it's invalid, if you do, you can ignore it and move on: 
`sudo gpart destroy -F da1`

The following commands will:
1. Create the partition. 
2. Erase hard drive by writing random data. 
3. Create an encryption key for this drive.
4. Initialize the drive with the encryption key
5. Update `/boot/loader.conf` with the new drive
6. Attach the drive to geli
6. Attach it back to the pool

```
sudo gpart create -s gpt da1
sudo dd if=/dev/random of=/dev/da1 bs=1m
sudo dd if=/dev/random of=/boot/keys/da1.key bs=128k count=1
sudo geli init -b -P -K /boot/keys/da1.key da1

sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_load=YES
sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_type="da1:geli_keyfile0"
sudo sysrc -f /boot/loader.conf geli_da1_keyfile0_name="/boot/keys/da1.key"

sudo geli attach -p -k /boot/keys/da1.key da1
sudo zpool attach tank da2 da1.eli
```

Once ZFS finishes resilvering the newly attached drive, repeat the process for the other drive

```
sudo zpool detach tank da2

sudo gpart create -s gpt da2
sudo dd if=/dev/random of=/dev/da2 bs=1m
sudo dd if=/dev/random of=/boot/keys/da2.key bs=128k count=1
sudo geli init -b -P -K /boot/keys/da2.key da2

sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_load=YES
sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_type="da2:geli_keyfile0"
sudo sysrc -f /boot/loader.conf geli_da2_keyfile0_name="/boot/keys/da2.key"

sudo geli attach -p -k /boot/keys/da2.key da2
sudo zpool attach tank da1.eli da2.eli
```