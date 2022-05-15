# Twinwork NOTES FreeBSD Post Installation script

This script will automate most of the post-installation install and configuration to set
up your FreeBSD environment found at ~~http://notes.twinwork.net/freebsd/~~.

The original NOTES website is no longer available. It was also extremely out of date. As a matter of fact, this script is mostly out of date as well, however from time to time I do need a FreeBSD server up and running and I still go back to my original NOTES from the early 2000s to bring it up. Since the original site is gone, the script still remains to quickly get the post-install of FreeBSD up and running. The other pages such as Apache, MySQL, PHP, and qmail are largely outdated and won't be ported over in its current form.

This is the abbreviated version of FreeBSD NOTES and assumes the following:
1. Completed the initial install for FreeBSD
3. Network is configured

Login locally as `root` and download the following

```sh
fetch https://github.com/kazuo/twinwork-notes/archive/master.zip
unzip master.zip
sh ./twinwork-notes-master/post-install.sh
```

The `post-install.sh` script has a couple of options:
```
    --help                        : usage
    --use-ports                   : use ports for post-install (default)
    --use-pkg                     : use pkg for post-install
                                    (ports tree will still be updated)
    --kernel-name=<custom_name>   : custom kernel name
                                    (this will install/update FreeBSD source tree)
```
The `--use-ports` flag is always implied unless you use `--use-pkg`. The latter is always faster but the former flag exists since this what this script originally installed through ports. The script will no longer prompt you for a kernel name if you choose to customize your kernel. Be aware if you choose to set `--kernel-name`, the FreeBSD source tree will first be updated using the `release` tag. And if you did not install the source tree during your initial setup, it will download the entire tree.

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

## The FEPP install script
I'm not sure what the cool acronym is for FreeBSD, Nginx, PostgreSQL, and PHP is, but we'll go with FEPP! Run the `fepp-install.sh` script. This script also has a `--use-ports` and `--use-pkg` flag just like `post-install.sh`. And by default it uses `--use-ports`.

```
sudo sh ./fepp-install.sh
```

The script does not automatically start the services for Nginx, PostgreSQL, or PHP-FPM. These services need to be configured first before starting.


### PostgreSQL
By default, PostgreSQL's data folder will be in `/var/db/postgres/data{version}` where `version` is PostgreSQL's major version (i.e. `/var/db/postgres/data14`). Also, by default the `postgres` user's home folder is `/var/db/postgres`. If you want to change where to store PostgreSQL data, you will need to change `postgres`' home folder as well.

In this example, I have folder called `/nyx` and want to place my `postgres` home folder there. We want to create the `postgres` home folder, set the the `postgres` user and group to own the home folder, change the `postgres` user to the new home folder, enable the `postgresql` service,and finally set the `postgresql_data` config in `/etc/rc.conf`

```
sudo mkdir -p /nyx/postgres
sudo chown postgres:postgres /nyx/postgres
sudo pw usermod -n postgres -d /nyx/postgres
sudo sysrc postgresql_enable=YES
sudo sysrc postgresql_data=/nyx/postgres/data14
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

## The media install script
Useful for using FreeBSD as a "media" server... really, for Plex Media Server (and SABnzbd+). Simply run the
`media-install.sh` script. This script has a `--use-ports` and `--use-pkg` flag. The default uses `--use-ports`.

```
sudo sh ./media-install.sh
```

After the install script finishes, enable both services at startup
```
sudo sysrc plexmediaserver_enable=YES
sudo sysrc sabnzbd_enable=YES
```

You can also start the services now
```
sudo service plexmediaserver start
sudo service sabnzbd start
```

Plex Media Server can be accessed at http://localhost:32400/web
SABnzbd+ can be accessed at http://localhost:8080/sabnzbd/