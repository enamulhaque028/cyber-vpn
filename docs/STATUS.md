# Status — Cyber VPN

**Last updated:** 20 August 2026  
**Repo:** `cyber-vpn` (new app). Turbo Secure is `flutter_vpn` — reference only.  
**Verdict:** OpenVPN client with kill switch, threat/stats/ping, **exit check**, **favorites/recents**, **session history**. **Not store-ready.** IAP deferred.

---

## Locked decisions (do not reopen unless the user says so)

- New app, new bundle IDs — not a reskin of Turbo Secure.
- Feature folders: `domain` / `data` / `presentation`. UI must not import Supabase, axevpn, or (later) RevenueCat/AdMob.
- State: **flutter_bloc** (`Bloc` for tunnel/locations/purchases/minutes; `Cubit` for tiny UI like theme).
- Models + Bloc events/states: **Freezed**. JSON: **json_serializable**.
- DI: **GetIt**, manual registration in `lib/app/di.dart`. **No Injectable.**
- Navigation: **auto_route**.
- Theme: light **and** dark; default `ThemeMode.system`; Settings override.
- Tunnel plugin: **axevpn_flutter** (OpenVPN). Wrap in `TunnelRepository`.
- MVP servers: **same Supabase OpenVPN fleet as Turbo Secure**. Fleet/WireGuard is a later project.
- Monetization model (plan): freemium + rewarded minutes + soft paywall + subscriptions. Not a hard lock on first open. **Implementation deferred** until tunnel/product slices below IAP.
- Forbidden: UXCam, `badCertificateCallback: true`, unused `.ovpn` private keys in the binary, logging destination IPs/DNS/payloads.

---

## Done

Shipped behavior with details: **[FEATURES.md](FEATURES.md)**.

### Product / UX (thin)

- Splash → privacy declaration → Home.
- Home: Protect ring, threat banner, stats ticker, location row, Check connection, Go Premium.
- Locations: All / Favorites / Recent tabs, search on All, flags, premium → paywall route, ping bars.
- Connection: HTTPS exit IP / city / country / ISP (`ipwho.is`; Freezed response DTO).
- History: on-device sessions with summary, 7-day chart, relative bars (Settings).
- Settings: theme, kill switch, Android Always-on / iOS stay-protected, history + connection links.
- Paywall: static $39.99 / $9.99. No store.

### Engineering

- Flutter app `cyber_vpn`, Android `com.cybervpn.cyber_vpn` (minSdk 24), iOS `com.cybervpn.cyberVpn`.
- GetIt + BlocProvider at app root.
- `LocationsRepository` → Supabase `vpn_config` / `vpn_servers`, memory + SharedPreferences cache; `forceRefresh` on connect timeout (one retry, then “try another location”).
- `TunnelRepository` → `OpenVPN` from `axevpn_flutter`. Home bootstraps `SessionBloc` from current locations (not only later emissions).
- Kill switch (best-effort OpenVPN): `OpenVpnKillSwitch` patches client config with `persist-tun`, `persist-key`, `ping` / `ping-restart`, `block-ipv6` when enabled. Unexpected drop or path change while Protect is intended → backoff reconnect (max 5). User disconnect does not reconnect.
- Android: VPN permission `onActivityResult`, `extractNativeLibs`, 16 KB page-size flags, JNI `pickFirst` for WireGuard `.so` clash, `OpenVPNService` + `VpnService` intent-filter, Always-on row via MethodChannel `com.cybervpn.cyber_vpn/device` (VPN settings + fallbacks; `<queries>` for API 30+).
- iOS: Packet Tunnel `tunPersist = true`; OpenVPNAdapter reconnects on Wi‑Fi **or** cellular path (not Wi‑Fi only). App Group `group.com.cybervpn.cyberVpn`. SPM **off**.
- Threat banner: `NetworkKind` from `connectivity_plus` (Wi‑Fi = untrusted, cellular, none). No SSID. Copy changes when `SessionPhase.protected`.
- Stats ticker: OpenVPN byte counters → rates in `SessionBloc`; Home `StatsTicker`. Values are volume/rate only, not destinations.
- Ping: `OpenVpnRemote.first` + `TcpServerProbe` (prefer TCP remote, else try 443; timeout ~1.8s, concurrency 4). Failed probe = empty bar, not an IP.
- Exit check: `ExitIpApi` (Dio + Retrofit) → `https://ipwho.is/` only; `IpWhoIsExitIpRepository` maps `IpWhoIsResponse` → `ExitInfo`. Shown on Connection page; not persisted.
- Favorites / recents: location IDs in SharedPreferences; Locations **tabs** (All flat list; Favorites / Recent filtered).
- Session history: `PrefsSessionHistoryRepository` (max 50); recorded when a protected session ends (≥3s) with byte deltas finished before counters clear; History UI uses `fl_chart`.
- No UXCam. No global TLS bypass.

