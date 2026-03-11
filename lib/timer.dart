import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:kart_v0/services/timer_service.dart';

/// Displays a radial gauge showing the current lap time relative to the
/// best lap. The gauge maximum is always equal to the best lap (or a
/// sensible default of 90 s when no laps have been completed yet).
///
/// The purple marker sits at the gauge maximum to mark where the best
/// lap time is. Exceeding it means you're going slower — the arc simply
/// stays full.
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  void initState() {
    super.initState();
    TimerService.currentLapMs.addListener(_rebuild);
    TimerService.laps.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TimerService.currentLapMs.removeListener(_rebuild);
    TimerService.laps.removeListener(_rebuild);
    super.dispose();
  }

  static String _fmt(int ms) {
    final m   = ms ~/ 60000;
    final s   = (ms ~/ 1000) % 60;
    final ms2 = ms % 1000;
    return '$m:${s.toString().padLeft(2, '0')}:${ms2.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentMs = TimerService.currentLapMs.value;
    final bestMs    = TimerService.bestLapMs;

    // Gauge max = best lap duration (seconds), fallback 90 s
    final maxSec     = (bestMs ?? 90000) / 1000.0;
    final displaySec = (currentMs / 1000.0).clamp(0.0, maxSec);

    return Center(
      child: SizedBox(
        width: 225,
        height: 225,
        child: SfRadialGauge(
          axes: [
            RadialAxis(
              minimum: 0,
              maximum: maxSec,
              startAngle: 220,
              endAngle: 130,
              isInversed: true,
              tickOffset: -0.295,
              offsetUnit: GaugeSizeUnit.factor,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.30,
                thicknessUnit: GaugeSizeUnit.factor,
                color: Color(0xFF333333),
              ),
              showLabels: true,
              labelOffset: -0.40,
              minorTicksPerInterval: 4,
              majorTickStyle: const MajorTickStyle(
                length: 0.28,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 2,
                color: Colors.white,
              ),
              minorTickStyle: const MinorTickStyle(
                length: 0.08,
                lengthUnit: GaugeSizeUnit.factor,
                thickness: 1,
                color: Color.fromARGB(255, 141, 141, 141),
              ),
              axisLabelStyle: const GaugeTextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              ranges: [
                GaugeRange(
                  startValue: 0,
                  endValue: displaySec,
                  gradient: const SweepGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 255, 0, 51),
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                    stops: [0.0, 0.90, 1.0],
                  ),
                  startWidth: 0.30,
                  endWidth: 0.30,
                  sizeUnit: GaugeSizeUnit.factor,
                ),
              ],
              annotations: [
                // ── Purple best-lap marker (only shown once a lap exists) ──
                if (bestMs != null) ...[
                  GaugeAnnotation(
                    angle: 220,
                    positionFactor: 1.0,
                    widget: Transform.rotate(
                      angle: -50 * (3.14159 / 180),
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
                  GaugeAnnotation(
                    angle: 220,
                    positionFactor: 1.4,
                    widget: Text(
                      _fmt(bestMs),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],

                // ── Current lap time + lap number ─────────────────────────
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.1,
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _fmt(currentMs),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lap ${TimerService.lapCount + 1}',
                        style: const TextStyle(
                          fontSize: 12,
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
