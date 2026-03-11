import 'package:flutter/material.dart';
import 'package:kart_v0/speedometer.dart';
import 'package:kart_v0/ride_stats.dart';
import 'package:kart_v0/laps.dart';
import 'package:kart_v0/settings_screen.dart';
import 'package:kart_v0/services/ride_service.dart';

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
  bool _isTrackMode = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final rideState  = RideService.state.value;
    final isIdle     = rideState == RideState.idle;
    final isPaused   = rideState == RideState.paused;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
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
                ),
              ),
            ),
          ),

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
        const Speedometer(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: RideStats(),
        ),
        const Spacer(),
        if (_isTrackMode && !isIdle) const Laps(),
        const SizedBox(height: 64), // clearance for bottom controls
      ],
    );
  }

  /// Landscape: gauge on the left, stats + laps stacked on the right.
  Widget _landscapeLayout(bool isIdle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Speedometer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const RideStats(),
            if (_isTrackMode && !isIdle) ...[
              const SizedBox(height: 16),
              const Laps(),
            ],
          ],
        ),
      ],
    );
  }
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
