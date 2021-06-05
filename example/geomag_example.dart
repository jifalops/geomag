import 'package:geomag/geomag.dart';

// See also the Flutter example: ...geomag/example/flutter

void main(List<String> args) {
  final geomag = GeoMag();
  final result = geomag.calculate(double.parse(args[0]), double.parse(args[1]),
      double.parse(args.length > 2 ? args[2] : '0'));
  print('Result: $result');
  print('Declination: ${result.dec}');
}
