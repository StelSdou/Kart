import 'dart:math' as math;
import 'package:kart_v0/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/services/settings_service.dart';
import '../odometer.dart';

class ArrowNeedlePainter extends CustomPainter {
  final double speedFraction; // 0.0 → 1.0
  final Color color;

  // Must match your RadialAxis defaults (no startAngle/endAngle set = 130° to 50°, 280° sweep)
  static const double _startDeg = 90.0;
  static const double _sweepDeg = 270.0;

  const ArrowNeedlePainter({required this.speedFraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final angleRad = (_startDeg + speedFraction * _sweepDeg) * math.pi / 180.0;

    // Needle geometry (pointing in the +x direction after rotation)
    final double tip        = radius * 0.93;  
    final double arrowBase  = tip - 10.0;     
    final double bodyHalf   = 4.0;            
    final double arrowHalf  = 4.0;           
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

/// Displays only the radial speed gauge.
/// The speed number is red while idle or paused, white while recording.
class Speedometer extends StatefulWidget {
  const Speedometer({super.key});

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {

  @override
  void initState() {
    super.initState();
    RideService.speedKmh.addListener(_rebuild);
    RideService.state.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RideService.speedKmh.removeListener(_rebuild);
    RideService.state.removeListener(_rebuild);
    super.dispose();
  }

  double getMinorTicks(double max) {
    if (max <= 120) { return 2; }
    else if (max <= 240) { return 10; }
    if (max == 320) { return 20; }
    if (max <= 480) { return 30; }
    return max / 20;
  }

  double getInterval(double max) {
    if (max <= 120) { return 10; }
    if (max <= 320) { return 40; }
    if (max <= 480) { return 60; }
    return max / 6;
  }

  /// Shifts the lightness of a color by [delta] (positive = lighter, negative = darker).
  /// Handles semi-transparent colors gracefully by normalising low-alpha ones first.
  Color _adjustLightness(Color c, double delta) {
    // If the color is nearly transparent, give it enough opacity to be useful
    final effective = c.alpha < 60 ? c.withAlpha(180) : c;
    final hsl = HSLColor.fromColor(effective);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .toColor()
        .withAlpha(effective.alpha);
  }

  //DO NOT DELETE
  @override
  Widget build(BuildContext context) {
    final isIdle = RideService.state.value == RideState.idle;
    final speed  = RideService.speedKmh.value;

    final size = MediaQuery.of(context).size.shortestSide * 0.8;

    return ValueListenableBuilder<AppTheme>(
      valueListenable: SettingsService.themeNotifier,
      builder: (context, theme, child) {

        final textColor = isIdle ? theme.accent : theme.speedText;

        return ValueListenableBuilder<double>(
          valueListenable: SettingsService.maxSpeedNotifier,
          builder: (context, gaugeMax, child) {
            final clampedSpeed = speed.clamp(0.0, gaugeMax);
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clampedSpeed),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, animatedSpeed, child) {

                // ── Depth: outer shadow + subtle accent glow ──────────────
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   boxShadow: [
                      // Main drop shadow – gives the gauge physical weight
                      // BoxShadow(
                      //   color: Colors.black.withOpacity(0.55),
                      //   blurRadius: size * 0.07,
                      //   offset: Offset(0, size * 0.025),
                      // ),
                      // Ambient accent glow (very subtle, theme-aware)
                      // BoxShadow(
                      //   color: theme.accent.withOpacity(0.10),
                      //   blurRadius: size * 0.12,
                      //   spreadRadius: size * 0.015,
                      // ),
                  //   ],
                  // ),
                  child: SfRadialGauge(
                    axes: [

                      // ── Layer 1: Bezel fill ───────────────────────────────
                      RadialAxis(
                        showLabels: false,
                        showTicks: false,
                        startAngle: 0,
                        endAngle: 360,
                        minimum: 0,
                        maximum: gaugeMax,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.55,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: theme.speedRing,
                        ),
                      ),

                      // ── Layer 2: Outer rim highlight (top-left light source) ──
                      // A thin bright ring at the very edge of the bezel simulates
                      // an overhead light catching the chamfered rim.
                      RadialAxis(
                        showLabels: false,
                        showTicks: false,
                        startAngle: 0,
                        endAngle: 360,
                        minimum: 0,
                        maximum: gaugeMax,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.018,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.white.withOpacity(0.14),
                        ),
                      ),

                      // ── Layer 3: Inner bezel edge shadow ──────────────────
                      // Darkens the inner lip where the bezel meets the gauge face,
                      // making the gauge face look recessed / sunken.
                      RadialAxis(
                        showLabels: false,
                        showTicks: false,
                        startAngle: 0,
                        endAngle: 360,
                        minimum: 0,
                        maximum: gaugeMax,
                        tickOffset: -0.47,
                        offsetUnit: GaugeSizeUnit.factor,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.025,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.black.withOpacity(0.35),
                        ),
                      ),

                      // ── Layer 4: Tick-only axis (inner ring) ──────────────
                      RadialAxis(
                        showLabels: false,
                        showTicks: true,
                        minorTicksPerInterval: getInterval(gaugeMax) / 2,
                        interval: getInterval(gaugeMax),
                        minorTickStyle: MinorTickStyle(
                          length: 0.04,
                          lengthUnit: GaugeSizeUnit.factor,
                          thickness: 1,
                          color: theme.textPrimary,
                        ),
                        majorTickStyle: MajorTickStyle(
                          length: 0.04,
                          lengthUnit: GaugeSizeUnit.factor,
                          thickness: 3,
                          color: theme.textPrimary,
                        ),
                        startAngle: 90,
                        endAngle: 360,
                        minimum: 0,
                        maximum: gaugeMax,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.02,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Color.fromARGB(30, 255, 255, 255),
                        ),
                      ),

                      RadialAxis(
                        showLabels: false,
                        showTicks: false,
                        startAngle: 0,
                        endAngle: 360,
                        minimum: 0,
                        maximum: gaugeMax,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.02,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Color.fromARGB(30, 255, 255, 255),
                        ),
                      ),

                      // ── Layer 5: Main gauge face (labels, ticks, arc, annotations) ──
                      RadialAxis(
                        minimum: 0,
                        maximum: gaugeMax,
                        startAngle: 90,
                        endAngle: 360,
                        tickOffset: -0.47,
                        offsetUnit: GaugeSizeUnit.factor,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.55,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.transparent,
                        ),
                        showLabels: true,
                        showFirstLabel: true,
                        showLastLabel: true,
                        interval: getInterval(gaugeMax),
                        labelOffset: 0.16,
                        minorTicksPerInterval: 3,
                        majorTickStyle: MajorTickStyle(
                          length: 0.1,
                          lengthUnit: GaugeSizeUnit.factor,
                          thickness: 3,
                          color: theme.textPrimary,
                        ),
                        minorTickStyle: MinorTickStyle(
                          length: 0.06,
                          lengthUnit: GaugeSizeUnit.factor,
                          thickness: 1,
                          color: theme.textPrimary,
                        ),
                        axisLabelStyle: GaugeTextStyle(
                          fontSize: size * 0.07,
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        ranges: [
                          // GaugeRange(
                          //   startValue: 0,
                          //   endValue: clampedSpeed,
                          //   // Starts fully transparent so the arc "fades in" from zero,
                          //   // peaks at the accent colour, then burns to white at the tip
                          //   // — like a glowing needle edge.
                          //   gradient: SweepGradient(
                          //     colors: [
                          //       theme.accent.withOpacity(0.0),   // fade-in start
                          //       theme.accent.withOpacity(0.6),   // ramp up
                          //       theme.accent,                    // full colour
                          //       const Color(0xFFFFFFFF),         // glowing white tip
                          //     ],
                          //     stops: const [0.0, 0.55, 0.88, 1.0],
                          //   ),
                          //   startWidth: 0.4,
                          //   endWidth: 0.4,
                          //   sizeUnit: GaugeSizeUnit.factor,
                          // ),
                        ],
                        annotations: [

                          // ── Center circle with depth ────────────────────
                          // Radial gradient offset top-left simulates a convex glass dome
                          // lit from above. BoxShadow adds physical weight.
                          GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.0,
                        widget: SizedBox(
                          width: size,
                          height: size,
                          child: CustomPaint(
                            painter: ArrowNeedlePainter(speedFraction: animatedSpeed / gaugeMax, color: theme.needleColor),
                          ),
                        ),
                      ),
                           GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.0,
                            widget: Container(
                              width: size * 0.45,
                              height: size * 0.45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                           ),
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.0,
                            widget: Container(
                              width: size * 0.45,
                              height: size * 0.45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // gradient: RadialGradient(
                                //   center: const Alignment(-0.30, -0.40),
                                //   radius: 0.88,
                                //   colors: [
                                //     _adjustLightness(theme.speedCenter, 0.20),  // highlight
                                //     theme.speedCenter,                           // mid
                                //     _adjustLightness(theme.speedCenter, -0.22), // shadow
                                //   ],
                                //   stops: const [0.0, 0.52, 1.0],
                                // ),
                                boxShadow: [
                                  // Drop shadow – depth
                                  BoxShadow(
                                    color: theme.speedCenter.withOpacity(0.6),
                                    blurRadius: size * 0.05,
                                    //offset: Offset(size * 0.012, size * 0.018),
                                  ),
                                  // Counter-shadow highlight top-left edge
                                  // BoxShadow(
                                  //   color: Colors.white.withOpacity(0.07),
                                  //   blurRadius: size * 0.025,
                                  //   offset: Offset(-size * 0.008, -size * 0.010),
                                  // ),
                                ],
                              ),
                              // ── Specular highlight (glossy lens flare) ──
                              // A small blurred oval near the top-left mimics
                              // a light reflection on a curved glass surface.
                              // child: Align(
                              //   alignment: const Alignment(-0.28, -0.52),
                              //   child: Container(
                              //     width: size * 0.115,
                              //     height: size * 0.055,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(size * 0.04),
                              //       color: Colors.white.withOpacity(0.22),
                              //     ),
                              //   ),
                              // ),
                            ),
                          ),

                          // ── Speed number + odometer ──────────────────────
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.1,
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${clampedSpeed.toInt()}',
                                  style: TextStyle(
                                    fontSize: size * 0.2,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                    shadows: [
                                      // Subtle text shadow for legibility over the gradient
                                      Shadow(
                                        color: Colors.black.withOpacity(0.40),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -size * 0.05),
                                  child: const Odometer(),
                                ),
                              ],
                            ),
                          ),

                          // ── km/h label ───────────────────────────────────
                          GaugeAnnotation(
                            angle: 10,
                            positionFactor: 1,
                            widget: Text(
                              'km/h',
                              style: TextStyle(
                                fontSize: size * 0.056,
                                fontWeight: FontWeight.w600,
                                color: theme.accent,
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
      },
    );
  }
}