import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kart_v0/Location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum RideState { idle, recording, paused }

/// Manages GPS and ride metrics.
///
/// States:
///   idle      → GPS off, no stats. Start button visible.
///   recording → GPS on, stats accumulating normally.
///   paused    → GPS on, stats frozen (displayed in red in the UI).
class RideService {
  RideService._();

  // ── Public state ──────────────────────────────────────────────────────────

  static final ValueNotifier<RideState> state          = ValueNotifier(RideState.idle);
  static final ValueNotifier<double>    speedKmh       = ValueNotifier(0.0);
  static final ValueNotifier<double>    maxSpeedKmh    = ValueNotifier(0.0);
  static final ValueNotifier<double>    avgSpeedKmh    = ValueNotifier(0.0);
  static final ValueNotifier<double>    distanceMeters = ValueNotifier(0.0);
  static final ValueNotifier<double>    odometer       = ValueNotifier(0.0);
  static final ValueNotifier<Duration>  driveDuration  = ValueNotifier(const Duration()); // Duration of the current drive, updated in real time while recording

  // ── Private state ─────────────────────────────────────────────────────────

  static StreamSubscription<Position>? _sub;
  static double    _speedSum   = 0.0;
  static int       _speedCount = 0;
  static Position? _lastPos;
  static Timer?    _speedResetTimer;
  static double    _lastSavedOdo = 0.0;
  static bool      _isInit       = false;
  static Timer?    _durationTimer; // Timer to track drive duration in real time

  // ── Controls ──────────────────────────────────────────────────────────────

  /// Load the lifetime odometer from persistent storage.
  static Future<void> init() async {
    if (_isInit) return;
    final prefs = await SharedPreferences.getInstance();
    odometer.value = prefs.getDouble('total_odometer_meters') ?? 0.0;
    _lastSavedOdo = odometer.value;
    _isInit = true;
  }

  /// Start GPS and begin accumulating stats.
  static Future<void> start() async {
    if (state.value != RideState.idle) return;
    await LocationService.start();
    WakelockPlus.enable(); // Prevent phone from turning off during ride
    _sub = LocationService.positionStream.listen(_onPosition, onError: (_) {});
    state.value = RideState.recording;
    _startTimer(); // Start the drive duration timer when the ride starts
  }

  /// Freeze stat accumulation. GPS stays on, speed gauge still updates.
  static void pause() {
    if (state.value != RideState.recording) return;
    state.value = RideState.paused;
    _stopTimer(); // Stop the drive duration timer when pausing the ride
  }

  /// Resume accumulating stats.
  static void resume() {
    if (state.value != RideState.paused) return;
    _lastPos    = null; // Discard last position to avoid a distance spike
    state.value = RideState.recording;
    _startTimer(); // Restart the drive duration timer when resuming the ride
  }

  /// Stop GPS, reset everything, return to idle.
  static Future<void> stop() async {
    _stopTimer(); // Stop the drive duration timer when stopping the ride
    driveDuration.value = Duration.zero; // Reset drive duration to zero when stopping the ride
    _resetInternals();
    await _sub?.cancel();
    _sub = null;
    await LocationService.stop();
    WakelockPlus.disable(); // Allow phone to sleep again
    await _saveOdometer(); // Ensure final progress is saved
    state.value = RideState.idle;
  }

  /// Reset stats only — GPS keeps running, stays in recording state.
  /// If currently paused, also resumes.
  static void resetStats() {
    if (state.value == RideState.idle) return;
    _stopTimer();
    driveDuration.value = Duration.zero; // Reset drive duration to zero when resetting stats
    _resetInternals();
    _startTimer();
    if (state.value == RideState.paused) state.value = RideState.recording;
  }

  /// Reset the lifetime odometer to zero.
  static Future<void> resetOdometer() async {
    odometer.value = 0.0; // Update UI immediately
    _lastSavedOdo = 0.0;  // Reset internal save tracker
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total_odometer_meters', 0.0);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _resetInternals() {
    maxSpeedKmh.value    = 0.0;
    avgSpeedKmh.value    = 0.0;
    distanceMeters.value = 0.0;
    speedKmh.value       = 0.0;
    _speedSum            = 0.0;
    _speedCount          = 0;
    _lastPos             = null;
    _speedResetTimer?.cancel();
    _speedResetTimer     = null;
    _durationTimer?.cancel(); // null aware and null check in case stop() is called without starting first
    _durationTimer       = null;
  }


  static void _startTimer() {  // Start a timer that updates driveDuration every second while recording

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      driveDuration.value += const Duration(seconds: 1);
    });
  }


  static void _stopTimer() { // Stop the drive duration timer when stopping or resetting the ride
    _durationTimer?.cancel();
    _durationTimer = null;
  }



  static Future<void> _saveOdometer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total_odometer_meters', odometer.value);
  }

  static void _onPosition(Position pos) {
    double mps = pos.speed;

    // Fallback: displacement-based speed when device returns NaN / 0
    final last = _lastPos;
    if ((mps.isNaN || mps <= 0) && last != null) {
      final dt =
          pos.timestamp.difference(last.timestamp).inMilliseconds / 1000.0;
      if (dt > 0.1) {
        final d = Geolocator.distanceBetween(
            last.latitude, last.longitude, pos.latitude, pos.longitude);
        mps = d / dt;
      }
    }

    final kmh = mps.isNaN ? 0.0 : mps * 3.6;

    // Speed gauge always updates (even while paused)
    speedKmh.value = kmh;

    // Reset speed to 0 if no updates for 3 seconds (when stopped)
    _speedResetTimer?.cancel();
    if (state.value != RideState.idle) {
      _speedResetTimer = Timer(const Duration(seconds: 3), () {
        speedKmh.value = 0.0;
      });
    }

    // Stats only accumulate while actively recording
    if (state.value == RideState.recording) {
      if (last != null) {
        final d = Geolocator.distanceBetween(
            last.latitude, last.longitude, pos.latitude, pos.longitude);
        if (!d.isNaN && d >= 0 && kmh > 1.0) { // Only accumulate distance if moving > 1 km/h
          distanceMeters.value += d;
          odometer.value += d;

          // Save every 500 meters to keep persistent data reasonably up to date
          if (odometer.value - _lastSavedOdo >= 100) {
            _saveOdometer();
            _lastSavedOdo = odometer.value;
          }
        }
      }

      if (kmh > maxSpeedKmh.value) maxSpeedKmh.value = kmh;

      if (kmh > 1.0) {
        _speedSum += kmh;
        _speedCount++;
        avgSpeedKmh.value = _speedSum / _speedCount;
      }
    }

    _lastPos = pos;
  }
}
