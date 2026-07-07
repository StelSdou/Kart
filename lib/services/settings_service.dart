import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/app_theme.dart';

enum DrivingMode { tour, sport, track }

class SettingsService {
  static const String _maxSpeedKey = 'max_speed_kmh';
  static const String _designKey = 'speedometer_design';
  static const String _modeKey = 'driving_mode';
  static const String _tourThemeKey = 'preferred_tour_theme';

  static final ValueNotifier<double> maxSpeedNotifier = ValueNotifier<double>(320.0);
  static final ValueNotifier<String> designNotifier = ValueNotifier<String>('Default');
  static final ValueNotifier<DrivingMode> modeNotifier = ValueNotifier<DrivingMode>(DrivingMode.tour);
  static final ValueNotifier<AppTheme> preferredTourThemeNotifier = ValueNotifier<AppTheme>(AppTheme.dark);
  static final ValueNotifier<AppTheme> themeNotifier = ValueNotifier<AppTheme>(AppTheme.dark);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    designNotifier.value = prefs.getString(_designKey) ?? 'Default';
    
    final speedVal = prefs.getDouble(_maxSpeedKey) ?? 320.0;
    maxSpeedNotifier.value = (speedVal / 40).round() * 40.0;

    // Load preferred theme for Tour mode
    final tourThemeId = prefs.getString(_tourThemeKey) ?? 'Default';
    preferredTourThemeNotifier.value = AppTheme.all.firstWhere(
      (t) => t.id == tourThemeId && t.id != 'Sport',
      orElse: () => AppTheme.dark,
    );

    // Load mode
    final modeIndex = prefs.getInt(_modeKey) ?? 0;
    modeNotifier.value = DrivingMode.values[modeIndex];

    _updateVisualTheme();
  }

  /// Updates the actual active theme based on Mode + Preference
  static void _updateVisualTheme() {
    if (modeNotifier.value == DrivingMode.sport) {
      themeNotifier.value = AppTheme.sport;
    } else if (modeNotifier.value == DrivingMode.track) {
      // Track mode currently uses Dark, but can be customized later
      themeNotifier.value = AppTheme.dark;
    } else {
      themeNotifier.value = preferredTourThemeNotifier.value;
    }
  }

  static Future<void> setMode(DrivingMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
    modeNotifier.value = mode;
    _updateVisualTheme();
  }

  static Future<void> setTheme(AppTheme theme) async {
    if (theme.id == 'Sport') return; // Sport is a mode, not a selectable theme
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tourThemeKey, theme.id);
    preferredTourThemeNotifier.value = theme;
    _updateVisualTheme();
  }

  static Future<void> setMaxSpeed(double value) async {
    // Round to nearest 40 km/h to enforce 40 km/h steps
    final rounded = (value / 40).round() * 40.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxSpeedKey, rounded);
    maxSpeedNotifier.value = rounded;
  }

  static Future<void> setDesign(String value) async { // Speedometer design setter
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_designKey, value); // 2. Save to shared preferences
    designNotifier.value = value; // 3. Update the notifier to trigger UI updates
  }

  static Future<void> resetOdometer() async {
    await RideService.resetOdometer();
  }
}
