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
<<<<<<< HEAD
            scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 15),
          )
        : ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 15),
            useMaterial3: true,
=======
            scaffoldBackgroundColor: Colors.transparent,
            fontFamily: 'RobotoMono',
          )
        : ThemeData(
            scaffoldBackgroundColor: Colors.transparent,
            useMaterial3: true,
            fontFamily: 'RobotoMono',
>>>>>>> old_ver
          );

    return MaterialApp(
      title: 'SpeedTrace',
<<<<<<< HEAD
      theme: theme,
=======
      theme: theme.copyWith(
    // Kill the ripple everywhere
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,

    // Optional: subtle overlay instead
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.08); // barely visible
            }
            return null;
          },
        ),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
  ),
>>>>>>> old_ver
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(
        onUseCupertinoChanged: (v) => setState(() => _useCupertino = v),
        currentUseCupertino: _useCupertino,
      ),
    );
  }
}
