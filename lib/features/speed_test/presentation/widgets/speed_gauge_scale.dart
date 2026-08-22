/// Non-linear 0–100 Mbps gauge scale (tick labels: 0, 5, 10, 20, 30, 50, 100).
const speedGaugeTickMbps = [0.0, 5.0, 10.0, 20.0, 30.0, 50.0, 100.0];

const speedTestDurationSeconds = 15;
const speedTestTotalSeconds = 22;

double mbpsToGaugeFraction(double mbps) {
  if (mbps <= 0) return 0;
  if (mbps >= speedGaugeTickMbps.last) return 1;
  for (var i = 0; i < speedGaugeTickMbps.length - 1; i++) {
    final lo = speedGaugeTickMbps[i];
    final hi = speedGaugeTickMbps[i + 1];
    if (mbps <= hi) {
      final t = (mbps - lo) / (hi - lo);
      return (i + t) / (speedGaugeTickMbps.length - 1);
    }
  }
  return 1;
}

String formatGaugeMbps(double mbps) {
  if (mbps.isNaN || mbps.isInfinite || mbps <= 0) return '—';
  if (mbps >= 100) return mbps.toStringAsFixed(0);
  return mbps.toStringAsFixed(1);
}
