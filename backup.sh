#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f .env ]]; then
    echo "Missing .env file. Copy .env.example to .env and fill in the values."
    exit 1
fi

source .env

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "Missing DATABASE_URL in .env."
    exit 1
fi

BACKUP_DIR="backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

# Extract database name from a standard mysql:// URL.
DB_NAME="$(printf '%s' "$DATABASE_URL" | sed -E 's|.*/([^/?]+)(\?.*)?$|\1|')"

if [[ -z "$DB_NAME" ]]; then
    echo "Could not determine database name from DATABASE_URL."
    exit 1
fi

if command -v mysqldump >/dev/null 2>&1; then
    mysqldump "$DB_NAME" > "$BACKUP_DIR/database-$TIMESTAMP.sql"
    echo "Database backup created: $BACKUP_DIR/database-$TIMESTAMP.sql"
else
    echo "mysqldump is not installed. Install MySQL client tools to enable database backups."
fi

if command -v tar >/dev/null 2>&1; then
    tar -czf "$BACKUP_DIR/files-$TIMESTAMP.tar.gz" resources server.cfg
    echo "File backup created: $BACKUP_DIR/files-$TIMESTAMP.tar.gz"
else
    echo "tar is not installed. Install tar to enable file backups."
fi
