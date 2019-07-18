import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geomag/geomag.dart';

Future<double> _getDeclination() async {
  final pos = await Geolocator().getLastKnownPosition() ??
      await Geolocator().getCurrentPosition();
  if (pos == null) return null;
  final result = await GeoMag().calculate(
      pos.latitude, pos.longitude, pos.altitude * 3.28084); // m -> ft
  return result.dec;
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _direction;
  double _declination;

  @override
  void initState() {
    super.initState();
    FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
    _getDeclination().then((dec) {
      setState(() {
        _declination = dec;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geomag Flutter Demo'),
        ),
        body: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Transform.rotate(
              angle: ((_direction ?? 0) * (math.pi / 180) * -1),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset('assets/compass.jpg'),
                  _declination == null
                      ? Container()
                      : Transform.rotate(
                          angle: _declination * math.pi / 180,
                          child: Column(
                            children: [
                              Text('True\nNorth\n(${_declination.round()}°)'),
                              Container(color: Colors.red, width: 1, height: 300,),
                            ],
                          ),
                        ),
                ],
              )),
        ),
      ),
    );
  }
}
