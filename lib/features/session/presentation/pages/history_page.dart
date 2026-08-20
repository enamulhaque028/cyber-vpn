import 'package:auto_route/auto_route.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/core/utils/traffic_format.dart';
import 'package:cyber_vpn/features/session/domain/entities/session_record.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/history_cubit.dart';
import 'package:cyber_vpn/features/session/presentation/history_aggregates.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static String _when(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  static const _weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistoryCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usage history'),
          actions: [
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                final empty =
                    state is HistoryLoaded && state.records.isEmpty;
                return IconButton(
                  onPressed: empty
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear history?'),
                              content: const Text(
                                'Removes on-device session records only.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await context.read<HistoryCubit>().clear();
                          }
                        },
                  icon: const Icon(Icons.delete_outline),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return switch (state) {
              HistoryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              HistoryFailed(:final message) => Center(child: Text(message)),
              HistoryLoaded(:final records) when records.isEmpty => Center(
                child: Text(
                  'No sessions yet.\nProtect, then disconnect to record.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.4,
                  ),
                ),
              ),
              HistoryLoaded(:final records) => _HistoryBody(
                records: records,
                when: _when,
                weekday: _weekday,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.records,
    required this.when,
    required this.weekday,
  });

  final List<SessionRecord> records;
  final String Function(DateTime) when;
  final List<String> weekday;

  @override
  Widget build(BuildContext context) {
    final summary = summarizeHistory(records);
    final scheme = Theme.of(context).colorScheme;
    final maxMinutes = summary.last7Days
        .map((d) => d.minutes)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxBytes = summary.last7Days
        .map((d) => d.bytes)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryChip(
                label: 'Protected',
                value: formatProtectedDuration(summary.totalMinutes),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryChip(
                label: 'Data',
                value: formatBytes(summary.totalBytes),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryChip(
                label: 'Sessions',
                value: '${summary.sessionCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Last 7 days',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Minutes protected · data used',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _WeekChart(
            days: summary.last7Days,
            weekday: weekday,
            maxMinutes: maxMinutes < 1 ? 1 : maxMinutes.toDouble(),
            maxBytes: maxBytes < 1 ? 1.0 : maxBytes.toDouble(),
            minutesColor: scheme.primary,
            dataColor: scheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: scheme.primary, label: 'Minutes'),
            const SizedBox(width: 16),
            _LegendDot(color: scheme.tertiary, label: 'Data'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Sessions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...records.map((r) {
          final mins = r.endedAt.difference(r.startedAt).inMinutes;
          final sessionBytes = r.bytesIn + r.bytesOut;
          final fraction = summary.maxSessionBytes <= 0
              ? 0.0
              : (sessionBytes / summary.maxSessionBytes).clamp(0.0, 1.0);
          return _SessionRow(
            title: r.locationName,
            subtitle: '${when(r.startedAt)} · ${mins}m',
            down: formatBytes(r.bytesIn),
            up: formatBytes(r.bytesOut),
            fraction: fraction,
          );
        }),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({
    required this.days,
    required this.weekday,
    required this.maxMinutes,
    required this.maxBytes,
    required this.minutesColor,
    required this.dataColor,
  });

  final List<HistoryDayBucket> days;
  final List<String> weekday;
  final double maxMinutes;
  final double maxBytes;
  final Color minutesColor;
  final Color dataColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.secondary,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.05,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = days[group.x.toInt()];
              final label = rodIndex == 0
                  ? '${day.minutes} min'
                  : formatBytes(day.bytes);
              return BarTooltipItem(
                label,
                TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weekday[days[i].day.weekday - 1],
                    style: labelStyle,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: (days[i].minutes / maxMinutes).clamp(0.0, 1.0),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: minutesColor,
                ),
                BarChartRodData(
                  toY: (days[i].bytes / maxBytes).clamp(0.0, 1.0),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: dataColor,
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.title,
    required this.subtitle,
    required this.down,
    required this.up,
    required this.fraction,
  });

  final String title;
  final String subtitle;
  final String down;
  final String up;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '↓ $down  ↑ $up',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value <= 0 ? 0.02 : value,
                  minHeight: 4,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: scheme.primary.withValues(alpha: 0.75),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
