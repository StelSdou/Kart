import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kart_v0/app_theme.dart';
import 'package:kart_v0/services/settings_service.dart';

/// Defines the available driving behaviors.
/// Using an enum here is a best practice because it provides type safety
/// and makes it impossible to pass an invalid mode string elsewhere in the app.
enum DrivingMode { tour, sport, track }

/// A glassmorphic segmented control for switching [DrivingMode].
/// This widget is designed to be placed at the top level of the dashboard.
class DrivingModeSwitcher extends StatelessWidget {
  /// The currently active mode, usually held in the parent's state.
  final DrivingMode currentMode;
  /// Callback triggered when a user taps a different mode button.
  final ValueChanged<DrivingMode> onModeChanged;

  const DrivingModeSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // We wrap the switcher in a ValueListenableBuilder so that the UI 
    // automatically refreshes its colors if the user changes the theme in settings.
    return ValueListenableBuilder<AppTheme>(
      valueListenable: SettingsService.themeNotifier,
      builder: (context, theme, child) {
        return ClipRRect(
          // ClipRRect is required here to ensure the BackdropFilter blur 
          // doesn't "leak" outside the rounded corners of the container.
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.cardBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // We iterate over the enum values to dynamically create the buttons.
                children: DrivingMode.values
                    .where((mode) => mode != DrivingMode.track)
                    .map((mode) {
                  final isSelected = currentMode == mode;
                  return _ModeButton(
                    label: mode.name.toUpperCase(),
                    isSelected: isSelected,
                    theme: theme,
                    onTap: () => onModeChanged(mode),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A private helper widget for the individual buttons.
/// Private (_) because it shouldn't be used outside of this specific switcher.
class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final AppTheme theme;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // AnimatedContainer provides a smooth transition for the background color
      // when switching between selected and unselected states.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          // When selected, we show a very faint version of the theme's accent color
          // to give it that "glowing glass" feel.
          color: isSelected ? theme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.accent : theme.textPrimary.withOpacity(0.5),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
