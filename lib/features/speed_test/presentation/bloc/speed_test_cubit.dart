import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cyber_vpn/features/speed_test/data/https_download_speed_test_repository.dart';
import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/domain/repositories/speed_test_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_test_cubit.freezed.dart';

@freezed
sealed class SpeedTestState with _$SpeedTestState {
  const factory SpeedTestState.idle() = SpeedTestIdle;

  const factory SpeedTestState.preparing() = SpeedTestPreparing;

  const factory SpeedTestState.running({
    required SpeedTestMeasurePhase phase,
    required double currentMbps,
    required int elapsedSeconds,
    int? pingMs,
  }) = SpeedTestRunning;

  const factory SpeedTestState.complete(SpeedTestResult result) =
      SpeedTestComplete;

  const factory SpeedTestState.error(String message) = SpeedTestError;
}

class SpeedTestCubit extends Cubit<SpeedTestState> {
  SpeedTestCubit(
    this._repository, {
    Connectivity? connectivity,
  })  : _connectivity = connectivity ?? Connectivity(),
        super(const SpeedTestState.idle());

  final SpeedTestRepository _repository;
  final Connectivity _connectivity;
  CancelToken? _cancelToken;
  DateTime? _startedAt;
  bool _cancelled = false;

  Future<void> start() async {
    await cancel(restoreIdle: false);
    _cancelled = false;

    if (!await _hasNetworkConnection()) {
      emit(
        const SpeedTestState.error(
          'No internet connection. Connect to Wi‑Fi or mobile data and try again.',
        ),
      );
      return;
    }

    emit(const SpeedTestState.preparing());
    _cancelToken = CancelToken();
    _startedAt = DateTime.now();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (isClosed || _cancelled) return;

      emit(
        const SpeedTestState.running(
          phase: SpeedTestMeasurePhase.ping,
          currentMbps: 0,
          elapsedSeconds: 0,
        ),
      );

      final result = await _repository.runSpeedTest(
        cancelToken: _cancelToken!,
        onProgress: (phase, mbps, pingMs) {
          if (isClosed || _cancelled) return;
          final elapsed = _startedAt == null
              ? 0
              : DateTime.now().difference(_startedAt!).inSeconds;
          emit(
            SpeedTestState.running(
              phase: phase,
              currentMbps: mbps,
              elapsedSeconds: elapsed,
              pingMs: pingMs,
            ),
          );
        },
      );

      if (isClosed || _cancelled) return;
      emit(SpeedTestState.complete(result));
    } on SpeedTestException catch (e) {
      if (isClosed || _cancelled) return;
      emit(SpeedTestState.error(e.message));
    } catch (_) {
      if (isClosed || _cancelled) return;
      emit(
        const SpeedTestState.error(
          'Speed test failed. Check your connection and try again.',
        ),
      );
    } finally {
      _cancelToken = null;
      _startedAt = null;
    }
  }

  Future<bool> _hasNetworkConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return false;
    return !(results.length == 1 && results.first == ConnectivityResult.none);
  }

  Future<void> cancel({bool restoreIdle = true}) async {
    _cancelled = true;
    _cancelToken?.cancel('user');
    _cancelToken = null;
    _startedAt = null;
    if (restoreIdle && !isClosed) emit(const SpeedTestState.idle());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('closed');
    return super.close();
  }
}
