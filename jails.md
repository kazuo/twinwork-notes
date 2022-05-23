# Jails

## Bastille
Pulled from https://bastillebsd.org/getting-started/

```
sudo pkg install sysutils/bastille

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

## NGINX reverse proxy jail
Create the NGINX reverse proxy jail... which we'll call www-proxy
```
sudo bastille create www-proxy 13.1-RELEASE 192.168.2.21
sudo bastille config www-proxy set sysvsem new
sudo bastille config www-proxy set sysvmsg new
sudo bastille config www-proxy set sysvshm new
sudo bastille config www-proxy set allow.raw_sockets
sudo bastille restart www-proxy
```

Install NGINX along with a few other packages

## PostgreSQL jail
Create the jail with the given release and IP

```
sudo bastille pkg www-proxy install \
    editors/vim \
    security/py-certbot \
    www/nginx
```
### Update pf rules
Ensure `/etc/pf.conf` has a similar rule on the host to make sure ports 80 and 443 are able to get through

```
pass in quick on $ext_if proto tcp from any to any port {http, https} flags S/SA keep state
```

Add all http/https redirects from the host to www-proxy
```
sudo bastille rdr www-proxy tcp http http
sudo bastille rdr www-proxy tcp https https
```
### nginx config
...
### Setup SSL 

Setup SSL via certbot

...

```
sudo bastille create postgres 13.1-RELEASE 192.168.2.23
sudo bastille config postgres set sysvsem new
sudo bastille config postgres set sysvmsg new
sudo bastille config postgres set sysvshm new
sudo bastille config postgres set allow.raw_sockets
sudo bastille restart postgres
```

Install PostgreSQL with a few other packages

```
sudo bastille pkg postgres install \
    security/sudo \
    editors/vim \
    databases/postgresql14-client \
    databases/postgresql14-server
```