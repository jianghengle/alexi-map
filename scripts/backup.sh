#!/bin/bash

# dump database
/usr/bin/pg_dump $PG_URL > $DB_BACKUP/db.dump

# transfer to attic
rsync -avz $DB_BACKUP hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/db-backup --delete
rsync -avz $ALEXI_ROOT hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/alexi-data --delete
rsync -avz $GDL_ROOT hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/gdl-data --delete