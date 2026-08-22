import 'package:freezed_annotation/freezed_annotation.dart';

part 'vpn_location.freezed.dart';
part 'vpn_location.g.dart';

@freezed
abstract class VpnLocation with _$VpnLocation {
  const VpnLocation._();

  const factory VpnLocation({
    required int id,
    required String country,
    required String region,
    required String city,
    required String title,
    required String flagUrl,
    required String config,
    required bool isPremium,
    /// Catalog origin: `vpnbook` | `vpngate` (and future sources).
    @Default('') String source,
    /// Transport: `tcp` | `udp` (empty if unknown).
    @Default('') String protocol,
    /// Approximate relay coordinates from catalog GeoIP (omit when unknown).
    double? lat,
    double? lng,
  }) = _VpnLocation;

  bool get hasCoordinates => lat != null && lng != null;

  factory VpnLocation.fromJson(Map<String, dynamic> json) =>
      _$VpnLocationFromJson(json);

  /// Place label without trailing protocol/port suffix from catalog city.
  String get placeName {
    final (place, _) = _splitCity(city);
    if (place.isNotEmpty) return place;
    if (title.isNotEmpty) return title;
    return country;
  }

  /// TCP / UDP (and vpnbook port when present), from city suffix or [protocol].
  String get protocolLabel {
    final (_, detail) = _splitCity(city);
    if (detail.isNotEmpty) return detail;
    return switch (protocol.toLowerCase()) {
      'tcp' => 'TCP',
      'udp' => 'UDP',
      _ => '',
    };
  }

  /// Primary list line: place + country.
  String get displayName =>
      placeName.isNotEmpty ? '$placeName, $country' : country;

  /// Secondary list line: region · protocol · tier.
  String get listSubtitle {
    final parts = <String>[];
    if (_regionForDisplay.isNotEmpty) parts.add(_regionForDisplay);
    final proto = protocolLabel;
    if (proto.isNotEmpty) parts.add(proto);
    final tier = isPremium ? 'Premium' : 'Free';
    if (parts.isEmpty) return tier;
    return '${parts.join(' · ')} · $tier';
  }

  String get _regionForDisplay {
    final r = region.trim();
    if (r.isEmpty) return '';
    // Gate fallback labels like "JP · operator" — skip in UI.
    if (RegExp(r'^[A-Z]{2}\s·').hasMatch(r)) return '';
    return r;
  }

  static (String place, String protocolDetail) _splitCity(String city) {
    final c = city.trim();
    if (c.isEmpty) return ('', '');

    final prefix = RegExp(r'^(TCP|UDP) · (.+)$', caseSensitive: false);
    final pm = prefix.firstMatch(c);
    if (pm != null) {
      return (pm.group(2)!.trim(), pm.group(1)!.toUpperCase());
    }

    final i = c.lastIndexOf(' · ');
    if (i > 0) {
      final place = c.substring(0, i).trim();
      final suffix = c.substring(i + 3).trim();
      if (RegExp(r'^(TCP|UDP)( \d+)?$', caseSensitive: false).hasMatch(suffix)) {
        return (place, suffix.toUpperCase());
      }
    }
    return (c, '');
  }
}

@freezed
abstract class VpnCredentials with _$VpnCredentials {
  const factory VpnCredentials({
    required String username,
    required String password,
    required int fastServerIndex,
    @Default(30) int connectionTimeoutSeconds,
  }) = _VpnCredentials;

  factory VpnCredentials.fromJson(Map<String, dynamic> json) =>
      _$VpnCredentialsFromJson(json);
}
