import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Μέθοδος για την έναρξη παρακολούθησης της θέσης και της κατεύθυνσης
  void _startLocationTracking() async {
    // *Σημείωση: Δεν περιλαμβάνεται ο έλεγχος δικαιωμάτων. Βεβαιωθείτε ότι έχει γίνει.*

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Υψηλή ακρίβεια
      distanceFilter: 1, // Ενημέρωση κάθε 1 μέτρο κίνησης
    );

    // Δημιουργούμε τη ροή ενημερώσεων
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      // Καλούμε το setState για να ενημερώσουμε τον χάρτη
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
          // Μετά την δημιουργία, ξεκινάμε την παρακολούθηση
          _startLocationTracking(); 
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