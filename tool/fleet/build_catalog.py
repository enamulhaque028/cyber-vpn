#!/usr/bin/env python3
"""Build fleet/catalog.json from vpnbook + curated VPN Gate entries."""

from __future__ import annotations

import base64
import csv
import hashlib
import io
import json
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.parse import urlencode

import requests

ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "fleet"
CATALOG_PATH = OUT_DIR / "catalog.json"
META_PATH = OUT_DIR / "catalog.meta.json"

UA = (
    "Mozilla/5.0 (compatible; CyberVpnFleetBot/1.0; "
    "+https://github.com/cyber-vpn/fleet-catalog)"
)
SESSION = requests.Session()
SESSION.headers.update({"User-Agent": UA})

VPNBOOK_PAGE = "https://www.vpnbook.com/freevpn/openvpn"
VPNBOOK_API = "https://www.vpnbook.com/api/openvpn"
VPNBOOK_PROTOCOLS = ("tcp80", "tcp443", "udp53", "udp25000")  # all published variants
VPNGATE_URLS = (
    "http://www.vpngate.net/api/iphone/",
    "https://www.vpngate.net/api/iphone/",
)
VPNGATE_LIMIT = 40

COUNTRY_BY_PREFIX = {
    "us": ("USA", "us"),
    "ca": ("Canada", "ca"),
    "uk": ("UK", "gb"),
    "de": ("Germany", "de"),
    "fr": ("France", "fr"),
    "pl": ("Poland", "pl"),
}

# City labels aligned with the former Supabase vpn_servers export (per host).
CITY_BY_SLUG = {
    "us16": "Oakton",
    "us178": "Hillsboro",
    "ca149": "Beauharnois",
    "ca196": "Montreal",
    "uk205": "Newcastle-under-Lyme",
    "uk68": "London",
    "de20": "Limburg an der Lahn",
    "de220": "Limburg an der Lahn",
    "fr200": "Roubaix",
    "fr2311": "Roubaix",
}

# Title / city protocol labels (vpnbook UI + historical Supabase rows).
PROTO_TITLE = {
    "tcp80": "TCP80",
    "tcp443": "TCP443",
    "udp53": "UDP53",
    "udp25000": "UDP25000",
}
PROTO_CITY_LABEL = {
    "tcp80": "TCP 80",
    "tcp443": "TCP 443",
    "udp53": "UDP 53",
    "udp25000": "UDP 25000",
}


def stable_id(source: str, key: str) -> int:
    digest = hashlib.sha256(f"{source}:{key}".encode("utf-8")).hexdigest()
    return int(digest[:8], 16) & 0x7FFFFFFF


def flag_url(country_short: str) -> str:
    code = (country_short or "").strip().lower()
    if not code:
        return ""
    return f"https://flagcdn.com/w80/{code}.png"


def country_from_host(hostname: str) -> tuple[str, str, str]:
    host = hostname.lower().removesuffix(".vpnbook.com")
    m = re.match(r"^([a-z]+)", host)
    prefix = m.group(1) if m else ""
    country, short = COUNTRY_BY_PREFIX.get(prefix, ("Unknown", ""))
    city = CITY_BY_SLUG.get(host, host.upper())
    return country, city, short


def fetch_text(url: str, *, timeout: float = 60) -> str:
    r = SESSION.get(url, timeout=timeout)
    r.raise_for_status()
    return r.text


def parse_vpnbook_credentials(html: str) -> tuple[str, str]:
    codes = re.findall(
        r'uppercase tracking-wider text-gray-500">(?:Username|Password)</label>'
        r".*?<code[^>]*>([^<]+)</code>",
        html,
        flags=re.I | re.S,
    )
    if len(codes) >= 2:
        return codes[0].strip(), codes[1].strip()
    # Flight / RSC fallback
    m_user = re.search(
        r'Username.*?children\\":\\"([A-Za-z0-9_-]+)\\"',
        html,
        flags=re.I | re.S,
    )
    m_pass = re.search(
        r'Password.*?children\\":\\"([A-Za-z0-9_-]+)\\"',
        html,
        flags=re.I | re.S,
    )
    if m_user and m_pass:
        return m_user.group(1), m_pass.group(1)
    raise RuntimeError("Could not parse vpnbook credentials from free VPN page")


