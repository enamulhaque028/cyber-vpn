import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';

class HistoryDayBucket {
  const HistoryDayBucket({
    required this.day,
    required this.minutes,
    required this.bytes,
    required this.sessions,
  });

  final DateTime day;
  final int minutes;
  final int bytes;
  final int sessions;
}

class HistorySummary {
  const HistorySummary({
    required this.sessionCount,
    required this.totalMinutes,
    required this.totalBytes,
    required this.maxSessionBytes,
    required this.last7Days,
  });

  final int sessionCount;
  final int totalMinutes;
  final int totalBytes;
  final int maxSessionBytes;
  final List<HistoryDayBucket> last7Days;
}

HistorySummary summarizeHistory(List<SessionRecord> records, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final days = List.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    return HistoryDayBucket(day: day, minutes: 0, bytes: 0, sessions: 0);
  });

  var totalMinutes = 0;
  var totalBytes = 0;
  var maxSessionBytes = 0;

  for (final r in records) {
    final mins = r.endedAt.difference(r.startedAt).inMinutes.clamp(0, 1 << 30);
    final sessionBytes = r.bytesIn + r.bytesOut;
    totalMinutes += mins;
    totalBytes += sessionBytes;
    if (sessionBytes > maxSessionBytes) maxSessionBytes = sessionBytes;

    final local = r.startedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final index = day.difference(today).inDays + 6;
    if (index >= 0 && index < 7) {
      final prev = days[index];
      days[index] = HistoryDayBucket(
        day: prev.day,
        minutes: prev.minutes + mins,
        bytes: prev.bytes + sessionBytes,
        sessions: prev.sessions + 1,
      );
    }
  }

  return HistorySummary(
    sessionCount: records.length,
    totalMinutes: totalMinutes,
    totalBytes: totalBytes,
    maxSessionBytes: maxSessionBytes,
    last7Days: days,
  );
}

String formatProtectedDuration(int totalMinutes) {
  if (totalMinutes < 60) return '${totalMinutes}m';
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (hours < 48) {
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }
  final days = hours ~/ 24;
  final remH = hours % 24;
  return remH == 0 ? '${days}d' : '${days}d ${remH}h';
}
