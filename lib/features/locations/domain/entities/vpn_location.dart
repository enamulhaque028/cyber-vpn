import 'package:cyber_vpn/core/json.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vpn_location.freezed.dart';
part 'vpn_location.g.dart';

@freezed
abstract class VpnLocation with _$VpnLocation {
  const VpnLocation._();

  const factory VpnLocation({
    @JsonKey(fromJson: jsonInt) required int id,
    @JsonKey(fromJson: jsonString) required String country,
    @JsonKey(fromJson: jsonString) required String region,
    @JsonKey(fromJson: jsonString) required String city,
    @JsonKey(fromJson: jsonString) required String title,
    @JsonKey(fromJson: jsonString) required String flagUrl,
    @JsonKey(fromJson: jsonString) required String config,
    @JsonKey(fromJson: jsonBool) required bool isPremium,
    /// Catalog origin: `vpnbook` | `vpngate` (and future sources).
    @JsonKey(fromJson: jsonString) @Default('') String source,
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
    @JsonKey(fromJson: jsonString) required String username,
    @JsonKey(fromJson: jsonString) required String password,
    @JsonKey(fromJson: jsonInt) required int fastServerIndex,
    @JsonKey(fromJson: jsonTimeout) @Default(30) int connectionTimeoutSeconds,
  }) = _VpnCredentials;

  factory VpnCredentials.fromJson(Map<String, dynamic> json) =>
      _$VpnCredentialsFromJson(json);
}
