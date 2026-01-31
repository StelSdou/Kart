import 'package:flutter/material.dart';
import 'package:kart_v0/timer.dart';
import 'package:kart_v0/best_laps.dart';

class Laps extends StatelessWidget {
  const Laps({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TimerWidget(),
          Bestlaps(),
        ],
    );
  }
}