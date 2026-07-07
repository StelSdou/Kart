import 'app_theme.dart';
import 'package:flutter/material.dart';
import 'package:kart_v0/speedometers/speedometer.dart';
import 'package:kart_v0/speedometers/speedometer_analog.dart';
import 'package:kart_v0/odometer.dart';
import 'package:kart_v0/ui%20elements/drive_stats_ui.dart';
import 'package:kart_v0/laps.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/services/settings_service.dart';
import 'package:kart_v0/ui%20elements/settings_button_ui.dart';
import 'package:kart_v0/ui%20elements/driving_modes_ui.dart';
import 'package:kart_v0/ui%20elements/bottom_controls_ui.dart';


class DashboardScreen extends StatefulWidget {
  final Function(bool)? onUseCupertinoChanged;
  final bool currentUseCupertino;

  const DashboardScreen({
    super.key,
    this.onUseCupertinoChanged,
    this.currentUseCupertino = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    RideService.init(); // Load persistent odometer data
    SettingsService.load(); // Load persistent settings (e.g. gauge choice)
    RideService.state.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RideService.state.removeListener(_rebuild);
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Widget _getSpeedometer() {
    switch (SettingsService.designNotifier.value) {
      case 'Retro Analog':
        return const SpeedometerAnalog();
      case 'Default':
      default:
        return const Speedometer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideState = RideService.state.value;
    final isIdle    = rideState == RideState.idle;
    final isPaused  = rideState == RideState.paused;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Animated theme-aware background gradient ──────────────────────
          ValueListenableBuilder<AppTheme>(
            valueListenable: SettingsService.themeNotifier,
            builder: (context, theme, _) => AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.gradientBegin, theme.gradientEnd],
                ),
              ),
            ),
          ),
          // ── Main content ──────────────────────────────────────────────────
          isPortrait ? _portraitLayout(isIdle) : _landscapeLayout(isIdle),

          // ── Settings button ───────────────────────────────────────────────
          SettingsButton(
            onUseCupertinoChanged: widget.onUseCupertinoChanged,
            currentUseCupertino: widget.currentUseCupertino,
          ),

          // ── Mode select ────────────────────────────────────────────────────
          Positioned(
            top: 50,
            right: 16,
            child: ValueListenableBuilder<DrivingMode>(
              valueListenable: SettingsService.modeNotifier,
              builder: (context, mode, _) => DrivingModeSwitcher(
                currentMode: mode,
                onModeChanged: (newMode) => SettingsService.setMode(newMode),
              ),
            ),
          ),

          // ── Bottom controls ───────────────────────────────────────────────
          RideControlsBar(isIdle: isIdle, isPaused: isPaused),
        ],
      ),
    );
  }

  // ── Layouts ────────────────────────────────────────────────────────────────

  /// Portrait: gauge on top, stats below it, laps (track mode) at the bottom.
  Widget _portraitLayout(bool isIdle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: SettingsService.designNotifier,
              builder: (context, design, _) => _getSpeedometer(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: RideStats(),
          ),
        ),
        const Spacer(),
        ValueListenableBuilder<DrivingMode>(
          valueListenable: SettingsService.modeNotifier,
          builder: (context, mode, _) => 
            (mode == DrivingMode.track && !isIdle) ? const Laps() : const SizedBox.shrink(),
        ),
        const SizedBox(height: 16), // clearance for bottom controls
      ],
    );
  }

  /// Landscape: gauge on the left, stats + laps stacked on the right.
  Widget _landscapeLayout(bool isIdle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: SettingsService.designNotifier,
              builder: (context, design, _) => _getSpeedometer(),
            ),
            Positioned(
              top: 100,
              left: 50,
              child: Odometer(),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const RideStats(),
            ValueListenableBuilder<DrivingMode>(
              valueListenable: SettingsService.modeNotifier,
              builder: (context, mode, _) => mode == DrivingMode.track && !isIdle 
                ? Column(children: [const SizedBox(height: 16), const Laps()])
                : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}