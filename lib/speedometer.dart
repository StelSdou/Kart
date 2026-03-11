import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/services/settings_service.dart';

/// Displays only the radial speed gauge.
/// The speed number is red while idle or paused, white while recording.
class Speedometer extends StatefulWidget {
  const Speedometer({super.key});

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer> {
  double _gaugeMax = 300.0;

  @override
  void initState() {
    super.initState();
    SettingsService.load().then((_) {
      if (mounted) setState(() => _gaugeMax = SettingsService.maxSpeedNotifier.value);
    });
    SettingsService.maxSpeedNotifier.addListener(_rebuild);
    RideService.speedKmh.addListener(_rebuild);
    RideService.state.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SettingsService.maxSpeedNotifier.removeListener(_rebuild);
    RideService.speedKmh.removeListener(_rebuild);
    RideService.state.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = RideService.state.value == RideState.recording;
    final speed       = RideService.speedKmh.value.clamp(0.0, _gaugeMax);
    final textColor   = isRecording
        ? Colors.white
        : const Color.fromARGB(255, 255, 0, 51);

    return SizedBox(
      width: 225,
      height: 225,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: _gaugeMax,
            startAngle: 90,
            endAngle: 360,
            tickOffset: -0.295,
            offsetUnit: GaugeSizeUnit.factor,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.30,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Color(0xFF333333),
            ),
            showLabels: true,
            showFirstLabel: true,
            showLastLabel: true,
            labelOffset: -0.45,
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
                endValue: speed,
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
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.10,
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${speed.toInt()}',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'km/h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
