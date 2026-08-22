#!/usr/bin/env python3
"""Add lat/lng to an existing fleet/catalog.json using DB-IP (no full rebuild).

Uses the same MMDB as build_catalog.py. Extracts the first `remote` host from
each server's OpenVPN config, resolves DNS when needed, and writes coordinates
when GeoIP succeeds.
"""

from __future__ import annotations

import json
import socket
import sys
from pathlib import Path

import geoip2.database

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from build_catalog import (  # noqa: E402
    CATALOG_PATH,
    ensure_dbip_database,
    lookup_ip_geo,
    write_outputs,
)


def remote_host(config: str) -> str | None:
    for line in config.splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if s.lower().startswith("remote "):
            parts = s.split()
            if len(parts) >= 2:
                return parts[1]
    return None


def resolve_ip(host: str) -> str | None:
    host = host.strip()
    if not host:
        return None
    # Already an IPv4 literal.
    if all(p.isdigit() for p in host.split(".")) and host.count(".") == 3:
        return host
    try:
        return socket.gethostbyname(host)
    except OSError:
        return None


def main() -> int:
    if not CATALOG_PATH.exists():
        print(f"error: missing {CATALOG_PATH}", file=sys.stderr)
        return 1
    db_path = ensure_dbip_database()
    if db_path is None:
        print("error: DB-IP unavailable", file=sys.stderr)
        return 1

    catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    servers: list[dict] = catalog.get("servers") or []
    cache: dict[str, tuple[float, float] | None] = {}
    with_coords = 0

    with geoip2.database.Reader(str(db_path)) as reader:
        for row in servers:
            host = remote_host(row.get("config") or "")
            if not host:
                row.pop("lat", None)
                row.pop("lng", None)
                continue
            if host not in cache:
                ip = resolve_ip(host)
                if not ip:
                    cache[host] = None
                else:
                    geo = lookup_ip_geo(reader, ip)
                    if geo and geo.get("lat") is not None and geo.get("lng") is not None:
                        cache[host] = (float(geo["lat"]), float(geo["lng"]))
                    else:
                        cache[host] = None
            coords = cache[host]
            if coords is None:
                row.pop("lat", None)
                row.pop("lng", None)
                continue
            row["lat"], row["lng"] = coords
            with_coords += 1

    write_outputs(catalog)
    print(f"enriched {with_coords}/{len(servers)} servers with lat/lng")
    return 0


if __name__ == "__main__":
    sys.exit(main())