def parse_vpnbook_hosts(html: str) -> list[tuple[str, str]]:
    """Return (label, hostname) for OpenVPN servers."""
    pairs = re.findall(
        r">([^<]*Server[^<]*)</span>\s*<span[^>]*>([a-z0-9]+\.vpnbook\.com)</span>",
        html,
        flags=re.I,
    )
    seen: set[str] = set()
    out: list[tuple[str, str]] = []
    for label, host in pairs:
        host = host.lower()
        if host in seen or host.startswith("www."):
            continue
        seen.add(host)
        out.append((label.strip(), host))
    if not out:
        hosts = sorted(
            {
                h.lower()
                for h in re.findall(r"([a-z0-9]+\.vpnbook\.com)", html, flags=re.I)
                if not h.lower().startswith("www.")
            }
        )
        out = [(h.split(".")[0].upper(), h) for h in hosts]
    return out


def fetch_vpnbook_ovpn(hostname: str, protocol: str) -> str | None:
    qs = urlencode({"hostname": hostname, "protocol": protocol})
    url = f"{VPNBOOK_API}?{qs}"
    try:
        r = SESSION.get(url, timeout=45)
        if r.status_code != 200:
            return None
        text = r.text.strip()
        if "remote " not in text or "client" not in text:
            return None
        return text
    except requests.RequestException:
        return None


def build_vpnbook_servers(html: str) -> list[dict[str, Any]]:
    """One catalog row per host × protocol (10 hosts × 4 protocols = 40)."""
    servers: list[dict[str, Any]] = []
    for _label, hostname in parse_vpnbook_hosts(html):
        country, city, short = country_from_host(hostname)
        slug = hostname.split(".")[0]
        for proto in VPNBOOK_PROTOCOLS:
            config = fetch_vpnbook_ovpn(hostname, proto)
            if not config:
                print(
                    f"warn: skip vpnbook {hostname} {proto} (no config)",
                    file=sys.stderr,
                )
                continue
            title = f"{slug.upper()}-{PROTO_TITLE[proto]}"
            # List UI shows `city, country` — include host + protocol so rows
            # are unique (4 protos × shared metros like Roubaix / Limburg).
            city_label = (
                f"{city} ({slug.upper()}) · {PROTO_CITY_LABEL[proto]}"
            )
            servers.append(
                {
                    "id": stable_id("vpnbook", f"{hostname}:{proto}"),
                    "country": country,
                    "region": "",
                    "city": city_label,
                    "title": title,
                    "flagUrl": flag_url(short),
                    "config": config,
                    "networkFlagUrl": "",
                    "isPremium": False,
                }
            )
            time.sleep(0.12)
    return servers


def _prefer_tcp_config(rows_for_ip: list[dict[str, Any]]) -> dict[str, Any]:
    tcp = [r for r in rows_for_ip if "proto tcp" in r["config"].lower()]
    if tcp:
        return max(tcp, key=lambda r: r["_score"])
    return max(rows_for_ip, key=lambda r: r["_score"])


