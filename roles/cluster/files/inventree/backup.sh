#!/bin/bash
set -euo pipefail

if [ -z "${BACKUP_DIR:-}" ]; then
    echo "BACKUP_DIR is either unset or empty."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
KEEP_DAYS=7
SNAPSHOT_DIR="${BACKUP_DIR}/${TIMESTAMP}"

mkdir -p "${SNAPSHOT_DIR}"

# Database dump
kubectl exec -n inventree deploy/inventree-db -- \
  pg_dump -U inventree inventree > "${SNAPSHOT_DIR}/db.sql"

# Media snapshot
tar -cf "${SNAPSHOT_DIR}/media.tar" -C /opt/inventree/data media/

# JSON dump (write inside container volume, then move on host)
kubectl exec -n inventree deploy/inventree-server -c inventree -- \
  invoke export-records -f /home/inventree/data/backup.json
mv /opt/inventree/data/backup.json "${SNAPSHOT_DIR}/records.json"

# Prune old backups
find "${BACKUP_DIR}" -maxdepth 1 -mindepth 1 -type d -mtime +${KEEP_DAYS} -exec rm -rf {} +
