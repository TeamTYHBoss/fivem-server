#!/usr/bin/env bash

set -euo pipefail

BACKUP_FILE="${1:-}"

if [[ -z "$BACKUP_FILE" ]]; then
    echo "Usage: ./restore.sh backups/database-YYYYMMDD-HHMMSS.sql"
    exit 1
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

if [[ ! -f .env ]]; then
    echo "Missing .env file. Copy .env.example to .env and fill in the values."
    exit 1
fi

source .env

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "Missing DATABASE_URL in .env."
    exit 1
fi

DB_NAME="$(printf '%s' "$DATABASE_URL" | sed -E 's|.*/([^/?]+)(\?.*)?$|\1|')"

if [[ -z "$DB_NAME" ]]; then
    echo "Could not determine database name from DATABASE_URL."
    exit 1
fi

if ! command -v mysql >/dev/null 2>&1; then
    echo "mysql is not installed. Install MySQL client tools to enable restore."
    exit 1
fi

echo "Restoring $BACKUP_FILE into database $DB_NAME."
echo "This will overwrite existing data. Press Ctrl+C to cancel."
read -r -p "Type RESTORE to continue: " CONFIRM

if [[ "$CONFIRM" != "RESTORE" ]]; then
    echo "Restore cancelled."
    exit 1
fi

mysql "$DB_NAME" < "$BACKUP_FILE"

echo "Restore complete."
