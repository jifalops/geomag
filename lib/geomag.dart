/// Translate GPS location data to geo-magnetic data such as magnetic declination.
///
///
library geomag;

import 'dart:math';
import 'src/wmm_cof.dart';
import 'src/wmm_cof_data.dart';

export 'src/wmm_cof.dart';

/// Translate GPS location data to geo-magnetic data such as magnetic declination.
///
/// [GeoMag] takes data from the World Magnetic Model Coefficients, [WmmCof],
/// to initialize. You can provide your own or use the bundled data, WMM-2015v2
/// from 09/18/2018. Use [calculate()] to process GPS coordinates into a
/// [GeoMagResult].
///
/// See http://www.ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml and
/// https://www.ngdc.noaa.gov/geomag/WMM/wmm_rdownload.shtml.
///
/// This is a port of the geomag Python package,
/// https://github.com/cmweiss/geomag.
///
/// > Adapted from the geomagc software and World Magnetic Model of the NOAA
/// > Satellite and Information Service, National Geophysical Data Center.
class GeoMag {
  static GeoMag _bundledInstance;
  factory GeoMag() =>
      _bundledInstance ??= GeoMag.fromWmmCof(WmmCof.fromString(wmmCofData));

  final WmmCof coeffs;
  final maxord = 12;
  final maxdeg = 12;
  final tc = List.filled(14, List.filled(13, 0.0));
  final sp = List.filled(14, 0.0);
  final cp = List.filled(14, 0.0);
  final pp = List.filled(13, 0.0);
  final p = List.filled(14, List.filled(14, 0.0));
  final dp = List.filled(14, List.filled(13, 0.0));
  static const a = 6378.137;
  static const b = 6356.7523142;
  static const re = 6371.2;
  static const a2 = a * a;
  static const b2 = b * b;
  static const c2 = a2 - b2;
  static const a4 = a2 * a2;
  static const b4 = b2 * b2;
  static const c4 = a4 - b4;
  final c = List.filled(14, List.filled(14, 0.0));
  final cd = List.filled(14, List.filled(14, 0.0));

// CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED
  final snorm = List.filled(13, List.filled(13, 0.0));
  final k = List.filled(13, List.filled(13, 0.0));
  static const fn = [
    0.0,
    2.0,
    3.0,
    4.0,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
    11.0,
    12.0,
    13.0
  ];
  static const fm = [
    0.0,
    1.0,
    2.0,
    3.0,
    4.0,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
    11.0,
    12.0
  ];

  GeoMag.fromWmmCof(this.coeffs) {
    cp[0] = 1.0;
    pp[0] = 1.0;
    p[0][0] = 1.0;
    coeffs.wmm.forEach((w) {
      if (w.m <= w.n) {
        c[w.m][w.n] = w.gnm;
        cd[w.m][w.n] = w.dgnm;
        if (w.m != 0) {
          c[w.n][w.m - 1] = w.hnm;
          cd[w.n][w.m - 1] = w.dhnm;
        }
      }
    });
    snorm[0][0] = 1.0;
    k[1][1] = 0.0; // That's what it said.

    int n;
    for (n = 1; n <= maxord; n++) {
      snorm[0][n] = snorm[0][n - 1] * (2.0 * n - 1) / n;
      var j = 2.0;
      //for (m=0,D1=1,D2=(n-m+D1)/D1;D2>0;D2--,m+=D1):
      var m = 0;
      var D1 = 1;
      var D2 = (n - m + D1) / D1;
      while (D2 > 0) {
        k[m][n] =
            (((n - 1) * (n - 1)) - (m * m)) / ((2.0 * n - 1) * (2.0 * n - 3.0));
        if (m > 0) {
          var flnmj = ((n - m + 1.0) * j) / (n + m);
          snorm[m][n] = snorm[m - 1][n] * sqrt(flnmj);
          j = 1.0;
          c[n][m - 1] = snorm[m][n] * c[n][m - 1];
          cd[n][m - 1] = snorm[m][n] * cd[n][m - 1];
        }
        c[m][n] = snorm[m][n] * c[m][n];
        cd[m][n] = snorm[m][n] * cd[m][n];
        D2 = D2 - 1;
        m = m + D1;
      }
    }
  }

