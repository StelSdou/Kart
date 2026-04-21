import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kart_v0/services/ride_service.dart';

/// Displays the odometer showing total distance traveled.
class Odometer extends StatefulWidget {
  const Odometer({super.key});

  @override
  State<Odometer> createState() => _OdometerState();
}

class _OdometerState extends State<Odometer> {
  @override
  void initState() {
    super.initState();
    // Listen to state changes so the color updates immediately
    RideService.state.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    RideService.state.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 255, 255, 255),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
              color: const Color.fromARGB(30, 255, 255, 255),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: RideService.odometer,
                builder: (context, totalMeters, _) {
                  final totalKm = totalMeters / 1000.0;
                  return Text(
                    totalKm.toStringAsFixed(1),
                    style: TextStyle(
                      color: RideService.state.value == RideState.recording
                          ? Colors.white
                          : Color.fromARGB(255, 255, 0, 51),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  );
                },
              ),
              const Text(
                'km',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:kart_v0/services/ride_service.dart';

// /// Displays a retro mechanical odometer showing total distance traveled.
// class Odometer extends StatefulWidget {
//   const Odometer({super.key});

//   @override
//   State<Odometer> createState() => _OdometerState();
// }

// class _OdometerState extends State<Odometer> {
//   @override
//   void initState() {
//     super.initState();
//     // Listen to state changes so UI updates immediately
//     RideService.state.addListener(_rebuild);
//   }

//   void _rebuild() {
//     if (mounted) setState(() {});
//   }

//   @override
//   void dispose() {
//     RideService.state.removeListener(_rebuild);
//     super.dispose();
//   }

//   /// Calculates the exact float value for each digit to create the interlocking roll effect.
//   List<double> _calculateDigits(double totalMeters, int wholeDigits, int decimalDigits) {
//     int totalDigitCount = wholeDigits + decimalDigits;
//     List<double> values = List.filled(totalDigitCount, 0.0);

//     // currentD represents the distance in units of the smallest displayed wheel (100m = 0.1km)
//     double currentD = totalMeters / 100.0;

//     // The smallest place value rolls continuously
//     values[0] = currentD % 10.0;
    
//     // Calculate larger place values
//     for (int i = 1; i < totalDigitCount; i++) {
//       int divisor = math.pow(10, i).toInt(); //
//       int baseDigit = (currentD / divisor).floor() % 10;
      
//       // The magic happens here: this digit only starts rolling when the digit 
//       // to its right is between 9.0 and 10.0
//       double fraction = math.max(0.0, values[i - 1] - 9.0);
//       values[i] = baseDigit + fraction;
//     }

//     // Return reversed so we can map them left-to-right in the UI
//     return values.reversed.toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Dimensions for each individual physical "wheel"
//     const double digitHeight = 44.0;
//     const double digitWidth = 28.0;
//     const int wholeDigits = 5;
//     const int decimalDigits = 1;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         ValueListenableBuilder<double>(
//           valueListenable: RideService.odometer,
//           builder: (context, totalMeters, _) {
//             final digits = _calculateDigits(totalMeters, wholeDigits, decimalDigits);

//             return Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFF111111),
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.white54, width: 1.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   )
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(4.5), // Just inside the border
//                 child: Stack(
//                   children: [
//                     // The rolling numbers
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: List.generate(digits.length, (index) {
//                         bool isDecimal = index == digits.length - 1;
//                         return _buildDigitColumn(
//                           value: digits[index],
//                           isDecimal: isDecimal,
//                           height: digitHeight,
//                           width: digitWidth,
//                         );
//                       }),
//                     ),
                    
//                     // Gradient overlay to create the 3D cylinder shadow effect
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.black.withOpacity(0.85),
//                               Colors.transparent,
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.85),
//                             ],
//                             stops: const [0.0, 0.35, 0.65, 1.0],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           'km',
//           style: TextStyle(
//             color: Colors.white70,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             letterSpacing: 1.0,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDigitColumn({
//     required double value,
//     required bool isDecimal,
//     required double height,
//     required double width,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       color: isDecimal ? const Color(0xFFB71C1C) : const Color(0xFF111111),
//       child: ClipRect(
//         // Using a Stack allows the Column to be larger than the container 
//         // without throwing a RenderFlex overflow error.
//         child: Stack(
//           children: [
//             Positioned(
//               // Shift the column up based on the exact float value
//               top: -value * height,
//               left: 0,
//               right: 0,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(11, (index) {
//                   // 0 through 9, then an extra 0 at the end to seamlessly loop the scroll
//                   return SizedBox(
//                     width: width,
//                     height: height,
//                     child: Center(
//                       child: Text(
//                         '${index % 10}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.w600,
//                           // TabularFigures prevents widths from jumping around
//                           fontFeatures: [FontFeature.tabularFigures()],
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }