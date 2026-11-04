#!/bin/sh
# Rebuilds and restarts Shahed after new files are uploaded.
#
#   ./update.sh            everything
#   ./update.sh backend    just one: backend, admin, vendor, site or waitlist
#
# Only the named services are rebuilt; the database is never recreated.
set -eu
cd "$(dirname "$0")"

services="${*:-backend admin vendor site waitlist}"
for s in $services; do
  case "$s" in
    backend|admin|vendor|site|waitlist) ;;
    *) echo "Unknown service: $s (use backend, admin, vendor, site or waitlist)"; exit 1 ;;
  esac
done

echo "Building: $services"
docker compose build $services
docker compose up -d --no-deps $services
docker image prune -f >/dev/null
docker compose ps
echo "Done."
