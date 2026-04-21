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
  DrivingMode _currentMode = DrivingMode.tour;

  /// Stores the theme (Light/Dark) that was active before switching to Sport mode.
  /// This ensures switching back from Sport restores the user's previous preference.
  AppTheme _previousNonSportTheme = AppTheme.dark;

  @override
  void initState() {
    super.initState();
    RideService.init(); // Load persistent odometer data
    SettingsService.load(); // Load persistent settings (e.g. gauge choice)
    RideService.state.addListener(_rebuild);
    SettingsService.themeNotifier.addListener(_syncModeWithTheme);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _syncModeWithTheme() {
    if (!mounted) return;
    // If the theme is manually changed away from the Sport theme (via settings)
    // while we are still in Sport mode, sync the mode selector back to Tour.
    if (SettingsService.themeNotifier.value.id != 'Sport' &&
        _currentMode == DrivingMode.sport) {
      setState(() {
        _currentMode = DrivingMode.tour;
      });
    }
  }

  void _onModeChanged(DrivingMode mode) {
    final oldMode = _currentMode;
    setState(() {
      _currentMode = mode;
    });

    // Automatically switch the app theme based on the selected driving mode.
    if (mode == DrivingMode.sport) {
      // If entering Sport mode, remember what the theme was before it turned orange
      if (oldMode != DrivingMode.sport) {
        _previousNonSportTheme = SettingsService.themeNotifier.value;
      }
      // Use the Sport theme visually, but do not save it as the persistent default.
      SettingsService.themeNotifier.value = AppTheme.sport;
    } else if (oldMode == DrivingMode.sport) {
      // If leaving Sport mode, restore the previously active theme (Light or Dark)
      SettingsService.setTheme(_previousNonSportTheme);
    }
  }

  @override
  void dispose() {
    RideService.state.removeListener(_rebuild);
    SettingsService.themeNotifier.removeListener(_syncModeWithTheme);
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
            currentMode: _currentMode,
            onModeChanged: _onModeChanged,
            onUseCupertinoChanged: widget.onUseCupertinoChanged,
            currentUseCupertino: widget.currentUseCupertino,
          ),

          // ── Mode select ────────────────────────────────────────────────────
          Positioned(
            top: 50,
            right: 16,
            child: DrivingModeSwitcher(
              currentMode: _currentMode,
              onModeChanged: _onModeChanged,
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
        if (_currentMode == DrivingMode.track && !isIdle) const Laps(),
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
            if (_currentMode == DrivingMode.track && !isIdle) ...[
              const SizedBox(height: 16),
              const Laps(),
            ],
          ],
        ),
      ],
    );
  }
}