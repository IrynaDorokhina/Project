#!/bin/bash

# Create a Backup of the local database.
#mysqldump -u wpuser -p wppassword wordpress > wpbackup.sql

# Import the local database backup to Amazon RDS.
#mysql -h $endpoint -P 3306 -u $usernamerds -p $passwordrds myrdsinstance < wpbackup.sql