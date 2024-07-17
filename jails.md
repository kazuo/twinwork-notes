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
sudo bastille create www-proxy 14.0-RELEASE 192.168.2.21
sudo bastille config www-proxy set sysvsem new
sudo bastille config www-proxy set sysvmsg new
sudo bastille config www-proxy set sysvshm new
sudo bastille config www-proxy set allow.raw_sockets
sudo bastille restart www-proxy
```

Install NGINX along with a few other packages

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
### Setup SSL 

Create a `dhparams.pem` file (this should be created for any other nginx jail that will use `ssl_common.conf`)
```
sudo bastille cmd www-proxy openssl dhparam -out /usr/local/etc/nginx/dhparams.pem 4096
```

Setup SSL via certbot without nginx. Since we haven't started the nginx service yet, we can create our SSL cert via certbot using cerbot's HTTPS server. I find it easier to setup our initial certs using certbot's HTTP server instead of nginx that way I don't need to worry about dealing with nginx's initial conf (though, in theory it should just work out of the box, I just want to rule it out for this setup: https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/)

```
sudo bastille cmd www-proxy certbot certonly --standalone -d sampledomain.com -d *.sampledomain.com
```

Take note where your cert/keys are stored (within `/usr/local/etc/letsencrypt/live`)

We do need to also update this cert once in awhile. Here's a sample where the host cron (root) will renew the cert once every 2 months via nginx (since by this point, nginx will be serving all HTTP requests)

```
5   4   2   */2 *   /usr/local/bin/bastille cmd www-proxy certbot --nginx renew
```

### nginx config
Copy over `www-proxy`'s nginx configs found in NOTES nginx folder. To make the commands clearer below, $NOTES will be prepended assuming that's where you have twinwork-notes cloned

```
# assumes this is where twinwork-notes resides
NOTES=/root/twinwork-notes-master

sudo bastille cp www-proxy $NOTES/nginx/www-proxy.conf /usr/local/etc/nginx/nginx.conf
sudo bastille cp www-proxy $NOTES/nginx/ssl_common.conf /usr/local/etc/nginx/
sudo bastille cp www-proxy $NOTES/nginx/proxy.conf /usr/local/etc/nginx/
```

You should edit those files to make sure they fit the configuration you want:
/usr/local/etc/nginx/nginx.conf
/usr/local/etc/nginx/ssl_common.conf
/usr/local/etc/nginx/proxy.conf

via bastille command example
```
sudo bastille cmd www-proxy vim /usr/local/etc/nginx/nginx.conf
```

Most likely your `/usr/local/etc/nginx/proxy.conf` wont' be ready to be used until you setup other nginx jails.

Once you confirm your configuration, add nginx to `www-proxy`'s `/etc/rc.conf` and start the service
```
sudo bastille sysrc www-proxy nginx_enable=YES
sudo bastille service www-proxy nginx start
```

## Poudriere jail
Create the jail with the given release and IP

```
sudo bastille create www-poudriere 13.1-RELEASE 192.168.2.23
sudo bastille config www-poudriere set sysvsem new
sudo bastille config www-poudriere set sysvmsg new
sudo bastille config www-poudriere set sysvshm new
sudo bastille config www-poudriere set allow.raw_sockets
sudo bastille restart www-poudriere
```

Install NGINX along with a few other packages

```
sudo bastille pkg www-poudriere install \
    editors/vim \
    www/nginx
```

This assumes that Poudriere was setup with ZFS support and using the default `zroot` `zpool`. Unfortuantely, those no other way, but we need to individually mount every zfs dataset related to Poudriere.

```
sudo bastille cmd www-poudriere mkdir /poudriere-html
sudo bastille mount www-poudriere /usr/local/poudriere poudriere
sudo bastille mount www-poudriere /usr/local/poudriere/data poudriere/data
sudo bastille mount www-poudriere /usr/local/poudriere/data/.m poudriere/data/.m
sudo bastille mount www-poudriere /usr/local/poudriere/data/cache poudriere/data/cache
sudo bastille mount www-poudriere /usr/local/poudriere/data/images poudriere/data/images
sudo bastille mount www-poudriere /usr/local/poudriere/data/logs poudriere/data/logs
sudo bastille mount www-poudriere /usr/local/poudriere/data/packages poudriere/data/packages
sudo bastille mount www-poudriere /usr/local/poudriere/data/wrkdirs poudriere/data/wrkdirs
sudo bastille mount www-poudriere /usr/local/share/poudriere/html poudriere-html/poudriere
```

### Setup SSL 

Create a `dhparams.pem` file (this should be created for any other nginx jail that will use `ssl_common.conf`)
```
sudo bastille cmd www-poudriere openssl dhparam -out /usr/local/etc/nginx/dhparams.pem 4096
```

Create a self-signed cert for this jail. This really only secures the connection between the host and the jail, so it's probably overkill to do, but it's probably a good practice. See (ssl-selfsigned.md)[./ssl-selfsigned.md]. It's probably easiest if you ran those commands within the jail itself:

```
sudo bastille console www-poudriere
```

Just like the certbot's renewal for `www-proxy`, you can do something simliar for `www-poudriere`'s self signed certifcate. On the host, add the following cron which will attempt to renew once every three months

```
5   4   2   */3 *   /usr/local/bin/bastille cmd www-poudriere openssl x509 -req -days 365 -in /usr/local/etc/ssl/public/selfsigned.csr -signkey /usr/local/etc/ssl/private/selfsigned.key -out /usr/local/etc/ssl/certs/selfsigned.crt
```

### nginx config
Copy over `www-poudriere`'s nginx configs found in NOTES nginx folder. To make the commands clearer below, $NOTES will be prepended assuming that's where you have twinwork-notes cloned

```
# assumes this is where twinwork-notes resides
NOTES=/root/twinwork-notes-master

