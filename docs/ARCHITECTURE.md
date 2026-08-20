# Architecture — Cyber VPN

Keep this small. Prefer extending existing features over new packages.

## Layout

```
lib/
  main.dart                 # Flutter + Supabase + configureDependencies()
  app/
    app.dart                # MaterialApp.router + BlocProviders
    di.dart                 # GetIt registrations
    router.dart             # @AutoRouterConfig
    router.gr.dart          # generated
  core/
    config/app_config.dart
    json.dart               # jsonInt / jsonString / jsonBool helpers
    theme/
    widgets/                # ClButton, ConnectRing, ThreatBanner, StatsTicker, PingBar
  features/
    onboarding/presentation/pages/
    session/
      domain/open_vpn_kill_switch.dart
      domain/entities/exit_info.dart, session_record.dart
      domain/repositories/tunnel_repository.dart
      domain/repositories/exit_ip_repository.dart
      domain/repositories/session_history_repository.dart
      data/axe_vpn_tunnel_repository.dart
      data/exit_ip_api.dart              # Retrofit client for ipwho.is
      data/ip_who_is_exit_ip_repository.dart
      data/prefs_session_history_repository.dart
      data/models/ip_who_is_response.dart  # Freezed DTO for exit lookup
      presentation/bloc/    # session + exit_check + history cubits
      presentation/history_aggregates.dart
      presentation/pages/  # home, connection_info, history
    locations/
      domain/entities/vpn_location.dart
      domain/open_vpn_remote.dart
      domain/repositories/locations_repository.dart
      domain/repositories/server_probe.dart
      data/supabase_locations_repository.dart
      data/tcp_server_probe.dart
      presentation/
    settings/               # ThemeCubit; paywall page currently lives here (move to subscription/)
```

Add **`features/subscription/`** and **`features/minutes/`** as new vertical slices (plan). Do not put RevenueCat or AdMob in `HomePage`.

## Rules

- Pages dispatch events and render states. No `Supabase.instance` or `OpenVPN` in widgets.
- Register new repos as `LazySingleton` in `di.dart`; Blocs as `Factory`; provide Blocs with `BlocProvider` in `app.dart`.
- Session is the only tunnel source of truth (`SessionBloc`). Locations listen; they do not keep a second `vpnInfo`.
- Home must start the session from the **current** `LocationsBloc` state (splash often finishes fetch before Home mounts).
- Kill switch + reconnect live in `SessionBloc` (`_intended`, backoff). Settings only dispatches events. Do not call `OpenVPN` from Settings.
- Threat banner uses `connectivity_plus` path only (Wi‑Fi / cellular / none). Do **not** read SSID (would need location permission). Do **not** log probe hosts or destination IPs.
- Location ping is TCP connect RTT via `ServerProbe` (`TcpServerProbe`). UI shows a bar + ms, never the host.
- Exit check uses **HTTPS** (`AppConfig.exitIpBaseUrl` via Dio + Retrofit). Never Turbo-style plain HTTP ip-api. Do not log exit IPs.
- Session history and favorites/recents are SharedPreferences only (on-device).
- Cache-first locations: memory → SharedPreferences → network. Refresh on connect **timeout** once (`didRefreshOnFailure`).
- iOS tunnel ids must stay in sync with `AppConfig.iosAppGroup` and `iosVpnExtensionBundleId`.

## Codegen

| Annotation | Output |
|------------|--------|
| `@freezed` | `*.freezed.dart` |
| `@JsonSerializable` via Freezed | `vpn_location.g.dart`, `ip_who_is_response.g.dart` |
| `@RestApi` (Retrofit) | `exit_ip_api.g.dart` |
| `@RoutePage` / `AppRouter` | `router.gr.dart` |

Do not hand-edit generated files. They are **gitignored** (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`); run `dart run build_runner build` after clone or model/route changes.

## Stack (current)

`flutter_bloc`, `freezed`, `get_it`, `auto_route`, `axevpn_flutter` ^2, `supabase_flutter`, `shared_preferences`, `connectivity_plus`, `google_fonts`, `cached_network_image`, `url_launcher`, `fl_chart`, `dio`, `retrofit`.

Swift Package Manager is **disabled** in `pubspec.yaml` because `axevpn_flutter` does not support it.

## Native

- Android: `MainActivity` calls `AxeVPNFlutterPlugin.connectWhileGranted` for requestCode 24. MethodChannel `com.cybervpn.cyber_vpn/device` → VPN settings (`ACTION_VPN_SETTINGS`, then wireless/settings fallback). Manifest `<queries>` must include `android.settings.VPN_SETTINGS` (API 30+). `OpenVPNService` must declare `android.net.VpnService`. Duplicate `libwg-go.so`: app `packaging.jniLibs.pickFirsts`.
- iOS: target `VPNExtension` + `ios/VPNExtension/PacketTunnelProvider.swift` (`tunPersist`, reconnect on Wi‑Fi or WWAN) + OpenVPNAdapter in `Podfile`.
- Kill switch: `OpenVpnKillSwitch.apply` on connect. Hard device block = Android Always-on + “Block connections without VPN.” MethodChannel must return a **bool** (`true`), not `null`/`void`, or Dart treats success as failure. Always-on overrides in-app disconnect until the user turns Always-on off.
