#!/bin/bash

. /scripts/mongourl_to_params.sh

MONGOURLS=$(echo $MONGODB_BACKUP_URLS | tr ";" "\n")

for MONGOURL in $MONGOURLS; do
  mongourl_to_params $MONGOURL

  MONGODB_HOST=$hostport
  MONGODB_USER=$user
  MONGODB_PASSWORD=$pass
  MONGODB_DATABASE=$db

  BACKUP_DIR=/backups/$MONGODB_HOST/$MONGODB_DATABASE
  TIME=$(date +"%Y%m%dT%H%M%S")

  echo "------- BACKUP START " `date "+ %Y-%m-%d %H:%M:%S"` "-------"

  echo "- mkdir -p $BACKUP_DIR -"
  mkdir -p $BACKUP_DIR

  echo "\n- backup database at $MONGODB_HOST -\n"
  mongodump -h $MONGODB_HOST -u $MONGODB_USER -p $MONGODB_PASSWORD -d $MONGODB_DATABASE --gzip --archive=$BACKUP_DIR/backup.$TIME.gz

  #keep 50 log files
  echo "\n- remove old logs -\n"
  ls -tpd -1 $BACKUP_DIR/* | grep -v '/$' | tail -n +51 | xargs -I {} rm -- {}

  if [ -z "$SCP_PORT" ] || [ -z "$SCP_HOST" ] || [ -z "$SCP_USER" ] || [ -z "$SCP_REMOTE_DIR" ]; then
    echo '- one or more scp variables are undefined, so no scp will be done'
  else
    echo '- trying to scp -'
    scp -P $SCP_PORT $BACKUP_DIR/backup.$TIME.gz $SCP_USER@$SCP_HOST:$SCP_REMOTE_DIR
  fi

  echo "------- BACKUP DONE -------\n"
done
