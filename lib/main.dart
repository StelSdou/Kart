import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:kart_v0/dashboard_screen.dart';

// LocationService.start() is now called by RideService.start()
// when the user presses the Start button — not here.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await WakelockPlus.enable();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _useCupertino = false;

  @override
  Widget build(BuildContext context) {
    final theme = _useCupertino
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
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(
        onUseCupertinoChanged: (v) => setState(() => _useCupertino = v),
        currentUseCupertino: _useCupertino,
      ),
    );
  }
}
