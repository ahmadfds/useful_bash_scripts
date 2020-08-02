#!/bin/bash

#
# Required Environment Variables
#
# SSH_USERNAME=
# SSH_HOST=
# MYSQL_CONTAINER_NAME=
# MYSQL_USER=
# MYSQL_PASSWORD=
# MYSQL_DB_NAME=
# MYSQL_TABLES=
# LOCAL_BACKUPS_DIR=
# S3_BACKUP_PATH=

cat << DOC



###############################################################################################
Make sure to do the follow steps on the target server.
1) Create new user on the remote ssh server like this:
    - useradd -m -d /home/${SSH_USERNAME} -s /bin/bash ${SSH_USERNAME})

2) Create mysqldump bash:
    - echo "docker exec -t ${MYSQL_CONTAINER_NAME} mysqldump \\\$@" > /usr/local/bin/${SSH_USERNAME}-mysqldump
    - chmod 755 /usr/local/bin/${SSH_USERNAME}-mysqldump

3) Make the user sudoer on that created bash script like this:
    - sudo visudo
    - then add this line:
      ${SSH_USERNAME}  ALL=(ALL) NOPASSWD: /usr/local/bin/${SSH_USERNAME}-mysqldump

4) Create MySQL read only user for backup:
    - CREATE USER 'backup'@'localhost' IDENTIFIED BY '<YOUR PASSWORD>';
    - GRANT SELECT, LOCK TABLES ON ${MYSQL_DB_NAME}.* TO 'backup'@'localhost';

5) Append this public key to the remote created user's file .ssh/authorized_key
$(cat ~/.ssh/id_rsa.pub)



DOC

BDATE=$(date +%Y-%m-%d-%H)
BACKUP_FILE_NAME="mysql-${MYSQL_DB_NAME}-${BDATE}.sql.gz"
REMOTE_FILE_PATH="/home/${SSH_USERNAME}/${BACKUP_FILE_NAME}"
LOCAL_FILE_PATH="${LOCAL_BACKUPS_DIR}${MYSQL_DB_NAME}-${BDATE}.sql.gz"

ssh -o "StrictHostKeyChecking no" ${SSH_USERNAME}@${SSH_HOST} "sudo /usr/local/bin/${SSH_USERNAME}-mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DB_NAME} ${MYSQL_TABLES} | gzip > ${REMOTE_FILE_PATH}"

scp -o "StrictHostKeyChecking no" ${SSH_USERNAME}@${SSH_HOST}:${REMOTE_FILE_PATH} $LOCAL_FILE_PATH

ssh -o "StrictHostKeyChecking no" ${SSH_USERNAME}@${SSH_HOST} "rm ${REMOTE_FILE_PATH}"

/usr/local/bin/aws s3 cp $LOCAL_FILE_PATH $S3_BACKUP_PATH --storage-class STANDARD_IA

rm $LOCAL_FILE_PATH
