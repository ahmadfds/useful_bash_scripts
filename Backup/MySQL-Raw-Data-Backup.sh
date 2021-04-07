#!/bin/bash

REMOTE_MYSQL_STOP_COMMAND="/etc/init.d/mysql stop"
REMOTE_MYSQL_START_COMMAND="/etc/init.d/mysql start"
REMOTE_USER=root
REMOTE_HOST=0.0.0.0
REMOTE_DIR=/var/lib/mysql
TMP_DIR=/tmp/
S3_BACKUP_DIR="s3://backup/project-directory"


#
# REMOTE PROCESSING
#
REMOTE_BASE_NAME=$(basename "${REMOTE_DIR}")
REMOTE_DIR=$(dirname "${REMOTE_DIR}")"/${REMOTE_BASE_NAME}"
OUTPUT_FILE_NAME="${REMOTE_BASE_NAME}$(date +%Y-%m-%d-%H)"

ssh -o "StrictHostKeyChecking no" ${REMOTE_USER}@${REMOTE_HOST} "${REMOTE_MYSQL_STOP_COMMAND}"
rsync -e "ssh -o StrictHostKeyChecking=no" -rv ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR} ${TMP_DIR}
ssh -o "StrictHostKeyChecking no" ${REMOTE_USER}@${REMOTE_HOST} "${REMOTE_MYSQL_START_COMMAND}"

cd "${TMP_DIR}" && tar -cjf "${OUTPUT_FILE_NAME}.tar.bz2" "${REMOTE_BASE_NAME}" && rm -rf "./${REMOTE_BASE_NAME}"
aws s3 cp "${TMP_DIR}${OUTPUT_FILE_NAME}.tar.bz2" "${S3_BACKUP_DIR}/"