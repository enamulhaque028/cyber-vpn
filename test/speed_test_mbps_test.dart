import 'package:cyber_vpn/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeMbps', () {
    test('returns 0 for zero bytes or zero elapsed', () {
      expect(computeMbps(0, const Duration(seconds: 1)), 0);
      expect(computeMbps(1024, Duration.zero), 0);
    });

    test('computes megabits per second from bytes and duration', () {
      // 1 MB in 1 second => ~8.39 Mbps (1 MiB * 8 / 1e6)
      const oneMb = 1024 * 1024;
      expect(computeMbps(oneMb, const Duration(seconds: 1)), closeTo(8.39, 0.01));
    });
  });

  group('formatMbps', () {
    test('formats small and large values', () {
      expect(formatMbps(0), '—');
      expect(formatMbps(42.37), '42.4');
      expect(formatMbps(128.2), '128');
    });
  });
}
