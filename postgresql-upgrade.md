# PostgreSQL upgrade
When upgrading major versions of PostgreSQL, you'll need to upgrade your DB by doing a `db_dump` (or `db_dumpall`) and then load via `psql` or `db_restore`. There is also a `pg_upgrade` utility, but it requires that you target the older verision's binary folder first. There's no easy way to do this in FreeBSD since there's only one place to install PostgreSQL.

Possible Solution? Use a jail for the older version. How? An example of upgrading from PostgreSQL 15 to 16.

Below is an example of what we can do if we have a jail named "cloud" with PostgreSQL we want to upgrade

1. Create a brand new jail for the older PostgreSQL and install said older PostgreSQL on new jail
2. Make a backup! do a `pg_dumpall` of your main Postgres server first!
3. Upgrade PostgreSQL in your currently existing jail that runs Postgres
4. Stop PostgreSQL service 
5. Init the new data for PostgreSQL (i.e. /postgres/data16)
Update the data for the new PostgreSQL (i.e. /postgres/data16)
6. Mount older PostgreSQL jail bin folder to newer jail so the newer jail has access to it for `pg_upgrade`
8. Run `pg_upgrade` from the newer jail pointing to the old and new binary folders in their respective jails
9. Restore access by updating pg_hba.conf 
10. Start/restart your Postgres service
11. Remove the temporary old PostgreSQL jail

## Create a new jail and install the older version of postgresql14 you want to upgrade from
```
sudo bastille create pg15 14.0-RELEASE 192.168.2.24
sudo bastille start pg15
sudo bastille pkg pg15 install databases/postgresql15-server
```

## Stop services and install new version of PostgreSQL
First stop services that could be using PostgreSQL and do a `pg_dumpall` as a backup

```
sudo bastille cmd cloud sudo -u postgres pg_dumpall -c -f /postgres/pgdata15-$(date '+%Y-%m-%d_%H-%M-%S').out
```

Finally stop PostgreSQL and install the newer version

```
sudo bastille service cloud postgresql stop
sudo bastille pkg cloud install postgresql16-server
sudo bastille sysrc cloud postgresql_data=/postgres/data16
sudo bastille service cloud postgresql initdb
sudo bastille mount cloud /usr/local/bastille/jails/pg15/root/usr/local/bin usr/pg15bin
```

You'll also want to (temporarily) install the newest version on the host just for `pg_upgrade`
```
sudo pkg install postgresql16-server
```

## Upgrade your data via `pg_upgrade`

You'll need to console into your jail for this
```
sudo bastille console cloud
sudo -u postgres pg_upgrade -b /usr/pg14bin -d /postgres/data14 -B /usr/local/bin -D /postgres/data15
exit
```

Then start and vaccum your new DB
```
sudo bastille service cloud postgresql start
sudo bastille cmd cloud sudo -u postgres vacuumdb --all --analyze-in-stages
```

If you don't need your old data files, you can also delete it by running
```
sudo bastille cmd cloud /tmp/delete_old_cluster.sh
```
When using `-k` with `pg_upgrade` you'll need to keep the old data directory to also be used with the new data directory. You can omit `-k` but expect the time to upgrade take a little longer.

## Update
```
sudo bastille sysrc cloud -f /etc/rc.conf postgresql_data=/postgres/data15
sudo bastille service cloud postgresql initdb
sudo bastille service cloud postgresql start
```

## Clean up older jail
Probably easiest to bring down the jails first.

```
sudo bastille umount cloud usr/pg14bin
sudo bastille stop pg14
sudo bastille destroy pg14
```

## Restoring from `pg_dumpall`

In case `pg_upgrade` fails you, you can also restore from `pg_dumpall`

This assumes you console into your jail

```
sudo -u postgres psql -f db.out
```