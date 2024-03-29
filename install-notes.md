# Nginx
--
Recent version of the NGINX introduces dynamic modules support.  In
FreeBSD ports tree this feature was enabled by default with the DSO
knob.  Several vendor's and third-party modules have been converted
to dynamic modules.  Unset the DSO knob builds an NGINX without
dynamic modules support.

To load a module at runtime, include the new `load_module'
directive in the main context, specifying the path to the shared
object file for the module, enclosed in quotation marks.  When you
reload the configuration or restart NGINX, the module is loaded in.
It is possible to specify a path relative to the source directory,
or a full path, please see
https://www.nginx.com/blog/dynamic-modules-nginx-1-9-11/ and
http://nginx.org/en/docs/ngx_core_module.html#load_module for
details.

Default path for the NGINX dynamic modules is

/usr/local/libexec/nginx.

# PostgreSQL
--
For procedural languages and postgresql functions, please note that
you might have to update them when updating the server.

If you have many tables and many clients running, consider raising
kern.maxfiles using sysctl(8), or reconfigure your kernel
appropriately.

The port is set up to use autovacuum for new databases, but you might
also want to vacuum and perhaps backup your database regularly. There
is a periodic script, /usr/local/etc/periodic/daily/502.pgsql, that
you may find useful. You can use it to backup and perform vacuum on all
databases nightly. Per default, it performs `vacuum analyze'. See the
script for instructions. For autovacuum settings, please review
~pgsql/data/postgresql.conf.

If you plan to access your PostgreSQL server using ODBC, please
consider running the SQL script /usr/local/share/postgresql/odbc.sql
to get the functions required for ODBC compliance.

Please note that if you use the rc script,
/usr/local/etc/rc.d/postgresql, to initialize the database, unicode
(UTF-8) will be used to store character data by default.  Set
postgresql_initdb_flags or use login.conf settings described below to
alter this behaviour. See the start rc script for more info.

To set limits, environment stuff like locale and collation and other
things, you can set up a class in /etc/login.conf before initializing
the database. Add something similar to this to /etc/login.conf:
---
postgres:\
	:lang=en_US.UTF-8:\
	:setenv=LC_COLLATE=C:\
	:tc=default:
