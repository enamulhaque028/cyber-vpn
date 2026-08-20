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
  }) = _ExitInfo;

  factory ExitInfo.fromJson(Map<String, dynamic> json) =>
      _$ExitInfoFromJson(json);
}
