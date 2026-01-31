import 'package:flutter/material.dart';
import 'package:kart_v0/speedometer.dart';
import 'package:kart_v0/laps.dart';
import 'package:kart_v0/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool)? onUseCupertinoChanged;
  final bool currentUseCupertino;

  const DashboardScreen({
    super.key,
    this.onUseCupertinoChanged,
    this.currentUseCupertino = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isTrackMode = false;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      body: Stack(
        children: [
          isPortrait
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Speedometer(),
                    if (isTrackMode) Laps(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Speedometer(),
                    if (isTrackMode) Laps(),
                  ],
                ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onTrackModeChanged: (bool trackMode) {
                        setState(() {
                          isTrackMode = trackMode;
                        });
                      },
                      currentTrackMode: isTrackMode,
                      onUseCupertinoChanged: widget.onUseCupertinoChanged,
                      currentUseCupertino: widget.currentUseCupertino,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}