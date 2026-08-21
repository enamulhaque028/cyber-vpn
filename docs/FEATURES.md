# Features — Cyber VPN

**Last updated:** 20 August 2026  
Source of truth for **what the app does today** and **what to enrich next**. Gaps / P0 money: [STATUS.md](STATUS.md). Full product vision: [PROJECT_PLAN.md](PROJECT_PLAN.md). Code layout: [ARCHITECTURE.md](ARCHITECTURE.md).

None of these log destination IPs, DNS queries, or payloads. Ping never shows a host.

**Positioning filter:** prove “I’m protected on this hotel/cafe Wi‑Fi.” Skip Meshnet, password manager, streaming guarantees, destination browsing logs.

---

## Onboarding

| Feature | Where | Details |
|---------|--------|---------|
| Splash | First screen | Short delay, then Home if privacy already accepted, else Privacy. Starts loading locations. |
| Privacy declaration | Before Home (first run) | Apple 5.4-style copy. Agree saved in prefs. Links to privacy/terms (still Turbo Secure Sites URLs). No ads. |

---

## Home

| Feature | Details |
|---------|---------|
| Protect ring | Tap to connect / disconnect the OpenVPN tunnel via `SessionBloc` → `TunnelRepository`. Connecting / Protected / idle. |
| Session bootstrap | Home starts the session from the **current** location list (splash often finishes fetch before Home mounts). |
| Location row | Shows selected city. Opens Locations. Premium cities are not connectable from here until IAP. |
| Check connection | Opens Connection screen (HTTPS exit check). Also in app bar info icon. |
| Go Premium | Opens static paywall (no store). |
| Reconnect copy | Under the ring while reconnecting after a drop. |

### Connection / exit check

| | |
|--|--|
| What | Shows public **exit** IP, city, country, ISP after Protect. |
| How | `ExitIpApi` (Dio + Retrofit) → `IpWhoIsExitIpRepository` → `https://ipwho.is/` (TLS). `ExitCheckCubit` on Connection page. User-triggered refresh. |
| Not | Never plain HTTP `ip-api`. Do not persist or log the IP to our backend. Fail soft if offline / not protected path. |

### Threat banner

| | |
|--|--|
| What | Copy that matches the **current path**: Wi‑Fi, cellular, or no internet. Changes to “Protected on…” when the tunnel is up. |
| How | `connectivity_plus` → `NetworkKind` on `SessionBloc`. Widget: `ThreatBanner`. |
| Not | Does **not** read SSID, captive-portal login, or “open vs password Wi‑Fi”. Wi‑Fi is treated as untrusted (cafe/hotel/campus). No extra location permission. |

### Stats ticker

| | |
|--|--|
| What | Uptime (`00:00:00`) plus ↓ / ↑ rates. Dimmed when not protected. |
| How | OpenVPN status callbacks send duration + byte in/out. `SessionBloc` turns byte **deltas** into rates (`traffic_format.dart`). Widget: `StatsTicker`. |
| Not | Not a speed test. Not destination traffic. Rates reset on disconnect. |

---

## Locations

| Feature | Details |
|---------|---------|
| List | Flag, city/country, Free vs Premium. Tabs: **All** / **Favorites** / **Recent**. |
| All | Flat searchable list (search by country, city, title). Star + ping on each row. |
| Favorites | Starred IDs only (SharedPreferences). Empty copy if none. |
| Recent | Last 5 free selections (when you pick a city). Own tab. |
| Premium tap | Opens paywall route (no purchase). |
| Free tap | Sets selected server, remembers recent, pops back. |

### Ping bar

| | |
|--|--|
| What | Small bar + `ms` (or `…` while loading, `—` if failed). No IP/hostname on screen. |
| When | After the **full server list loads** at app start (not when you open Locations). Search does not re-probe. |
| How many | **4 TCP probes in parallel**; next city starts when one finishes. |
| How ms is calculated | Parse `.ovpn` `remote` / `proto` (`OpenVpnRemote.first`). Prefer a TCP remote. `Stopwatch` around `Socket.connect(host, port)` (timeout 1.8s). Try TCP port, then 443, then listed port. First success = `ms`. Fail/timeout = `null`. **Not ICMP ping. Not tunnel speed.** |
| Code | `TcpServerProbe` → `LocationsBloc.rttMs[id]` → `PingBar`. |

---

## Settings

