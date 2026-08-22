import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/session/domain/repositories/exit_ip_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device cache of approximate Direct (non-VPN) coordinates from ipwho.is.
///
/// Captured once on first successful lookup while the tunnel is down.
/// Cleared with app data / reinstall (SharedPreferences). Does **not** store IP.
class DirectLocationStore {
  DirectLocationStore(this._prefs, this._exitIp);

  final SharedPreferences _prefs;
  final ExitIpRepository _exitIp;

  bool get hasCached => read() != null;

  /// Cached lat/lng, or null if never captured.
  ({double lat, double lng})? read() {
    final lat = _prefs.getDouble(AppConfig.prefsDirectLocationLat);
    final lng = _prefs.getDouble(AppConfig.prefsDirectLocationLng);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  /// If already cached, returns it. Otherwise looks up via ipwho.is **only when
  /// [isDirect]** (VPN not connecting/protected) and persists lat/lng.
  Future<({double lat, double lng})?> ensureCaptured({
    required bool isDirect,
  }) async {
    final existing = read();
    if (existing != null) return existing;
    if (!isDirect) return null;

    try {
      final info = await _exitIp.lookup();
      final lat = info.latitude;
      final lng = info.longitude;
      if (lat == null || lng == null) return null;
      await _prefs.setDouble(AppConfig.prefsDirectLocationLat, lat);
      await _prefs.setDouble(AppConfig.prefsDirectLocationLng, lng);
      return (lat: lat, lng: lng);
    } catch (_) {
      return null;
    }
  }
}
