#!/usr/bin/env python3
"""Build fleet/catalog.json from vpnbook + curated VPN Gate entries."""

from __future__ import annotations

import base64
import csv
import gzip
import hashlib
import io
import json
import os
import re
import shutil
import socket
import sys
import time
from datetime import date, datetime, timezone
from zoneinfo import ZoneInfo
from pathlib import Path
from typing import Any
from urllib.parse import urlencode

import geoip2.database
import geoip2.errors
import requests

ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "fleet"
CATALOG_PATH = OUT_DIR / "catalog.json"
META_PATH = OUT_DIR / "catalog.meta.json"
BD_TZ = ZoneInfo("Asia/Dhaka")


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
# No hard cap: keep every valid Gate relay (TCP + UDP when both exist).
# Soft safety only if the public list ever explodes in size.
VPNGATE_SOFT_MAX = 300

FLEET_DIR = Path(__file__).resolve().parent
DBIP_CACHE_DIR = FLEET_DIR / ".cache"
DBIP_MMD_PATH = DBIP_CACHE_DIR / "dbip-city-lite.mmdb"
DBIP_URL = "https://download.db-ip.com/free/dbip-city-lite-{month}.mmdb.gz"
# DB-IP City Lite — CC BY 4.0; attribute in docs/FLEET_CATALOG.md.
DBIP_ATTRIBUTION = "IP Geolocation by DB-IP (https://db-ip.com)"

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

