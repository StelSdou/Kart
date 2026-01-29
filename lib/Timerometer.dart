import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Αυτό το widget εμφανίζει ένα χρονόμετρο με ακρίβεια χιλιοστού.
// Ξεκινάει αυτόματα κατά το initState() και σταματάει όταν φτάσει
// στο 1:30.000 (90.000 ms). Μπορείτε αργότερα να εκθέσετε start/stop
// μεθόδους αν θέλετε χειροκίνητο έλεγχο.
class Timerometer extends StatefulWidget {
  const Timerometer({super.key});

  @override
  _TimerometerState createState() => _TimerometerState();
}

class _TimerometerState extends State<Timerometer> {
  // Χρησιμοποιούμε το `Stopwatch` για ακριβή μέτρηση χρόνου σε ms
  final Stopwatch _stopwatch = Stopwatch();
  // Περιοδικός Timer που προκαλεί ενημέρωση της UI (rebuild)
  Timer? _ticker;

  // Στόχος: 1 λεπτό 30 δευτερόλεπτα (1:30.000). Ο χρόνος θα σταματήσει ακριβώς εδώ.
  static const Duration _targetDuration = Duration(minutes: 1, seconds: 30);

  @override
  void initState() {
    super.initState();

    // Ξεκινάει αυτόματα το `Stopwatch`.
    _stopwatch.start();
    // Δημιουργούμε έναν περιοδικό Timer (κάθε 10ms) για να ενημερώνουμε την οθόνη.
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      final int elapsedMs = _stopwatch.elapsedMilliseconds;
      // Αν φτάσουμε τον στόχο, σταματάμε και ακυρώνουμε τον Timer.
      if (elapsedMs >= _targetDuration.inMilliseconds) {
        // Σταματάμε ακριβώς στο στόχο και ακυρώνουμε τον Timer.
        _stopwatch.stop();
        _ticker?.cancel();
        setState(() {}); // Ενημερώνουμε την UI για να δείξει την τελική τιμή.
      } else {
        setState(() {}); // Ανανεώνουμε την UI με τον τρέχοντα χρόνο.
      }
    });
  }

  @override
  void dispose() {
    // Καθαρίζουμε τους πόρους όταν το widget αφαιρείται από το δέντρο.
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // Μετατρέπει milliseconds σε μορφή m:ss:ms (π.χ. 1:30:000)
  String _formatTimeFromMs(int ms) {
    // Πλήθος λεπτών (ολόκληρα λεπτά)
    final int minutes = ms ~/ 60000;
    // Υπόλοιπα δευτερόλεπτα στο τρέχον λεπτό
    final int seconds = (ms ~/ 1000) % 60;
    // Υπολοιπόμενα milliseconds
    final int milliseconds = ms % 1000;

    final String secStr = seconds.toString().padLeft(2, '0');
    final String msStr = milliseconds.toString().padLeft(3, '0');

    return '$minutes:$secStr:$msStr';
  }

  @override
  Widget build(BuildContext context) {
    // Συντεταγμένες/γωνίες για τις annotations στο gauge
    const double locationTopTime = 220;
    const int degTopTime = 50;

    const int bestTime = 90; 

    // Ο χρόνος που θα εμφανίσουμε (κλειδωμένος στην τιμή στόχου αν την υπερβούμε)
    final int elapsedMs = (_stopwatch.elapsedMilliseconds >= _targetDuration.inMilliseconds)
        ? _targetDuration.inMilliseconds
        : _stopwatch.elapsedMilliseconds;

    // Το μέγιστο της κλίμακας είναι 90 δευτερόλεπτα (1:30)
    final double maxTime = _targetDuration.inSeconds.toDouble(); // 90 seconds
    // Χρόνος σε δευτερόλεπτα για να γεμίσει σωστά το range του gauge
    final double elapsedSeconds = elapsedMs / 1000.0;

    return Center(
      child: SizedBox(
        width: 225, // Ρυθμίστε το μέγεθος
        height: 225, // Ρυθμίστε το μέγεθος
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              // Ρυθμίσεις για να μοιάζει με το ημικύκλιο
              minimum: 0,
              maximum: maxTime,
              startAngle: 220,
              endAngle: 130,
              isInversed: true,

              tickOffset: -0.295, //offset των άσπρων γραμμών
              offsetUnit: GaugeSizeUnit.factor,
              // Οπτικές ρυθμίσεις
              axisLineStyle: const AxisLineStyle(
                thickness: 0.30, // Πάχος της γκρι γραμμής
                thicknessUnit: GaugeSizeUnit.factor,
                color: Color(0xFF333333), // Σκούρο γκρι για το μη χρησιμοποιούμενο μέρος
              ),

              showLabels: true,
              labelOffset: -0.40,
              // Ρυθμίσεις για τα μεγάλα ticks (0, 20, 40, 60, 80)
              majorTickStyle: const MajorTickStyle(
                length: 0.28,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 2, //Πάχος των άσπρων γραμμών μέσα στο χρονόμετρο
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
                fontWeight: FontWeight.w500,
              ),

              // --- Ζώνες Χρωμάτων (Range) ---
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: elapsedSeconds.clamp(0.0, maxTime),
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
                // μοβ γραμμή
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

                // μοβ best Score
                GaugeAnnotation(
                  angle: locationTopTime,
                  positionFactor: 1.4,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '$bestTime',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Εμφάνιση χρόνου στο κέντρο σε μορφή m:ss:ms
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.25,
                  widget: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _formatTimeFromMs(elapsedMs),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 255, 255, 255),
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