---
and run `cap_mkdb /etc/login.conf'.
Then add 'postgresql_class="postgres"' to /etc/rc.conf.

======================================================================

To initialize the database, run

  /usr/local/etc/rc.d/postgresql initdb

You can then start PostgreSQL by running:

  /usr/local/etc/rc.d/postgresql start

For postmaster settings, see ~pgsql/data/postgresql.conf

NB. FreeBSD's PostgreSQL port logs to syslog by default
    See ~pgsql/data/postgresql.conf for more info

NB. If you're not using a checksumming filesystem like ZFS, you might
    wish to enable data checksumming. It can only be enabled during
    the initdb phase, by adding the "--data-checksums" flag to
    the postgres_initdb_flags rcvar.  Check the initdb(1) manpage
    for more info and make sure you understand the performance
    implications.

======================================================================

To run PostgreSQL at startup, add
'postgresql_enable="YES"' to /etc/rc.conf


initdb: warning: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    /usr/local/bin/pg_ctl -D /var/db/postgres/data12 -l logfile start


# ssmtp
sSMTP has been installed successfully.

Firstly, edit /etc/mail/mailer.conf to replace sendmail with ssmtp:

sendmail        /usr/local/sbin/ssmtp
send-mail       /usr/local/sbin/ssmtp
mailq           /usr/local/sbin/ssmtp
newaliases      /usr/local/sbin/ssmtp
hoststat        /usr/bin/true
purgestat       /usr/bin/true

Hint: in case sSMPT is being installed directly from ports,
editing /etc/mail/mailer.conf can be done by running "make replace".

Secondly, edit the following files to configure sSMTP:

- /usr/local/etc/ssmtp/revaliases
- /usr/local/etc/ssmtp/ssmtp.conf

At this point sSMTP should be ready to go.

# smartmontools
Installing smartmontools-7.2_3...
smartmontools has been installed

To check the status of drives, use the following:

        /usr/local/sbin/smartctl -a /dev/ad0    for first ATA/SATA drive
        /usr/local/sbin/smartctl -a /dev/da0    for first SCSI drive
        /usr/local/sbin/smartctl -a /dev/ada0   for first SATA drive

To include drive health information in your daily status reports,
add a line like the following to /etc/periodic.conf:
        daily_status_smart_devices="/dev/ad0 /dev/da0"
substituting the appropriate device names for your SMART-capable disks.

To enable drive monitoring, you can use /usr/local/sbin/smartd.
A sample configuration file has been installed as
/usr/local/etc/smartd.conf.sample
Copy this file to /usr/local/etc/smartd.conf and edit appropriately

To have smartd start at boot
        echo 'smartd_enable="YES"' >> /etc/rc.conf

===>  Cleaning for smartmontools-7.2_3


Installing py38-certbot-1.22.0,1...
This port installs the "standalone" client only, which does not use and
is not the certbot-auto bootstrap/wrapper script.

The simplest form of usage to obtain certificates is:

 # sudo certbot certonly --standalone -d <domain>, [domain2, ... domainN]>

NOTE:

The client requires the ability to bind on TCP port 80 or 443 (depending
on the --preferred-challenges option used). If a server is running on that
port, it will need to be temporarily stopped so that the standalone server
can listen on that port to complete the challenge authentication process.

For more information on the 'standalone' mode, see:

  https://certbot.eff.org/docs/using.html#standalone

The certbot plugins to support apache and nginx certificate installation
will be made available in the following ports:

 * Apache plugin: security/py-certbot-apache
 * Nginx plugin: security/py-certbot-nginx

In order to automatically renew the certificates, add this line to
/etc/periodic.conf:

    weekly_certbot_enable="YES"

More config details in the certbot periodic script:

    /usr/local/etc/periodic/weekly/500.certbot-3.8



Installing samba413-4.13.17...
How to start: http://wiki.samba.org/index.php/Samba4/HOWTO

* Your configuration is: /usr/local/etc/smb4.conf

* All the relevant databases are under: /var/db/samba4

* All the logs are under: /var/log/samba4

For additional documentation check: http://wiki.samba.org/index.php/Samba4

Bug reports should go to the: https://bugzilla.samba.org/

===> SECURITY REPORT: 
      This port has installed the following files which may act as network
      servers and may therefore pose a remote security risk to the system.
/usr/local/lib/samba4/private/libsamba-sockets-samba4.so
/usr/local/lib/samba4/private/libsmb-transport-samba4.so
/usr/local/bin/nmblookup
/usr/local/lib/samba4/private/libgse-samba4.so
/usr/local/lib/samba4/private/libkrb5-samba4.so.26
/usr/local/sbin/winbindd
/usr/local/lib/samba4/private/libsmbd-base-samba4.so
/usr/local/lib/samba4/libsmbconf.so.0
/usr/local/sbin/smbd

      If there are vulnerabilities in these programs there may be a security
      risk to the system. FreeBSD makes no guarantee about the security of
      ports included in the Ports Collection. Please type 'make deinstall'
      to deinstall the port if this is a concern.

      For more information, and contact details about the security
      status of this software, see the following webpage: 
https://www.samba.org/    



[1/1] Installing plexmediaserver-plexpass-1.32.6.7468...
===> Creating groups.
Using existing group 'plex'.
===> Creating users
Using existing user 'plex'.
[1/1] Extracting plexmediaserver-plexpass-1.32.6.7468: 100%
=====
Message from plexmediaserver-plexpass-1.32.6.7468:

--
multimedia/plexmediaserver_plexpass includes an RC script:
/usr/local/etc/rc.d/plexmediaserver_plexpass

TO START PLEXMEDIASERVER ON BOOT:
sysrc plexmediaserver_plexpass_enable=YES

START MANUALLY:
service plexmediaserver_plexpass start

Once started, visit the following to configure:
http://localhost:32400/web

@@@ INTEL GPU OFFLOAD NOTES @@@

If you have a supported Intel GPU, you can leverage hardware
accelerated encoding/decoding in Plex Media Server on FreeBSD 12.0+.

The requirements are as follows:

* Install multimedia/drm-kmod: e.g., pkg install drm-fbsd12.0-kmod

* Enable loading of kernel module on boot: sysrc kld_list+="i915kms"
** If Plex will run in a jail, you must load the module outside the jail!

* Load the kernel module now (although reboot is advised): kldload i915kms

* Add plex user to the video group: pw groupmod -n video -m plex

* For jails, make a devfs ruleset to expose /dev/dri/* devices.

e.g., /dev/devfs.rules on the host:

[plex_drm=10]
add include $devfsrules_hide_all
add include $devfsrules_unhide_basic
add include $devfsrules_unhide_login
add include $devfsrules_jail
add path 'dri*' unhide
add path 'dri/*' unhide
add path 'drm*' unhide
add path 'drm/*' unhide

* Enable the devfs ruleset for your jail. e.g., devfs_ruleset=10 in your
/etc/jail.conf or for iocage, iocage set devfs_ruleset="10"

Please refer to documentation for all other FreeBSD jail management
utilities.

* Make sure hardware transcoding is enabled in the server settings

@@@ INTEL GPU OFFLOAD NOTES @@@


Message from zfsnap-1.11.1_1:

--
To run zfSnap periodically you can add these options to your
        /etc/periodic.conf

        xPERIODICx_zfsnap_enable        - Enable xPERIODICx snapshots
                                          (values: YES | NO)
        xPERIODICx_zfsnap_fs            - Space separated zfs filesystems
                                          to create non-recursive snapshots
        xPERIODICx_zfsnap_recursive_fs  - Space separated zfs filesystems
                                          to create recursive snapshots
        xPERIODICx_zfsnap_ttl           - Set Time To Live
        xPERIODICx_zfsnap_verbose       - Verbose output (values: YES | NO)
        xPERIODICx_zfsnap_flags         - zfSnap generic flags
                                          (except -v and -d)
        xPERIODICx_zfsnap_enable_prefix - Create snapshots with prefix
                                          (Default = YES)
        xPERIODICx_zfsnap_prefix        - Set prefix to use for new snapshots
                                          (Default = "xPERIODICx-")
        (where xPERIODICx is any of hourly, daily, weekly, monthly, reboot)

        xPERIODICx_zfsnap_delete_enable    - Delete old snapshots periodically
                                             (values: YES | NO)
        xPERIODICx_zfsnap_delete_flags     - zfSnap generic flags
                                             (except -v and -d)
        xPERIODICx_zfsnap_delete_verbose   - Verbose output (values: YES | NO)
        xPERIODICx_zfsnap_delete_prefixes  - Space separated list of prefixes
                                             of old zfSnap snapshots to delete
                                             'hourly-', 'daily-', 'weekly-',
                                             'monthly-' and 'reboot-' prefixes
                                             are hard-coded
        (where xPERIODICx is any of daily, weekly, monthly)


        Add these lines to your /etc/crontab
        4       *       *       *       *       root    periodic hourly
        @reboot                                 root    periodic reboot

        NOTE: it is not recommended to delete zfSnap snapshots every hour.
        Deleting zfs snapshots takes more time than creating them.
        There for it's better to delete snapshots once per day...


        Periodic scripts provide very limited feature set. If you want to use
        more advanced setup, you need to call zfSnap from crontab directly.
        This way you can combine all sort of parameter combinations.

        Don't forget to check https://github.com/graudeejs/zfSnap/wiki for more
        info.

        Feedback welcomed: graudeejs@gmail.com

# endlessh

Message from endlessh-1.1_1:

--
Configure endlessh either via endlessh.conf or using endlessh_args in rc.conf.
The defaults are commented out in endlessh.conf.

The default configuration only logs starts & stops to /var/log/endlessh.log.
To see the connections set LogLevel 1 in endlessh.conf or add "-v" to
endlessh_args. Sending SIGUSR1 to endlessh (pkill USR1 endlessh) will add
statistics to the /var/log/endlessh.log file

Link (or copy) endlessh.newsyslog.conf to /usr/local/newsyslog.conf.d/
to take care of log rotation.

ln -s /usr/local/etc/endlessh.newsyslog.conf /usr/local/etc/newsyslog.conf.d/



Message from py39-fail2ban-0.11.2_3:

--
Please do not edit the fail2ban.conf, jail.conf, or any other
files in the distributen as they will be overwritten upon each
upgrade of the port. Instead, create new files named *.local e.g.
fail2ban.local or jail.local.

For more information, see the official manual:
http://www.fail2ban.org/wiki/index.php/MANUAL_0_8#Configuration

If you have custom filters or actions and you are upgrading from
0.9.x please check them.

Users of pf: please read the notes in action.d/pf.conf and the
discussion at https://github.com/fail2ban/fail2ban/pull/1925
Please note that fail2ban will put curly braces '{}' around the
ports in the action so you shouldn't do it yourself.



=====
Message from pcsc-lite-1.9.9,2:

--
PC/SC-Lite has been installed.

You need to install a driver for your smartcard reader e.g.,
- devel/libccid

For cardreaders connected to the serial port: After installing the driver,
please update the pcscd configuration file:
/usr/local/etc/reader.conf

For USB cardreaders add the following lines to /etc/devd.conf to enable
hotplugging:

attach 100 {
        device-name "ugen[0-9]+";
        action "/usr/local/sbin/pcscd -H";
};

detach 100 {
        device-name "ugen[0-9]+";
        action "/usr/local/sbin/pcscd -H";
};
=====
Message from u2f-devd-1.1.10_7:

--
U2F authentication requires read/write access to USB devices. To
facilitate such access it comes with a devd.conf(5) file, but you
still need to restart devd(8), add the desired users to "u2f" group
and log those out of the current session. For example:

# service devd restart
# pw group mod u2f -m <user>
$ exit

For details, see /usr/local/etc/devd/u2f.conf
=====
Message from libu2f-host-1.1.10_1:

--
===>   NOTICE:

The libu2f-host port currently does not have a maintainer. As a result, it is
more likely to have unresolved issues, not be up-to-date, or even be removed in
the future. To volunteer to maintain this port, please create an issue at:

https://bugs.freebsd.org/bugzilla

More information about port maintainership is available at:

https://docs.freebsd.org/en/articles/contributing/#ports-contributing
=====
Message from ccid-1.5.1:

--
===>   NOTICE:

The ccid port currently does not have a maintainer. As a result, it is
more likely to have unresolved issues, not be up-to-date, or even be removed in
the future. To volunteer to maintain this port, please create an issue at:

https://bugs.freebsd.org/bugzilla

More information about port maintainership is available at:

https://docs.freebsd.org/en/articles/contributing/#ports-contributing
=====
Message from py39-yubikey-manager-4.0.9_4:

--
In order to use `ykman otp` commands, you need to make sure the uhid(4)
driver attaches to the USB device:

  # usbconfig -d ugenX.Y add_quirk UQ_KBD_IGNORE
  # usbconfig -d ugenX.Y reset

The correct device to operate on (ugenX.Y) can be determined using
`usbconfig list`.

When using FreeBSD 13 or higher, you can switch to the more modern
hidraw(4) driver. This allows YubiKey Manager to access OTP HID in a
non-exclusive way, so that the key will still function as a USB keyboard:

  # sysrc kld_list+="hidraw hkbd"
  # cat >>/boot/loader.conf<<EOF
  hw.usb.usbhid.enable="1"
  hw.usb.quirk.0="0x1050 0x0010 0 0xffff UQ_KBD_IGNORE"  # YKS_OTP
  hw.usb.quirk.1="0x1050 0x0110 0 0xffff UQ_KBD_IGNORE"  # NEO_OTP
  hw.usb.quirk.2="0x1050 0x0111 0 0xffff UQ_KBD_IGNORE"  # NEO_OTP_CCID
  hw.usb.quirk.3="0x1050 0x0114 0 0xffff UQ_KBD_IGNORE"  # NEO_OTP_FIDO
  hw.usb.quirk.4="0x1050 0x0116 0 0xffff UQ_KBD_IGNORE"  # NEO_OTP_FIDO_CCID
  hw.usb.quirk.5="0x1050 0x0401 0 0xffff UQ_KBD_IGNORE"  # YK4_OTP
  hw.usb.quirk.6="0x1050 0x0403 0 0xffff UQ_KBD_IGNORE"  # YK4_OTP_FIDO
  hw.usb.quirk.7="0x1050 0x0405 0 0xffff UQ_KBD_IGNORE"  # YK4_OTP_CCID
  hw.usb.quirk.8="0x1050 0x0407 0 0xffff UQ_KBD_IGNORE"  # YK4_OTP_FIDO_CCID
  hw.usb.quirk.9="0x1050 0x0410 0 0xffff UQ_KBD_IGNORE"  # YKP_OTP_FIDO
  EOF
  # reboot