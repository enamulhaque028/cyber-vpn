import 'package:freezed_annotation/freezed_annotation.dart';

part 'ip_who_is_response.freezed.dart';
part 'ip_who_is_response.g.dart';

@freezed
abstract class IpWhoIsResponse with _$IpWhoIsResponse {
  const factory IpWhoIsResponse({
    @Default(true) bool success,
    @Default('') String ip,
    @Default('') String city,
    @Default('') String country,
    double? latitude,
    double? longitude,
    IpWhoIsConnection? connection,
  }) = _IpWhoIsResponse;

  factory IpWhoIsResponse.fromJson(Map<String, dynamic> json) =>
      _$IpWhoIsResponseFromJson(json);
}

@freezed
abstract class IpWhoIsConnection with _$IpWhoIsConnection {
  const factory IpWhoIsConnection({
    int? asn,
    @Default('') String org,
    @Default('') String isp,
    @Default('') String domain,
  }) = _IpWhoIsConnection;

  factory IpWhoIsConnection.fromJson(Map<String, dynamic> json) =>
      _$IpWhoIsConnectionFromJson(json);
}
