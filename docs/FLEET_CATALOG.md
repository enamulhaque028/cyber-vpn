# Fleet catalog — GitHub + jsDelivr migration

**Date:** 21 August 2026  
**Status:** Implemented in the working tree (commit when ready). Supabase is no longer used for locations.

This doc records exactly what changed and what **you** need to do before the app can load locations from the CDN in production.

---

## Why

Locations used to come from Supabase tables `vpn_config` / `vpn_servers`. That path is replaced by:

1. A daily (or manual) GitHub Actions job that builds `fleet/catalog.json`
2. Public delivery via **jsDelivr**, with **raw GitHub** as fallback
3. The Flutter app fetching that JSON through `HttpLocationsRepository` (same `LocationsRepository` API → Blocs unchanged)

Own WireGuard / first-party fleet hosting is still out of scope.

---

## What was built

### 1. Catalog schema (`fleet/catalog.json`)

Single file, one HTTP GET for credentials + servers. Keys match existing Freezed models (`VpnCredentials` / `VpnLocation`) — camelCase, no model changes.

```json
{
  "version": 1,
  "updatedAt": "2026-08-21T06:00:51Z",
  "credentials": {
    "username": "vpnbook",
    "password": "…",
    "fastServerIndex": 0,
    "connectionTimeoutSeconds": 30
  },
  "servers": [
    {
      "id": 2023905441,
      "country": "United States",
      "region": "",
      "city": "US16",
      "title": "vpnbook-us16-tcp443",
      "flagUrl": "https://flagcdn.com/w80/us.png",
      "config": "<full .ovpn text>",
      "isPremium": false,
      "source": "vpnbook"
    }
  ]
}
```

- **Stable `id`s:** SHA-256 of `source:key` → 31-bit int (not array index), so favorites/recents survive refreshes.
- **`fleet/catalog.meta.json`:** `{ updatedAt, updatedAtBd, serverCount, sha256 }` for debugging only (app does not read it). `updatedAtBd` is Asia/Dhaka, e.g. `2026-08-21 02:38:12 PM BST`.
- Catalog is written **pretty-printed** (`indent=2`) for readability in git diffs.

### 2. Ingest script — `tool/fleet/build_catalog.py`

| Source | Behavior |
|--------|----------|
| **vpnbook** | Scrapes `https://www.vpnbook.com/freevpn/openvpn` for hosts + shared user/pass (or env secrets). For **each** of the 10 OpenVPN hosts, downloads all four published protocols via `GET /api/openvpn?hostname=…&protocol=` (`tcp80`, `tcp443`, `udp53`, `udp25000`) → **40** rows (same coverage as the old Supabase `vpn_servers` export). Titles like `US16-TCP443`. |
| **VPN Gate** | `GET http://www.vpngate.net/api/iphone/` (HTTPS fallback). Decode Base64 configs; skip empty; prefer TCP when both exist; dedupe by IP; sort by Score; keep top **40**. |

Merge order: **vpnbook first**, then VPN Gate. Job **fails if zero servers** (won’t publish an empty wipe).

Dependencies: `tool/fleet/requirements.txt` (`requests`).

Local verify helper: `dart run tool/fleet/verify_catalog_parse.dart` (parses with Freezed models).

### 3. GitHub Actions — `.github/workflows/fleet-catalog.yml`

- Triggers: `cron: 0 6 * * *` (06:00 UTC daily) + `workflow_dispatch`
- Permissions: `contents: write` (commit + push)
- Steps: checkout → Python 3.12 → `build_catalog.py` → commit `fleet/catalog.json` + `catalog.meta.json` if changed (`chore(fleet): refresh catalog [skip ci]`) → purge jsDelivr
- Optional secrets: `VPNBOOK_USERNAME`, `VPNBOOK_PASSWORD` (if unset, script scrapes the free page)

### 4. App — `HttpLocationsRepository`

| Item | Detail |
|------|--------|
| File | `lib/features/locations/data/http_locations_repository.dart` |
| DI | `lib/app/di.dart` registers it as `LocationsRepository` |
| URLs | `AppConfig.fleetCatalogUrl` (jsDelivr) → `AppConfig.fleetCatalogFallbackUrl` (raw) |
| Cache | Memory → SharedPreferences (`cached_vpn_config` / `cached_vpn_servers`) → network |
| Fetch | One shared in-flight load for both `getCredentials` and `getLocations` |
| Failure | Fall back to memory/prefs; rethrow only if nothing cached |
| Empty servers | Do **not** overwrite prefs server cache |
| Timeout | ~12s connect / ~15s receive; optional `If-None-Match` / 304 |
| Blocs | Unchanged (`forceRefresh` on connect timeout still works) |

### 5. Supabase removed

| Removed / changed | Notes |
|-------------------|--------|
| `supabase_flutter` | Dropped from `pubspec.yaml` |
| `Supabase.initialize` | Removed from `lib/main.dart` |
| `supabaseUrl` / `supabaseAnonKey` | Removed from `AppConfig` |
| `supabase_locations_repository.dart` | Deleted |

### 6. Docs updated

`STATUS.md`, `ARCHITECTURE.md`, `FEATURES.md` now describe the GitHub catalog control plane (not Supabase).

### 7. Seed catalog in repo

A first `fleet/catalog.json` was generated locally with **10 vpnbook** servers. **VPN Gate timed out** from this machine; expect Gate rows after CI runs on GitHub (or when the API is reachable locally).

