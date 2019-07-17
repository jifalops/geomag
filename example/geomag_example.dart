import 'package:geomag/geomag.dart';

main(List<String> args) {
  final geomag = GeoMag();
  final result = geomag.calculate(double.parse(args[0]), double.parse(args[1]));
  print('Declination: ${result.dec}');
}
