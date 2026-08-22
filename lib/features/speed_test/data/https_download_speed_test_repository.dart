import 'dart:async';
import 'dart:typed_data';

import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/domain/repositories/speed_test_repository.dart';
import 'package:dio/dio.dart';

class HttpsDownloadSpeedTestRepository implements SpeedTestRepository {
  HttpsDownloadSpeedTestRepository({Dio? dio})
      : _dio =
            dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 45),
                sendTimeout: const Duration(seconds: 45),
                headers: {Headers.acceptHeader: '*/*'},
              ),
            );

  final Dio _dio;

  static const _host = 'https://speed.cloudflare.com';
  static const _downloadMaxDuration = Duration(seconds: 10);
  static const _uploadMaxDuration = Duration(seconds: 8);
  static const _downloadMaxBytes = 15 * 1024 * 1024;
  static const _uploadMaxBytes = 10 * 1024 * 1024;
  static const _parallelWorkers = 3;
  static const _chunkBytes = 8 * 1024 * 1024;
  static const _uploadChunkBytes = 512 * 1024;

  static final _uploadPayload = Uint8List(_uploadChunkBytes);

  @override
  Future<SpeedTestResult> runSpeedTest({
    required SpeedTestProgress onProgress,
    required CancelToken cancelToken,
  }) async {
    final startedAt = DateTime.now();

    _ensureActive(cancelToken);

    onProgress(SpeedTestMeasurePhase.ping, 0, null);
    final pingMs = await _measurePing(cancelToken);
    onProgress(SpeedTestMeasurePhase.ping, 0, pingMs);

    _ensureActive(cancelToken);

    onProgress(SpeedTestMeasurePhase.download, 0, pingMs);
    final download = await _measureDownload(
      cancelToken: cancelToken,
      onProgress: (mbps) =>
          onProgress(SpeedTestMeasurePhase.download, mbps, pingMs),
    );

    _ensureActive(cancelToken);

    onProgress(SpeedTestMeasurePhase.upload, 0, pingMs);
    final upload = await _measureUpload(
      cancelToken: cancelToken,
      onProgress: (mbps) =>
          onProgress(SpeedTestMeasurePhase.upload, mbps, pingMs),
    );

    return SpeedTestResult(
      downloadPeakMbps: download.peakMbps,
      downloadAvgMbps: download.avgMbps,
      uploadPeakMbps: upload.peakMbps,
      uploadAvgMbps: upload.avgMbps,
      pingMs: pingMs,
      durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      testedAt: startedAt,
    );
  }

  void _ensureActive(CancelToken cancelToken) {
    if (cancelToken.isCancelled) {
      throw SpeedTestException('Speed test cancelled.');
    }
  }

  Future<int> _measurePing(CancelToken cancelToken) async {
    final samples = <int>[];
    for (var i = 0; i < 4; i++) {
      if (cancelToken.isCancelled) break;
      final watch = Stopwatch()..start();
      try {
        await _dio.get<String>(
          '$_host/cdn-cgi/trace',
          options: Options(responseType: ResponseType.plain),
          cancelToken: cancelToken,
        );
        samples.add(watch.elapsedMilliseconds);
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    if (samples.isEmpty) return 0;
    samples.sort();
    return samples[samples.length ~/ 2];
  }

  Future<({double peakMbps, double avgMbps})> _measureDownload({
    required CancelToken cancelToken,
    required void Function(double mbps) onProgress,
  }) async {
    final stop = _PhaseStop();
    final stopwatch = Stopwatch()..start();
    var totalBytes = 0;
    var peakMbps = 0.0;
    var urlIndex = 0;

    void emitProgress() {
      final mbps = computeMbps(totalBytes, stopwatch.elapsed);
      if (mbps > peakMbps) peakMbps = mbps;
      onProgress(mbps);
    }

    final progressTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => emitProgress(),
    );

    try {
      await Future.any([
        Future.delayed(_downloadMaxDuration, stop.requestStop),
        _runDownloadWorkers(
          cancelToken: cancelToken,
          stop: stop,
          onBytes: (chunk) {
            totalBytes += chunk;
            if (totalBytes >= _downloadMaxBytes) stop.requestStop();
          },
          pickUrl: () {
            final bytes = urlIndex.isEven ? _chunkBytes : _chunkBytes ~/ 2;
            urlIndex++;
            return '$_host/__down?bytes=$bytes';
          },
        ),
      ]);
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) rethrow;
    } finally {
      stop.requestStop();
      progressTimer.cancel();
    }

    stopwatch.stop();
    emitProgress();

    if (totalBytes <= 0) {
      throw SpeedTestException('Could not reach the speed test server.');
    }

    final avgMbps = computeMbps(totalBytes, stopwatch.elapsed);
    if (peakMbps <= 0) peakMbps = avgMbps;
    return (peakMbps: peakMbps, avgMbps: avgMbps);
  }

  Future<({double peakMbps, double avgMbps})> _measureUpload({
    required CancelToken cancelToken,
    required void Function(double mbps) onProgress,
  }) async {
    final stop = _PhaseStop();
    final stopwatch = Stopwatch()..start();
    var totalBytes = 0;
    var peakMbps = 0.0;

    void emitProgress() {
      final mbps = computeMbps(totalBytes, stopwatch.elapsed);
      if (mbps > peakMbps) peakMbps = mbps;
      onProgress(mbps);
    }

    final progressTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => emitProgress(),
    );

    try {
      await Future.any([
        Future.delayed(_uploadMaxDuration, stop.requestStop),
        _runUploadWorkers(
          cancelToken: cancelToken,
          stop: stop,
          onBytes: (chunk) {
            totalBytes += chunk;
            if (totalBytes >= _uploadMaxBytes) stop.requestStop();
          },
        ),
      ]);
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) rethrow;
    } finally {
      stop.requestStop();
      progressTimer.cancel();
    }

    stopwatch.stop();
    emitProgress();

    if (totalBytes <= 0) {
      return (peakMbps: 0.0, avgMbps: 0.0);
    }

    final avgMbps = computeMbps(totalBytes, stopwatch.elapsed);
    if (peakMbps <= 0) peakMbps = avgMbps;
    return (peakMbps: peakMbps, avgMbps: avgMbps);
  }

  Future<void> _runDownloadWorkers({
    required CancelToken cancelToken,
    required _PhaseStop stop,
    required void Function(int chunk) onBytes,
    required String Function() pickUrl,
  }) async {
    await Future.wait(
      List.generate(
        _parallelWorkers,
        (_) => _downloadWorker(
          cancelToken: cancelToken,
          stop: stop,
          onBytes: onBytes,
          pickUrl: pickUrl,
        ),
      ),
    );
  }

  Future<void> _runUploadWorkers({
    required CancelToken cancelToken,
    required _PhaseStop stop,
    required void Function(int chunk) onBytes,
  }) async {
    await Future.wait(
      List.generate(
        2,
        (_) => _uploadWorker(
          cancelToken: cancelToken,
          stop: stop,
          onBytes: onBytes,
        ),
      ),
    );
  }

  Future<void> _downloadWorker({
    required CancelToken cancelToken,
    required _PhaseStop stop,
    required void Function(int chunk) onBytes,
    required String Function() pickUrl,
  }) async {
    while (!cancelToken.isCancelled && !stop.isStopped) {
      try {
        final response = await _dio.get<ResponseBody>(
          pickUrl(),
          options: Options(responseType: ResponseType.stream),
          cancelToken: cancelToken,
        );
        final stream = response.data?.stream;
        if (stream == null) continue;
        await stream.forEach((chunk) {
          if (cancelToken.isCancelled || stop.isStopped) return;
          onBytes(chunk.length);
        });
      } on DioException catch (e) {
        if (CancelToken.isCancel(e) || stop.isStopped) return;
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  Future<void> _uploadWorker({
    required CancelToken cancelToken,
    required _PhaseStop stop,
    required void Function(int chunk) onBytes,
  }) async {
    while (!cancelToken.isCancelled && !stop.isStopped) {
      try {
        await _dio.post<void>(
          '$_host/__up',
          data: _uploadPayload,
          options: Options(
            contentType: 'application/octet-stream',
            responseType: ResponseType.bytes,
          ),
          cancelToken: cancelToken,
        );
        onBytes(_uploadPayload.length);
      } on DioException catch (e) {
        if (CancelToken.isCancel(e) || stop.isStopped) return;
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }
}

class _PhaseStop {
  bool _stopped = false;

  bool get isStopped => _stopped;

  void requestStop() {
    _stopped = true;
  }
}

class SpeedTestException implements Exception {
  SpeedTestException(this.message);
  final String message;

  @override
  String toString() => message;
}
