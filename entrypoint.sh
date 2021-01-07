#!/bin/bash

while getopts "s:m:u:g:" arg; do
  case ${arg} in
  s)
      SYNC_DEST=${OPTARG}
      ;;
  m)
      JVM_HEAP=${OPTARG}
      ;;
  u)
      SYNC_UID=${OPTARG}
      ;;
  g)
      SYNC_GID=${OPTARG}
      ;;
  *)
      continue
      ;;
  esac
done

SYNCJOB() {
  CONF_DIR="$1"
  DEST_DIR="$2"
  BACKUP_DIR="${DEST_DIR}/$(basename ${CONF_DIR})"

  CHOWN_MODE=
  if [ -n ${SYNC_UID} ] || [ -n ${SYNC_GID} ]; then
    CHOWN_MODE="--chown=${SYNC_UID}:${SYNC_GID}"
  fi

  if [ -d ${CONF_DIR} ]; then
    if [ -d ${BACKUP_DIR} ]; then
      mv "${BACKUP_DIR}" "${BACKUP_DIR}.$(date +%s)"
    fi

    rsync -avh "${CHOWN_MODE}" "$(realpath ${CONF_DIR})" "${DEST_DIR}"
  else
    if [ -d ${BACKUP_DIR} ]; then
      rsync -avh "${BACKUP_DIR}" "$(dirname ${CONF_DIR})"
    fi
  fi

  mkdir -p "${CONF_DIR}"
  while inotifywait -r -e modify,create,delete,move "${CONF_DIR}"; do
    rsync -avh --delete "${CHOWN_MODE}" "$(realpath ${CONF_DIR})" "${DEST_DIR}"
  done
}

## Adjust memory settings
if [ -n "${JVM_HEAP}" ]; then
  CONF_FILE=/opt/jetbrain/bin/webstorm64.vmoptions

  sed -i "s/-Xms.*/-Xms${JVM_HEAP}/" ${CONF_FILE}
  sed -i "s/-Xmx.*/-Xmx${JVM_HEAP}/" ${CONF_FILE}
fi

## World share
if [ -n "${SYNC_DEST}" ]; then
  SYNCJOB /root/.config/JetBrains/ ${SYNC_DEST} &
  SYNCJOB /root/workspace ${SYNC_DEST} &
fi

/opt/jetbrain/bin/webstorm.sh
