#!/usr/bin/env bash
#
# Local fleet catalog workflow (build + verify).
#
# Usage (from anywhere):
#   ./tool/fleet/run_local.sh
#   # or from repo root:
#   bash tool/fleet/run_local.sh
#
# What it does:
#   1. Creates .venv-fleet + installs tool/fleet/requirements.txt if missing
#   2. Runs tool/fleet/build_catalog.py → fleet/catalog.json (+ catalog.meta.json)
#      - vpnbook: all 10 hosts × 4 protocols (tcp80/443, udp53/25000)
#      - VPN Gate: curated top 40 when the API is reachable (may time out locally)
#   3. Runs dart run tool/fleet/verify_catalog_parse.dart (if dart is on PATH)
#
# Optional env (same as CI):
#   VPNBOOK_USERNAME / VPNBOOK_PASSWORD  — skip scraping free-page credentials
#
# What it does NOT do (GitHub Actions only):
#   - git commit / push
#   - jsDelivr purge
#
# After a successful run, commit fleet/catalog.json yourself if you want it on
# main/CDN. App cache still won't refresh until forceRefresh/TTL (see STATUS).
# Full docs: docs/FLEET_CATALOG.md
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

VENV="${ROOT}/.venv-fleet"
PYTHON="${VENV}/bin/python"
PIP="${VENV}/bin/pip"

if [[ ! -x "$PYTHON" ]]; then
  echo "==> Creating ${VENV}"
  python3 -m venv "$VENV"
  "$PIP" install -q -r tool/fleet/requirements.txt
fi

echo "==> Building fleet/catalog.json"
"$PYTHON" tool/fleet/build_catalog.py

if command -v dart >/dev/null 2>&1; then
  echo "==> Verifying Freezed parse"
  dart run tool/fleet/verify_catalog_parse.dart
else
  echo "==> Skipping Dart verify (dart not on PATH)"
fi

echo "==> Done"
ls -la fleet/catalog.json fleet/catalog.meta.json
cat fleet/catalog.meta.json
