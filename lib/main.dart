import 'package:flutter/material.dart';
import 'package:kart_v0/dashboard_screen.dart';
import 'package:kart_v0/Location.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
// Για τον έλεγχο του προσανατολισμό οθόνης

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Καθορίζουμε ρητά τον προσανατολισμό που επιτρέπουμε
  await SystemChrome.setPreferredOrientations([
    // Επιτρέπουμε μόνο τον οριζόντιο προσανατολισμό (αριστερά και δεξιά)
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
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



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useCupertino = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData materialTheme = useCupertino
        ? ThemeData(
            platform: TargetPlatform.iOS,
            useMaterial3: false,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 15),
          )
        : ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 15),
            useMaterial3: true,
          );

    return MaterialApp(
      title: 'SpeedTrace',
      theme: materialTheme,
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(
        onUseCupertinoChanged: (bool v) {
          setState(() {
            useCupertino = v;
          });
        },
        currentUseCupertino: useCupertino,
      ),
    );
  }
}