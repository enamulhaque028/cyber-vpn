import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';

abstract class SessionHistoryRepository {
  Future<List<SessionRecord>> list();
  Future<void> add(SessionRecord record);
  Future<void> clear();
}