def build_vpngate_servers() -> list[dict[str, Any]]:
    raw = ""
    last_err: Exception | None = None
    for url in VPNGATE_URLS:
        try:
            raw = fetch_text(url, timeout=120)
            break
        except requests.RequestException as exc:
            last_err = exc
            print(f"warn: VPN Gate fetch failed ({url}): {exc}", file=sys.stderr)
    if not raw:
        if last_err is not None:
            print(f"warn: VPN Gate unavailable: {last_err}", file=sys.stderr)
        return []

    # Strip comment / footer lines; CSV body starts after header row.
    lines = [
        ln
        for ln in raw.splitlines()
        if ln and not ln.startswith("*") and not ln.startswith("#")
    ]
    if not lines:
        print("warn: VPN Gate CSV empty", file=sys.stderr)
        return []

    reader = csv.reader(io.StringIO("\n".join(lines)))
    by_ip: dict[str, list[dict[str, Any]]] = {}
    for row in reader:
        if len(row) < 15:
            continue
        host_name = row[0]
        ip = row[1]
        score_s = row[2]
        country_long = row[5]
        country_short = row[6]
        b64 = row[14]
        if not b64 or not ip:
            continue
        try:
            config = base64.b64decode(b64).decode("utf-8", errors="replace").strip()
        except Exception:
            continue
        if "client" not in config or "remote " not in config:
            continue
        try:
            score = int(float(score_s))
        except ValueError:
            score = 0
        entry = {
            "id": 0,  # set after prefer
            "country": country_long or "Unknown",
            "region": "",
            "city": host_name or ip,
            "title": f"vpngate-{host_name or ip}",
            "flagUrl": flag_url(country_short),
            "config": config,
            "networkFlagUrl": "",
            "isPremium": False,
            "_score": score,
            "_ip": ip,
            "_key": f"{ip}:{host_name}",
        }
        by_ip.setdefault(ip, []).append(entry)

    preferred = [_prefer_tcp_config(group) for group in by_ip.values()]
    preferred.sort(key=lambda r: r["_score"], reverse=True)
    out: list[dict[str, Any]] = []
    for row in preferred[:VPNGATE_LIMIT]:
        key = row.pop("_key")
        row.pop("_score", None)
        row.pop("_ip", None)
        row["id"] = stable_id("vpngate", key)
        out.append(row)
    return out


def load_credentials(html: str) -> dict[str, Any]:
    user = os.environ.get("VPNBOOK_USERNAME", "").strip()
    password = os.environ.get("VPNBOOK_PASSWORD", "").strip()
    if not user or not password:
        try:
            scraped_user, scraped_pass = parse_vpnbook_credentials(html)
            user = user or scraped_user
            password = password or scraped_pass
        except RuntimeError as exc:
            print(f"warn: {exc}", file=sys.stderr)
    return {
        "username": user,
        "password": password,
        "fastServerIndex": 0,
        "connectionTimeoutSeconds": 30,
    }


def write_outputs(catalog: dict[str, Any]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(catalog, separators=(",", ":"), ensure_ascii=False)
    CATALOG_PATH.write_text(payload + "\n", encoding="utf-8")
    digest = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    meta = {
        "updatedAt": catalog["updatedAt"],
        "serverCount": len(catalog["servers"]),
        "sha256": digest,
    }
    META_PATH.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {CATALOG_PATH} ({len(catalog['servers'])} servers, sha256={digest[:12]}…)")


def main() -> int:
    print("fetching vpnbook free OpenVPN page…")
    html = fetch_text(VPNBOOK_PAGE, timeout=60)
    credentials = load_credentials(html)
    if not credentials["username"] or not credentials["password"]:
        print(
            "warn: publishing empty credentials; VPN Gate configs may still connect",
            file=sys.stderr,
        )

    print("building vpnbook servers…")
    vpnbook = build_vpnbook_servers(html)
    print(f"  vpnbook: {len(vpnbook)}")

    print("building VPN Gate servers…")
    vpngate = build_vpngate_servers()
    print(f"  vpngate: {len(vpngate)}")

    servers = vpnbook + vpngate
    if not servers:
        print("error: zero servers — refusing to publish empty catalog", file=sys.stderr)
        return 1

    catalog = {
        "version": 1,
        "updatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "credentials": credentials,
        "servers": servers,
    }
    write_outputs(catalog)
    return 0


if __name__ == "__main__":
    sys.exit(main())
