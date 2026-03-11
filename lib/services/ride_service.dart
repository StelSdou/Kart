import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kart_v0/Location.dart';

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

  // ── Private state ─────────────────────────────────────────────────────────

  static StreamSubscription<Position>? _sub;
  static double    _speedSum   = 0.0;
  static int       _speedCount = 0;
  static Position? _lastPos;

  // ── Controls ──────────────────────────────────────────────────────────────

  /// Start GPS and begin accumulating stats.
  static Future<void> start() async {
    if (state.value != RideState.idle) return;
    await LocationService.start();
    _sub = LocationService.positionStream.listen(_onPosition, onError: (_) {});
    state.value = RideState.recording;
  }

  /// Freeze stat accumulation. GPS stays on, speed gauge still updates.
  static void pause() {
    if (state.value != RideState.recording) return;
    state.value = RideState.paused;
  }

  /// Resume accumulating stats.
  static void resume() {
    if (state.value != RideState.paused) return;
    _lastPos    = null; // Discard last position to avoid a distance spike
    state.value = RideState.recording;
  }

  /// Stop GPS, reset everything, return to idle.
  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await LocationService.stop();
    _resetInternals();
    state.value = RideState.idle;
  }

  /// Reset stats only — GPS keeps running, stays in recording state.
  /// If currently paused, also resumes.
  static void resetStats() {
    if (state.value == RideState.idle) return;
    _resetInternals();
    if (state.value == RideState.paused) state.value = RideState.recording;
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
  }

  static void _onPosition(Position pos) {
    double mps = pos.speed;

    // Fallback: displacement-based speed when device returns NaN / 0
    final last = _lastPos;
    if ((mps.isNaN || mps <= 0) && last != null) {
      if (pos.timestamp != null && last.timestamp != null) {
        final dt =
            pos.timestamp!.difference(last.timestamp!).inMilliseconds / 1000.0;
        if (dt > 0.1) {
          final d = Geolocator.distanceBetween(
              last.latitude, last.longitude, pos.latitude, pos.longitude);
          mps = d / dt;
        }
      }
    }

    final kmh = mps.isNaN ? 0.0 : mps * 3.6;

    // Speed gauge always updates (even while paused)
    speedKmh.value = kmh;

    // Stats only accumulate while actively recording
    if (state.value == RideState.recording) {
      if (last != null) {
        final d = Geolocator.distanceBetween(
            last.latitude, last.longitude, pos.latitude, pos.longitude);
        if (!d.isNaN && d >= 0) distanceMeters.value += d;
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
