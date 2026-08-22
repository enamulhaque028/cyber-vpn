import 'package:cyber_vpn/features/speed_test/presentation/widgets/speed_gauge_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mbpsToGaugeFraction', () {
    test('maps anchor values to even tick positions', () {
      expect(mbpsToGaugeFraction(0), 0);
      expect(mbpsToGaugeFraction(5), closeTo(1 / 6, 0.001));
      expect(mbpsToGaugeFraction(100), 1);
    });

    test('interpolates between anchors', () {
      expect(mbpsToGaugeFraction(15), closeTo(2.5 / 6, 0.001));
    });
  });
}
