import 'package:geomag/geomag.dart';
import 'package:test/test.dart';

void main() {
  final d1 = DateTime(2015, 1, 1);
  final d2 = DateTime(2017, 7, 2);



  group('A group of tests', () {
    // Awesome awesome;

    setUp(() {
      // awesome = Awesome();
    });

    test('First Test', () {
      // expect(awesome.isAwesome, isTrue);
    });
  });
}

// class GeoMagTest(unittest.TestCase):

//     d1=date(2015,1,1)
//     d2=date(2017,7,2)

//     test_values = (
//         // date, alt, lat, lon, var
//         (d1, 0, 80, 0,  -3.85),
//         (d1, 0, 0, 120, 0.57),
//         (d1, 0, -80, 240,  69.81),
//         (d1, 328083.99, 80, 0, -4.27),
//         (d1, 328083.99, 0, 120, 0.56),
//         (d1, 328083.99, -80, 240, 69.22),
//         (d2, 0, 80, 0, -2.75),
//         (d2, 0, 0, 120, 0.32),
//         (d2, 0, -80, 240, 69.58),
//         (d2, 328083.99, 80, 0, -3.17),
//         (d2, 328083.99, 0, 120, 0.32),
//         (d2, 328083.99, -80, 240, 69.00),
//     )

//     def test_declination(self):
//         gm = GeoMag()
//         for values in test_values:
//             calcval=gm.GeoMag(values[2], values[3], values[1], values[0])
//             assertAlmostEqual(values[4], calcval.dec, 2, 'Expected %s, result %s' % (values[4], calcval.dec))

// if __name__ == '__main__':
//     unittest.main()
// }
