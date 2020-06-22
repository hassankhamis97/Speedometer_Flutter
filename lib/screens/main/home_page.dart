import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:segment_display/segment_display.dart';
class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    calculateVelocity();
  }
  final Distance distance = new Distance();
  int _currentTime = 0;
  int _oldTime = 0;
  int _timeAt10 = 0;
  int _timeAt30 = 0;
  int _timeFrom10_30 = 0;
  int _timeFrom30_10 = 0;
  int _currentSpeed = 0;
  int _oldSpeed = 0;
  double _pastLongitude = 0;
  double _pastLatitute = 0;
  void calculateVelocity() async{
    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);
    StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(
            (Position position) {
          setState((){
            _currentTime = new DateTime.now().millisecondsSinceEpoch;
            double _difTime = (_currentTime - _oldTime) / 1000;
            double _currentDistance = distance.as(LengthUnit.Meter,
                new LatLng(_pastLatitute,_pastLongitude),new LatLng(position.latitude,position.longitude));
            if (_difTime > 0) {
              double x = _currentDistance / _difTime;
              _currentSpeed = x.toInt();
              if (_currentSpeed > 150 || _currentSpeed <= 3) {
                _currentSpeed = 0;
              }
              _oldTime = _currentTime;

              _pastLatitute = position.latitude;
              _pastLongitude = position.longitude;
              if (_currentSpeed > _oldSpeed) {
                if (_currentSpeed >= 10 && _oldSpeed < 10) {
                  _timeAt10 = _currentTime;
                }
                else if (_currentSpeed >= 30 && _oldSpeed < 30) {
                  _timeAt30 = _currentTime;
                  _timeFrom10_30 = _timeAt10 > 0
                      ? ((_timeAt30 - _timeAt10) / 1000).toInt()
                      : _timeFrom10_30;
                  _timeAt10 = 0;
                  print(_currentSpeed);
                }
              }

              else {
                if (_currentSpeed <= 30 && _oldSpeed > 30) {
                  _timeAt30 = _currentTime;
                }
                else if (_currentSpeed <= 10 && _oldSpeed > 10) {
                  _timeAt10 = _currentTime;
                  _timeFrom30_10 = _timeAt30 > 0
                      ? ((_timeAt10 - _timeAt30) / 1000).toInt()
                      : _timeFrom30_10;
                  _timeAt30 = 0;
                  print(_currentSpeed);
                }
              }
              _oldSpeed = _currentSpeed;
            }
          });
          print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
        });

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    _pastLatitute = position.latitude;
    _pastLongitude = position.longitude;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SfRadialGauge(
                  title: GaugeTitle(
                      text: 'Speedometer',
                      textStyle: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 150, ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0,
                          endValue: 50,
                          color: Colors.green,
                          startWidth: 10,
                          endWidth: 10),
                      GaugeRange(
                          startValue: 50,
                          endValue: 100,
                          color: Colors.orange,
                          startWidth: 10,
                          endWidth: 10),
                      GaugeRange(
                          startValue: 100,
                          endValue: 150,
                          color: Colors.red,
                          startWidth: 10,
                          endWidth: 10)
                    ], pointers: <GaugePointer>[
                      NeedlePointer(value: _currentSpeed*1.0)
                    ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                            widget: Container(
                                child: Text('$_currentSpeed KMH',
                                    style: TextStyle(
                                        fontSize: 25, fontWeight: FontWeight.bold))),
                            angle: 90,
                            positionFactor: 0.5)
                      ],
                    )]),
              Text(
                'Time from 10 to 30:',
                style: TextStyle(
                  fontSize: 27,
                ),
              ),
              SevenSegmentDisplay(
                value: '$_timeFrom10_30',
                size: 5,
                characterSpacing: 10.0,
                backgroundColor: Colors.transparent,
                segmentStyle: HexSegmentStyle(
                  enabledColor: Colors.green,
                  disabledColor: Colors.green.withOpacity(0.15),
                ),
              ),
              Text(
                'Seconds',
              ),

              Text(
                'Time from 30 to 10:',
                style: TextStyle(
                  fontSize: 27,

                ),
              ),
              SevenSegmentDisplay(
                value: '$_timeFrom30_10',
                size: 5,
                characterSpacing: 10.0,
                backgroundColor: Colors.transparent,
                segmentStyle: HexSegmentStyle(
                  enabledColor: Colors.green,
                  disabledColor: Colors.green.withOpacity(0.15),
                ),
              ),
              Text(
                'Seconds',
              ),
            ],
          ),
        ),
      ),
    );
  }
}