### Identifiers

| Item | Value |
|------|--------|
| App name | Cyber VPN |
| iOS bundle | `com.cybervpn.cyberVpn` |
| iOS extension | `com.cybervpn.cyberVpn.VPNExtension` |
| App Group | `group.com.cybervpn.cyberVpn` |
| Android applicationId | `com.cybervpn.cyber_vpn` |
| Supabase | URL/key in `lib/core/config/app_config.dart` (same project as Turbo) |
| Privacy / terms | Still Turbo Secure Google Sites URLs — replace before store |

---

## Not done (MVP from PROJECT_PLAN §10)

Money loop is **deferred**. Next agent should continue **retention / product**, then return to P0 money.

### Next — retention / product (do this now)

1. Connection polish: `PremiumGate` widget (UI only until IAP), goldens for Home / Paywall / Locations × light × dark.
2. `bloc_test` for Session / Locations / History / Exit check.
3. Tier B from [FEATURES.md — Enrichment roadmap](FEATURES.md#enrichment-roadmap-same-doc): widget, auto best-ping, Android split tunnel (later).

### P0 — money loop (later, owner request)

4. **`subscription` feature:** RevenueCat, `SubscriptionBloc`, restore, monthly $9.99, annual $39.99 default CTA, 7-day trial on annual only. Home/Locations never import the store SDK.
5. **Contextual soft paywall:** minutes exhausted; tap premium city; after 3 successful protects. Large dismiss. No fake countdown.
6. **`minutes` feature:** free daily cap **or** rewarded +30 min (plan §6).
7. **Ads:** rewarded for minutes; banners on **non-connect** screens only. UMP if EEA.
8. Wire paywall/minutes into `SessionBloc` so free users cannot use all premium cities.

### P1 — store / trust

9. Apple Developer: App Group + Packet Tunnel on both App IDs (portal work; project is already wired).
10. Apple 5.4 declaration on-screen before tunnel **and** before IAP. `PrivacyInfo.xcprivacy`. Play Data safety. Honest privacy/terms (not mismatched Sites pages).
11. Crashlytics + first-party connect success / time-to-protected. **No** destination IPs, DNS, payloads. No session replay.
12. Replace Turbo privacy/terms URLs; org App Store account if not already.
13. In-app review **once** after N successful protects (do not reset on splash).

### Protection layers (what each control does)

Real-life examples: **[FEATURES.md — Kill switch vs Always-on](FEATURES.md#kill-switch-vs-always-on-real-life)**.

| Control | Where | If on | Real-life |
|---------|--------|--------|-----------|
| In-app kill switch | Settings, default on | Sticky OpenVPN + reconnect if Protect was on and the tunnel dies. User disconnect stays off. | Hotel Wi‑Fi blip → app reconnects. You tap Protect off → stays off. **Can still leak for a second.** |
| Auto-reconnect | While Protect is on | Retry same city on path change / drop (max 5). | Leave café Wi‑Fi, LTE kicks in → tries same city. |
| Always-on VPN | Android **system** profile | OS keeps this VPN running (swipe/reboot). Protect off usually **comes back**. | Swipe app away → VPN returns. Want it off? Turn Always-on off first. |
| Block connections without VPN | Same system screen | No app internet while tunnel is down. | Blip → Instagram has **no** internet until VPN is back. Real leak block. |

Do not claim “military-grade kill switch.” iOS On Demand / `includeAllNetworks` from the app VPN manager is **V1**. Extension already persists TUN and reconnects on path.

### Explicitly later (do not build unless asked)

- **V1:** Superwall, split tunnel, widget, accounts + 5 devices + deletion, iOS On Demand, referral.
- **V2:** new fleet, WireGuard default, per-device keys, drop shared password + client `.ovpn` warehouse, audit, dedicated IP.

---

## How to run

```bash
cd /Users/sabrinaakter/development/flutter/cyber-vpn
flutter pub get
dart run build_runner build
flutter run
```

After changing Freezed / routes / JSON: `dart run build_runner build`.

Android hard kill switch: in-app Settings → Always-on VPN → Cyber VPN profile → Always-on **and** Block connections without VPN. To disconnect by Protect, turn Always-on off first.

---

## Definition of “ready to ship”

Not a prettier OpenVPN wrapper. Ready means: real IAP + restore, free limiter (minutes) + rewarded bridge, compliant ads, working kill switch, 5.4/Play disclosures, Crashlytics, and connect on the current fleet without TLS bypass. See PROJECT_PLAN §6 and §10.
