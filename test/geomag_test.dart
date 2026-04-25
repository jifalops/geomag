import 'dart:io';
import 'package:geomag/geomag.dart';
import 'package:test/test.dart';

final gm = GeoMag();

void main() {
  final lines = File('test/WMM2025_TestValues.txt')
      .readAsLinesSync()
      .where((l) => !l.startsWith('#') && l.trim().isNotEmpty)
      .toList();

  group('WMM2025 declination within 0.1 degree', () {
    for (var i = 0; i < lines.length; i++) {
      final f = lines[i].trim().split(RegExp(r'\s+'));
      final decimalYear = double.parse(f[0]);
      final altFeet = double.parse(f[1]) * 3280.84;
      final lat = double.parse(f[2]);
      final lon = double.parse(f[3]);
      final expectedDec = double.parse(f[4]);
      final date = _decimalYearToDateTime(decimalYear);

      test('Test $i (year=$decimalYear lat=$lat lon=$lon)', () {
        final result = gm.calculate(lat, lon, altFeet, date);
        expect(result.dec, closeTo(expectedDec, 0.15));
      });
    }
  });
}

DateTime _decimalYearToDateTime(double decimalYear) {
  final year = decimalYear.floor();
  final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  final daysInYear = isLeap ? 366.0 : 365.0;
  final dayOfYear = ((decimalYear - year) * daysInYear).floor();
  return DateTime(year, 1, 1).add(Duration(days: dayOfYear));
}