| Feature | Details |
|---------|---------|
| Appearance | System / Light / Dark. Persisted. Default system. |
| Kill switch | Default **on**. See **Kill switch vs Always-on** below. |
| Bypass selected apps (Android) | Exclude-list split tunnel. Conflicts with Block-without-VPN. See **Split tunnel**. |
| Auto-reconnect | While Protect is on: Wi‑Fi ↔ cellular or unexpected drop retries the **same** location. |
| Always-on VPN (Android) | System setting. See **Kill switch vs Always-on** below. |
| Block connections without VPN (Android) | System setting. See **Kill switch vs Always-on** below. Do not combine with app bypass. |
| Stay protected (iOS) | Copy only. Extension `tunPersist` + reconnect on Wi‑Fi or cellular. Full On Demand is later. |
| Usage history | Settings → Usage history. Summary chips, 7-day animated chart, session list with relative bars. Clearable. |
| Connection check | Settings shortcut to Connection page. |
| Legal | Privacy / Terms links. |

### Usage history

| | |
|--|--|
| What | After Protect then disconnect (sessions ≥ ~3s), store city, start/end, ↓/↑ byte totals. UI: totals + last-7-days bar chart (`fl_chart`) + per-session relative data bar. |
| How | `SessionHistoryRepository` in SharedPreferences (max 50). Written from `SessionBloc` when a protected session ends (byte deltas snapshotted **before** counters clear). |
| Not | Not browsing history. Not DNS. Not uploaded. Old rows recorded before the byte fix may still show 0 B. |

---

## Kill switch vs Always-on (real life)

Two different layers. The **in-app kill switch** is Cyber VPN trying to stay up. **Always-on / Block without VPN** is **Android** freezing traffic. Do not market the in-app switch as “no internet possible without VPN.”

### In-app kill switch (Settings, default on)

**What it does**

- Makes the OpenVPN client more sticky (`persist-tun`, `ping-restart`, `block-ipv6`).
- If you tapped Protect and the tunnel **dies on its own**, the app tries the **same city** again (up to 5 times).
- If **you** tap Protect to turn it off, it **stays off** (this switch does not fight you).

**Example — hotel Wi‑Fi blip**  
You are Protected. The hotel Wi‑Fi drops for two seconds, then comes back. Kill switch on: the app notices the drop and reconnects. You might see “Reconnecting…” then Protected again. Kill switch off: the tunnel can stay dead until you tap Protect yourself. For a moment, WhatsApp/Instagram may use the hotel Wi‑Fi **without** the VPN (leak).

**Example — you meant to turn VPN off**  
You tap Protect to disconnect so you can use banking that blocks VPNs. Kill switch does **not** turn it back on. That is correct.

**What it does *not* do**  
It cannot freeze the whole phone. Between drop and reconnect, some packets can still leave on Wi‑Fi/cellular. IPv6 block is best-effort on this OpenVPN stack.

### Always-on VPN (Android system screen)

**What it does**  
Android’s job: “Cyber VPN should be running whenever this phone has a network.” If the VPN process dies (app swipe, crash, reboot), **the OS starts it again**.

**Example — you swipe Cyber VPN away**  
Always-on **off:** VPN dies; you are on raw Wi‑Fi until you open the app.  
Always-on **on:** Android brings Cyber VPN back even if you did not open the app.

**Example — you tap Protect to disconnect**  
Always-on **on:** disconnect often **does not stick**. Android starts the tunnel again. To actually stay off: turn Always-on **off**, then tap Protect.

**Example — phone reboot**  
Always-on **on:** after unlock, Android tries to connect Cyber VPN again without you tapping Protect. Always-on **off:** VPN stays down until you open the app.

### Block connections without VPN (Android system screen)

**What it does**  
If the tunnel is **not** up, **no app gets internet** — not Chrome, not Play Store, not WhatsApp. That is the real leak block.

**Example — hotel Wi‑Fi blip, Always-on + Block both on**  
Tunnel drops. For those seconds: **nothing online**, including you. When Cyber VPN is back, apps work through the tunnel. No “oops, Instagram used hotel Wi‑Fi.”

**Example — you turn Protect off but leave Block on**  
You may have **no internet at all** until the VPN is up again (or you turn Block off). Annoying on purpose — that is the kill switch people mean when they say Nord/Express.

**Example — Always-on on, Block off**  
OS keeps trying to reconnect, but during the gap apps **can** use raw Wi‑Fi. Safer than nothing; not a hard block.

### What to turn on

| Goal | Do this |
|------|---------|
| Casual “keep trying if it drops” | In-app kill switch on (default). |
| VPN should survive swipe/reboot | Android Always-on on. |
| **No leak even for a second** (cafe/hotel) | Always-on **and** Block connections without VPN. |
| I want a normal on/off Protect button | Always-on **off** (and Block off), then use Protect. |

