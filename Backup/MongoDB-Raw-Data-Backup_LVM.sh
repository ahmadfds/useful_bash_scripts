#!/bin/bash

MONGO_STOP_COMMAND=
MONGO_START_COMMAND=
S3_ARCHIVE_PATH=
SNAPSHOT_MOUNT_DIR=/var/lib/mongodb-snapshot
LVM_DATA_NAME="mongo-data"
LVM_GROUP_NAME="vg00"
LVM_SNAPSHOT_COW_SIZE=100
LVM_SNAPSHOT_NAME="tmp-backup-snapshot"

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
  EXISTS=$(/sbin/lvs | grep -o "$LVM_SNAPSHOT_NAME")
  if [ ! -z $EXISTS ]; then
    echo "Deleting an old snapshot ..."
    umount /dev/${LVM_GROUP_NAME}/${LVM_SNAPSHOT_NAME}
    /sbin/lvremove -y /dev/${LVM_GROUP_NAME}/${LVM_SNAPSHOT_NAME}
  fi
}

createSnapshot() {
  echo "Createing a new snapshot ..."
  /sbin/lvcreate -L ${LVM_SNAPSHOT_COW_SIZE}G -s -n $LVM_SNAPSHOT_NAME /dev/${LVM_GROUP_NAME}/${LVM_DATA_NAME}
  mount /dev/${LVM_GROUP_NAME}/$LVM_SNAPSHOT_NAME $SNAPSHOT_MOUNT_DIR
}

archiveToS3() {
  echo "Archiving to S3 ..."
  CURRDATE=$(date +%Y-%m-%d-%H-%M-%S)
  /usr/local/bin/aws s3 sync "${SNAPSHOT_MOUNT_DIR}/*" ${S3_ARCHIVE_PATH}/${CURRDATE}/ --storage-class ONEZONE_IA
}


deleteSnapshotIfExists || exit 2
stopMongo
createSnapshot || rollbackAction
startMongo
archiveToS3
deleteSnapshotIfExists