import 'package:flutter/material.dart';
import 'package:kart_v0/services/ride_service.dart';

/// Displays max speed, average speed, and distance.
/// Red while idle or paused, white while actively recording.
class RideStats extends StatefulWidget {
  const RideStats({super.key});

  @override
  State<RideStats> createState() => _RideStatsState();
}

class _RideStatsState extends State<RideStats> {
  @override
  void initState() {
    super.initState();
    RideService.state.addListener(_rebuild);
    RideService.maxSpeedKmh.addListener(_rebuild);
    RideService.avgSpeedKmh.addListener(_rebuild);
    RideService.distanceMeters.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RideService.state.removeListener(_rebuild);
    RideService.maxSpeedKmh.removeListener(_rebuild);
    RideService.avgSpeedKmh.removeListener(_rebuild);
    RideService.distanceMeters.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = RideService.state.value == RideState.recording;
    final maxSpeed    = RideService.maxSpeedKmh.value;
    final avgSpeed    = RideService.avgSpeedKmh.value;
    final distM       = RideService.distanceMeters.value;
    final distKm      = distM / 1000.0;
    final color       = isRecording
        ? Colors.white
        : const Color.fromARGB(255, 255, 0, 51);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatTile(label: 'MAX', value: maxSpeed.toStringAsFixed(1), unit: 'km/h', color: color),
        _StatTile(label: 'AVG', value: avgSpeed.toStringAsFixed(1), unit: 'km/h', color: color),
        _StatTile(
          label: 'DIST',
          value: distKm >= 1.0 ? distKm.toStringAsFixed(2) : distM.toStringAsFixed(0),
          unit:  distKm >= 1.0 ? 'km' : 'm',
          color: color,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color  color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: color),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}