iOS has no Always-on sheet like this. The extension keeps TUN and reconnects on Wi‑Fi/cellular; full On Demand is later.

---

## Split tunnel / per-app VPN

**Status:** Android **exclude-list shipped**. Include-only / IP split / iOS per-app remain deferred.

### Shipped (Android)

| | |
|--|--|
| What | Settings → **Bypass selected apps** + **Choose apps**. Selected launchable packages skip the VPN while Protect is on. |
| How | Prefs (`prefsSplitTunnelEnabled`, `prefsBypassPackages`) → `SessionBloc` → `TunnelRepository.connect(bypassPackages:)` → `axevpn_flutter` `OpenVPN.connect` → native `addDisallowedApplication`. App list via MethodChannel `listLaunchableApps` (MAIN/LAUNCHER only; no `QUERY_ALL_PACKAGES`). |
| Reconnect | Toggle or list change while Protected disconnects and reconnects with the new list. |
| iOS | UI hidden. No consumer per-app VPN. |

### Conflict with Block connections without VPN

**Block** = no internet unless traffic is on this VPN. **Bypass** = some apps leave the VPN. Enabling bypass shows a warning; Always-on copy tells users not to use Block with bypass.

| User goal | Settings |
|-----------|----------|
| Cafe/hotel leak protection | Full tunnel + Always-on + **Block on**; **bypass off** |
| Bypass banking / local apps | Bypass on + apps chosen; **Block off** |

Bypassed apps on public Wi‑Fi are **unprotected by design**.

### Still deferred

| Mode | Why |
|------|-----|
| Include-only (“only these apps on VPN”) | Needs `axevpn_flutter` fork |
| IP / route split | We do not own `VpnService.Builder` |
| iOS per-app VPN | MDM/enterprise only — not App Store |

---

## Tunnel

| Feature | Details |
|---------|---------|
| Protocol | OpenVPN via `axevpn_flutter`, wrapped in `TunnelRepository`. |
| Servers | GitHub `fleet/catalog.json` via jsDelivr (+ raw GitHub fallback): vpnbook + curated VPN Gate. Cache: memory → SharedPreferences → network. Free Gate relays are volatile. |
| Connect timeout | First miss: refresh list and retry once. Second miss: “try another location.” |
| Android VPN permission | System VPN consent; `MainActivity` `requestCode` 24. |
| iOS | Packet Tunnel `VPNExtension`, App Group `group.com.cybervpn.cyberVpn`. |

---

## Paywall (stub)

| Feature | Details |
|---------|---------|
| UI | Annual **$39.99** (best value) and Monthly **$9.99**. |
| Store | None. No restore, no trial, no RevenueCat. |

---

## Explicitly not shipped yet

Subscriptions, minutes, ads, real IAP gate on premium cities, Crashlytics, honest privacy URLs, own WireGuard / first-party fleet hosting. Android **include-only** / IP split / iOS per-app VPN (exclude-list bypass is shipped — see above).

---

## Enrichment roadmap (same doc)

Keep enriching the product without becoming a Nord clone. Shipped Tier A items are documented above.

### Tier A — done or next

| Feature | Status | Why / privacy |
|---------|--------|----------------|
| Exit / connection check | **Shipped** | HTTPS only (`ipwho.is`). User-triggered. Do not log IP. Never plain HTTP ip-api. |
| Favorites + recents | **Shipped** | IDs only in SharedPreferences; Locations tabs (All / Favorites / Recent). |
| Session history | **Shipped** | On-device only. Charts + byte totals. No DNS/destinations. |
| PremiumGate + goldens | **Next** | UI lock only until RevenueCat. |

### Tier B — later

| Feature | Notes |
|---------|--------|
| **Android exclude-list split** | **Shipped** — Settings bypass + `bypassPackages`. See [Split tunnel](#split-tunnel--per-app-vpn). |
| Home widget | Later. |
| Auto best-ping | Later. |
| In-app review once | After N protects; do not reset on splash. |
| Protected / dropped notifications | Later. |

### Tier C / D

Store trust, Crashlytics; WireGuard/fleet = V2. No UXCam / TLS bypass / “military grade.”

**Deferred (do not promise):** Android include-only list, IP/route split, iOS consumer per-app VPN (MDM-only).

### Build order

Exit check → favorites/recents → session history → Android exclude bypass → **PremiumGate/goldens** → money loop when owner asks → remaining Tier B.
