import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD

class SettingsService {
  static const String _maxSpeedKey = 'max_speed_kmh';
  static final ValueNotifier<double> maxSpeedNotifier = ValueNotifier<double>(300.0);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getDouble(_maxSpeedKey) ?? 300.0;
    final rounded = (val / 50).round() * 50.0;
    maxSpeedNotifier.value = rounded;
  }

  static Future<void> setMaxSpeed(double value) async {
    // Round to nearest 50 km/h to enforce 50 km/h steps
    final rounded = (value / 50).round() * 50.0;
=======
import 'package:kart_v0/services/ride_service.dart';
import 'package:kart_v0/app_theme.dart';

class SettingsService {
  static const String _maxSpeedKey = 'max_speed_kmh';
  static const String _designKey = 'speedometer_design';
  static final ValueNotifier<double> maxSpeedNotifier = ValueNotifier<double>(320.0);
  static final ValueNotifier<String> designNotifier = ValueNotifier<String>('Default');
  static final ValueNotifier<AppTheme> themeNotifier = ValueNotifier<AppTheme>(AppTheme.dark);


  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getDouble(_maxSpeedKey) ?? 320.0;
    designNotifier.value = prefs.getString(_designKey) ?? 'Default';
    final rounded = (val / 40).round() * 40.0;
    maxSpeedNotifier.value = rounded;

    final themeId = prefs.getString('app_theme') ?? 'Default';
    AppTheme loadedTheme = AppTheme.all.firstWhere(
      (t) => t.id == themeId,
      orElse: () => AppTheme.dark,
    );

    // If the app was closed in Sport mode, revert to the Default theme on restart.
    if (loadedTheme.id == 'Sport') loadedTheme = AppTheme.dark;

    themeNotifier.value = loadedTheme;
  }

  static Future<void> setTheme(AppTheme theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_theme', theme.id);
  themeNotifier.value = theme;
}

  static Future<void> setMaxSpeed(double value) async {
    // Round to nearest 40 km/h to enforce 40 km/h steps
    final rounded = (value / 40).round() * 40.0;
>>>>>>> old_ver
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxSpeedKey, rounded);
    maxSpeedNotifier.value = rounded;
  }
<<<<<<< HEAD
=======

  static Future<void> setDesign(String value) async { // Speedometer design setter
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_designKey, value); // 2. Save to shared preferences
    designNotifier.value = value; // 3. Update the notifier to trigger UI updates
  }

  static Future<void> resetOdometer() async {
    await RideService.resetOdometer();
  }
>>>>>>> old_ver
}
