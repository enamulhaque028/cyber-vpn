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
  }) = _VpnLocation;

  factory VpnLocation.fromJson(Map<String, dynamic> json) =>
      _$VpnLocationFromJson(json);

  String get displayName => city.isNotEmpty
      ? '$city, $country'
      : (title.isNotEmpty ? title : country);
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
