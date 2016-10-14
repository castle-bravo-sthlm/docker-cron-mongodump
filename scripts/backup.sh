#!/bin/bash
. /scripts/mongourl_to_params.sh

MONGOURLS=$(echo $MONGODB_BACKUP_URLS | tr ";" "\n")

for MONGOURL in $MONGOURLS; do
  mongourl_to_params $MONGOURL

  MONGODB_HOST=$hostport
  MONGODB_USER=$user
  MONGODB_PASSWORD=$pass
  MONGODB_DATABASE=$db

  BACKUP_TMP_DIR=/tmp/backup
  BACKUP_DIR=/backups/$MONGODB_HOST/$MONGODB_DATABASE

  echo "------- BACKUP START " `date "+ %Y-%m-%d %H:%M:%S"` "-------"
  echo "- mkdir -p $BACKUP_DIR -"
  mkdir -p $BACKUP_DIR

  echo "- mkdir -p $BACKUP_TMP_DIR - \n"
  mkdir -p $BACKUP_TMP_DIR

  echo "- backup database at $MONGODB_HOST -"
  mongodump -h $MONGODB_HOST -u $MONGODB_USER -p $MONGODB_PASSWORD -d $MONGODB_DATABASE -o $BACKUP_TMP_DIR

  if [ "$(ls -A $BACKUP_TMP_DIR)" ]; then
     echo "\n- save tar file with content: -\n"
     mv $BACKUP_DIR/$MONGODB_DATABASE-latest.tar.gz $BACKUP_DIR/$MONGODB_DATABASE.tar.gz 2>/dev/null
     tar -zcvf $BACKUP_DIR/$MONGODB_DATABASE-latest.tar.gz $BACKUP_TMP_DIR

     echo "\n- to $BACKUP_DIR/$MONGODB_DATABASE-latest.tar.gz -\n"
  else
     echo "- no tar created because no output from mongodump -"
  fi

  echo "- removing $BACKUP_DIR -\n"
  rm -rf $BACKUP_TMP_DIR

  echo "------- BACKUP DONE -------\n"
done
