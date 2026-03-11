import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_maxSpeedKey, rounded);
    maxSpeedNotifier.value = rounded;
  }
}
