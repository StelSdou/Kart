import 'dart:ui';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/services/settings_service.dart';

/// Displays max speed, average speed, and distance.
/// Red while idle or paused, white while actively recording.
///
/// Uses a glassmorphic panel to match the bottom control bar style.
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
    RideService.driveDuration.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {}); // Rebuild whenever any stat changes if it hasn't been disposed
  }

  @override
  void dispose() { // Remove listeners to prevent memory leaks and setState calls after disposal
    RideService.state.removeListener(_rebuild);
    RideService.maxSpeedKmh.removeListener(_rebuild);
    RideService.avgSpeedKmh.removeListener(_rebuild);
    RideService.distanceMeters.removeListener(_rebuild);
    RideService.driveDuration.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = RideService.state.value == RideState.recording;
    final maxSpeed    = RideService.maxSpeedKmh.value;
    final avgSpeed    = RideService.avgSpeedKmh.value;
    final distM       = RideService.distanceMeters.value;
    final distKm      = distM / 1000.0;
    final driveDuration = RideService.driveDuration.value;


    (String, String) formatDuration(Duration d) {
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      final units = hours > 0 ? 'hr:min:sec' :  'min:sec';
      return (units, hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds');
    }


     return ValueListenableBuilder<AppTheme>(          // ← ADD THIS
      valueListenable: SettingsService.themeNotifier,
     builder: (context, theme, child) {

      // Now theme.speedText replaces your textColor logic:
      final textColor = isRecording ? theme.accent : theme.speedText;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect( //
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), //16
          //padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.cardBorder,
              width: 1.0,
            ),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color.fromRGBO(0, 0, 0, 0.16),
            //     blurRadius: 20,
            //     offset: Offset(0, 10),
            //   ),
            // ],
          ),
          child: 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatTile(
                label: 'TIME',
                unit: formatDuration(driveDuration).$1,
                value: formatDuration(driveDuration).$2,
                color: theme.textPrimary,
              ),
              //const SizedBox(height: 16),
              Divider(
                color: theme.cardBorder,
                thickness: 1,
                //height: 24,
              ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: _StatTile(label: 'MAX', value: maxSpeed.toStringAsFixed(1), unit: 'km/h', color: theme.textPrimary),
                ),
              ),
              Expanded(
                child: Center(
                  child: _StatTile(label: 'AVG', value: avgSpeed.toStringAsFixed(1), unit: 'km/h', color: theme.textPrimary),
                ),
              ),
              Expanded(
                child: Center(
                  child: _StatTile(
                    label: 'DIST',
                    value: distKm >= 1.0 ? distKm.toStringAsFixed(2) : distM.toStringAsFixed(0),
                    unit: distKm >= 1.0 ? 'km' : 'm',
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          ],
          ),
        ),
      ),
    ),
      );
      }
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
    return ValueListenableBuilder<AppTheme>(          // ← ADD THIS
    valueListenable: SettingsService.themeNotifier,
    builder: (context, theme, child) {
      return
    
    
     Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
         SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: RideService.state.value == RideState.recording ? theme.textPrimary : theme.accent, fontFeatures: [FontFeature.tabularFigures()]),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(fontSize: 11, color: theme.textPrimary, ),
          ),
      ],
    );
    }
    );
  }
}
