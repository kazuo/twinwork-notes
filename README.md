# Twinwork NOTES FreeBSD Post Installation script

This script will automate most of the post-installation install and configuration to set up your FreeBSD environment found at ~~http://notes.twinwork.net/freebsd/~~.

The original NOTES website is no longer available as it was completely out of date. This script was designed to setup a few customizations from a fresh FreeBSD install. It assumes the following:
1. Completed the initial install for FreeBSD
2. ZFS is enabled and uses `zroot` where FreeBSD is installed
3. Network is configured

Login locally as `root` and download the following

```sh
fetch https://github.com/kazuo/twinwork-notes/archive/main.zip
unzip main.zip
sh ./twinwork-notes-main/scripts/post-install.sh
```

The `post-install.sh` script has a couple of options:
```
    --help          : usage
    --use-zsh       : sets zsh as default shell and installs oh-my-zsh for root
    --use-loki      : uses Twinwork's LOKI poudriere repo
    --use-open      : installs and uses OpenBSD ports of libressl, SSHd, and NTPd    
```
The `post-install.sh` script will only install from packages. We'll be using `poudriere` to build ports

Once the install finishes, log back out and back in as `root`. You should see the new shell changes.

After the initial settings have been established, add your first user... yourself.

```sh
adduser
```

One more thing about `/etc/skel`. NOTES used to symlink `.profile` to `.bashrc.` This used to work in `/etc/skel` for 4.x-RELEASE, but any modern version of FreeBSD `adduser` does not copy over these symlinks. You will need to generate them yourself. I do not know what the work around is... and honestly, I don't care as much since I am the only user who logs into my machines. When you log in as your new user, create a symlink `.profile` to `.bashrc` :)

If you didn't already add yourself to the `wheel` group through the `adduser` prompts, you can do so manually by editing via `pw`

```
pw groupmod -n wheel -m rey
```

*`rey`* is my added self to `wheel`. This is important. By adding yourself to `wheel`, you do not need to login as `root` anymore. Just `su` to get `root` access and administer from there. Better yet, instead of using `su` use `sudo` instead, but first add yourself to the `sudoers` file

```
visudo
```

Go through the file until you see the following line to uncomment
```
## Same thing without a password
%wheel ALL=(ALL) NOPASSWD: ALL
```
Uncommenting that line allows you to use `sudo` without ever prompting for a password. This is convenient but proceed with caution

## Setting up `poudriere`
We previously used ports to set custom options, but since it's generally bad practice to use both `pkg` and `ports`, the better practice is to build your ports in `poudriere` and set your pkg repo to point to your custom build. Another reason I converted over to building my own packages in poudriere is my increased usage of FreeBSD jails. It was just a lot easier to point the jails to my own package repo than it was to build ports within the jail. 

We can automate the initial `poudriere` setup that `twinwork-notes` uses by running the following script

```
sh ./twinwork-notes-main/scripts/setup-poudriere.sh
```

The `setup-poudriere.sh` script has a couple of options:
```
    --help          : usage
    --use-loki      : uses Twinwork's Loki poudriere repo
```

If you specify the `--use-loki` option, you'll still copy over the main Poudriere.conf file but that repo will be disabled by default and the Loki.conf poudriere file will be enabled. This repo has all of packages built from `twinwork-notes` plus a few additional ones found in `shared.sh`. You can always check https://loki.twinwork.net/poudriere. Packages aren't updated on schedule, but closer to once every two weeks or so. They're definitely going to be more up to date than using FreeBSD's quarterly repo. Also, be aware of what Loki is actually building... here's a copy of Loki's `/usr/local/etc/poudriere.d/make.conf`:

```
# see defaults at https://github.com/freebsd/freebsd-ports/blob/main/Mk/bsd.default-versions.mk
DEFAULT_VERSIONS+=python=3.9 python3=3.9 pgsql=15 php=8.1 samba=4.16

# MariaDB 10.6
DEFAULT_VERSIONS+=mysql=10.6m

OPTIONS_UNSET=ALSA CUPS DEBUG DOCBOOK DOCS EXAMPLES FONTCONFIG HTMLDOCS PROFILE TESTS X11
```

