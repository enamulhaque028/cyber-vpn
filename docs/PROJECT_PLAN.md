# Clearline — New VPN Product Plan

**Working name:** Clearline (placeholder). **Shipped working name in this repo:** Cyber VPN.  
**Status:** Product spec. Implementation lives in this repository (`cyber-vpn`). Progress: [STATUS.md](STATUS.md). Agent entry: [README.md](README.md).  
**Date:** August 2026  
**Related:** Turbo Secure VPN lives in a separate repo (`flutter_vpn`). Do not reskin that app.

**How to read this doc**

| Label | Meaning |
|-------|---------|
| **Fact** | True of this repository / shipped Turbo Secure VPN |
| **Research** | Public market, competitor, protocol, or store-policy sources (cited) |
| **Assumption** | Unverified number or business guess; must be tested |
| **Recommendation** | Proposed product, architecture, or roadmap for the *new* app |

This is **not** a reskin of Turbo Secure VPN. The existing app is analyzed as a baseline of what *not* to copy architecturally.

---

## 1. Goals

**Recommendation.** Optimize jointly for:

1. **Revenue** — subscriptions + compliant in-app ads, not traffic resale.
2. **Growth** — ASO and a usable free tier (organic loop), not only paid UA.
3. **Retention** — connect reliability, kill switch, always-on, honest pricing.
4. **Security** — per-device keys, modern protocol, no TLS bypass.
5. **User trust** — store-legal privacy, no session replay, no-logs with an audit path.

---

## 2. Existing product analysis (Turbo Secure VPN)

### 2.1 Product snapshot

