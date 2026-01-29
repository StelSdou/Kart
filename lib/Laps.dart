import 'package:flutter/material.dart';
import 'package:kart_v0/Timerometer.dart';
import 'package:kart_v0/BestLaps.dart';

class Laps extends StatelessWidget {
  const Laps({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Timerometer(),
          Bestlaps(),
        ],
    );
  }
}