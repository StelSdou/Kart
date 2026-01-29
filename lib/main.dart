import 'package:flutter/material.dart';
import 'package:kart_v0/DashboardScreen.dart';
import 'package:kart_v0/Location.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
// Για τον έλεγχο του προσανατολισμό οθόνης

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Καθορίζουμε ρητά τον προσανατολισμό που επιτρέπουμε
  await SystemChrome.setPreferredOrientations([
    // Επιτρέπουμε μόνο τον οριζόντιο προσανατολισμό (αριστερά και δεξιά)
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Ξεκινάει το gps
  await LocationService.start();

  // Κρατάει την οθόνη ανοικτή
  await WakelockPlus.enable();

  // Hide status and navigation bars (immersive full-screen)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeedTrace',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 15),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}