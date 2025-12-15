import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Timerometer extends StatelessWidget {
  const Timerometer({super.key});
  
  @override
  Widget build(BuildContext context) {
    double locationTopTime = 220;
    int degTopTime = 50;
    int bestTime = 60;

    double sec = 35;
    double maxTime = bestTime.toDouble();

    return Center(
      child: SizedBox(
        width: 300, // Ρυθμίστε το μέγεθος
        height: 300, // Ρυθμίστε το μέγεθος
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              // Ρυθμίσεις για να μοιάζει με το ημικύκλιο
              minimum: 0,
              maximum: maxTime,
              startAngle: 220,
              endAngle: 130,
              isInversed: true,

              tickOffset: -0.3,
              offsetUnit: GaugeSizeUnit.factor,
              // Οπτικές ρυθμίσεις
              axisLineStyle: const AxisLineStyle(
                thickness: 0.30, // Πάχος της γραμμής
                thicknessUnit: GaugeSizeUnit.factor,
                color: Color(0xFF333333), // Σκούρο γκρι για το μη χρησιμοποιούμενο μέρος
              ),
              showLabels: true,
              labelOffset: -0.4,
              // Ρυθμίσεις για τα μεγάλα ticks (0, 20, 40, 60, 80)
              majorTickStyle: const MajorTickStyle(
                length: 0.29,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 1.5,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              // Ρυθμίσεις για τα labels
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500
              ),
              
              // --- Ζώνες Χρωμάτων (Range) ---
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: sec,
                  gradient: const SweepGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 255, 0, 51),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                    // Stops: Πού τελειώνει το 1ο χρώμα και πού αρχίζει το 2ο (σε κλάσματα 0.0 έως 1.0)
                    stops: <double>[0.0, 0.95, 1.0], 
                  ),
                  startWidth: 0.30,
                  endWidth: 0.30,
                  sizeUnit: GaugeSizeUnit.factor,
                ),
              ],
              
              // --- Ένδειξη Ταχύτητας (Annotation) ---
              annotations: <GaugeAnnotation>[

                //μοβ γραμμή 
                GaugeAnnotation(
                  angle: locationTopTime, 
                  positionFactor: 1,
                  widget: Transform.rotate(
                    // 50 μοίρες 
                    angle: -degTopTime * (3.14 / 180), 
                    child: Container(
                        width: 5.0,
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.purple, 
                            borderRadius: BorderRadius.circular(2.0),
                        ),
                    ),
                  ),
                ),
                
                //μοβ best Score
                GaugeAnnotation(
                  angle: locationTopTime, 
                  positionFactor: 1.3,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                    Text(
                      '$bestTime',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.purple,
                      ),
                    ),
                    ]
                  ),
                ),

                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.15,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${sec.toInt()}',
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      // "km/h"
                      const Text(
                        'Sec',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
            ),
          ],
        ),
      ),
    );
  }
}