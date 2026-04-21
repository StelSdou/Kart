import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/services/settings_service.dart';
import '../odometer.dart';

class ArrowNeedlePainter extends CustomPainter {
  final double speedFraction; // 0.0 → 1.0
  final Color color;

  // Must match your RadialAxis defaults (no startAngle/endAngle set = 130° to 50°, 280° sweep)
  static const double _startDeg = 130.0;
  static const double _sweepDeg = 280.0;

  const ArrowNeedlePainter({required this.speedFraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final angleRad = (_startDeg + speedFraction * _sweepDeg) * math.pi / 180.0;

    // Needle geometry (pointing in the +x direction after rotation)
    final double tip        = radius * 0.93;  
    final double arrowBase  = tip - 10.0;     
    final double bodyHalf   = 5.0;            
    final double arrowHalf  = 5.0;           
    final double tail       = -radius * 0.23; 

    final path = Path()
      ..moveTo(tail, bodyHalf)
      ..lineTo(arrowBase, bodyHalf)
      ..lineTo(arrowBase, arrowHalf)
      ..lineTo(tip, 0)                  
      ..lineTo(arrowBase, -arrowHalf)
      ..lineTo(arrowBase, -bodyHalf)
      ..lineTo(tail, -bodyHalf)
      ..close();

    // ─────────────────────────────────────────────────────────────────
    // 1. GLOBAL DROP SHADOW
    // ─────────────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(center.dx + 4.0, center.dy + 6.0); 
    canvas.rotate(angleRad);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
    canvas.restore();

    // ─────────────────────────────────────────────────────────────────
    // 2. FLAT PHYSICAL NEEDLE BODY 
    // ─────────────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRad);

    // Flat shading: A very slight light catch on the top edge, 
    // flat true color in the middle, and a shadow on the bottom edge.
    final Color topEdge    = Color.lerp(color, Colors.white, 0.15)!; 
    final Color midColor   = color;
    final Color bottomEdge = Color.lerp(color, Colors.black, 0.45)!;

    final rect = Rect.fromLTRB(tail, -bodyHalf, tip, bodyHalf);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        // The middle 70% is now perfectly flat, no white streak
        colors: [topEdge, midColor, midColor, bottomEdge],
        stops: const [0.0, 0.15, 0.85, 1.0], 
      ).createShader(rect);

    canvas.drawPath(path, fillPaint);

    // ─────────────────────────────────────────────────────────────────
    // 3. SPECULAR RIM HIGHLIGHT
    // Keeps the cut edges looking sharp and realistic
    // ─────────────────────────────────────────────────────────────────
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withOpacity(0.25); // Softened this slightly too

    canvas.drawPath(path, rimPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(ArrowNeedlePainter old) => 
      old.speedFraction != speedFraction || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  HYPERREALISTIC GLASS LENS
//
//  Physics layers (bottom → top):
//   1.  Base tint          — faint blue-grey coating colour
//   2.  Fresnel vignette   — edges darken asymmetrically (Fresnel effect)
//   3.  Glass thickness    — centre is optically thicker → warm glow
//   4.  Caustic ring       — refracted-light ring, characteristic of watch crystal
//   5.  Diffuse highlight  — large soft dome of reflected light (1.0× parallax)
//   6.  Mid specular       — medium blob, offset from primary    (1.3× parallax)
//   7.  Hot spot           — bright ellipse                       (1.6× parallax)
//   8.  Micro glint        — pure white pin-point, zero blur      (1.8× parallax)
//   9.  Counter-reflection — opposite side, env. bounce          (0.3× parallax)
//  10.  Chromatic fringe   — rainbow aberration at the very rim
//  11.  Scratches + dust   — static surface micro-artifacts
//  12.  AR coating shift   — faint interference colour near edge
//  13.  Rim bevel arc      — bright stroke on the bevel, rotates with tilt
//  14.  Inner shadow ring  — bezel depth illusion
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  HYPERREALISTIC GLASS LENS (with stronger, more obvious tilt response)
// ─────────────────────────────────────────────────────────────────────────────
class GlassLensPainter extends CustomPainter {
  final double tiltX;
  final double tiltY;

  const GlassLensPainter({this.tiltX = 0.0, this.tiltY = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width  / 2;
    final cy     = size.height / 2;
    final center = Offset(cx, cy);
    final R      = size.width  / 2;
    final rect   = Rect.fromCircle(center: center, radius: R);

    // ── Light source position (increased sensitivity for testing) ─────────────
    final lx = cx + (-0.20 - tiltX * 0.55) * R;   // ← boosted from 0.42
    final ly = cy + (-0.28 - tiltY * 0.55) * R; // 0.55 is the sensitivity multiplier for the light position (higher = more exaggerated tilt response)

    canvas.save(); //
    canvas.clipPath(Path()..addOval(rect));

    // (All your beautiful layers stay exactly the same — only light position changed)
    // 1. BASE TINT
    canvas.drawCircle(center, R, Paint()..color = const Color.fromARGB(14, 130, 165, 255));

    // 2. FRESNEL VIGNETTE
    final vigCenter = Alignment(-tiltX * 0.18, -tiltY * 0.18);
    canvas.drawCircle(
      center, R,
      Paint()..shader = RadialGradient(
        center: vigCenter,
        radius: 1.0,
        colors: [Colors.transparent, Colors.black.withOpacity(0.07), Colors.black.withOpacity(0.42)],
        stops: const [0.48, 0.76, 1.0], // each number here is how far from the center the gradient color stop is, as a fraction of the radius. Adjust these to change where the Fresnel effect starts and how quickly it ramps up.
      ).createShader(rect),
    );

    // 3. GLASS THICKNESS GRADIENT
    final thickRect = Rect.fromCircle(center: center, radius: R * 0.88);
    canvas.drawCircle(
      center, R * 0.88,
      Paint()..shader = RadialGradient(
        colors: [const Color.fromARGB(10, 255, 245, 210), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(thickRect)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // 4. CAUSTIC RING
    final causticShift = Offset(tiltX * R * 0.06, tiltY * R * 0.06);
    canvas.drawCircle(
      center + causticShift, R * 0.81,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.14
        ..shader = SweepGradient(
          center: Alignment.center,
          colors: [Colors.white.withOpacity(0.03), Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01), Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
          stops: const [0.0, 0.18, 0.42, 0.58, 0.80, 1.0],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // 5. DIFFUSE HIGHLIGHT DOME (1.0× parallax)
    final diffuseRect = Rect.fromCenter(center: Offset(lx, ly), width: R * 1.55, height: R * 1.08);
    canvas.drawOval(
      diffuseRect,
      Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(0.24), Colors.white.withOpacity(0.09), Colors.transparent], stops: const [0.0, 0.52, 1.0]).createShader(diffuseRect)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // 6. MID SPECULAR
    final mx = cx + (-0.18 - tiltX * 0.55) * R;
    final my = cy + (-0.26 - tiltY * 0.55) * R;
    final midRect = Rect.fromCenter(center: Offset(mx, my), width: R * 0.72, height: R * 0.46);
    canvas.drawOval(
      midRect,
      Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(0.42), Colors.white.withOpacity(0.14), Colors.transparent], stops: const [0.0, 0.38, 1.0]).createShader(midRect)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // 7. HOT SPOT
    final hx = cx + (-0.24 - tiltX * 0.68) * R;
    final hy = cy + (-0.33 - tiltY * 0.68) * R;
    final hotRect = Rect.fromCenter(center: Offset(hx, hy), width: R * 0.34, height: R * 0.21);
    canvas.drawOval(
      hotRect,
      Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(0.88), Colors.white.withOpacity(0.38), Colors.transparent], stops: const [0.0, 0.32, 1.0]).createShader(hotRect)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
    );

    // 8. MICRO GLINT
    final gx = cx + (-0.26 - tiltX * 0.76) * R;
    final gy = cy + (-0.35 - tiltY * 0.76) * R;
    canvas.drawOval(Rect.fromCenter(center: Offset(gx, gy), width: R * 0.085, height: R * 0.052), Paint()..color = Colors.white.withOpacity(0.97));

    // 9–14. (All remaining layers unchanged — counter-reflection, chromatic fringe, scratches, AR coating, rim bevel, inner shadow)
    // ... (exactly the same code as you had before)

    // ── 9. COUNTER-REFLECTION
    final crx = cx + (0.10 + tiltX * 0.12) * R;
    final cry = cy + (0.52 + tiltY * 0.12) * R;
    final crRect = Rect.fromCenter(center: Offset(crx, cry), width: R * 1.05, height: R * 0.34);
    canvas.drawOval(crRect, Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(0.10), Colors.transparent], stops: const [0.0, 1.0]).createShader(crRect)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));

    // 10. CHROMATIC ABERRATION FRINGE
    canvas.drawCircle(
      center, R - 2.5,
      Paint()..style = PaintingStyle.stroke..strokeWidth = 4.5..shader = SweepGradient(
        center: Alignment.center,
        colors: [const Color.fromARGB(22, 255, 40, 40), const Color.fromARGB(12, 40, 40, 255), const Color.fromARGB(16, 40, 220, 80), const Color.fromARGB(14, 255, 220, 40), const Color.fromARGB(20, 180, 40, 255), const Color.fromARGB(22, 255, 40, 40)],
      ).createShader(rect),
    );

    // 11. MICRO-SCRATCHES & DUST (unchanged)
    final scratchPaint = Paint()..color = Colors.white.withOpacity(0.045)..strokeWidth = 0.65..style = PaintingStyle.stroke;
    const scratches = [[0.13, 0.19, 0.36, 0.23], [0.56, 0.09, 0.74, 0.16], [0.31, 0.56, 0.42, 0.59], [0.69, 0.73, 0.80, 0.69], [0.21, 0.86, 0.39, 0.83], [0.60, 0.44, 0.66, 0.47], [0.44, 0.31, 0.50, 0.27]];
    for (final s in scratches) {
      canvas.drawLine(Offset(size.width * s[0], size.height * s[1]), Offset(size.width * s[2], size.height * s[3]), scratchPaint);
    }
    final dustPaint = Paint()..color = Colors.white.withOpacity(0.065);
    const dusts = [[0.63, 0.23, 1.3], [0.36, 0.71, 1.6], [0.76, 0.56, 1.1], [0.19, 0.46, 0.9], [0.49, 0.86, 1.2], [0.84, 0.32, 0.8], [0.28, 0.14, 1.0]];
    for (final d in dusts) {
      canvas.drawCircle(Offset(size.width * d[0], size.height * d[1]), d[2] as double, dustPaint);
    }

    // 12. AR COATING
    canvas.drawCircle(center, R, Paint()..shader = RadialGradient(center: Alignment(-tiltX * 0.28, -tiltY * 0.28), radius: 1.0, colors: [Colors.transparent, Colors.transparent, const Color.fromARGB(9, 110, 190, 255), const Color.fromARGB(14, 255, 155, 80)], stops: const [0.0, 0.70, 0.87, 1.0]).createShader(rect));

    canvas.restore();

    // 13. RIM BEVEL ARC (unchanged)
    final rimAngle = math.atan2(-tiltY - 0.55, -tiltX - 0.35);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rimAngle);
    canvas.translate(-cx, -cy);
    canvas.drawCircle(center, R - 1.4, Paint()..style = PaintingStyle.stroke..strokeWidth = 3.2..shader = SweepGradient(colors: [Colors.white.withOpacity(0.00), Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.00), Colors.white.withOpacity(0.00)], stops: const [0.0, 0.12, 0.25, 0.38, 0.52, 1.0]).createShader(rect));
    canvas.restore();

    // 14. INNER SHADOW RING (unchanged)
    for (double i = 0; i < 6; i++) {
      canvas.drawCircle(center, R - i * 0.9, Paint()..color = Colors.black.withOpacity(math.max(0, 0.055 - i * 0.009))..style = PaintingStyle.stroke..strokeWidth = 1.6);
    }
  }

