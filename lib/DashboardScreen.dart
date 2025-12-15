import 'package:flutter/material.dart';
import 'package:kart_v0/Speedometer.dart';
import 'package:kart_v0/Laps.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Speedometer(),
          Laps(),
        ],
      ),
    );
  }
}