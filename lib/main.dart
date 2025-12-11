import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerScreen extends StatelessWidget {
  const SpeedometerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Η τιμή που εμφανίζεται στην εικόνα
    const double speedValue = 85.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 300, // Ρυθμίστε το μέγεθος
          height: 300, // Ρυθμίστε το μέγεθος
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                // Ρυθμίσεις για να μοιάζει με το ημικύκλιο
                minimum: 0,
                maximum: 100,
                startAngle: 50, // Ξεκινάει από τις 180 μοίρες (κάτω αριστερά)
                endAngle: 310,     // Τελειώνει στις 0 μοίρες (κάτω δεξιά)

                tickOffset: -0.35,
                offsetUnit: GaugeSizeUnit.factor,
                // Οπτικές ρυθμίσεις
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.30, // Πάχος της γραμμής
                  thicknessUnit: GaugeSizeUnit.factor,
                  color: Color(0xFF333333), // Σκούρο γκρι για το μη χρησιμοποιούμενο μέρος
                ),
                showLabels: true,
                labelOffset: -0.14,
                // Ρυθμίσεις για τα μεγάλα ticks (0, 20, 40, 60, 80)
                majorTickStyle: const MajorTickStyle(
                  length: 0.05,
                  lengthUnit: GaugeSizeUnit.factor,
                  thickness: 3.0,
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
                  // Κόκκινη/Σκούρο Κόκκινη Ζώνη (0-40)
                  GaugeRange(
                    startValue: 0,
                    endValue: speedValue,
                    color: const Color(0xFF8B0000), // Σκούρο Κόκκινο
                    startWidth: 0.30,
                    endWidth: 0.30,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  // Ελαφρώς πιο φωτεινή κόκκινη ζώνη (40-45)
                  
                  // Σκούρο γκρι/μαύρη ζώνη (45-80) - Αντιστοιχεί στο υπόλοιπο της axisLine
                  // Αυτή η ζώνη είναι προαιρετική αν έχουμε ρυθμίσει σωστά το axisLineStyle
                  // (Αν και η εικόνα δείχνει τη γραμμή στο 42, ας το μοντελοποιήσουμε)
                ],
                
                // --- Ένδειξη Ταχύτητας (Annotation) ---
                annotations: <GaugeAnnotation>[
                  // Μεγάλος αριθμός "42"
                  GaugeAnnotation(
                    widget: Row(
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
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    angle: 90, // Κέντρο
                    positionFactor: 0.5, // Κέντρο
                  ),
                ],
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeedometerScreen(),
    );
  }
}