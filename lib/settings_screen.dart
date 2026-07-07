import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kart_v0/services/settings_service.dart';
import 'app_theme.dart';

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
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.accent,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'General',
                  style: TextStyle(
                    color: theme.textPrimary.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
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
                      SwitchListTile(
                        title: Text('Enable Notifications', style: TextStyle(color: theme.textPrimary)),
                        value: true, // Placeholder for actual setting
                        activeThumbColor: theme.accent,
                        onChanged: (bool value) {
                          // Logic to save setting
                        },
                      ),
                ),
              ),
            ),


           // ── Theme ────────────────────────────────────────────────────
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
                    ListTile(
                      title: Text('Theme', style: TextStyle(color: theme.textPrimary)),
                      trailing: ValueListenableBuilder<AppTheme>(
                        valueListenable: SettingsService.preferredTourThemeNotifier,
                        builder: (context, currentTheme, _) => DropdownButton<AppTheme>(
                          value: currentTheme,
                          dropdownColor: theme.cardBackground.withOpacity(1.0),
                          underline: const SizedBox.shrink(),
                          items: AppTheme.all
                              .where((t) => t.id != 'Sport')
                              .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.id, style: TextStyle(color: theme.textPrimary)),
                          )).toList(),
                          onChanged: (t) { if (t != null) SettingsService.setTheme(t); },
                        ),
                      ),
                    )
                ),
              ),
            ),
            // ── Mode ────────────────────────────────────────────────────
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
                    ListTile(
                      title: Text('Mode', style: TextStyle(color: theme.textPrimary)),
                      trailing: ValueListenableBuilder<DrivingMode>(
                        valueListenable: SettingsService.modeNotifier,
                        builder: (context, currentMode, _) => DropdownButton<DrivingMode>(
                          value: currentMode,
                          dropdownColor: theme.cardBackground.withOpacity(1.0),
                          underline: const SizedBox.shrink(),
                          items: DrivingMode.values.map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.name.toUpperCase(), style: TextStyle(color: theme.textPrimary)),
                          )).toList(),
                          onChanged: (m) { if (m != null) SettingsService.setMode(m); },
                        ),
                      ),
                    )
                ),
              ),
            ),

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
                                activeColor: const Color.fromARGB(255, 255, 0, 64),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    //color: const Color.fromARGB(20, 255, 255, 255),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 0, 64),
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
                          return Colors.transparent;
                        },
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 65)),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      animationDuration: const Duration(milliseconds: 150),
                    ),
                    child: const Text('RESET ODOMETER', style: TextStyle(color:  Color.fromARGB(255, 255, 0, 64), fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                )
              )
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Support',
                  style: TextStyle(
                    color: theme.textPrimary.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
           Divider(
            color: Color.fromARGB(30, 255, 255, 255),
            height: 1.5,
            indent: 10,
            endIndent: 10
            ),

            
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
