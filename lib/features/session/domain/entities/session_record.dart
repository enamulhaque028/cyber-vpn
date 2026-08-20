import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_record.freezed.dart';
part 'session_record.g.dart';

@freezed
abstract class SessionRecord with _$SessionRecord {
  const factory SessionRecord({
    required int locationId,
    required String locationName,
    required DateTime startedAt,
    required DateTime endedAt,
    required int bytesIn,
    required int bytesOut,
  }) = _SessionRecord;

  factory SessionRecord.fromJson(Map<String, dynamic> json) =>
      _$SessionRecordFromJson(json);
}