sudo bastille cp www-poudriere $NOTES/conf/nginx/www-poudriere.conf /usr/local/etc/nginx/nginx.conf
sudo bastille cp www-poudriere $NOTES/conf/nginx/ssl_common.conf /usr/local/etc/nginx/
sudo bastille cp www-poudriere $NOTES/conf/nginx/poudriere.conf /usr/local/etc/nginx/
```

You might need to tweak your config. Once you confirm your configuration, add nginx to `www-poudriere`'s `/etc/rc.conf` and start the service
```
sudo bastille sysrc www-poudriere nginx_enable=YES
sudo bastille service www-poudriere nginx start
```
### Poudriere repo config on jails
Now that you have your first two jails setup, update where they get their packages

```
sudo bastille cmd ALL tee /usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
# Ensures that Poudriere will always be used for pkg
FreeBSD: {
    enabled: no,
}
EOF

sudo bastille cmd ALL tee /usr/local/etc/pkg/repos/Poudriere.conf <<EOF
Poudriere: {
    url: "http://192.168.2.23/poudriere/packages/140amd64-default",
    signature_type: "pubkey",
    pubkey: "/usr/local/etc/ssl/certs/poudriere.cert",
    enabled: yes,
    priority: 100,
}
EOF
```

The IP for the Poudriere repo is actually the IP of the host. I couldn't get HTTPS working correctly (despite the self-signed cert), but didn't think it would be that big of a deal since it's all happening on the host system

Now you can update the packages on your jails

```
sudo bastille pkg ALL upgrade -f
sudo bastille pkg ALL autoremove
```

## PostgreSQL jail
Create the jail with the given release and IP

```
sudo bastille create postgres 14.0-RELEASE 192.168.2.30
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
    shells/bash \
    databases/postgresql6-client \
    databases/postgresql6-server
```

Create your database and start PostgreSQL

```
sudo bastille cmd postgres mkdir /pgdb
sudo bastille cmd postgres chown postgres:postgres /pgdb
sudo bastille cmd postgres pw usermod -n postgres -d /pgdb
sudo bastille cmd chsh -s /usr/local/bin/bash postgres
sudo bastille sysrc postgres postgresql_enable=YES
sudo bastille sysrc postgres postgresql_data=/pgdb/data16
sudo bastille service postgres postgresql initdb
sudo bastille service postgres postgresql start
```

To login into PostgreSQL:

```
sudo bastille cmd postgres sudo -u postgres psql
```

You can create a user and DB from a few CLI commands. This will create a local user called `plex` without a password

```
sudo bastille cmd postgres sudo -u postgres createuser -e plex
```

And create a new database called `sandbox` owned by your new user

```
sudo bastille cmd postgres sudo -u postgres createdb -e -O plex -E UTF8 sandbox
```

Then you can login as `plex` to your `sandbox` database

```
sudo bastille cmd postgres psql -U plex sandbox
```

## SABnzbd
We don't want to expose SABnzbd to the outside network, so add the following rule (or something similar) to `/etc/pf.conf`. This allows connections from the server itself (useful through SSH tunneling) or from your local network

```
pass in inet proto tcp from { 127.0.0.1, 192.168.1.0/24 } to any port 8080 flags S/SA keep state
```

Create the jail with the given release and IP
```
sudo bastille create nzb 14.1-RELEASE 192.168.2.32
sudo bastille config nzb set sysvsem new
sudo bastille config nzb set sysvmsg new
sudo bastille config nzb set sysvshm new
sudo bastille config nzb set allow.raw_sockets
sudo bastille rdr nzb tcp 8080 8080
sudo bastille restart nzb
sudo bastille pkg nzb install news/sabnzbd
sudo bastille sysrc nzb sabnzbd_enable=YES
sudo bastille service nzb sabnzbd start
sudo bastille service nzb sabnzbd stop

```

With `sabnzbd` now stopped, mount a folder from your host to the Downloads folder in your `nzb` jail. 

```
sudo bastille mount nzb /nyx/sabnzbd usr/local/sabnzbd/Downloads nullfs rw 0 0 
sudo bastille cmd nzb chmod -R 775 /usr/local/sabnzbd/Downloads
```

In SABnzbd's Folders setting, ensure your "Permissions for completed downloads" is set to `775` (or at least `755`). This will easily allow you (as a normal user) to view the downloads folder on the host