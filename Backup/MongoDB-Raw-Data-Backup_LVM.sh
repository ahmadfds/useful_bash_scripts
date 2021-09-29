#!/bin/bash

MONGO_STOP_COMMAND=
MONGO_START_COMMAND=
SNAPSHOT_MOUNT_DIR=/var/lib/mongodb-snapshot
BACKUP_DIR=/var/lib/mongodb-backup
LVM_DATA_NAME="mongo-data"
LVM_GROUP_NAME="vg00"
LVM_SNAPSHOT_COW_SIZE=20
LVM_SNAPSHOT_NAME="tmp-backup-snapshot"
BACKUP_FILE_PREFIX="mongodb-backup"
S3_ARCHIVE_PATH=
CURRDATE=$(date +%Y-%m-%d-%H-%M-%S)

startMongo() {
  echo "Starting MongoDB ..."
  $MONGO_START_COMMAND
}

stopMongo() {
  echo "Stopping MongoDB ..."
  $MONGO_STOP_COMMAND
}

rollbackAction() {
  echo "Backup process failed, rolling back ..."
  $MONGO_START_COMMAND
  exit 2
}

deleteSnapshotIfExists() {
  EXISTS=$(lvs | grep -o "$LVM_SNAPSHOT_NAME")
  if [ ! -z $EXISTS ]; then
    echo "Deleting an old snapshot ..."
    umount /dev/${LVM_GROUP_NAME}/${LVM_SNAPSHOT_NAME}
    lvremove -y /dev/${LVM_GROUP_NAME}/${LVM_SNAPSHOT_NAME}
  fi
}

createSnapshot() {
  echo "Createing a new snapshot ..."
  lvcreate -L ${LVM_SNAPSHOT_COW_SIZE}G -s -n $LVM_SNAPSHOT_NAME /dev/${LVM_GROUP_NAME}/${LVM_DATA_NAME}
  mount /dev/${LVM_GROUP_NAME}/$LVM_SNAPSHOT_NAME $SNAPSHOT_MOUNT_DIR
}

backupFiles() {
  echo "Archiving data directory to ${BACKUP_FILE_PREFIX}-${CURRDATE}.tar"
  cd $BACKUP_DIR
  tar -cf "${BACKUP_FILE_PREFIX}-${CURRDATE}.tar" -C $SNAPSHOT_MOUNT_DIR .
}

archiveToS3() {
  echo "Archiving to S3 ..."
  /usr/local/bin/aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE_PREFIX}-${CURRDATE}.tar" ${S3_ARCHIVE_PATH} --storage-class ONE-ZONE_IA
}

cleanBackupDirectory() {
  cd $BACKUP_DIR
  rm -f ${BACKUP_FILE_PREFIX}*.tar
}

cleanBackupDirectory || exit 2
deleteSnapshotIfExists || exit 2
stopMongo
createSnapshot || rollbackAction
startMongo
backupFiles
deleteSnapshotIfExists
archiveToS3
cleanBackupDirectory