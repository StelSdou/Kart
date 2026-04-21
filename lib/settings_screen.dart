<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:kart_v0/services/settings_service.dart';
=======
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kart_v0/services/settings_service.dart';
import 'app_theme.dart';
>>>>>>> old_ver

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onTrackModeChanged;
  final bool currentTrackMode;
  final Function(bool)? onUseCupertinoChanged;
  final bool currentUseCupertino;

  const SettingsScreen({super.key, 
    this.onTrackModeChanged,
    this.currentTrackMode = false,
    this.onUseCupertinoChanged,
    this.currentUseCupertino = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
<<<<<<< HEAD
  late bool trackMode;
  late bool useCupertino;

  @override
  void initState() {
    super.initState();
    trackMode = widget.currentTrackMode;
    useCupertino = widget.currentUseCupertino;
    // initialize slider value from settings
    SettingsService.load().then((_) {
      setState(() {});
    });
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
=======
  @override
  void initState() {
    super.initState();
    // Settings are already loaded at app startup in DashboardScreen.
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
    valueListenable: SettingsService.themeNotifier,
    builder: (context, theme, child) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 0, 51),
            fontWeight: FontWeight.w600,
            // letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),



      body: Stack(
        children: [
          // ── Theme-aware background gradient ─────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.gradientBegin, theme.gradientEnd],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[

            // ── Enable Notifications Button ────────────────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.cardBorder,
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                    child:
                      SwitchListTile(
                        title: Text('Enable Notifications', style: TextStyle(color: theme.textPrimary)),
                        value: true, // Placeholder for actual setting
                        activeThumbColor: const Color.fromARGB(255, 255, 0, 51),
                        onChanged: (bool value) {
                          // Logic to save setting
                        },
                      ),
                ),
              ),
            ),


           // ── Design ────────────────────────────────────────────────────
           const SizedBox(height: 16),
           Divider(
            color: Color.fromARGB(30, 255, 255, 255),
            height: 1.5,
            indent: 10,
            endIndent: 10
            ),
           const SizedBox(height: 16),
           ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: theme.cardBorder,
                        width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: 
                    // ListTile(
                    //   title: const Text('Speedometer Design', style: TextStyle(color: Colors.white)),
                    //   trailing: ValueListenableBuilder<String>(
                    //     valueListenable: SettingsService.designNotifier,
                    //     builder: (context, design, child) {
                    //       return DropdownButton<String>(
                    //         value: design,
                    //         dropdownColor: const Color.fromARGB(255, 30, 30, 40),
                    //         underline: const SizedBox.shrink(),
                    //         items: const [
                    //           DropdownMenuItem(value: 'Default', child: Text('Default', style: TextStyle(color: Colors.white))),
                    //           DropdownMenuItem(value: 'Retro Analog', child: Text('Retro Analog', style: TextStyle(color: Colors.white))),
                    //         ],
                    //         onChanged: (String? newValue) {
                    //           if (newValue != null) {
                    //             SettingsService.setDesign(newValue); // 1. Calls SettingsService.setDesign('Retro Analog') or ('Default')
                    //           }
                    //         },
                    //       );
                    //     },
                    //   ),
                    // ),
                    DropdownButton<AppTheme>(
                      value: SettingsService.themeNotifier.value,
                      items: AppTheme.all.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.id, style: TextStyle(color: theme.textPrimary)),
                      )).toList(),
                      onChanged: (t) { if (t != null) SettingsService.setTheme(t); },
                    )
                ),
              ),
            ),
            

            /* 
               To simplify: Use widget.currentTrackMode directly instead of 'trackMode'.
               When the value changes, call the callback immediately.
            */
            // ── Mode select ────────────────────────────────────────────────────
            /*
            ListTile(
              title: const Text('Driving Mode', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: widget.currentTrackMode ? 'Track' : 'Normal',
>>>>>>> old_ver
                dropdownColor: const Color.fromARGB(255, 30, 30, 40),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'Normal', child: Text('Normal', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'Track', child: Text('Track', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (String? newValue) {
                  if (newValue == null) return;
<<<<<<< HEAD
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
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Max speed (km/h)', style: TextStyle(color: Colors.white)),
              subtitle: ValueListenableBuilder<double>(
                valueListenable: SettingsService.maxSpeedNotifier,
                builder: (context, value, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: value,
                      min: 50,
                      max: 400,
                      // divisions = (max - min) / step -> (400-50)/50 = 7
                      divisions: 7,
                      activeColor: const Color.fromARGB(255, 255, 0, 51),
                      label: value.toInt().toString(),
                      onChanged: (v) {
                        SettingsService.setMaxSpeed(v);
                      },
                    ),
                    Text('${value.toInt()} km/h', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
=======
                  widget.onTrackModeChanged?.call(newValue == 'Track');
                },
              ),
            ),
            */

            // ── Cupertino Look ────────────────────────────────────────────────────
            // SwitchListTile(
            //   title: const Text('Use Cupertino look', style: TextStyle(color: Colors.white)),
            //   value: widget.currentUseCupertino,
            //   activeThumbColor: const Color.fromARGB(255, 255, 0, 51),
            //   onChanged: widget.onUseCupertinoChanged,
            // ),
            // Add more settings options here

            // ── MAX Speedometer Range ────────────────────────────────────────────────────────────────
            
            const SizedBox(height: 16),
            // const Divider(color: Colors.white70),
            // const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.cardBorder,
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                    child: 
                      ListTile(
                        title: Text('Max Speedometer Range\n(km/h)', style: TextStyle(color: theme.textPrimary)),
                        subtitle: ValueListenableBuilder<double>(
                          valueListenable: SettingsService.maxSpeedNotifier,
                          builder: (context, value, child) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Slider(
                                value: value,
                                min: 160,
                                max: 480,
                                // divisions = (max - min) / step
                                divisions: 8, //160, 200, 240, 280, 320, 360, 400, 440, 480
                                activeColor: const Color.fromARGB(255, 255, 0, 51),
                                label: value.toInt().toString(),
                                onChanged: (v) {
                                  SettingsService.setMaxSpeed(v);
                                },
                              ),
                              Text('${value.toInt()} km/h', style: TextStyle(color: theme.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            ),

            // ── Reset Odometer button ────────────────────────────────────────────────────────────────
            const SizedBox(height: 16),
           Divider(
            color: Color.fromARGB(30, 255, 255, 255),
            height: 1.5,
            indent: 10,
            endIndent: 10
            ),
           const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(20, 255, 255, 255),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 0, 51),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => SettingsService.resetOdometer(),
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: Color.fromARGB(255, 255, 0, 51),
                    //   elevation: 0,
                    //   minimumSize: const Size(double.infinity, 65),
                    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    // ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white.withOpacity(0.15);
                          }
                          return const Color.fromARGB(20, 255, 0, 51);
                        },
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 65)),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      animationDuration: const Duration(milliseconds: 150),
                    ),
                    child: const Text('RESET ODOMETER', style: TextStyle(color:  Color.fromARGB(255, 255, 0, 51), fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                )
              )
            )


            
          ],
        ),
      ),
          ),   // SafeArea
        ],
      ),      // Stack
    );
    },
  );
  }
  }
>>>>>>> old_ver
