#!/bin/sh
# Dumps the Shahed database to /backups and keeps the last 14 days.
set -eu
stamp=$(date -u +%Y-%m-%d_%H%M)
pg_dump --no-owner --format=custom shahed > "/backups/shahed-$stamp.dump.tmp"
mv "/backups/shahed-$stamp.dump.tmp" "/backups/shahed-$stamp.dump"
find /backups -name '*.dump' -mtime +14 -delete
echo "backup done $stamp"
