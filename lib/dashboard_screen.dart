<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:kart_v0/speedometer.dart';
import 'package:kart_v0/ride_stats.dart';
import 'package:kart_v0/laps.dart';
import 'package:kart_v0/settings_screen.dart';
import 'package:kart_v0/services/ride_service.dart';
=======
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

>>>>>>> old_ver

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
<<<<<<< HEAD
  bool _isTrackMode = false;
=======
  DrivingMode _currentMode = DrivingMode.tour;

  /// Stores the theme (Light/Dark) that was active before switching to Sport mode.
  /// This ensures switching back from Sport restores the user's previous preference.
  AppTheme _previousNonSportTheme = AppTheme.dark;
>>>>>>> old_ver

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    RideService.state.addListener(_rebuild);
=======
    RideService.init(); // Load persistent odometer data
    SettingsService.load(); // Load persistent settings (e.g. gauge choice)
    RideService.state.addListener(_rebuild);
    SettingsService.themeNotifier.addListener(_syncModeWithTheme);
>>>>>>> old_ver
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

<<<<<<< HEAD
  @override
  void dispose() {
    RideService.state.removeListener(_rebuild);
=======
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
>>>>>>> old_ver
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final rideState  = RideService.state.value;
    final isIdle     = rideState == RideState.idle;
    final isPaused   = rideState == RideState.paused;
=======
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
>>>>>>> old_ver
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
<<<<<<< HEAD
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────────
          isPortrait ? _portraitLayout(isIdle) : _landscapeLayout(isIdle),

          // ── Settings button ───────────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      onTrackModeChanged: (v) =>
                          setState(() => _isTrackMode = v),
                      currentTrackMode:      _isTrackMode,
                      onUseCupertinoChanged: widget.onUseCupertinoChanged,
                      currentUseCupertino:   widget.currentUseCupertino,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Mode badge ────────────────────────────────────────────────────
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 30, 40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isTrackMode ? 'Track Mode' : 'Normal Mode',
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 0, 51),
                  fontSize: 12,
=======
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
>>>>>>> old_ver
                ),
              ),
            ),
          ),
<<<<<<< HEAD

          // ── Bottom controls ───────────────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: isIdle
                  ? _ControlButton(
                      icon: Icons.play_circle_fill,
                      color: Colors.white,
                      size: 48,
                      tooltip: 'Start session',
                      onPressed: () => RideService.start(),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ControlButton(
                          icon: isPaused
                              ? Icons.play_circle_outline
                              : Icons.pause_circle_outline,
                          color: isPaused
                              ? const Color.fromARGB(255, 255, 0, 51)
                              : Colors.white,
                          tooltip: isPaused ? 'Resume' : 'Pause',
                          onPressed: isPaused
                              ? RideService.resume
                              : RideService.pause,
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          icon: Icons.stop_circle_outlined,
                          color: Colors.white,
                          tooltip: 'Stop & reset all',
                          onPressed: () => RideService.stop(),
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          icon: Icons.restart_alt,
                          color: Colors.white70,
                          tooltip: 'Reset stats',
                          onPressed: RideService.resetStats,
                        ),
                      ],
                    ),
            ),
          ),
=======
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
>>>>>>> old_ver
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
<<<<<<< HEAD
        const Speedometer(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: RideStats(),
        ),
        const Spacer(),
        if (_isTrackMode && !isIdle) const Laps(),
        const SizedBox(height: 64), // clearance for bottom controls
=======
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
>>>>>>> old_ver
      ],
    );
  }

  /// Landscape: gauge on the left, stats + laps stacked on the right.
  Widget _landscapeLayout(bool isIdle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
<<<<<<< HEAD
        const Speedometer(),
=======
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
>>>>>>> old_ver
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const RideStats(),
<<<<<<< HEAD
            if (_isTrackMode && !isIdle) ...[
=======
            if (_currentMode == DrivingMode.track && !isIdle) ...[
>>>>>>> old_ver
              const SizedBox(height: 16),
              const Laps(),
            ],
          ],
        ),
      ],
    );
  }
<<<<<<< HEAD
}

// ── Control button helper ──────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final double       size;
  final String       tooltip;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
=======
}
>>>>>>> old_ver
