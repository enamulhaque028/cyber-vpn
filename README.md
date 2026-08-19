# Cyber VPN

Implementation of the product in [docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md).

**Agents:** start at [docs/README.md](docs/README.md), then [docs/STATUS.md](docs/STATUS.md).

Flutter VPN client. Features are vertical slices (`domain` / `data` / `presentation`).

- **State:** flutter_bloc. Models and Bloc events/states are **Freezed**.
- **DI:** **GetIt** in `lib/app/di.dart` (manual registration, no Injectable). Blocs are still provided with `BlocProvider`.
- **Nav:** auto_route. **Tunnel:** `axevpn_flutter` behind `TunnelRepository`.

MVP uses the same OpenVPN servers as Turbo Secure VPN. The app is **not store-ready** until STATUS P0 (IAP, minutes, ads, kill switch) is done.

## Run

```bash
cd /Users/sabrinaakter/development/flutter/cyber-vpn
flutter pub get
dart run build_runner build
flutter run
```

## Android

- `minSdk` 24
- `extractNativeLibs`, 16 KB page-size flags, legacy JNI packaging
- `MainActivity` VPN-permission result (`requestCode == 24`)

## iOS

- App: `com.cybervpn.cyberVpn`
- Extension: `com.cybervpn.cyberVpn.VPNExtension`
- App Group: `group.com.cybervpn.cyberVpn`
- Team: `T8EJN9YNF9`

In Apple Developer, register that App Group and enable **Network Extensions → Packet Tunnel** on both App IDs.

Minimum iOS **16.0**. Swift Package Manager is off because axevpn_flutter does not support it.