Whether or not you're choosing Poudriere.conf or Loki.conf, running `setup-poudriere.sh` will disable FreeBSD's package repo. If you need to install anything else from this point on, follow the rest of the instructions by creating the default ports tree and building all of the prepopulated packages related to these NOTES

```
poudriere ports -c && poudriere bulk -j 140amd64 -p default -f /usr/local/etc/poudriere.d/pkglist
```

If you're building all of the packages related to NOTES, this will take awhile... nearly 8 hours on a Intel Core i3 from 2019 (blame `llvm` for taking so long). But once that's complete, you can also force upgrade all your existsing packages and remove any packages no longer needed

```
pkg upgrade -f && pkg autoremove
```

Some configurations of note are:
/usr/local/etc/pkg/repos
/usr/local/etc/poudriere.d/make.conf

### Additional configuration for hosting your own pkg repo

To continue building and serving your own package repo, create an SSL key and cert that clients can use

```
sudo mkdir -p /usr/local/etc/ssl/{keys,certs}
sudo chmod 0600 /usr/local/etc/ssl/keys
sudo openssl genrsa -out /usr/local/etc/ssl/keys/poudriere.key 4096
sudo openssl rsa -in /usr/local/etc/ssl/keys/poudriere.key -pubout -out /usr/local/etc/ssl/certs/poudriere.cert
```

Update `/usr/local/etc/poudriere.conf` and modify the following values

```
PKG_REPO_SIGNING_KEY=/usr/local/etc/ssl/keys/poudriere.key
URL_BASE=https://sampledomain.com/poudriere
```

Modify your poudriere conf to add the public key: `/usr/local/etc/pkg/repos/Poudriere.conf`

```
Poudriere: {
    url: "file:///usr/local/poudriere/data/packages/140amd64-default",
    mirror_type: "srv",
    signature_type: "pubkey",
    pubkey: "/usr/local/etc/ssl/certs/poudriere.cert",
    enabled: yes,
    priority: 100,
}
```

### Poudriere for arm64 (aarch64)
By default, the jails are for amd64, but you can also build it out for a different architecture. You can run the following below to build out an arm64 repository. I find this useful while testing FreeBSD as a VM guest on Apple Silicon

```
sudo pkg install emulators/qemu-user-static
sudo sysrc qemu_user_static_enable="YES"
sudo service qemu_user_static start
sudo poudriere jail -c -j 140arm64 -v 14.0-RELEASE -a arm64.aarch64
sudo poudriere bulk -j 140arm64 -f /usr/local/etc/poudriere.d/pkglist
```

## The FEPP install script
I'm not sure what the cool acronym is for FreeBSD, Nginx, PostgreSQL, and PHP is, but we'll go with FEPP! Run the `fepp-install.sh` script.

```
sh ./twinwork-notes-main/fepp-install.sh
```

The script does not automatically start the services for Nginx, PostgreSQL, or PHP-FPM. These services need to be configured first before starting.


### PostgreSQL
By default, PostgreSQL's data folder will be in `/var/db/postgres/data{version}` where `version` is PostgreSQL's major version (i.e. `/var/db/postgres/data15`). Also, by default the `postgres` user's home folder is `/var/db/postgres`. If you want to change where to store PostgreSQL data, you will need to change `postgres`' home folder as well.

In this example, I have folder called `/nyx` and want to place my `postgres` home folder there. We want to create the `postgres` home folder, set the the `postgres` user and group to own the home folder, change the `postgres` user to the new home folder, enable the `postgresql` service,and finally set the `postgresql_data` config in `/etc/rc.conf`

