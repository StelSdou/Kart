import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Speedometer extends StatelessWidget {
  const Speedometer({super.key});
  
  @override
  Widget build(BuildContext context) {
    const double speedValue = 45;
    const double maxSpeed = 100;

    return Center(
      child: SizedBox(
        width: 300, // Ρυθμίστε το μέγεθος
        height: 300, // Ρυθμίστε το μέγεθος
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              // Ρυθμίσεις για να μοιάζει με το ημικύκλιο
              minimum: 0,
              maximum: maxSpeed,
              startAngle: 50, // Ξεκινάει από τις 180 μοίρες (κάτω αριστερά)
              endAngle: 310,     // Τελειώνει στις 0 μοίρες (κάτω δεξιά)

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
                  endValue: speedValue,
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
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.15,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${speedValue.toInt()}',
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      // "km/h"
                      const Text(
                        'km/h',
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