  GeoMagResult calculate(double dlat, double dlon,
      [double h = 0.0, DateTime date]) {
    date ??= DateTime.now();
    date = DateTime(date.year, date.month, date.day);
// time = date('Y') + date('z')/365

    final time =
        date.year + (date.difference(DateTime(date.year, 1, 1)).inDays / 365.0);
    final alt = h / 3280.8399;

    double otime = -1000.0, oalt = -1000.0, olat = -1000.0, olon = -1000.0;

    final dt = time - coeffs.epoch;
    final glat = dlat;
    final glon = dlon;
    final rlat = radians(glat);
    final rlon = radians(glon);
    final srlon = sin(rlon);
    final srlat = sin(rlat);
    final crlon = cos(rlon);
    final crlat = cos(rlat);
    final srlat2 = srlat * srlat;
    final crlat2 = crlat * crlat;
    sp[1] = srlon;
    cp[1] = crlon;

    // CONVERT FROM GEODETIC COORDS. TO SPHERICAL COORDS.
    assert(alt != oalt || glat != olat);
    final q = sqrt(a2 - c2 * srlat2);
    final q1 = alt * q;
    final q2 = ((q1 + a2) / (q1 + b2)) * ((q1 + a2) / (q1 + b2));
    final ct = srlat / sqrt(q2 * crlat2 + srlat2);
    final st = sqrt(1.0 - (ct * ct));
    final r2 = (alt * alt) + 2.0 * q1 + (a4 - c4 * srlat2) / (q * q);
    final r = sqrt(r2);
    final d = sqrt(a2 * crlat2 + b2 * srlat2);
    final ca = (alt + d) / r;
    final sa = c2 * crlat * srlat / (r * d);
    // } end of assertion.

    if (glon != olon) {
      for (var m = 2; m <= maxord; m++) {
        sp[m] = sp[1] * cp[m - 1] + cp[1] * sp[m - 1];
        cp[m] = cp[1] * cp[m - 1] - sp[1] * sp[m - 1];
      }
    }

    final aor = re / r;
    var ar = aor * aor;
    double br = 0.0, bt = 0.0, bp = 0.0, bpp = 0.0;
    for (var n = 1; n <= maxord; n++) {
      ar = ar * aor;

      //for (m=0,D3=1,D4=(n+m+D3)/D3;D4>0;D4--,m+=D3):
      var m = 0;
      final D3 = 1;
      //D4=(n+m+D3)/D3
      var D4 = (n + m + 1);
      while (D4 > 0) {
        //
        // COMPUTE UNNORMALIZED ASSOCIATED LEGENDRE POLYNOMIALS
        // AND DERIVATIVES VIA RECURSION RELATIONS
        //
        if (alt != oalt || glat != olat) {
          if (n == m) {
            p[m][n] = st * p[m - 1][n - 1];
            dp[m][n] = st * dp[m - 1][n - 1] + ct * p[m - 1][n - 1];
          } else if (n == 1 && m == 0) {
            p[m][n] = ct * p[m][n - 1];
            dp[m][n] = ct * dp[m][n - 1] - st * p[m][n - 1];
          } else if (n > 1 && n != m) {
            if (m > n - 2) {
              p[m][n - 2] = 0.0;
            }
            if (m > n - 2) {
              dp[m][n - 2] = 0.0;
            }
            p[m][n] = ct * p[m][n - 1] - k[m][n] * p[m][n - 2];
            dp[m][n] =
                ct * dp[m][n - 1] - st * p[m][n - 1] - k[m][n] * dp[m][n - 2];
          }
        }
        //
        // TIME ADJUST THE GAUSS COEFFICIENTS
        //
        assert(time != otime);
        tc[m][n] = c[m][n] + dt * cd[m][n];
        if (m != 0) {
          tc[n][m - 1] = c[n][m - 1] + dt * cd[n][m - 1];
        }
        // } end of assertion.

        //
        // ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
        //
        final par = ar * p[m][n];
        double temp1, temp2;
        if (m == 0) {
          temp1 = tc[m][n] * cp[m];
          temp2 = tc[m][n] * sp[m];
        } else {
          temp1 = tc[m][n] * cp[m] + tc[n][m - 1] * sp[m];
          temp2 = tc[m][n] * sp[m] - tc[n][m - 1] * cp[m];
        }

        bt = bt - ar * temp1 * dp[m][n];
        bp = bp + (fm[m] * temp2 * par);
        br = br + (fn[n] * temp1 * par);
        //
        // SPECIAL CASE:  NORTH/SOUTH GEOGRAPHIC POLES
        //
        if (st == 0.0 && m == 1) {
          if (n == 1) {
            pp[n] = pp[n - 1];
          } else {
            pp[n] = ct * pp[n - 1] - k[m][n] * pp[n - 2];
          }
          final parp = ar * pp[n];
          bpp = bpp + (fm[m] * temp2 * parp);
        }

        D4 = D4 - 1;
        m = m + 1;
      }
    }
    if (st == 0.0) {
      bp = bpp;
    } else {
      bp = bp / st;
    }
    //
    // ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO
    // GEODETIC COORDINATES
    //
    final bx = -bt * ca - br * sa;
    final by = bp;
    final bz = bt * sa - br * ca;
    //
    // COMPUTE DECLINATION (DEC), INCLINATION (DIP) AND
    // TOTAL INTENSITY (TI)
    //
    final bh = sqrt((bx * bx) + (by * by));
    final ti = sqrt((bh * bh) + (bz * bz));
    final dec = degrees(atan2(by, bx));
    final dip = degrees(atan2(bz, bh));
    //
    // COMPUTE MAGNETIC GRID VARIATION IF THE CURRENT
    // GEODETIC POSITION IS IN THE ARCTIC OR ANTARCTIC
    // (I.E. GLAT > +55 DEGREES OR GLAT < -55 DEGREES)

    // OTHERWISE, SET MAGNETIC GRID VARIATION TO -999.0
    //
    var gv = -999.0;
    if (fabs(glat) >= 55) {
      if (glat > 0.0 && glon >= 0.0) gv = dec - glon;
      if (glat > 0.0 && glon < 0.0) gv = dec + fabs(glon);
      if (glat < 0.0 && glon >= 0.0) gv = dec + glon;
      if (glat < 0.0 && glon < 0.0) gv = dec - fabs(glon);
      if (gv > 180.0) gv = gv - 360.0;
      if (gv < -180.0) gv = gv + 360.0;
    }

    otime = time;
    oalt = alt;
    olat = glat;
    olon = glon;

    return GeoMagResult._(dec, dip, ti, bh, bx, by, bz, dlat, dlon, h, time);
  }

  static double radians(double degrees) => degrees * pi / 180;
  static double degrees(double radians) => radians * 180 / pi;
  static double fabs(double n) => n.abs();
}

class GeoMagResult {
  const GeoMagResult._(this.dec, this.dip, this.ti, this.bh, this.bx, this.by,
      this.bz, this.lat, this.lon, this.alt, this.time);
  final double dec;
  final double dip;
  final double ti;
  final double bh;
  final double bx;
  final double by;
  final double bz;
  final double lat;
  final double lon;
  final double alt;

  /// Years since the [WmmCof.epoch].
  final double time;
}