# State/province fallback when DNS or GeoIP lookup fails (10 vpnbook hosts).
REGION_BY_SLUG = {
    "us16": "Virginia",
    "us178": "Oregon",
    "ca149": "Quebec",
    "ca196": "Quebec",
    "uk205": "England",
    "uk68": "England",
    "de20": "Hesse",
    "de220": "Hesse",
    "fr200": "Hauts-de-France",
    "fr2311": "Hauts-de-France",
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

# Normalized transport for catalog `protocol` field.
PROTO_TRANSPORT = {
    "tcp80": "tcp",
    "tcp443": "tcp",
    "udp53": "udp",
    "udp25000": "udp",
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


def vpnbook_geo_for_host(
    hostname: str,
    country_short: str,
    reader: geoip2.database.Reader | None,
) -> tuple[str, float | None, float | None]:
    """Region + lat/lng from DB-IP on resolved hostname IP; static region fallback."""
    slug = hostname.split(".")[0].lower()
    fallback = REGION_BY_SLUG.get(slug, "")
    if reader is None:
        return fallback, None, None
    expected = (country_short or "").upper()
    try:
        ip = socket.gethostbyname(hostname)
    except OSError:
        return fallback, None, None
    geo = lookup_ip_geo(reader, ip)
    if not geo:
        return fallback, None, None
    lat = geo.get("lat")
    lng = geo.get("lng")
    if expected and geo.get("country_code") == expected and geo.get("region"):
        return geo["region"], lat, lng
    return fallback, lat, lng


def build_vpnbook_servers(html: str) -> list[dict[str, Any]]:
    """One catalog row per host × protocol (10 hosts × 4 protocols = 40)."""
    hosts = parse_vpnbook_hosts(html)
    geo_by_host: dict[str, tuple[str, float | None, float | None]] = {}
    db_path = ensure_dbip_database()
    if db_path is not None:
        with geoip2.database.Reader(str(db_path)) as reader:
            for _label, hostname in hosts:
                _country, _city, short = country_from_host(hostname)
                geo_by_host[hostname] = vpnbook_geo_for_host(
                    hostname, short, reader
                )
    else:
        for _label, hostname in hosts:
            slug = hostname.split(".")[0].lower()
            geo_by_host[hostname] = (REGION_BY_SLUG.get(slug, ""), None, None)

    servers: list[dict[str, Any]] = []
    for _label, hostname in hosts:
        country, city, short = country_from_host(hostname)
        slug = hostname.split(".")[0]
        region, lat, lng = geo_by_host.get(hostname, ("", None, None))
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
            row: dict[str, Any] = {
                "id": stable_id("vpnbook", f"{hostname}:{proto}"),
                "country": country,
                "region": region,
                "city": city_label,
                "title": title,
                "flagUrl": flag_url(short),
                "config": config,
                "isPremium": False,
                "source": "vpnbook",
                "protocol": PROTO_TRANSPORT[proto],
            }
            if lat is not None and lng is not None:
                row["lat"] = lat
                row["lng"] = lng
            servers.append(row)
            time.sleep(0.12)
    return servers


def detect_ovpn_protocol(config: str) -> str:
    """Return tcp|udp from the active `proto` line (ignore comments)."""
    for line in config.splitlines():
        s = line.strip().lower()
        if not s or s.startswith("#"):
            continue
        if s.startswith("proto "):
            if "udp" in s:
                return "udp"
            if "tcp" in s:
                return "tcp"
    return "unknown"


def gate_city_label(host_name: str, ip: str, protocol: str) -> str:
    """Human list label — Gate has no real city; use protocol + short id."""
    proto_label = "TCP" if protocol == "tcp" else "UDP"
    host = (host_name or "").strip()
    if host.startswith("public-vpn-"):
        short = host  # e.g. public-vpn-257
    else:
        parts = ip.split(".")
        # Avoid raw vpn######## hostnames; last two IPv4 octets are stable enough.
        short = ".".join(parts[-2:]) if len(parts) == 4 else (host[:18] or ip)
    return f"{proto_label} · {short}"


def gate_region(country_short: str, operator: str) -> str:
    """Fallback region when GeoIP is unavailable or country mismatches."""
    code = (country_short or "").strip().upper()
    op = (operator or "").strip()
    if "_" in op:
        op = op.split("_", 1)[0].strip()
    for noise in ("'s owner", "’s owner", " owner"):
        if op.lower().endswith(noise.strip().lower()):
            op = op[: -len(noise)].strip()
            break
    if len(op) > 40:
        op = op[:37].rstrip() + "…"
    if code and op:
        return f"{code} · {op}"
    return code or op


def dbip_month_candidates(today: date | None = None) -> list[str]:
    """Current month then previous — DB-IP publishes monthly."""
    today = today or date.today()
    months = [today.strftime("%Y-%m")]
    if today.month == 1:
        months.append(f"{today.year - 1}-12")
    else:
        months.append(f"{today.year:04d}-{today.month - 1:02d}")
    return months


def ensure_dbip_database() -> Path | None:
    """Download DB-IP City Lite MMDB if missing; return path or None on failure."""
    if DBIP_MMD_PATH.exists() and DBIP_MMD_PATH.stat().st_size > 1_000_000:
        return DBIP_MMD_PATH

    DBIP_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    gz_path = DBIP_MMD_PATH.with_suffix(".mmdb.gz")
    for month in dbip_month_candidates():
        url = DBIP_URL.format(month=month)
        try:
            print(f"  downloading DB-IP City Lite ({month})…", file=sys.stderr)
            with SESSION.get(url, timeout=180, stream=True) as resp:
                resp.raise_for_status()
                with open(gz_path, "wb") as out:
                    shutil.copyfileobj(resp.raw, out)
            if gz_path.stat().st_size < 1_000_000:
                raise RuntimeError("download too small")
            with gzip.open(gz_path, "rb") as src, open(DBIP_MMD_PATH, "wb") as dst:
                shutil.copyfileobj(src, dst)
            gz_path.unlink(missing_ok=True)
            print(f"  DB-IP ready ({DBIP_MMD_PATH.stat().st_size // 1_048_576} MiB)", file=sys.stderr)
            return DBIP_MMD_PATH
        except (OSError, requests.RequestException, RuntimeError) as exc:
            print(f"warn: DB-IP fetch failed ({month}): {exc}", file=sys.stderr)
            gz_path.unlink(missing_ok=True)
            DBIP_MMD_PATH.unlink(missing_ok=True)
    return None


def lookup_ip_geo(reader: geoip2.database.Reader, ip: str) -> dict[str, Any] | None:
    try:
        rec = reader.city(ip)
    except geoip2.errors.AddressNotFoundError:
        return None
    region = ""
    if rec.subdivisions:
        region = rec.subdivisions.most_specific.name or ""
    city = rec.city.name if rec.city else ""
    lat = rec.location.latitude if rec.location else None
    lng = rec.location.longitude if rec.location else None
    out: dict[str, Any] = {
        "country_code": (rec.country.iso_code or "").upper(),
        "country_name": rec.country.name or "",
        "region": region.strip(),
        "city": city.strip(),
    }
    if lat is not None and lng is not None:
        out["lat"] = float(lat)
        out["lng"] = float(lng)
    return out


def parse_gate_message(message: str) -> tuple[str, str]:
    """Volunteer Message field sometimes names a prefecture/region."""
    msg = (message or "").strip()
    if not msg:
        return "", ""
    m = re.search(r"Japan_([A-Za-z][A-Za-z\s-]+(?:Prefecture|Pref\.?))", msg, re.I)
    if m:
        return m.group(1).strip().rstrip("."), ""
    m = re.search(r"([A-Za-z][A-Za-z\s-]+ Prefecture)", msg, re.I)
    if m:
        return m.group(1).strip(), ""
    return "", ""


def resolve_gate_labels(
    *,
    ip: str,
    country_short: str,
    operator: str,
    message: str,
    host_label: str,
    protocol: str,
    geo: dict[str, str] | None,
) -> tuple[str, str]:
    """GeoIP-enriched labels when country matches Gate; else protocol · id fallback."""
    gate_cc = (country_short or "").strip().upper()
    msg_region, msg_city = parse_gate_message(message)
    proto_label = "TCP" if protocol == "tcp" else "UDP"

    if (
        geo
        and gate_cc
        and gate_cc != "ZZ"
        and geo.get("country_code") == gate_cc
    ):
        region = msg_region or geo.get("region") or gate_cc
        city_base = msg_city or geo.get("city") or ""
        if city_base:
            city = f"{city_base} · {proto_label}"
        else:
            city = gate_city_label(host_label, ip, protocol)
        return region, city

    return gate_region(country_short, operator), gate_city_label(host_label, ip, protocol)


def build_vpngate_servers() -> list[dict[str, Any]]:
    """All valid Gate relays; keep both TCP and UDP when present."""
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

    lines = [
        ln
        for ln in raw.splitlines()
        if ln and not ln.startswith("*") and not ln.startswith("#")
    ]
    if not lines:
        print("warn: VPN Gate CSV empty", file=sys.stderr)
        return []

    reader = csv.reader(io.StringIO("\n".join(lines)))
    # Best row per (ip, protocol): highest Score.
    best: dict[tuple[str, str], dict[str, Any]] = {}
    for row in reader:
        if len(row) < 15:
            continue
        host_name = row[0]
        ip = row[1]
        score_s = row[2]
        country_long = row[5]
        country_short = row[6]
        operator = row[12] if len(row) > 12 else ""
        message = row[13] if len(row) > 13 else ""
        b64 = row[14]
        if not b64 or not ip:
            continue
        try:
            config = base64.b64decode(b64).decode("utf-8", errors="replace").strip()
        except Exception:
            continue
        if "client" not in config or "remote " not in config:
            continue
        protocol = detect_ovpn_protocol(config)
        if protocol not in ("tcp", "udp"):
            continue
        try:
            score = int(float(score_s))
        except ValueError:
            score = 0
        key = (ip, protocol)
        prev = best.get(key)
        if prev is not None and prev["_score"] >= score:
            continue
        host_label = host_name or ip
        best[key] = {
            "id": 0,
            "country": country_long or "Unknown",
            "region": "",
            "city": "",
            "title": f"vpngate-{host_label}-{protocol}",
            "flagUrl": flag_url(country_short),
            "config": config,
            "isPremium": False,
            "source": "vpngate",
            "protocol": protocol,
            "_score": score,
            "_key": f"{ip}:{host_label}:{protocol}",
            "_ip": ip,
            "_country_short": country_short,
            "_operator": operator,
            "_message": message,
            "_host_label": host_label,
        }

    preferred = sorted(best.values(), key=lambda r: r["_score"], reverse=True)
    if len(preferred) > VPNGATE_SOFT_MAX:
        print(
            f"warn: VPN Gate truncated {len(preferred)} → {VPNGATE_SOFT_MAX}",
            file=sys.stderr,
        )
        preferred = preferred[:VPNGATE_SOFT_MAX]

    geo_by_ip: dict[str, dict[str, Any] | None] = {}
    db_path = ensure_dbip_database()
    if db_path is not None:
        unique_ips = {r["_ip"] for r in preferred}
        with geoip2.database.Reader(str(db_path)) as reader:
            for ip in unique_ips:
                geo_by_ip[ip] = lookup_ip_geo(reader, ip)
        matched = 0
        for ip in unique_ips:
            geo = geo_by_ip.get(ip)
            if not geo:
                continue
            gate_cc = next(r["_country_short"] for r in preferred if r["_ip"] == ip).upper()
            if gate_cc and gate_cc != "ZZ" and geo["country_code"] == gate_cc:
                matched += 1
        print(
            f"  vpngate geo ({DBIP_ATTRIBUTION}): "
            f"{matched}/{len(unique_ips)} IPs country-matched",
            file=sys.stderr,
        )
    else:
        print("warn: DB-IP unavailable — Gate labels use protocol · id fallback", file=sys.stderr)

    out: list[dict[str, Any]] = []
    for row in preferred:
        ip = row.pop("_ip")
        country_short = row.pop("_country_short")
        operator = row.pop("_operator")
        message = row.pop("_message")
        host_label = row.pop("_host_label")
        region, city = resolve_gate_labels(
            ip=ip,
            country_short=country_short,
            operator=operator,
            message=message,
            host_label=host_label,
            protocol=row["protocol"],
            geo=geo_by_ip.get(ip),
        )
        row["region"] = region
        row["city"] = city
        geo = geo_by_ip.get(ip)
        if geo and geo.get("lat") is not None and geo.get("lng") is not None:
            row["lat"] = geo["lat"]
            row["lng"] = geo["lng"]
        key = row.pop("_key")
        row.pop("_score", None)
        row["id"] = stable_id("vpngate", key)
        out.append(row)

    countries = {r["country"] for r in out}
    print(
        f"  vpngate detail: {len(out)} configs "
        f"({sum(1 for r in out if r['protocol']=='tcp')} tcp / "
        f"{sum(1 for r in out if r['protocol']=='udp')} udp), "
        f"{len(countries)} countries",
        file=sys.stderr,
    )
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


def format_updated_at_bd(updated_at_utc: str) -> str:
    """Human-readable Asia/Dhaka time, e.g. 2026-08-21 02:38:12 PM BST."""
    dt = datetime.fromisoformat(updated_at_utc.replace("Z", "+00:00"))
    return dt.astimezone(BD_TZ).strftime("%Y-%m-%d %I:%M:%S %p BST")


def write_outputs(catalog: dict[str, Any]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(catalog, indent=2, ensure_ascii=False)
    CATALOG_PATH.write_text(payload + "\n", encoding="utf-8")
    digest = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    updated_at = catalog["updatedAt"]
    meta = {
        "updatedAt": updated_at,
        "updatedAtBd": format_updated_at_bd(updated_at),
        "serverCount": len(catalog["servers"]),
        "sha256": digest,
        "geoAttribution": DBIP_ATTRIBUTION,
    }
    META_PATH.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {CATALOG_PATH} ({len(catalog['servers'])} servers, sha256={digest[:12]}…)")
    print(f"  updatedAtBd: {meta['updatedAtBd']}")


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

    servers = vpnbook + vpngate  # vpnbook first, then VPN Gate
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
