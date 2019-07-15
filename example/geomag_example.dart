import 'package:geomag/geomag.dart';

main() {
  final geomag = GeoMag();
  final result = geomag.calculate(41.6528, 83.5379);
  print('Declination: ${result.dec}');
}
