import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onTrackModeChanged;
  final bool currentTrackMode;
  final Function(bool)? onUseCupertinoChanged;
  final bool currentUseCupertino;

  const SettingsScreen({
    this.onTrackModeChanged,
    this.currentTrackMode = false,
    this.onUseCupertinoChanged,
    this.currentUseCupertino = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool trackMode;
  late bool useCupertino;

  @override
  void initState() {
    super.initState();
    trackMode = widget.currentTrackMode;
    useCupertino = widget.currentUseCupertino;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
        foregroundColor: const Color.fromARGB(255, 255, 0, 51),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Enable Notifications', style: TextStyle(color: Colors.white)),
              value: true, // Placeholder for actual setting
              activeThumbColor: const Color.fromARGB(255, 255, 0, 51),
              onChanged: (bool value) {
                // Logic to save setting
              },
            ),
            ListTile(
              title: const Text('Driving Mode', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: trackMode ? 'Track' : 'Normal',
                dropdownColor: const Color.fromARGB(255, 30, 30, 40),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Track', child: Text('Track', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  final bool newTrackMode = newValue == 'Track';
                  setState(() {
                    trackMode = newTrackMode;
                  });
                  widget.onTrackModeChanged?.call(newTrackMode);
                },
              ),
            ),
            SwitchListTile(
              title: const Text('Use Cupertino look', style: TextStyle(color: Colors.white)),
              value: useCupertino,
              activeThumbColor: const Color.fromARGB(255, 255, 0, 51),
              onChanged: (bool value) {
                setState(() {
                  useCupertino = value;
                });
                widget.onUseCupertinoChanged?.call(value);
              },
            ),
            // Add more settings options here
          ],
        ),
      ),
    );
  }
}