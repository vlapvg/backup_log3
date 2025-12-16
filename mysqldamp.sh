#!/bin/bash

#Mysql backup script

MYSQL="mysql --skip-column-names";

DIR="/tmp/backupdb"

for s in mysql -p `$MYSQL -e "SHOW DATABASES"`;
	do
	mkdir -p $DIR/$s;
for t in `$MYSQL -e "SHOW TABLES FROM $s"`;
	do
	/usr/bin/mysqldump --opt $s $t |
	/usr/bin/gzip -c > $DIR/$s/$t.sql.gz;
done
done
