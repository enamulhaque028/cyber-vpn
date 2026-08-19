# Status — Cyber VPN

**Last updated:** 19 August 2026  
**Repo:** `cyber-vpn` (new app). Turbo Secure is `flutter_vpn` — reference only.  
**Verdict:** Architecture + OpenVPN client with **kill switch / reconnect**. **Not store-ready.** IAP / minutes / ads **deferred** (owner: after remaining product features).

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

### Product / UX (thin)

- Splash → privacy declaration → Home.
- Home: connect ring, duration, location row, threat **copy** (static, not real Wi‑Fi detect). Reconnect copy under the ring when the tunnel drops.
- Locations: search, flags, premium → paywall **route** (no purchase).
- Settings: System / Light / Dark; **kill switch toggle** (default on); Android **Always-on VPN** row opens the **system** Cyber VPN profile (Always-on + Block connections without VPN). iOS stay-protected copy.
- Paywall page: static Annual $39.99 / Monthly $9.99 cards. No store, no restore, no trial.

### Engineering

- Flutter app `cyber_vpn`, Android `com.cybervpn.cyber_vpn` (minSdk 24), iOS `com.cybervpn.cyberVpn`.
- GetIt + BlocProvider at app root.
- `LocationsRepository` → Supabase `vpn_config` / `vpn_servers`, memory + SharedPreferences cache; `forceRefresh` on connect timeout (one retry, then “try another location”).
- `TunnelRepository` → `OpenVPN` from `axevpn_flutter`. Home bootstraps `SessionBloc` from current locations (not only later emissions).
- Kill switch (best-effort OpenVPN): `OpenVpnKillSwitch` patches client config with `persist-tun`, `persist-key`, `ping` / `ping-restart`, `block-ipv6` when enabled. Unexpected drop or path change while Protect is intended → backoff reconnect (max 5). User disconnect does not reconnect.
- Android: VPN permission `onActivityResult`, `extractNativeLibs`, 16 KB page-size flags, JNI `pickFirst` for WireGuard `.so` clash, `OpenVPNService` + `VpnService` intent-filter, Always-on row via MethodChannel `com.cybervpn.cyber_vpn/device` (VPN settings + fallbacks; `<queries>` for API 30+).
- iOS: Packet Tunnel `tunPersist = true`; OpenVPNAdapter reconnects on Wi‑Fi **or** cellular path (not Wi‑Fi only). App Group `group.com.cybervpn.cyberVpn`. SPM **off**.
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

1. **Real threat banner** (untrusted Wi‑Fi), stats ticker (uptime already partial), ping bar on Locations.
2. Connection polish: `PremiumGate` widget (UI only until IAP), goldens for Home / Paywall / Locations × light × dark.
3. `bloc_test` for Session (kill switch / reconnect) / Locations.

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

| Control | Where | If on |
|---------|--------|--------|
| In-app kill switch | Settings, default on | Patch `.ovpn` (`persist-tun`, `ping-restart`, `block-ipv6`). If Protect is **intended** and the tunnel drops, app reconnects (max 5). User tap to disconnect does **not** auto-reconnect. |
| Auto-reconnect | Always while Protect is on | Wi‑Fi ↔ cellular or unexpected drop → retry same location. |
| Always-on VPN | Android **system** profile for Cyber VPN | System keeps this VPN running. **Tapping Protect to disconnect usually does not stick** — Android starts the tunnel again. Turn Always-on **off** first if the user wants a real disconnect. |
| Block connections without VPN | Same system screen | No app internet while the tunnel is down. Real leak block. Use with Always-on. |

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
