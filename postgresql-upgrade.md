# PostgreSQL upgrade
When upgrading major versions of PostgreSQL, you'll need to upgrade your DB by doing a `db_dump` (or `db_dumpall`) and then load via `psql` or `db_restore`. There is also a `pg_upgrade` utility, but it requires that you target the older verision's binary folder first. There's no easy way to do this in FreeBSD since there's only one place to install PostgreSQL.

Possible Solution? Use a jail for the older version. How? An example of upgrading from PostgreSQL 14 to 15.

1. Create a new jail for the older PostgreSQL and install said older PostgreSQL on new jail
2. Make a backup! do a `pg_dumpall` of your main Postgres server first!
3. Upgrade PostgreSQL in your currently existing jail that runs Postgres
4. Stop PostgreSQL service in Postgres jail
5. Install the new PostgreSQL on the host system (we'll be running `pg_upgrade` from the host)
6. Run `pg_upgrade` from the host system pointing to the old and new binary folders in their respective jails
7. Update Postgres data folder in your main Postgres jail
8. Restart your Postgres service in that main Postgres jail
9. Optionally remove PostgreSQL from the host system (probably best if you do)