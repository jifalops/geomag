@Skip('Needs updated with the 2020 test values')
import 'dart:math';
import 'package:geomag/geomag.dart';
import 'package:test/test.dart';

final d1 = DateTime(2015, 1, 1);
final d2 = DateTime(2017, 7, 2);
final testValues = [
  [d1, 0.0, 80.0, 0.0, -3.85],
  [d1, 0.0, 0.0, 120.0, 0.57],
  [d1, 0.0, -80.0, 240.0, 69.81],
  [d1, 328083.99, 80.0, 0.0, -4.27],
  [d1, 328083.99, 0.0, 120.0, 0.56],
  [d1, 328083.99, -80.0, 240.0, 69.22],
  [d2, 0.0, 80.0, 0.0, -2.75],
  [d2, 0.0, 0.0, 120.0, 0.32],
  [d2, 0.0, -80.0, 240.0, 69.58],
  [d2, 328083.99, 80.0, 0.0, -3.17],
  [d2, 328083.99, 0.0, 120.0, 0.32],
  [d2, 328083.99, -80.0, 240.0, 69.00],
];
final gm = GeoMag();

void main() {
  group('Correct to one tenth of a degree', () {
    runTest(1);
  });
  // group('Correct to one hundredth of a degree', () {
  //   runTest(2);
  // });
}

void runTest(int places) {
  testValues.asMap().forEach((i, v) {
    test('Test values $i', () {
      final result = gm.calculate(
          v[2] as double, v[3] as double, v[1] as double, v[0] as DateTime);
      expect(round(result.dec, places), round(v[4] as double, places));
    });
  });
}

double round(double value, int places) =>
    (value * pow(10, places)).round() / pow(10, places);
