import 'dart:async';
import 'package:flutter/foundation.dart';

/// Controls the session stopwatch and lap history.
///
/// All widgets observe the public [ValueNotifier]s and call the static
/// control methods — no widget holds timer state directly.
class TimerService {
  TimerService._();

  // ── Public state ──────────────────────────────────────────────────────────

  /// Total elapsed time since [start] was last called.
  static final ValueNotifier<int>       elapsedMs    = ValueNotifier(0);

  /// Time elapsed since the start of the current (in-progress) lap.
  static final ValueNotifier<int>       currentLapMs = ValueNotifier(0);

  /// Completed lap times in chronological order (ms).
  static final ValueNotifier<List<int>> laps         = ValueNotifier(const []);

  static final ValueNotifier<bool>      isRunning    = ValueNotifier(false);

  // ── Computed helpers ──────────────────────────────────────────────────────

  static int? get bestLapMs {
    final l = laps.value;
    return l.isEmpty ? null : l.reduce((a, b) => a < b ? a : b);
  }

  static int get lapCount => laps.value.length;

  // ── Private state ─────────────────────────────────────────────────────────

  static final Stopwatch _sw     = Stopwatch();
  static Timer?          _ticker;
  static int             _lapStart = 0;

  // ── Controls ──────────────────────────────────────────────────────────────

  static void start() {
    if (isRunning.value) return;
    isRunning.value = true;
    _sw.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      elapsedMs.value    = _sw.elapsedMilliseconds;
      currentLapMs.value = _sw.elapsedMilliseconds - _lapStart;
    });
  }

  static void stop() {
    if (!isRunning.value) return;
    isRunning.value = false;
    _sw.stop();
    _ticker?.cancel();
    _ticker = null;
  }

  /// Record the current lap and start a new one.
  static void lap() {
    if (!isRunning.value) return;
    final lapTime = _sw.elapsedMilliseconds - _lapStart;
    _lapStart      = _sw.elapsedMilliseconds;
    laps.value     = [...laps.value, lapTime];
    currentLapMs.value = 0;
  }

  /// Stop, clear all data, and return to initial state.
  static void reset() {
    stop();
    _sw.reset();
    _lapStart          = 0;
    elapsedMs.value    = 0;
    currentLapMs.value = 0;
    laps.value         = const [];
  }
}
