import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:dio/dio.dart';

typedef SpeedTestProgress = void Function(
  SpeedTestMeasurePhase phase,
  double currentMbps,
  int? pingMs,
);

abstract class SpeedTestRepository {
  /// Ping → download → upload. [onProgress] emits live phase metrics.
  Future<SpeedTestResult> runSpeedTest({
    required SpeedTestProgress onProgress,
    required CancelToken cancelToken,
  });
}
