import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_test_result.freezed.dart';

enum SpeedTestMeasurePhase { ping, download, upload }

@freezed
abstract class SpeedTestResult with _$SpeedTestResult {
  const factory SpeedTestResult({
    required double downloadPeakMbps,
    required double downloadAvgMbps,
    required double uploadPeakMbps,
    required double uploadAvgMbps,
    required int pingMs,
    required int durationMs,
    required DateTime testedAt,
  }) = _SpeedTestResult;
}

/// Throughput from bytes transferred over elapsed wall time.
double computeMbps(int bytes, Duration elapsed) {
  if (bytes <= 0 || elapsed.inMilliseconds <= 0) return 0;
  final seconds = elapsed.inMilliseconds / 1000;
  return (bytes * 8) / seconds / 1000000;
}

String formatMbps(double mbps) {
  if (mbps.isNaN || mbps.isInfinite || mbps <= 0) return '—';
  if (mbps >= 100) return mbps.toStringAsFixed(0);
  return mbps.toStringAsFixed(1);
}

String formatPingMs(int? ms) {
  if (ms == null || ms <= 0) return '—';
  return '$ms';
}
