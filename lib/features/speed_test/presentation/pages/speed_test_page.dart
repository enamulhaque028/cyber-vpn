import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/presentation/bloc/speed_test_cubit.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_meter.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_test_connection_pill.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_test_gradient_button.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_test_progress_card.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_test_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SpeedTestPage extends StatelessWidget {
  const SpeedTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SpeedTestCubit>(),
      child: const _SpeedTestView(),
    );
  }
}

class _SpeedTestView extends StatelessWidget {
  const _SpeedTestView();

  SpeedMeterPhase _phase(SpeedTestState state) {
    return switch (state) {
      SpeedTestIdle() => SpeedMeterPhase.idle,
      SpeedTestPreparing() => SpeedMeterPhase.preparing,
      SpeedTestRunning() => SpeedMeterPhase.running,
      SpeedTestComplete() => SpeedMeterPhase.complete,
      SpeedTestError() => SpeedMeterPhase.error,
    };
  }

  SpeedTestMeasurePhase _measurePhase(SpeedTestState state) {
    return switch (state) {
      SpeedTestRunning(:final phase) => phase,
      SpeedTestComplete() => SpeedTestMeasurePhase.download,
      _ => SpeedTestMeasurePhase.download,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speed Test',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SpeedTestCubit, SpeedTestState>(
        builder: (context, state) {
          final cubit = context.read<SpeedTestCubit>();
          final running = state is SpeedTestRunning || state is SpeedTestPreparing;
          final preparing = state is SpeedTestPreparing;
          final measurePhase = _measurePhase(state);

          final mbps = switch (state) {
            SpeedTestRunning(:final currentMbps) => currentMbps,
            SpeedTestComplete(:final result) => result.downloadPeakMbps,
            _ => 0.0,
          };
          final peakMbps = switch (state) {
            SpeedTestComplete(:final result) => result.downloadPeakMbps,
            _ => null,
          };
          final pingMs = switch (state) {
            SpeedTestRunning(:final pingMs) => pingMs,
            SpeedTestComplete(:final result) => result.pingMs,
            _ => null,
          };

          double? downloadMbps;
          double? uploadMbps;
          switch (state) {
            case SpeedTestComplete(:final result):
              downloadMbps = result.downloadPeakMbps;
              uploadMbps = result.uploadPeakMbps;
            case SpeedTestRunning(:final phase, :final currentMbps):
              if (phase == SpeedTestMeasurePhase.download && currentMbps > 0) {
                downloadMbps = currentMbps;
              }
              if (phase == SpeedTestMeasurePhase.upload && currentMbps > 0) {
                uploadMbps = currentMbps;
              }
            default:
              break;
          }

          final elapsedSeconds = switch (state) {
            SpeedTestRunning(:final elapsedSeconds) => elapsedSeconds,
            _ => 0,
          };
          final runPhase = switch (state) {
            SpeedTestRunning(:final phase) => phase,
            _ => SpeedTestMeasurePhase.download,
          };

          final actionLabel = switch (state) {
            SpeedTestRunning() || SpeedTestPreparing() => 'Cancel',
            SpeedTestComplete() => 'Test again',
            SpeedTestError() => 'Retry',
            SpeedTestIdle() => 'Start test',
          };

          VoidCallback? onAction = switch (state) {
            SpeedTestRunning() || SpeedTestPreparing() => cubit.cancel,
            _ => () => cubit.start(),
          };

          final subtitle = switch (state) {
            SpeedTestComplete(:final result) =>
              'Finished in ${(result.durationMs / 1000).ceil()}s · ↓ ${formatMbps(result.downloadAvgMbps)} · ↑ ${formatMbps(result.uploadAvgMbps)} · ${result.pingMs} ms',
            SpeedTestError(:final message) => message,
            SpeedTestIdle() =>
              'Measures ping, download, and upload through your current connection.',
            _ => null,
          };

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const Center(child: SpeedTestConnectionPill()),
                const SizedBox(height: 20),
                Center(
                  child: SpeedMeter(
                    phase: _phase(state),
                    mbps: mbps,
                    peakMbps: peakMbps,
                    measurePhase: measurePhase,
                    pingMs: pingMs,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: state is SpeedTestError
                              ? scheme.secondary
                              : scheme.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                  ),
                ],
                const SizedBox(height: 20),
                if (running) ...[
                  SpeedTestProgressCard(
                    phase: runPhase,
                    elapsedSeconds: elapsedSeconds,
                    preparing: preparing,
                  ),
                  const SizedBox(height: 20),
                ],
                SpeedTestGradientButton(
                  label: actionLabel,
                  onPressed: onAction,
                ),
                const SizedBox(height: 20),
                SpeedTestStatsCard(
                  downloadMbps: downloadMbps,
                  uploadMbps: uploadMbps,
                  pingMs: pingMs,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: scheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Uses mobile data when not on Wi‑Fi. A typical run uses about 25 MB from a public HTTPS CDN. Ping is HTTPS round-trip time to the test server.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.secondary,
                              height: 1.45,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
