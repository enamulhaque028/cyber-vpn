import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_gauge_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpeedTestStatsCard extends StatelessWidget {
  const SpeedTestStatsCard({
    super.key,
    this.downloadMbps,
    this.uploadMbps,
    this.pingMs,
  });

  final double? downloadMbps;
  final double? uploadMbps;
  final int? pingMs;

  static const _uploadBlue = Color(0xFF3B82F6);
  static const _pingPurple = Color(0xFFA78BFA);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                asset: 'assets/icons/speed_download.svg',
                label: 'Download',
                value: _formatMbps(downloadMbps),
                unit: 'Mbps',
                color: scheme.primary,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _StatColumn(
                asset: 'assets/icons/speed_upload.svg',
                label: 'Upload',
                value: _formatMbps(uploadMbps),
                unit: 'Mbps',
                color: _uploadBlue,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _StatColumn(
                asset: 'assets/icons/speed_ping.svg',
                label: 'Ping',
                value: formatPingMs(pingMs),
                unit: 'ms',
                color: _pingPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMbps(double? mbps) {
    if (mbps == null || mbps <= 0) return '—';
    return formatGaugeMbps(mbps);
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.asset,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String asset;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.secondary,
                ),
          ),
        ],
      ),
    );
  }
}
