# Jails

## `pf`

Setup `pf` first

```
sudo sysrc pf_enable=YES
sudo sysrc pf_flags=
sudo sysrc pf_rules=/etc/pf.conf
sudo sysrc pflog_enable=YES
sudo sysrc pflog_logfile=/var/log/pflog
sudo sysrc pflog_flags=
```

Add a loopback device for the jails
```
sudo sysrc cloned_interfaces=lo1
sudo sysrc ipv4_addrs_lo1="10.0.0.0 netmask 255.255.255.0"
sudo service netif cloneup
```

Add a simple free-flowing config for `/etc/pf.conf`

```
# Required order: options, normalization, queueing, translation, filtering.
if_ext = "em0" # your actual network card
if_loop = "lo0"
if_jail_loop = "lo1"

set skip on $if_loop
set skip on $if_jail_loop
set debug urgent

scrub in on $if_ext all

table <jailnet> { 10.0.0.0/24 }

# NAT rules
nat pass on $if_ext from <jailnet> to any -> ($if_ext)
nat on $if_ext from <jailnet> to any -> ($if_ext)

# Free flowing traffic
pass in quick all
pass out quick all
```

Then start `pf`
```
sudo service pf start
```

# iocage
https://iocage.io/
https://github.com/iocage/iocage

This assumes the `zpool` you want to activate `iocage` on is called `emerald`. The jail being created is called `sandbox`

If you don't already have `fdescfs` in your `/etc/fstab`, you can add it (`iocage` warns you with a message if you try to activate without it)

``
fdescfs /dev/fd  fdescfs  rw  0  0
``

You can also mount it now
```
sudo mount -t fdescfs null /dev/fd
```

```
(cd /usr/ports/sysutils/iocage && sudo make install clean)
sudo sysrc iocage_enable=YES
sudo iocage activate emerald
sudo iocage fetch -r LATEST
```

My `emerald` `zpool` is mounted to `/nyx`, so by default my `sandbox` jail will be found in `/nyx/iocage/jails/sandbox`. Create the jail

```
sudo iocage create -r LATEST -n sandbox boot=on
sudo iocage set ip4_addr="lo1|10.0.0.31/24" sandbox
sudo iocage stop sandbox
```

Ports aren't installed, so we let's mount a read-only version of it

```
sudo iocage exec sandbox mkdir /usr/ports
sudo iocage fstab -a sandbox "/usr/ports /usr/ports nullfs ro 0 0"
sudo iocage start sandbox
```

We'll also export a simple path to our jail to be used and create directories to download and build ports:
```
export D=/nyx/iocage/jails/sandbox
echo "WRKDIRPREFIX?=  /usr/portsbuild" | sudo tee $D/root/etc/make.conf
echo "DISTDIR=  /usr/portsdistfiles" | sudo tee -a $D/root/etc/make.conf
echo "nameserver 8.8.8.8" | sudo tee $D/root/etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a $D/root/etc/resolv.conf
```

If you need to update to the latest patch release
```
sudo iocage update sandbox
```

If you want to enable pinging within the jail, you'll need to enable raw sockets for the jail
```
sudo iocage set allow_raw_sockets=1 sandbox
```

Check out the `iocage` `man` page for more: https://www.freebsd.org/cgi/man.cgi?query=iocage&sektion=8

You can get into the jail's console by doing the following

```
sudo iocage console sandbox
```

If you want to execute you can use `exec` (e.g. installing `vim`)

```
sudo iocage exec sandbox "(cd /usr/ports/editors/vim && make -DBATCH install clean)"
```

# Bastille
Alternative jail manager to iocage. Pulled from https://bastillebsd.org/getting-started/

```
sudo make -C /usr/ports/sysutils/bastille/ -DBATCH install clean

sudo sysrc bastille_enable=YES
sudo sysrc -f /usr/local/etc/bastille/bastille.conf bastille_tzdata=America/Los_Angeles
sudo sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_enable=YES
sudo sysrc -f /usr/local/etc/bastille/bastille.conf bastille_zfs_zpool=zroot

sudo sysrc cloned_interfaces+=lo1
sudo sysrc ifconfig_lo1_name="bastille0"
sudo service netif cloneup
```

Enable `pf`
```
sudo sysrc pf_enable=YES
sudo sysrc pf_flags=
sudo sysrc pf_rules=/etc/pf.conf
sudo sysrc pflog_enable=YES
sudo sysrc pflog_logfile=/var/log/pflog
sudo sysrc pflog_flags=
```

Edit `/etc/pf.conf`
```
ext_if="re0"

set block-policy return
scrub in on $ext_if all fragment reassemble
set skip on lo

table <jails> persist
nat on $ext_if from <jails> to any -> ($ext_if:0)
rdr-anchor "rdr/*"

block in all
pass out quick keep state
antispoof for $ext_if inet
pass in inet proto tcp from any to any port ssh flags S/SA keep state
```

Replace `re0` with your external interface

Start `pf`

```
sudo service pf start
```

## PostgreSQL jail
Requires this jail config before doing a DB init
```
sudo bastille config postgres set sysvsem new
sudo bastille config postgres set sysvmsg new
sudo bastille config postgres set sysvshm new
sudo bastille config postgres set allow.raw_sockets
sudo bastille restart postgres
```

PostgreSQL needs a few other packages
```
sudo bastille cmd postgres pkg install sudo
sudo bastille cmd postgres portsnap fetch auto
```

Install PostgreSQL
```
host$ sudo bastille console postgres
postgres# make -C /usr/ports/editors/vim/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-client/ -DBATCH install clean && \
    make -C /usr/ports/databases/postgresql14-server/ -DBATCH install clean
```