import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service that broadcasts live location updates to all listeners.
class LocationService {
  static final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  static StreamSubscription<Position>? _positionSubscription;

  static Stream<Position> get positionStream => _positionController.stream;

  /// Adds a position update to the stream and logs it for debugging.
  static void addPosition(Position pos) {
    // Log position: latitude, longitude, speed (m/s), heading (degrees)
    // ignore: avoid_print
    print('[LocationService] LAT: ${pos.latitude.toStringAsFixed(6)}, LON: ${pos.longitude.toStringAsFixed(6)}, SPEED: ${pos.speed.toStringAsFixed(3)} m/s, HEADING: ${pos.heading.toStringAsFixed(1)}°');
    if (!_positionController.isClosed) _positionController.add(pos);
  }

  /// Starts tracking GPS positions. Safe to call multiple times (idempotent).
  static Future<void> start() async {
    if (_positionSubscription != null) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // ignore: avoid_print
        print('[LocationService] Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ignore: avoid_print
        print('[LocationService] Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // ignore: avoid_print
          print('[LocationService] Permission denied by user.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // ignore: avoid_print
        print('[LocationService] Permission permanently denied.');
        return;
      }

      LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          intervalDuration: const Duration(milliseconds: 200), // Request 5Hz updates
        );
      } else {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }

      // ignore: avoid_print
      print('[LocationService] Starting GPS stream (high accuracy, 1m filter)');
      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        addPosition(position);
      }, onError: (e) {
        // ignore: avoid_print
        print('[LocationService] Stream error: $e');
      });
    } catch (e) {
      // ignore: avoid_print
      print('[LocationService] Error starting location tracking: $e');
    }
  }

  /// Stops tracking GPS positions.
  static Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Stops tracking and closes the stream. Call when the app shuts down.
  static Future<void> dispose() async {
    await stop();
    if (!_positionController.isClosed) await _positionController.close();
  }
}
