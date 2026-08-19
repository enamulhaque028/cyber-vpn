# Status — Cyber VPN

**Last updated:** 19 August 2026  
**Repo:** `cyber-vpn` (new app). Turbo Secure is `flutter_vpn` — reference only.  
**Verdict:** Architecture + OpenVPN client **shell**. **Not store-ready.** **Not the revenue product** in the plan.

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
- Monetization model (plan): freemium + rewarded minutes + soft paywall + subscriptions. Not a hard lock on first open.
- Forbidden: UXCam, `badCertificateCallback: true`, unused `.ovpn` private keys in the binary, logging destination IPs/DNS/payloads.

---

## Done

### Product / UX (thin)

- Splash → privacy declaration → Home.
- Home: connect ring, duration, location row, threat **copy** (static, not real Wi‑Fi detect).
- Locations: search, flags, premium → paywall **route** (no purchase).
- Settings: System / Light / Dark; kill switch **stub** (`Switch` disabled).
- Paywall page: static Annual $39.99 / Monthly $9.99 cards. No store, no restore, no trial.

### Engineering

- Flutter app `cyber_vpn`, Android `com.cybervpn.cyber_vpn` (minSdk 24), iOS `com.cybervpn.cyberVpn`.
- GetIt + BlocProvider at app root.
- `LocationsRepository` → Supabase `vpn_config` / `vpn_servers`, memory + SharedPreferences cache; `forceRefresh` on connect timeout (one retry, then “try another location”).
- `TunnelRepository` → `OpenVPN` from `axevpn_flutter`.
- Android: VPN permission `onActivityResult`, `extractNativeLibs`, 16 KB page-size flags.
- iOS: Packet Tunnel target `VPNExtension`, OpenVPNAdapter pod, App Group `group.com.cybervpn.cyberVpn`, extension id `com.cybervpn.cyberVpn.VPNExtension`, team `T8EJN9YNF9`. SPM **off** (plugin does not support it).
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

Ordered for **revenue × retention**. Next agent should start at **P0**.

### P0 — money loop (this is the gap vs Turbo)

1. **`subscription` feature:** RevenueCat (or current best IAP SDK if you re-evaluate), `SubscriptionBloc`, restore, monthly $9.99, annual $39.99 default CTA, 7-day trial on annual only. Home/Locations never import the store SDK.
2. **Contextual soft paywall:** minutes exhausted; tap premium city; after 3 successful protects. Large dismiss. No fake countdown.
3. **`minutes` feature:** free daily cap **or** rewarded +30 min (plan §6). App-defined minutes, not ad-geo tricks.
4. **Ads:** rewarded for minutes; banners on **non-connect** screens only. UMP if EEA.

### P0 — retention / tunnel product

5. **Kill switch** that actually blocks leak on drop (best-effort on OpenVPN); Settings copy for Android always-on.
6. Wire paywall/minutes into `SessionBloc` so free users cannot use all premium cities.

### P1 — store / trust

7. Apple Developer: App Group + Packet Tunnel on both App IDs (portal work; project is already wired).
8. Apple 5.4 declaration on-screen before tunnel **and** before IAP. `PrivacyInfo.xcprivacy`. Play Data safety. Honest privacy/terms (not mismatched Sites pages).
9. Crashlytics + first-party connect success / time-to-protected. **No** destination IPs, DNS, payloads. No session replay.
10. Replace Turbo privacy/terms URLs; org App Store account if not already.

### P1 — product polish from the plan

11. Real threat banner (untrusted Wi‑Fi), stats ticker, ping bar, `PremiumGate`, goldens for Home / Paywall / Locations × light × dark.
12. `bloc_test` for Session / Locations / Subscription / Minutes.
13. In-app review **once** after N successful protects (do not reset on splash).

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

---

## Definition of “ready to ship”

Not a prettier OpenVPN wrapper. Ready means: real IAP + restore, free limiter (minutes) + rewarded bridge, compliant ads, working kill switch, 5.4/Play disclosures, Crashlytics, and connect on the current fleet without TLS bypass. See PROJECT_PLAN §6 and §10.
