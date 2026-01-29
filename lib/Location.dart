import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Broadcast service to expose live position updates to other widgets
//
// Αυτό το μικρό singleton παρέχει ένα broadcast `Stream<Position>` ώστε πολλαπλά widgets
// να μπορούν να εγγραφούν και να λαμβάνουν ενημερώσεις θέσης χωρίς να χρειάζεται κάθε
// widget να ανοίξει ξεχωριστή ροή θέσης. Η μέθοδος `addPosition` προωθεί `Position`
// στον stream και το `dispose` κλείνει τον controller όταν δεν χρειάζεται πλέον.
class LocationService {
  static final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  static StreamSubscription<Position>? _positionSubscription;

  static Stream<Position> get positionStream => _positionController.stream;

  static void addPosition(Position pos) {
    // Log position for debugging (latitude, longitude, speed m/s, heading)
    // ignore: avoid_print
    print('[LocationService] POS: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}, speed=${pos.speed.toStringAsFixed(3)} m/s, heading=${pos.heading.toStringAsFixed(1)}°');
    if (!_positionController.isClosed) _positionController.add(pos);
  }

  // Start tracking positions. Idempotent.
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
        print('[LocationService] Permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // ignore: avoid_print
          print('[LocationService] Permission still denied by user.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // ignore: avoid_print
        print('[LocationService] Permission permanently denied (deniedForever).');
        return;
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // Υψηλή ακρίβεια
        distanceFilter: 1, // Ενημέρωση κάθε 1 μέτρο κίνησης
      );

      // Start the Geolocator stream and forward positions to our broadcast controller
      // ignore: avoid_print
      print('[LocationService] Starting position stream (accuracy: ${locationSettings.accuracy}, distanceFilter: ${locationSettings.distanceFilter})');
      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        addPosition(position);
      }, onError: (e) {
        // ignore: avoid_print
        print('[LocationService] Position stream error: $e');
      });
    } catch (e) {
      // ignore: avoid_print
      print('[LocationService] Error starting location tracking: $e');
    }
  }

  static Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  static Future<void> dispose() async {
    await stop();
    if (!_positionController.isClosed) await _positionController.close();
  }
}

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _DirectionalMapScreenState();
}

class _DirectionalMapScreenState extends State<Location> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  // Η ροή των ενημερώσεων θέσης
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // Αρχική θέση (Αθήνα)
  static const LatLng _initialPosition = LatLng(37.9838, 23.7275); 

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    // Σταματάμε την παρακολούθηση όταν το widget καταστραφεί
    // ignore: avoid_print
    print('[Location] Disposing, cancelling position subscription.');
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Μέθοδος για την έναρξη παρακολούθησης της θέσης και της κατεύθυνσης
  //
  // Ενέργειες που γίνονται εδώ:
  //  - Αποφυγή πολλαπλών εγγραφών (idempotent) ώστε να μην υπάρχουν διπλές ροές
  //  - Χρήση του global `LocationService` για να ξεκινήσει η ροή (ελέγχοι & permissions εκεί)
  //  - Εγγραφή σε `LocationService.positionStream` για ενημέρωση του χάρτη
  Future<void> _startLocationTracking() async {
    // Prevent multiple subscriptions (αποφυγή διπλών subscription)
    if (_positionStreamSubscription != null) return;

    // Ensure the service is started (requests permissions if needed)
    await LocationService.start();

    // Subscribe to the global position stream to update the map
    _positionStreamSubscription = LocationService.positionStream.listen((Position position) {
      if (!mounted) return;
      setState(() {
        final LatLng newPosition = LatLng(position.latitude, position.longitude);

        // 1. Δημιουργία ή ενημέρωση του Marker
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('livePosition'),
            position: newPosition,
            // Η ιδιότητα rotation περιστρέφει το εικονίδιο του Marker
            rotation: position.heading, // <-- Η κατεύθυνση σε μοίρες (0-360)
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Μπλε Marker
            anchor: const Offset(0.5, 0.5), // Το κέντρο του εικονιδίου είναι το σημείο αναφοράς
          ),
        );

        // 2. Μετακινούμε την κάμερα για να παρακολουθήσει τη νέα θέση
        // Χρησιμοποιούμε ημισφαιρική μετάβαση (ease)
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: 17, // Μεγάλο ζουμ για ακρίβεια
              bearing: position.heading, // <-- Επίσης, περιστρέφουμε την ΚΑΜΕΡΑ του χάρτη
              tilt: 60, // Προαιρετικά: Μικρή κλίση για 3D αίσθηση
            ),
          ),
        );
      });
    }, onError: (e) {
      // ignore: avoid_print
      print('[Location] position stream error: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Χάρτης με Κατεύθυνση'),
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _markers,
        // myLocationEnabled και myLocationButtonEnabled μπορούν να παραμείνουν true, 
        // αλλά ο custom marker σας θα είναι πιο εμφανής.
        myLocationEnabled: false, 
        myLocationButtonEnabled: true,
      ),
    );
  }
}