**Fact.** App name `Turbo Secure VPN`; Dart package `openvpn_flutter_example`; version `1.3.0+38`; bundle `com.audacityitvpn.turboSecureVpn`. Stores: [Google Play](https://play.google.com/store/apps/details?id=com.audacityitvpn.turboSecureVpn), [App Store](https://apps.apple.com/us/app/turbo-secure-vpn-fast-proxy/id1659339197).

It is a **Flutter OpenVPN client** that loads shared credentials and `.ovpn` blobs from **Supabase**. It is **not** a first-party VPN network. Leftover VPNBook / FreeOpenVPN configs (including private keys) live in unused `lib/config/vpn_config.dart`. Runtime truth is whatever is in Supabase `vpn_servers`.

The BA doc still says version 1.2.9+33 and that Firebase is inactive. **Fact:** Firebase Analytics, Crashlytics (release), Performance, Messaging, and local notifications **are initialized** in the current tree.

### 2.2 Architecture

**Fact.**

- Feature folders under `lib/src/features/` (home, bookmark, premium_upgrade, ads, inhouse_ads, consent, splash, tab, settings, drawer, notification).
- State: Cubits only (`PremiumUpgradeCubit`, `VpnServerCubit`). Home still keeps parallel local `vpnInfo` / `vpnServerInfo`.
- Navigation: `MaterialApp(home: SplashPage)` then `Navigator.push`. `TabPage` Bookmark / Location / Menu **push a route or open the end drawer**; they are not real `IndexedStack` tabs. `_pages` is only `[HomePage]`.
- `SettingsPage` exists and is **orphaned** (no navigator callers).
- Boot (`lib/main.dart`): global `HttpOverrides` → Supabase init → RevenueCat → Firebase → portrait lock → Crashlytics (release) → Mobile Ads → `runApp`. UXCam starts in `MyApp.initState` (iOS).

### 2.3 VPN technology and connection flow

**Fact.**

- Protocol: **OpenVPN** via `openvpn_flutter`. iOS Network Extension packet-tunnel (`VPNExtension`, OpenVPNAdapter). Android tunnel via the plugin / `VpnService`.
- Connect: `_engine.connect(config, country, username:, password:, certIsRequired: true)` in `VpnService`.
- Credentials: first row of Supabase `vpn_config` → `VpnConfigModel` (username, password, `fastServerIndex`, defaults, `connectionTimeoutSeconds`).
- Servers: `vpn_servers` rows → `VpnServerModel` including full OpenVPN `config` string and `isPremium`.
- Cache (recent): memory + SharedPreferences (`cachedVpnConfig`, `cachedVpnServers`, `cachedInHouseAds`); refetch on connect **timeout** (`forceRefresh`).
- Timeout: first miss refreshes backend and retries once; second miss shows “Try another server”.
- Auto-connect: `connectVpnOnAppLaunch` pref; drawer toggle.
- Disconnect writes `serverLocationId = -1`, so the next launch can fall through to **fast server index** (premium-gated in the location UI, but still used as default pick).

### 2.4 Features and UI/UX

**Fact.** Splash → consent (first run) → Home. Connect / disconnect, uptime and crude speed from OpenVPN callbacks, change location (search, Fast, Auto), bookmarks, Connection Info (`http://ip-api.com/json`), drawer (auto-connect, about, rate, share, feedback, legal, More Apps). Paywall on GET PRO / premium server / Fast. In-app review after connect count `% 3 == 0`, but splash **resets** `hasShownRatingDialog` every launch.

UX is a generic “blue connect button + globe/map” pattern. Theme is `primarySwatch: indigo` plus `Constants.kBgColor` (`#2E6BFF`). No threat-aware copy (“you’re on open Wi-Fi”).

### 2.5 Backend

**Fact.**

- Supabase: `vpn_config`, `vpn_servers`; in-house ads via git package `inhouse_app_ads` (table not defined in this repo).
- Firebase project `turbo--vpn-3e820`.
- No user authentication. Restore relies on store / RevenueCat anonymous IDs.

### 2.6 Security and privacy

**Fact.**

- Shared VPN username/password delivered to every client; password **persisted in plaintext JSON** in SharedPreferences.
- `MyHttpOverrides.badCertificateCallback` returns **true** for all certs (global TLS bypass) — `lib/core/network/http_overrides.dart`.
- Secrets in Dart: RevenueCat keys, AdMob unit IDs, Supabase URL + publishable key, UXCam app key.
- Tracking: Firebase Analytics + observer, Crashlytics, Performance, FCM, UXCam (iOS), AdMob `AD_ID`.
- Consent is in-app ToS/Privacy tap-through. **No** ATT / `NSUserTrackingUsageDescription` / Google UMP in code.
- Connection Info uses **unencrypted HTTP** to ip-api.com.

### 2.7 Performance

**Fact.** Splash waits on VPN config + in-house ads (not the full server list). Servers load on Home. `PerformanceWrapper` traces connect. `cached_network_image` on ads. OpenVPN is relatively heavy on mobile battery vs WireGuard (**Research**, below).

### 2.8 Monetization (current)

**Fact.**

- RevenueCat `purchases_flutter`; entitlement `Premium`. `fetchOffers()` uses `offerings.current`; `Constants.offeringIdentifier` is unused.
- Free: free servers, Home banner (`BannerAdWidget`), in-house ad after connect (Word Connect / Translator).
- Premium: premium + Fast servers, no banner, skip post-connect ads.
- Rewarded **AdMob** is implemented but **commented out**.
- Epic-deal paywall variant exists and is **unwired**.

### 2.9 Store compliance (current)

**Fact.** Privacy / Terms / FAQ on Google Sites; About on audacityventures.ca; feedback `aits.vpn@gmail.com`. Consent before Home. Paywall footer “Privacy & Terms” opens **privacy URL only**.

**Recommendation.** Treat Apple Guideline **5.4** as a hard constraint the current SDK mix (UXCam + ads + analytics) may fail if data is disclosed to third parties for any purpose.

### 2.10 Gaps vs a real VPN product

**Fact + Recommendation.** Wrapper architecture, shared credentials, TLS bypass, OpenVPN-only, no kill switch / split tunnel / always-on in product code, no per-device keys, no independent audit story, generic UX, dark-pattern-adjacent review reset, Play/App Store trust debt. **Do not clone this stack.**

---

## 3. Market research

### 3.1 Landscape

**Research.** The consumer VPN market is consolidated around two portfolios: Nord Security (NordVPN, Surfshark) and Unikmind / former Kape (ExpressVPN, CyberGhost, PIA). Together they account for a large share of **paid** subscribers. Proton VPN is the main independent “trust” brand (Swiss, audited, free tier). Mullvad / IVPN occupy high-anonymity niches. ([VPNVerdict, 2026 ownership guide](https://vpnverdict.net/who-owns-your-vpn-2026-ownership-guide/))

Market-size figures in vendor reports vary widely (tens of billions USD, double-digit CAGRs). Treat any single TAM number as **marketing research**, not a forecast you can underwrite.

### 3.2 Competitor snapshot

**Research** (typical 2026 review positioning, not audited financials):

| Brand | Typical hook | Weakness users cite |
|-------|----------------|---------------------|
| NordVPN | Scale, NordLynx (WireGuard-based), ecosystem | Conglomerate + renewal pricing |
| Surfshark | Unlimited devices, low intro price | Same parent as Nord; promo-heavy apps |
| ExpressVPN | Apps, Lightway, streaming reputation | Price; Kape/Unikmind ownership |
| Proton VPN | Free tier, open source, audits | Free-tier limits; OpenVPN weaker if forced |
| Mullvad | Flat €5, anonymity | Fewer locations; power-user UX |
| Super Unlimited (mobile) | Generous free + organic ASO | Lower conversion by design ([RevenueCat interview, 2026](https://www.revenuecat.com/blog/growth/tanuj-chatterjee-super-unlimited-vpn-sub-club-podcast-2026)) |

### 3.3 Gaps and pain points

**Research + Recommendation.**

- **Trust:** ownership opacity; “no logs” without audits; free VPNs that harvest data.
- **Pricing:** intro vs renewal shock.
- **Mobile quality:** OpenVPN drain and reconnects; missing kill switch / always-on in cheap apps.
- **UX:** vanity globes; dark-pattern paywalls that convert once and churn + get 1-star reviews.
- **What is *not* a gap:** “one more app with 100 countries.” Nord already won that axis.

**Opportunity:** a **mobile-first, public-Wi-Fi / travel** VPN with WireGuard, kill switch default, honest prices, a real free tier, and a privacy stack that survives Apple 5.4 — not a Nord clone.

### 3.4 Monetization research

**Research** (subscription apps broadly; not VPN-only):

- Hard paywall ~10–12% of downloads to paid by D35 vs freemium ~2% ([PricePush / RevenueCat-style 2025–2026 summaries](https://pricepush.app/blog/trial-to-paid-conversion-rate-benchmarks)).
- Longer trials (17–32 days) convert trial-to-paid better than ≤4-day trials.
- Ryn VPN: rewarded-ad “continue with ads / +30 minutes” raised conversion from **0.08% → 1.2%** and lifted revenue in a 28-day window ([Superwall case study](https://superwall.com/case-studies/ryn-vpn)).
- Super Unlimited: low conversion, huge organic funnel from a good free product.

**Recommendation.** For a new brand with no Nord-scale ads budget, use **freemium + rewarded minutes + soft paywall**, not a hard lock on first open.

### 3.5 Protocols

**Research.** Default **WireGuard** (speed, ~4k LOC, battery). **IKEv2 + MOBIKE** for iOS network handoff. **OpenVPN TCP/443** as censorship fallback. ([WireGuard vs OpenVPN vs IKEv2 roundups, 2026](https://www.snapvpn.net/blog/wireguard-vs-openvpn-vs-ikev2))

### 3.6 Store policy (must design for)

**Research.**

- **Apple 5.4:** NEVPNManager / Network Extension; **organization** enrollment; data declaration **on an app screen before purchase or use**; VPN apps **may not sell, use, or disclose to third parties any data for any purpose** and must say so in the privacy policy; licenses in Review Notes where required. ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))
- **Play VpnService:** encrypt device → tunnel endpoint; document VPN in the listing; **do not** redirect/manipulate other apps’ traffic for monetization (including ad-geo tricks); Data safety must match the privacy policy; account **deletion** if you offer accounts. ([Play VpnService help](https://support.google.com/googleplay/android-developer/answer/12564964), [User Data](https://support.google.com/googleplay/android-developer/answer/10144311))

---

## 4. New product: Clearline

### 4.1 Positioning

**Recommendation.** *The honest mobile VPN for untrusted networks* (cafes, hotels, campuses, roaming). One-tap protect, kill switch on, premium UI. **MVP runs on the current server fleet** (OpenVPN). WireGuard + per-device keys + new nodes come **later**, when servers change.

**Not:** “45+ locations, best streaming, military grade.”

### 4.2 Target audiences

**Recommendation.**

1. Travelers and hotel Wi-Fi users.
2. Students / campus networks.
3. Remote workers on cafes.
4. Price-sensitive regions (LATAM, SEA, MENA) where Nord annuals lose.

### 4.3 Differentiation

**Recommendation.**

1. Threat-aware Home (“Open Wi-Fi detected — Protect”) instead of a vanity globe.
2. **Later:** per-device WireGuard keys and our own/partner nodes — never keep shared passwords as the long-term model. **MVP:** same servers and credentials as Turbo Secure, hidden behind repositories.
3. Trust stack that can pass Apple 5.4: **no UXCam**, no selling data, minimal first-party analytics, public no-logs + dated audit roadmap.
4. Growth: usable free tier + **rewarded minutes** + dismissible paywall (Ryn-style bridge, Super Unlimited-style ASO).
5. Reliability in V1: kill switch, always-on (Android), reconnect on network change — retention > 90th country.

**Out of scope years 1–2:** 9,000 servers / 120 countries; marketing “unblock Netflix”; desktop-first.

### 4.3a Server fleet (current vs later)

**Decision (from product).** MVP uses the **same VPN servers as Turbo Secure today** (Supabase `vpn_servers` + existing OpenVPN endpoints and shared config). The fleet, protocol, and credential model will be **replaced later** — not in the first ship of Clearline.

**Recommendation.** Still isolate servers behind `LocationsRepository` / `TunnelRepository` so UI and Blocs do not care whether the backend is today’s Supabase list or a future WireGuard control plane. Do not bake VPNBook/Supabase types into widgets.

**Implication.** Kill switch, premium UX, Bloc architecture, and paywall ship first. Per-device WireGuard keys, own nodes, and 8–15 new cities are a **later** cutover, not MVP blockers.

### 4.4 UX principles

**Recommendation.**

- Time-to-protected &lt; 3 seconds on a warm WireGuard session (**Assumption** as a target, not a measurement).
- Kill switch **on by default** with a clear “no internet if VPN drops” explanation.
- Paywall after value (minutes gone, premium city, 3rd successful protect), not at second 0.
- Privacy declaration screen **before** any IAP or first tunnel (Apple 5.4).
- No review-prompt reset on every cold start (do not copy Turbo Secure’s splash bug).

### 4.5 Visual design (premium, not generic VPN-blue)

**Fact.** Turbo Secure uses a default indigo `ThemeData`, a flat `#2E6BFF` home, stock Lottie, and a commodity “big power button” layout. That reads as a free VPN clone.

**Recommendation.** Clearline should look like a **premium network utility** (think Linear / Arc / Nord’s current apps), not a 2018 VPNhub reskin.

**Direction**

- **Both light and dark from MVP**, driven by **semantic tokens** (not hardcoded `#0B0D12` in widgets). Default `ThemeMode.system` so the app matches iOS/Android appearance. Settings: System / Light / Dark.
- Why both: outdoor/daytime readability, accessibility, OS expectations, and store screenshots in two appearances. Why not dark-only: a “premium dark” app that ignores system light mode feels unfinished and fails Dynamic Type / high-noon use.
- Dark: OLED black `#0B0D12` + deep slate; accent metallic teal / mint (`#3DFFC8` or similar) **only on protected**. Disconnected = cool gray.
- Light: warm off-white surface (`#F4F6FA`), ink text (`#12141A`), same mint accent at slightly lower saturation so it does not glow on white. Avoid default Material white + indigo (that is Turbo Secure).
- One layout for both modes. Goldens: Home, Paywall, Locations × light × dark.
- Type: one display face (e.g. **Satoshi / Geist / SF Pro** with tight tracking) + tabular figures for timers and speeds.
- Motion: 200–400ms spring on connect ring; no looping globe Lottie. Status is a **breathing ring + mesh gradient** that settles when connected. Reduce-motion: static ring.
- Surfaces: 16–24px radius, hairline borders (dark: 8% white; light: 8% black), blur only on sheets.
- Paywall: editorial, 3 plans, annual “Best value” chip. No fake countdown.
- Accessibility: 4.5:1 contrast in **both** themes, Dynamic Type.

**Screen intent**

| Screen | Feel |
|--------|------|
| Privacy declaration | Quiet legal, full-width primary, no ads |
| Home | One hero control, threat line (“Open Wi-Fi”), stats as a slim ticker |
| Locations | Search + continent sections, lock glyph on premium cities, ping as a bar not a laggy list |
| Paywall | Dark studio lighting, product shot of the ring, 3 SKUs |
| Settings | Grouped lists, kill switch first; appearance: System / Light / Dark |

Design tokens live in `lib/core/theme/` (`AppColors.light` / `AppColors.dark`, radii, text). Widgets use `Theme.of(context).colorScheme` only. A `ThemeCubit` (or `SettingsBloc`) persists override; default is system.

---

## 5. Architecture (new app)

### 5.1 Stack

**Recommendation.**

| Layer | Choice | Rationale |
|-------|--------|-----------|
| UI | Flutter, feature modules, **one** session/server source of truth | Team skill; dual store |
| State | **flutter_bloc** (`Bloc` for async flows, `Cubit` only for tiny local UI) | Testable; no Home `setState` duplicating a Cubit |
| Tunnel | **MVP:** `axevpn_flutter` OpenVPN against **current servers**. **Later:** same plugin’s WireGuard API or a WG-specific package when the fleet changes | Maintained fork of `openvpn_flutter`; `.ovpn` compatible; 16 KB page-size |
| Fallback (later) | OpenVPN TCP/443 remains; optional IKEv2 on iOS | Censorship / handoff after cutover |
| Identity | Device-scoped keypair **when servers change**; MVP may still use shared `vpn_config` credentials | Do not block UI rewrite on key infra |
| Control plane | **MVP:** existing Supabase `vpn_config` / `vpn_servers` (cache-first). **Later:** own HTTPS API + Postgres | Same product, new data impl |
| Nodes | **Same servers as now.** Later: partner or self-host WG, 8–15+ cities | Product owner will change fleet separately |
| Flags | Remote Config / Firestore for **flags only** | Not the tunnel source of truth |
| Payments | RevenueCat + Superwall | Experiments without app releases |
| Ads | AdMob **in-app** banners + rewarded minutes | Never reroute other apps’ ads (Play) |
| Telemetry | Crashlytics + sparse first-party events | **No session replay** |
| Forbidden | Global `badCertificateCallback = true`; plaintext password cache; UXCam | Trust + 5.4 |

**Recommendation.** Keep Flutter for UI. **MVP tunnel = current OpenVPN servers.** `TunnelRepository` is the seam for a later WireGuard cutover.

### 5.1b VPN connection plugin: `axevpn_flutter`

**Fact.** Turbo Secure uses `openvpn_flutter` **1.3.4**, last published ~18 months ago.

**Decision.** Clearline MVP uses **[`axevpn_flutter`](https://pub.dev/packages/axevpn_flutter)** for the tunnel — not `openvpn_flutter`.

**Why.** It is a maintained fork of `openvpn_flutter`, still accepts `.ovpn` configs (same servers), targets current Flutter / Android 15 16 KB page size, and can add WireGuard later without swapping the whole app.

**How.** `TunnelRepository` wraps `axevpn_flutter` only. UI and `SessionBloc` never import the plugin. When servers change, replace the repository impl (WireGuard API on the same package, or another WG plugin).

**Fallback.** If iOS Network Extension, Play 16 KB, or crashes block shipping: native ics-openvpn + TunnelKit behind the same repository. Do not go back to stale `openvpn_flutter` as the long-term choice.

### 5.1a Independence from this repo (packages and features)

**Decision.** Clearline does **not** have to follow Turbo Secure’s dependencies, patterns, or feature set. For every library and every feature, pick what is **best for the new product** (maintenance, store policy, performance, team speed) — not what is already in `pubspec.yaml`.

**Examples (illustrative, not a lock-in):** this app uses `openvpn_flutter`, `awesome_dialog`, UXCam, unnamed `Navigator.push`. The new app uses **auto_route**, flutter_bloc as specified, and may drop or replace ads, analytics, dialogs, cache, and tunnel plugins when a better option exists. RevenueCat stays only if it still wins vs alternatives at implementation time.

Same rule for work items: bookmarks, ip-api “location”, in-house ads, splash review-flag hacks, orphan Settings — **re-evaluate**; do not port by default.

### 5.2 Layering (UI ≠ business logic)

**Fact.** Turbo Secure mixes `setState`, Cubit, and API calls inside `HomePage` (connect, ads, timeout, server pick).

**Recommendation.** Each feature is a vertical slice. Widgets know **nothing** about Supabase, RevenueCat, or WireGuard.

```
presentation  →  pages, widgets, BlocListener / BlocBuilder
     ↓ events
application   →  Blocs / Cubits, use cases
     ↓
domain        →  entities, repository interfaces, failures
     ↓
data          →  DTOs, API/local implementations, platform channels
```

Rules:

- **Pages** dispatch events and render states. No `VpnServerApi.instance` in widgets.
- **Blocs** call use cases / repositories; map failures to user-facing states.
- **Repositories** (interfaces in domain, impl in data) own caching, network, and native tunnel.
- **Reusable widgets** live in `lib/core/widgets/` (buttons, cards, sheets) or `lib/core/theme/`. Feature-specific composites stay under that feature’s `presentation/widgets/`.
- Dependency injection at `lib/app/di.dart` (get_it or `RepositoryProvider` + `BlocProvider`). No new singletons like `VpnService.instance` except for the process-wide tunnel adapter behind a repository.

### 5.3 Feature-based folder structure

**Recommendation.**

```
lib/
  main.dart
  app/
    app.dart                 # MaterialApp.router, theme, BlocProviders
    router.dart              # auto_route (generated)
    di.dart
  core/
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
      app_radii.dart
    widgets/                 # reuse across features
      cl_button.dart
      cl_card.dart
      cl_sheet.dart
      connect_ring.dart      # hero control, themed
      premium_badge.dart
      section_header.dart
    error/
      failures.dart
    network/
      api_client.dart        # TLS verified
    utils/
  features/
    onboarding/              # privacy declaration, consent
      domain/
      data/
      presentation/
        bloc/
        pages/
        widgets/
    session/                 # connect / disconnect / stage / stats
      domain/
        entities/vpn_session.dart
        repositories/tunnel_repository.dart
      data/
        tunnel_repository_impl.dart
        native/              # MethodChannel adapters
      presentation/
        bloc/session_bloc.dart
        pages/home_page.dart
        widgets/
    locations/
      domain/
      data/
      presentation/
        bloc/locations_bloc.dart
        pages/locations_page.dart
        widgets/
    subscription/
      domain/
      data/                  # RevenueCat impl
      presentation/
        bloc/subscription_bloc.dart
        pages/paywall_page.dart
        widgets/
    minutes/                 # free cap + rewarded ads
    settings/
    legal/
```

Shared session state is **only** `SessionBloc`. Locations and subscription **listen** to it; they do not keep a second `vpnInfo` in the page.

Navigation: **auto_route** (code-generated, typed routes, guards for privacy declaration / paywall). No `MaterialPageRoute` sprawl; no fake four-tab bar. Do **not** copy this repo’s Navigator.push graph.

### 5.4 flutter_bloc conventions

**Recommendation.**

| Use | When |
|-----|------|
| `Bloc<Event, State>` | Tunnel, locations fetch, purchase, rewarded minutes |
| `Cubit<State>` | Search query, sheet open, tab index |
| `Equatable` | All states |
| `BlocObserver` | Debug logging only; no PII |
| `sealed class` states | `SessionInitial`, `SessionConnecting`, `SessionConnected`, `SessionFailed` |

Example flow: `HomePage` → `ConnectPressed` → `SessionBloc` → `TunnelRepository.connect()` → states drive `ConnectRing` (idle / spinning / locked). Paywall is `context.read<SubscriptionBloc>()`; Home never imports `purchases_flutter`.

Tests: bloc_test for every Bloc; widget tests for `core/widgets`; golden tests for Home, Paywall, Locations (dark theme).

### 5.5 Reusable component inventory (MVP)

**Recommendation.** Build these once in `core/widgets`, then compose screens:

- `ClButton` (primary / ghost / destructive)
- `ClCard`, `ClListTile`
- `ConnectRing` (the product hero)
- `ThreatBanner` (open Wi-Fi / captive portal)
- `StatsTicker` (uptime, sparkline)
- `LocationRow` (flag, ping bar, lock)
- `PlanCard` (paywall SKU)
- `ClSheet` (modal)
- `PremiumGate` (wraps a child; shows lock + paywall route)

**Fact to avoid:** Turbo Secure’s `AllServerCard` duplicated between location and bookmark with copy-paste connect logic.

---

## 6. Monetization

### 6.1 Model

**Recommendation.** Freemium + ads + subscriptions. Soft paywall (large dismiss). Not a hard gate on first open (growth + ratings). Not a hard-paywall-only Nord clone.

### 6.2 Free vs Premium

**Recommendation.**

| Free | Premium |
|------|---------|
| WireGuard + kill switch | All locations, higher throughput |
| 1–2 generic/nearby locations | 8–40 locations as network grows |
| Daily minutes **or** rewarded +30 min | Unlimited |
| Banners on **non-connect** screens | No ads |
| 1 device | 5 devices (V1 account) |
| — | Split tunnel (V1), dedicated IP (V2) |

### 6.3 Pricing (USD list, testable)

**Recommendation / Assumption.** Starting list (A/B via Superwall):

- Weekly $4.99 (intro $1.99) — high ARPU, high churn; keep but do not default-highlight.
- Monthly $9.99.
- Annual $39.99 (intro $19.99 year 1). **Default CTA.**
- 7-day trial on **annual only**.

Localize later (research: localization experiments often beat copy tweaks).

### 6.4 Paywall

**Recommendation.** Triggers: minutes exhausted; tap on a premium city; after 3 successful protects. Screen order: **privacy declaration → plans**. Restore purchases. No fake countdown timers.

### 6.5 Ads (compliant)

**Recommendation.** Rewarded ads grant **app-defined VPN minutes**, not “watch ad to geo-shift someone else’s auction.” No DNS/ad-blocking that interferes with other apps’ monetization on-device (Play VpnService). Tracker blocking, if any, belongs **on our servers** in V2.

---

## 7. Revenue estimates

All figures in this section are **Assumptions**, not forecasts. They exist to show sensitivity, not to promise MRR.

### 7.1 Shared assumptions

| Input | Conservative | Notes |
|-------|----------------|-------|
| Paying share of MAU | 2.0% | Freemium D35 often ~2% of **downloads**; using MAU is optimistic if many users churn in week 1 |
| Share of MAU in ad cohort | 80% | Non-paid |
| Ad ARPU | $0.20 / MAU / month | Mix of banner + rewarded; geo-dependent |
| Net sub ARPPU | $5.00 / paid user / month | After 15–30% store fee; mix of weekly/monthly/annual |
| Infra (10K MAU) | $0.08 / MAU / month | Light usage |
| Infra (100K) | $0.12 / MAU / month | |
| Infra (1M) | $0.25 / MAU / month | Bandwidth dominates |

**Assumption.** Store mix 70% Play (15% fee after year 1) / 30% App Store (15–30%). Blended into the $5 net ARPPU already.

### 7.2 Conservative (2% paid)

| MAU | Paid users | Sub MRR (net) | Ad MRR | Gross MRR | Infra | Illustrative contribution |
|-----|------------|---------------|--------|-----------|-------|---------------------------|
| 10,000 | 200 | $1,000 | $1,600 | $2,600 | $800 | ~$1,800 |
| 100,000 | 2,000 | $10,000 | $16,000 | $26,000 | $12,000 | ~$14,000 |
| 1,000,000 | 20,000 | $100,000 | $160,000 | $260,000 | $250,000 | ~$10,000 |

**Recommendation.** At 1M MAU and 2% paid, **transit cost can erase ads**. Either raise paid mix, cap free bandwidth, or buy cheaper IP transit. Do not scale free unlimited.

### 7.3 Upside (4% paid, $6 net ARPPU, $0.25 ad ARPU)

| MAU | Paid | Sub MRR | Ad MRR | Infra @ $0.20/MAU | Contribution |
|-----|------|---------|--------|-------------------|--------------|
| 10,000 | 400 | $2,400 | $2,000 | $2,000 | ~$2,400 |
| 100,000 | 4,000 | $24,000 | $20,000 | $20,000 | ~$24,000 |
| 1,000,000 | 40,000 | $240,000 | $200,000 | $200,000 | ~$240,000 |

**Assumption.** 4% is closer to a strong contextual paywall + minutes bridge, still below hard-paywall medians.

### 7.4 LTV / CAC sketch

**Assumption.** Monthly paid churn 10%; annual equivalent ~50% yearly non-renew. Rough paid LTV ≈ `ARPPU / churn` → $5 / 0.10 = **$50** if all were monthly (annuals are higher LTV, lower monthly ARPPU).

**Recommendation.** Target **CAC &lt; $15** on paid UA until D35 conversion is measured; prefer organic (ASO, referral) until contribution margin at 100K MAU is proven. Payback target: **&lt; 2 months** of net ARPPU.

---

## 8. KPIs

**Recommendation.** Instrument from day one (first-party events only).

| KPI | Definition | Direction |
|-----|------------|-----------|
| D1 / D7 / D30 retention | % of installs that open the app | Growth health |
| Connect success rate | Connected / connect attempts (60s) | Product quality |
| Time-to-protected | Median ms from tap to `connected` | UX |
| Minutes consumed (free) | Distribution | Paywall timing |
| Trial start rate | Trials / eligible views | Monetization |
| D35 download-to-paid | Paid / installs in 35 days | Primary conversion |
| Trial-to-paid | Charge success / trials | Offer quality |
| Monthly churn | Paid who lapse / paid start | Retention |
| ARPU | Net revenue / MAU | Blended |
| ARPPU | Net revenue / paying MAU | Mix quality |
| LTV | Discounted expected net revenue / user | UA ceiling |
| MRR / ARR | Recurring + ads (report separately) | Board metric |
| CAC | Marketing spend / new paid | Efficiency |
| CAC payback | CAC / net ARPPU | Cash |
| Crash-free sessions | Crashlytics | Trust |
| Store rating | Rolling 90-day | ASO |

Do **not** log destination IPs, DNS queries, or traffic payloads (**Recommendation** + **Research** Apple 5.4 / no-logs).

---

## 9. Compliance

**Recommendation** (ship blockers for MVP):

1. Apple Developer **organization** account; Network Extension entitlements; 5.4 declaration UI before tunnel **and** before IAP.
2. Privacy policy: no sale/disclosure of user data to third parties; list Crashlytics/AdMob/RevenueCat as processors with purpose limitation; match App Privacy Nutrition Label and `PrivacyInfo.xcprivacy`.
3. Play: VpnService disclosure in listing; Data safety accurate; encrypt to endpoint; no ad-traffic reroute; UMP if serving EEA ads.
4. If accounts in V1: in-app **and** web account deletion.
5. Age 13+; no COPPA collection.
6. VPN licensing: geo-restrict or file licenses (e.g. some APAC/ME markets) in Review Notes.
7. Copy: no “FBI-proof / military-grade / unblock Netflix guaranteed.”
8. Kill UXCam and TLS bypass; do not ship unused ovpn private keys in the binary.

---

## 10. Roadmap

Priority = **revenue × retention × user trust / complexity**.

### MVP (store-shippable)

- Org accounts, 5.4 declaration, Play Data safety.
- Connect/disconnect via **`axevpn_flutter`** on **the same VPN servers as Turbo Secure** (OpenVPN `.ovpn` + current Supabase list). Wrapped in `TunnelRepository`.
- Kill switch on (best-effort on current stack); Android always-on documented in-app.
- New architecture (feature folders, Bloc, premium UI) + RevenueCat monthly + annual + restore; contextual paywall.
- Rewarded minutes + optional banner (non-connect UI).
- Crashlytics; connect success analytics only.
- No UXCam; no `badCertificateCallback: true`.
- Consent + real privacy/terms (not a thin Sites page mismatch).

### V1 (growth)

- Superwall experiments (trial length, annual highlight, minutes pack).
- Split tunnel; home-screen widget; “protect on untrusted Wi-Fi.”
- Optional account + deletion + 5-device.
- iOS On Demand / network-change reconnect.
- Referral; in-app review **once** after N successful protects.
- **Still the same server fleet unless cutover has started.**

### Later / V2 (network cutover + moat)

- **Change VPN servers** (partner or self-host); WireGuard default; per-device keys; drop shared password + client `.ovpn` warehouse.
- Independent no-logs audit; RAM-only nodes.
- OpenVPN as fallback; multi-hop.
- Family plan; dedicated IP.
- On-server malware/tracker filtering (not local Play-hostile ad blocking).
- Scale toward 20–40 locations **after** the new fleet exists.

---

## 11. What we will not copy from Turbo Secure

**Recommendation.**

- Shared VPNBook-style passwords and client-side `.ovpn` warehouses.
- Global TLS verification off.
- Session replay (UXCam).
- Fake four-tab bar that is actually one page.
- Resetting review flags on every splash.
- Premium Fast server as silent default after disconnect.
- Marketing claims the network cannot support.

Reuse from this repo is **optional**, never required. Prefer the best package and design for each job (`auto_route`, current best HTTP client, ads SDK, etc.). Do not port UXCam, TLS bypass, unused `vpn_config.dart` keys, or the fake tab bar.

---

## 12. Implementation gate

This document is the product spec for a **new** app. **Do not modify application code** until product/legal signs:

1. Working name vs final brand.
2. Node strategy: partner vs self-host.
3. Freemium minutes vs location-cap as the free limiter.
4. Whether V1 accounts are in or delayed.
5. **Confirmed:** MVP uses **current VPN servers**; fleet/protocol change is a later project, behind repositories.

After that, implementation should be a **new project** (new bundle IDs), not a reskin of `openvpn_flutter_example`.

---

## 13. Sources (Research)

- [Apple App Review Guidelines §5.4 VPN Apps](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play VpnService policy](https://support.google.com/googleplay/android-developer/answer/12564964)
- [Google Play User Data / Data safety](https://support.google.com/googleplay/android-developer/answer/10144311)
- [VPNVerdict — Who Owns Your VPN (2026)](https://vpnverdict.net/who-owns-your-vpn-2026-ownership-guide/)
- [Trial-to-paid / paywall conversion summaries](https://pricepush.app/blog/trial-to-paid-conversion-rate-benchmarks)
- [Superwall — Ryn VPN rewarded paywall](https://superwall.com/case-studies/ryn-vpn)
- [RevenueCat — Super Unlimited](https://www.revenuecat.com/blog/growth/tanuj-chatterjee-super-unlimited-vpn-sub-club-podcast-2026)
- [WireGuard vs OpenVPN vs IKEv2](https://www.snapvpn.net/blog/wireguard-vs-openvpn-vs-ikev2)
