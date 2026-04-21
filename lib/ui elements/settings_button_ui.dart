import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kart_v0/services/settings_service.dart';
import 'package:kart_v0/settings_screen.dart';
import '../app_theme.dart';
import 'driving_modes_ui.dart';

class SettingsButton extends StatefulWidget {
  final DrivingMode currentMode;
  final ValueChanged<DrivingMode> onModeChanged;
  final Function(bool)? onUseCupertinoChanged;
  final bool currentUseCupertino;

  const SettingsButton({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.onUseCupertinoChanged,
    this.currentUseCupertino = false,
  });

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: SettingsService.themeNotifier,
      builder: (context, theme, child) {
        return Positioned(
          top: 50,
          left: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.cardBorder, width: 1.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Use a microtask to ensure the button's ripple/tap state
                    // finishes before we start the heavy route transition.
                    Future.microtask(() {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: true,
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration: const Duration(milliseconds: 250),
                          // Keep the page in memory to prevent jank on second use
                          maintainState: true,
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              SettingsScreen(
                            onTrackModeChanged: (v) => widget.onModeChanged(
                              v ? DrivingMode.track : DrivingMode.tour,
                            ),
                            currentTrackMode: widget.currentMode == DrivingMode.track,
                            onUseCupertinoChanged: widget.onUseCupertinoChanged,
                            currentUseCupertino: widget.currentUseCupertino,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            return FadeTransition(
                              opacity: curvedAnimation,
                              child: ScaleTransition(
                                // A tiny scale makes the fade feel physical and smoother
                                scale: Tween<double>(begin: 0.98, end: 1.0)
                                    .animate(curvedAnimation),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white, // Ensures ripple is visible
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Icon(Icons.menu, color: theme.textPrimary, size: 26),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