  @override
  bool shouldRepaint(GlassLensPainter old) => old.tiltX != tiltX || old.tiltY != tiltY;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPEEDOMETER (fixed + calibrated accelerometer tilt)
// ─────────────────────────────────────────────────────────────────────────────
class SpeedometerAnalog extends StatefulWidget {
  const SpeedometerAnalog({super.key});

  @override
  State<SpeedometerAnalog> createState() => _SpeedometerAnalogState();
}

class _SpeedometerAnalogState extends State<SpeedometerAnalog> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // Calibration: we record the "at-rest" gravity vector once so it works no matter how the phone is mounted in the kart
  double _baselineX = 0.0;
  double _baselineY = 0.0;
  bool _calibrated = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  static const double _lpf = 0.78; // snappier response than before

  @override
  void initState() {
    super.initState();
    RideService.speedKmh.addListener(_rebuild);
    RideService.state.addListener(_rebuild);

    _accelSub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (AccelerometerEvent e) {
        if (!mounted) return;

        final rawX = (e.x / 9.8).clamp(-1.0, 1.0);
        final rawY = (e.y / 9.8).clamp(-1.0, 1.0); // no hard-coded +9.8 anymore

        if (!_calibrated) {
          _baselineX = rawX;
          _baselineY = rawY;
          _calibrated = true;
        }

        final tiltX = ((rawX - _baselineX) * 1.8).clamp(-1.0, 1.0); // slight amplification
        final tiltY = ((rawY - _baselineY) * 1.8).clamp(-1.0, 1.0);

        setState(() {
          _tiltX = _tiltX * _lpf + tiltX * (1 - _lpf);
          _tiltY = _tiltY * _lpf + tiltY * (1 - _lpf);
        });
      },
      onError: (e) => debugPrint('Accelerometer error: $e'),
    );
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RideService.speedKmh.removeListener(_rebuild);
    RideService.state.removeListener(_rebuild);
    _accelSub?.cancel();
    super.dispose();
  }

  double getInterval(double max) {
    if (max <= 120) { return 10; }
    else if (max <= 240) { return 20; }
    if (max <= 320) { return 40; }
    if (max <= 480) { return 60; }
    return max / 6;
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = RideService.state.value == RideState.idle;
    final speed = RideService.speedKmh.value;
    final textColor = isIdle ? const Color.fromARGB(255, 255, 230, 0) : Colors.white;

    final size = MediaQuery.of(context).size.shortestSide * 0.9;

    return ValueListenableBuilder<double>(
      valueListenable: SettingsService.maxSpeedNotifier,
      builder: (context, gaugeMax, child) {
        final clampedSpeed = speed.clamp(0.0, gaugeMax);
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: clampedSpeed),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, animatedSpeed, child) {
            return SizedBox(
              width: size,
              height: size,
              child: SfRadialGauge(
                axes: [
                  // (your three RadialAxis exactly as before)
                  RadialAxis(
                    showLabels: false,
                    showTicks: false,
                    startAngle: 0,
                    endAngle: 360,
                    minimum: 0,
                    maximum: gaugeMax,
                    axisLineStyle: const AxisLineStyle(thickness: 0.6, thicknessUnit: GaugeSizeUnit.factor, color: Colors.black),
                  ),
                  RadialAxis(
                showLabels: false,
                showTicks: true,
                minorTicksPerInterval: getInterval(gaugeMax)/2,
                interval: getInterval(gaugeMax),
                minorTickStyle: const MinorTickStyle(
                  length: 0.04,
                  lengthUnit: GaugeSizeUnit.factor,
                  thickness: 1,
                  color: Colors.white38,
                ),
                majorTickStyle: const MajorTickStyle(
                  length: 0.04,
                  lengthUnit: GaugeSizeUnit.factor,
                  thickness: 3,
                  color: Colors.white54,
                ),
                // startAngle: 90,
                // endAngle: 360,
                minimum: 0,
                maximum: gaugeMax,
                axisLineStyle: const AxisLineStyle(thickness: 0.02, thicknessUnit: GaugeSizeUnit.factor, color: Color.fromARGB(30, 255, 255, 255)),
              ),
                  RadialAxis(
                    minimum: 0,
                    maximum: gaugeMax,
                    tickOffset: -0.52,
                    offsetUnit: GaugeSizeUnit.factor,
                    axisLineStyle: const AxisLineStyle(thickness: 0.6, thicknessUnit: GaugeSizeUnit.factor, color: Colors.transparent),
                    showLabels: true,
                    showFirstLabel: true,
                    showLastLabel: true,
                    interval: getInterval(gaugeMax),
                    labelOffset: 0.15,
                    minorTicksPerInterval: 3,
                    majorTickStyle: const MajorTickStyle(length: 0.1, lengthUnit: GaugeSizeUnit.factor, thickness: 2, color: Colors.white),
                    minorTickStyle: const MinorTickStyle(length: 0.05, lengthUnit: GaugeSizeUnit.factor, thickness: 1, color: Colors.white54),
                    axisLabelStyle: GaugeTextStyle(fontSize: size * 0.066, color: Colors.white, fontWeight: FontWeight.w500),
                    annotations: [
                      // White underlay, needle, black center, speed text, odometer (unchanged)
                      GaugeAnnotation(angle: 90, positionFactor: 0.0, widget: Container(width: size * 0.437, height: size * 0.437, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white70))),
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.0,
                        widget: SizedBox(
                          width: size,
                          height: size,
                          child: CustomPaint(
                            painter: ArrowNeedlePainter(speedFraction: animatedSpeed / gaugeMax, color: const Color.fromARGB(255, 255, 0, 51)),
                          ),
                        ),
                      ),
                      GaugeAnnotation(angle: 90, positionFactor: 0.0, widget: Container(width: size * 0.433, height: size * 0.433, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black))),
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.1,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${animatedSpeed.toInt()}', style: TextStyle(fontSize: size * 0.183, fontWeight: FontWeight.w600, color: textColor)),
                            Transform.translate(offset: Offset(0, size * 0.166), child: const Odometer()), // ODOMETER POSITION
                          ],
                        ),
                      ),
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.25,
                      widget: Text('km/h', style: TextStyle(fontSize: size * 0.05, color: Colors.white70, fontWeight: FontWeight.w500)),
                    ),
                      // ── HYPERREALISTIC GLASS (now calibrated + more visible) ──
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.0,
                        widget: SizedBox(
                          width: size,
                          height: size,
                          child: CustomPaint(
                            painter: GlassLensPainter(tiltX: _tiltX, tiltY: _tiltY),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}