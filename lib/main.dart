import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:kart_v0/DashboardScreen.dart';
import 'package:kart_v0/Location.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); 

  // // Καθορίζουμε ρητά τον προσανατολισμό που επιτρέπουμε
  // SystemChrome.setPreferredOrientations([
  //   // Επιτρέπουμε μόνο τον οριζόντιο προσανατολισμό (αριστερά και δεξιά)
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]).then((_) {
  //   // Μόλις οριστεί ο προσανατολισμός, τρέχουμε την εφαρμογή
    runApp(const MyApp()); 
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Location(),
    );
  }
}