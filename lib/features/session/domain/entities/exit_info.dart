import 'package:freezed_annotation/freezed_annotation.dart';

part 'exit_info.freezed.dart';
part 'exit_info.g.dart';

@freezed
abstract class ExitInfo with _$ExitInfo {
  const factory ExitInfo({
    required String ip,
    required String city,
    required String country,
    required String isp,
    /// Approximate public-IP coordinates from ipwho.is (when available).
    double? latitude,
    double? longitude,
  }) = _ExitInfo;

  factory ExitInfo.fromJson(Map<String, dynamic> json) =>
      _$ExitInfoFromJson(json);
}
