#!/bin/bash
set -euo pipefail

if [ -z "${BACKUP_DIR:-}" ]; then
    echo "BACKUP_DIR is either unset or empty."
    exit 1
fi

# Resolve snapshot directory
if [ $# -ge 1 ]; then
    SNAPSHOT_DIR="${BACKUP_DIR}/$1"
else
    SNAPSHOT_DIR=$(find "${BACKUP_DIR}" -maxdepth 1 -mindepth 1 -type d | sort -r | head -1)
    if [ -z "${SNAPSHOT_DIR}" ]; then
        echo "ERROR: No backups found in ${BACKUP_DIR}"
        exit 1
    fi
    echo "No timestamp provided, using latest: $(basename "${SNAPSHOT_DIR}")"
fi

if [ ! -d "${SNAPSHOT_DIR}" ]; then
    echo "ERROR: Snapshot directory not found: ${SNAPSHOT_DIR}"
    echo ""
    echo "Available backups:"
    ls -1d "${BACKUP_DIR}"/*/ 2>/dev/null | xargs -I{} basename {} | sort -r
    exit 1
fi

DB_DUMP="${SNAPSHOT_DIR}/db.sql"
MEDIA_TAR="${SNAPSHOT_DIR}/media.tar"
RECORDS_JSON="${SNAPSHOT_DIR}/records.json"

if [ ! -f "${DB_DUMP}" ]; then
    echo "ERROR: Database dump not found: ${DB_DUMP}"
    exit 1
fi

echo "==> Restoring from: $(basename "${SNAPSHOT_DIR}")"
echo "    Database: ${DB_DUMP}"
[ -f "${MEDIA_TAR}" ]    && echo "    Media:    ${MEDIA_TAR}"    || echo "    Media:    NOT FOUND (skipping)"
[ -f "${RECORDS_JSON}" ] && echo "    Records:  ${RECORDS_JSON}" || echo "    Records:  NOT FOUND (skipping)"
echo ""
read -p "This will DESTROY the current database. Continue? [y/N] " confirm
if [ "${confirm}" != "y" ]; then
    echo "Aborted."
    exit 0
fi

# Scale down server and worker
echo "==> Scaling down InvenTree..."
kubectl scale deployment inventree-server inventree-worker -n inventree --replicas=0
echo "==> Waiting for pods to terminate..."
kubectl wait pod -n inventree -l app=inventree-server --for=delete --timeout=60s 2>/dev/null || true
kubectl wait pod -n inventree -l app=inventree-worker --for=delete --timeout=60s 2>/dev/null || true
sleep 5

# Restore database
echo "==> Restoring database..."
kubectl exec -n inventree deploy/inventree-db -- psql -U inventree -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'inventree' AND pid <> pg_backend_pid();"
kubectl exec -n inventree deploy/inventree-db -- dropdb -U inventree --if-exists inventree
kubectl exec -n inventree deploy/inventree-db -- createdb -U inventree inventree
kubectl exec -i -n inventree deploy/inventree-db -- psql -U inventree inventree < "${DB_DUMP}"

# Restore media
if [ -f "${MEDIA_TAR}" ]; then
    echo "==> Restoring media files..."
    if [ -d "/opt/inventree/data/media" ]; then
        sudo rm -rf /opt/inventree/data/media
    fi
    tar -xf "${MEDIA_TAR}" -C /opt/inventree/data/
fi

# Scale back up
echo "==> Scaling up InvenTree..."
kubectl scale deployment inventree-server inventree-worker -n inventree --replicas=1

# Import JSON records if available
if [ -f "${RECORDS_JSON}" ]; then
    echo "==> Waiting for InvenTree server to be ready..."
    kubectl wait -n inventree deployment/inventree-server --for=condition=available --timeout=120s

    echo "==> Importing JSON records..."
    cp "${RECORDS_JSON}" /opt/inventree/data/restore-records.json
    kubectl exec -n inventree deploy/inventree-server -c inventree -- \
      invoke import-records -f /home/inventree/data/restore-records.json
    rm -f /opt/inventree/data/restore-records.json
fi

echo "==> Restore complete."
