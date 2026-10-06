#!/usr/bin/env bash
set -euo pipefail

deployment_dir="$(cd "$(dirname "$0")" && pwd)"
backup_dir="${1:-$HOME/backups/n8n}"
stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
chmod 700 "$backup_dir"

container_id="$(cd "$deployment_dir" && docker compose ps -q n8n)"
test -n "$container_id"
data_dir="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/home/node/.n8n"}}{{.Source}}{{end}}{{end}}' "$container_id")"
test -n "$data_dir"

database_backup="$backup_dir/n8n-$stamp.sqlite"
sudo python3 - "$data_dir/database.sqlite" "$database_backup" <<'PY'
import sqlite3
import sys

source = sqlite3.connect(f"file:{sys.argv[1]}?mode=ro", uri=True)
target = sqlite3.connect(sys.argv[2])
source.backup(target)
assert target.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
target.close()
source.close()
PY
sudo chown "$(id -u):$(id -g)" "$database_backup"
chmod 600 "$database_backup"
gzip "$database_backup"
install -m 600 "$deployment_dir/.env" "$backup_dir/n8n-$stamp.env"
find "$backup_dir" -type f \( -name 'n8n-*.sqlite.gz' -o -name 'n8n-*.env' \) -mtime +14 -delete
echo "n8n backup created: $stamp"