---

## How the runtime path works

```
GitHub Actions (daily)
  → build_catalog.py
  → commit fleet/catalog.json on main
  → purge.jsdelivr.net/.../fleet/catalog.json

App cold start
  → memory / prefs (if any)
  → GET cdn.jsdelivr.net/gh/<owner>/<repo>@main/fleet/catalog.json
  → on failure: raw.githubusercontent.com/.../main/fleet/catalog.json
  → write prefs for offline / CDN blips
```

Current slug in code:

```dart
AppConfig.fleetGithubSlug = 'enamulhaque028/cyber-vpn';
```

jsDelivr URL:

`https://cdn.jsdelivr.net/gh/enamulhaque028/cyber-vpn@main/fleet/catalog.json`

---

## What you need to do next

Do these in order. Until the catalog is on GitHub `main` under the same slug as `AppConfig.fleetGithubSlug`, the CDN/raw URLs will 404 and the app will only work from a previously cached prefs snapshot (or fail on a clean install).

### 1. Confirm GitHub repo slug

Remote should be `enamulhaque028/cyber-vpn` (matches `AppConfig.fleetGithubSlug`). Check:

```bash
git remote -v
```

- If the remote owner/repo differs, update `AppConfig.fleetGithubSlug` in `lib/core/config/app_config.dart` to match exactly (jsDelivr and raw URLs use it).

### 2. Add / fix the remote and push

```bash
# example — use your real URL
git remote add origin git@github.com:OWNER/REPO.git
git add -A   # or stage the fleet migration files intentionally
git commit -m "…"   # when you are ready to commit
git push -u origin HEAD
```

Ensure `fleet/catalog.json`, the workflow, tool scripts, and app changes are on **`main`** (or change the URLs from `@main` if you use another default branch).

### 3. Enable the workflow

1. On GitHub: **Actions** → allow workflows if prompted.
2. Open **Fleet catalog** → **Run workflow** once (`workflow_dispatch`).
3. Confirm the job:
   - Builds without “zero servers”
   - Commits updated `fleet/catalog.json` if Gate/vpnbook data changed
   - Purge step runs (non-fatal if purge returns an error)

### 4. Optional: vpnbook secrets

In the repo: **Settings → Secrets and variables → Actions**

| Secret | Purpose |
|--------|---------|
| `VPNBOOK_USERNAME` | Prefer over scraping (usually `vpnbook`) |
| `VPNBOOK_PASSWORD` | Prefer over scraping (rotates on their site) |

If omitted, CI scrapes the free OpenVPN page. Secrets are more reliable when the page HTML changes.

### 5. Smoke-test the published URLs

After push + successful workflow:

```bash
curl -sI "https://cdn.jsdelivr.net/gh/OWNER/REPO@main/fleet/catalog.json"
curl -sI "https://raw.githubusercontent.com/OWNER/REPO/main/fleet/catalog.json"
```

Both should be **200**. Then cold-start the app on a device/emulator with no old prefs and confirm Locations load.

### 6. Device checks (recommended)

1. **Cold start** — locations list appears without Supabase.
2. **Airplane mode** (second launch) — list still loads from prefs.
3. **Connect timeout path** — `forceRefresh: true` still retries against the network.
4. **Favorites/recents** — still resolve after a catalog refresh (stable IDs).
5. **Connect** — one vpnbook entry and, when present, one VPN Gate entry.

### 7. Local rebuild (optional)

```bash
python3 -m venv .venv-fleet
.venv-fleet/bin/pip install -r tool/fleet/requirements.txt
.venv-fleet/bin/python tool/fleet/build_catalog.py
dart run tool/fleet/verify_catalog_parse.dart
```

VPN Gate may still time out on some networks; that is OK if CI can reach it.

---

## Files touched (checklist)

| Path | Role |
|------|------|
| `fleet/catalog.json` | Published server list + credentials |
| `fleet/catalog.meta.json` | Build metadata |
| `tool/fleet/build_catalog.py` | Ingest |
| `tool/fleet/requirements.txt` | Python deps |
| `tool/fleet/verify_catalog_parse.dart` | Parse smoke test |
| `.github/workflows/fleet-catalog.yml` | Daily / manual publish |
| `lib/features/locations/data/http_locations_repository.dart` | App fetch + cache |
| `lib/app/di.dart` | DI swap |
| `lib/main.dart` | No Supabase init |
| `lib/core/config/app_config.dart` | Fleet URLs; Supabase keys gone |
| `pubspec.yaml` | `supabase_flutter` removed |
| `docs/STATUS.md` / `ARCHITECTURE.md` / `FEATURES.md` | Product docs |

Deleted: `lib/features/locations/data/supabase_locations_repository.dart`

---

## Risks / notes

- **Catalog is public** (shared free VPN credentials + `.ovpn` blobs). Same class of exposure as the old public Supabase anon read.
- **VPN Gate** exits are community relays: volatile, uneven quality, and sometimes blocked from certain networks.
- **jsDelivr branch cache** can be sticky; the workflow purges after each successful publish. Raw GitHub is the app’s safety net.
- Do **not** treat this as a first-party VPN network. Own WireGuard fleet remains a later project.
- **Cache refresh (deferred):** App keeps prefs until connect-timeout `forceRefresh` or data clear — CDN updates are not picked up automatically. Tracked under STATUS → Explicitly later.
