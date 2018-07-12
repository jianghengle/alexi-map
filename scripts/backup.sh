#!/bin/bash

# dump database
/usr/bin/pg_dump $PG_URL > $ALEXI_ROOT/../db-backup/db.dump

# transfer to attic
rsync -avz $ALEXI_ROOT/../db-backup hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/db-backup
rsync -avz $ALEXI_ROOT hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/alexi-data
rsync -avz $ALEXI_ROOT/../gdl-data hjiang5@attic.unl.edu:/attic/waterforfood/hjiang5/glodet_backup/gdl-data
