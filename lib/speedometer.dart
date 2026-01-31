import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:kart_v0/Location.dart';
import 'package:geolocator/geolocator.dart';

class Speedometer extends StatefulWidget {
  const Speedometer({super.key});
  
  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  StreamSubscription<Position>? _posSub;
  double _speedKmh = 0.0;
  final double maxSpeed = 300.0; // Μέγιστη ταχύτητα στο ταχύμετρο (km/h)

  Position? _lastPos;

  @override
  void initState() {
    super.initState();
    _posSub = LocationService.positionStream.listen((pos) {
      double speedMps = pos.speed;

      // Fallback: compute speed from displacement if device reports NaN/zero speed
      if (speedMps.isNaN || speedMps <= 0) {
        if (_lastPos != null && pos.timestamp != null && _lastPos!.timestamp != null) {
          final dt = pos.timestamp!.difference(_lastPos!.timestamp!).inMilliseconds / 1000.0;
          if (dt > 0.1) {
            final dist = Geolocator.distanceBetween(_lastPos!.latitude, _lastPos!.longitude, pos.latitude, pos.longitude);
            speedMps = dist / dt; // meters per second
          }
        }
      }

      final s = (speedMps.isNaN ? 0.0 : speedMps * 3.6);
      setState(() => _speedKmh = s);

      _lastPos = pos;
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double displaySpeed = _speedKmh.clamp(0, maxSpeed);

    return Center(
      child: SizedBox(
        width: 225, // Ρυθμίστε το μέγεθος
        height: 225, // Ρυθμίστε το μέγεθος
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              // Ρυθμίσεις για να μοιάζει με το ημικύκλιο
              minimum: 0,
              maximum: maxSpeed,
              startAngle: 50, // Ξεκινάει από τις 180 μοίρες (κάτω αριστερά)
              endAngle: 310,     // Τελειώνει στις 0 μοίρες (κάτω δεξιά)

              tickOffset: -0.295, //offset των άσπρων γραμμών
              offsetUnit: GaugeSizeUnit.factor,
              // Οπτικές ρυθμίσεις
              axisLineStyle: const AxisLineStyle(
                thickness: 0.30, // Πάχος της γκρι γραμμής
                thicknessUnit: GaugeSizeUnit.factor,
                color: Color(0xFF333333), // Σκούρο γκρι για το μη χρησιμοποιούμενο μέρος
              ),

              showLabels: true,
              showFirstLabel: true,
              showLastLabel: true,
              labelOffset: -.45,
              // Ρυθμίσεις για τα μεγάλα ticks (0, 20, 40, 60, 80)
              //interval: 50, // Labels every 50 km/h (0, 50, 100, 150, 200, 250, 300)
              minorTicksPerInterval: 4, // Show minor ticks (and labels) between major ticks
              majorTickStyle: const MajorTickStyle(
                length: 0.28,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 2, //Πάχος των άσπρων γραμμών μέσα στο ταχύμετρο
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              minorTickStyle: const MinorTickStyle(
                length: 0.08,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 1,
                color: Color.fromARGB(255, 141, 141, 141),
              ),

              // Ρυθμίσεις για τα labels
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500
              ),
              
              // --- Ζώνες Χρωμάτων (Range) ---
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: displaySpeed,
                  gradient: const SweepGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 255, 0, 51),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                    // Stops: Πού τελειώνει το 1ο χρώμα και πού αρχίζει το 2ο (σε κλάσματα 0.0 έως 1.0)
                    stops: <double>[0.0, 0.90, 1.0], 
                  ),
                  startWidth: 0.30,
                  endWidth: 0.30,
                  sizeUnit: GaugeSizeUnit.factor,
                ),
              ],
              
              
              // --- Ένδειξη Ταχύτητας (Annotation) ---
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.10,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${displaySpeed.toInt()}',
                        style: const TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      // "km/h"
                      const Text(
                        'km/h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                // GaugeAnnotation(
                  
                //   positionFactor: .5,
                //   widget: Text(
                //     'km/h',
                //     style: TextStyle(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w400,
                //       color: Colors.white,
                //     ),
                //     ))
              ],
              
            ),
          ],
        ),
      ),
    );
  }
}