```
sudo mkdir -p /nyx/postgres
sudo chown postgres:postgres /nyx/postgres
sudo pw usermod -n postgres -d /nyx/postgres
sudo chsh -s /usr/local/bin/bash postgres
sudo sysrc postgresql_enable=YES
sudo sysrc postgresql_data=/nyx/postgres/data15
```

Now you can initialize your DB and start the server.

```
sudo service postgresql initdb
sudo service postgresql start
```

If you ever need to migrate your DB folder anywhere, don't forget to move the `postgres` user's home folder, too.

To log into postgres:
```
sudo -u postgres psql
```

You can create a user and DB from a few CLI commands. This will create a local user called `plex` without a password

```
sudo -u postgres createuser -e plex
```

And create a new database called `sandbox` owned by your new user

```
sudo -u postgres createdb -e -O plex -E UTF8 sandbox
```

Then you can login as `plex` to your `sandbox` database

```
psql -U plex sandbox
```


### PHP-FPM

Copy the sample production `php.ini` in place and enable the service
```
sudo cp /usr/local/etc/php.ini{-production,}
```

Modify `/usr/local/etc/php-fpm.d/www.conf`. We want to use a unix socket instead of TCP as well as setting other options. Find (or add) the keys in the file to modify

```
listen = /var/run/php-fpm.sock
listen.owner = www
listen.group = www
listen.mode = 0660
```

Enable and start the PHP-FPM service

```
sudo sysrc php_fpm_enable=YES
sudo service php-fpm start
```

### Nginx
Add Nginx to `/etc/rc.conf` and start the service

```
sudo sysrc nginx_enable=YES
sudo service nginx start
```

Not Nginx specific, but we should create a new folder for `www` for all our websites. Set `www`'s home folder and create an `.ssh` folder. I generally use `git` as `www` and add any SSH keys to access my repos.

```
sudo pw usermod -n www -d /nyx/www
sudo -u www mkdir ~/.ssh
```

If you want to quickly test PHP, you can use the default
Under `server` block, add the following `location` block to get PHP up and running:

```
        # from https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/
        location ~ [^/]\.php(/|$) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            if (!-f $document_root$fastcgi_script_name) {
                return 404;
            }
            root           /usr/local/www/nginx;
            fastcgi_pass   unix:/var/run/php-fpm.sock;
            fastcgi_index  index.php;
            include        fastcgi_params;
            fastcgi_param  HTTP_PROXY       "";
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        }
```

Here's another sample configuring if you're using the Yii 2 framework.

From https://www.yiiframework.com/doc/guide/2.0/en/start-installation
```
server {
    charset utf-8;
    client_max_body_size 128M;

    listen 80; ## listen for ipv4
    #listen [::]:80 default_server ipv6only=on; ## listen for ipv6

    server_name sandbox.nyx;
    root        /nyx/www/sandbox/web;
    index       index.php;

    access_log  /nyx/www/sandbox/log/access.log;
    error_log   /nyx/www/sandbox/log/error.log;

    location / {
        # Redirect everything that isn't a real file to index.php
        try_files $uri $uri/ /index.php$is_args$args;
    }

    # uncomment to avoid processing of calls to non-existing static files by Yii
    #location ~ \.(js|css|png|jpg|gif|swf|ico|pdf|mov|fla|zip|rar)$ {
    #    try_files $uri =404;
    #}
    #error_page 404 /404.html;

    # deny accessing php files for the /assets directory
    location ~ ^/assets/.*\.php$ {
        deny all;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }
        fastcgi_pass   unix:/var/run/php-fpm.sock;
        fastcgi_index  index.php;
        include        fastcgi_params;
        fastcgi_param  HTTP_PROXY       "";
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        try_files $uri =404;
    }

    location ~* /\. {
        deny all;
    }
}
```

If you're doing anything under your `www` folder, make sure you run any commands as the `www` user.

```
sudo -u www mkdir /nyx/www/sandbox
```

Any time you change your Nginx configuration, be sure to test it before restarting

```
sudo service nginx configtest
sudo service nginx restart
```
