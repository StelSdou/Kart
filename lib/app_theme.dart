import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final Color accent;           // red, white, orange
  final Color speedCenter;      // the circle behind the speed number
  final Color speedRing;        // the gauge
  final Color needleColor;
  final Color speedText;        // color of the speed number
  final Color gaugeTrack;       // the filled arc color (or gradient start)
  final Color cardBackground;   // ride stats + settings boxes bg
  final Color cardBorder;       // their border color
  final Color textPrimary;      // labels inside cards
  final Color gaugelabels;      // gauge labels
  final Color settingsButtonBg; // settings FAB/button background
  final Color gradientBegin;    // top-left of full-screen background gradient
  final Color gradientEnd;      // bottom-right of full-screen background gradient
  final Color arcFill;          // color that floods the 0→speed arc
  final Color arcFillLabel;     // label color inside the flooded arc zone

  const AppTheme({
    required this.id,
    required this.accent,
    required this.speedCenter,
    required this.speedRing,
    required this.needleColor,
    required this.speedText,
    required this.gaugeTrack,
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.gaugelabels,
    required this.settingsButtonBg,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.arcFill,
    required this.arcFillLabel,
  });

  // ── Presets ──────────────────────────────────────────
  static const AppTheme dark = AppTheme(
    id: 'Default',
    accent:            Color.fromARGB(255, 255, 0, 64),
    speedCenter:       Colors.black,
    speedRing:         Color.fromARGB(20, 255, 255, 255),
    speedText:         Colors.white,
    needleColor:       Color.fromARGB(255, 255, 0, 64),
    gaugeTrack:        Color.fromARGB(255, 255, 0, 64),
    cardBackground:    Color.fromARGB(20, 255, 255, 255),
    cardBorder:        Color.fromARGB(30, 255, 255, 255),
    textPrimary:       Colors.white,
    gaugelabels:       Colors.white,
    settingsButtonBg:  Color.fromARGB(40, 255, 255, 255),
    gradientBegin:     Color.fromARGB(255, 30, 30, 35),
    gradientEnd:       Color.fromARGB(255, 10, 10, 15),
    arcFill:           Colors.white,
    arcFillLabel:      Colors.black,
  );

  static const AppTheme light = AppTheme(
    id: 'White',
    accent:            Color.fromARGB(255, 255, 0, 64),
    speedCenter:       Colors.black,
    speedRing:         Colors.white70,
    speedText:         Colors.white,
    needleColor:       Color.fromARGB(255, 255, 0, 64),
    gaugeTrack:        Color.fromARGB(255, 255, 0, 64),
    cardBackground:    Colors.white70,
    cardBorder:        Color.fromARGB(80, 0, 0, 0),
    textPrimary:       Colors.black,
    gaugelabels:       Colors.white,
    settingsButtonBg:  Color.fromARGB(200, 255, 255, 255),
    gradientBegin:     Color.fromARGB(255, 30, 30, 35),
    gradientEnd:       Color.fromARGB(255, 10, 10, 15),
    arcFill:           Color.fromARGB(255, 20, 20, 25), // dark fill on light bg
    arcFillLabel:      Colors.white,
  );

  static const AppTheme sport = AppTheme(
    id: 'Sport',
    accent:            Color.fromARGB(255, 255, 115, 0),
    speedCenter:       Colors.black,
    speedRing:         Colors.black,
    speedText:         Color.fromARGB(255, 255, 115, 0),
    needleColor:       Colors.white,
    gaugeTrack:        Color.fromARGB(255, 255, 115, 0),
    cardBackground:    Color.fromARGB(30, 255, 115, 0),
    cardBorder:        Color.fromARGB(80, 255, 115, 0),
    textPrimary:       Color.fromARGB(255, 255, 115, 0),
    gaugelabels:       Color.fromARGB(70, 255, 115, 0),
    settingsButtonBg:  Color.fromARGB(40, 255, 115, 0),
    gradientBegin:     Color.fromARGB(255, 15, 15, 15),
    gradientEnd:       Color.fromARGB(255, 0, 0, 0),
    arcFill:           Color.fromARGB(255, 255, 115, 0), // orange flood on sport
    arcFillLabel:      Colors.black,
  );

  static const List<AppTheme> all = [dark, light, sport];
}