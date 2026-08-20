import 'dart:convert';

import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';
import 'package:cyber_vpn/features/session/domain/repositories/session_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsSessionHistoryRepository implements SessionHistoryRepository {
  PrefsSessionHistoryRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _max = 50;

  @override
  Future<List<SessionRecord>> list() async {
    final raw = _prefs.getString(AppConfig.prefsSessionHistory);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> add(SessionRecord record) async {
    final current = await list();
    final next = [record, ...current].take(_max).toList();
    await _prefs.setString(
      AppConfig.prefsSessionHistory,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(AppConfig.prefsSessionHistory);
  }
}
