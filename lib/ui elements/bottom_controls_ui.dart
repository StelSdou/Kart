import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kart_v0/services/ride_service.dart';

class RideControlsBar extends StatelessWidget {
  final bool isIdle;
  final bool isPaused;

  const RideControlsBar({
    super.key,
    required this.isIdle,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: isIdle ? _buildStartButton() : _buildActiveControls(),
    );
  }

  // ── START ────────────────────────────────────────────────────────────────────

  Widget _buildStartButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 65,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 255, 255, 255),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.18),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => RideService.start(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white.withOpacity(0.15);
                  }
                  return const Color.fromARGB(20, 255, 255, 255);
                },
              ),
              elevation: WidgetStateProperty.all(0),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              minimumSize: WidgetStateProperty.all(
                const Size(double.infinity, 65),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              animationDuration: const Duration(milliseconds: 150),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow,
                      color: Color.fromARGB(255, 255, 0, 51), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'START',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 0, 51),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── PAUSE / STOP / RESET ─────────────────────────────────────────────────────

  Widget _buildActiveControls() {
    return Row(
      spacing: 10,
      children: [
        // PAUSE / RESUME
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ElevatedButton(
                onPressed: isPaused ? RideService.resume : RideService.pause,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.15);
                      }
                      return const Color.fromARGB(20, 255, 255, 255);
                    },
                  ),
                  elevation: WidgetStateProperty.all(0),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(0, 65)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  )),
                  animationDuration: const Duration(milliseconds: 150),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaused ? Icons.play_arrow : Icons.pause,
                        color: isPaused
                            ? Colors.white
                            : const Color.fromARGB(255, 255, 0, 51),
                        size: 23,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPaused ? 'RESUME' : 'PAUSE',
                        style: TextStyle(
                          color: isPaused
                              ? Colors.white
                              : const Color.fromARGB(255, 255, 0, 51),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // STOP
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ElevatedButton(
                onPressed: () => RideService.stop(),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.15);
                      }
                      return const Color.fromARGB(20, 255, 0, 51);
                    },
                  ),
                  elevation: WidgetStateProperty.all(0),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(0, 65)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 255, 0, 51),
                      width: 1,
                    ),
                  )),
                  animationDuration: const Duration(milliseconds: 150),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop,
                          color: Color.fromARGB(255, 255, 0, 51), size: 23),
                      SizedBox(width: 4),
                      Text(
                        'STOP',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 0, 51),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // RESET
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ElevatedButton(
                onPressed: RideService.resetStats,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withOpacity(0.15);
                      }
                      return const Color.fromARGB(20, 255, 255, 255);
                    },
                  ),
                  elevation: WidgetStateProperty.all(0),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  minimumSize: WidgetStateProperty.all(const Size(0, 65)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: const BorderSide(color: Colors.white, width: 1),
                  )),
                  animationDuration: const Duration(milliseconds: 150),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 23),
                      SizedBox(width: 4),
                      Text(
                        'RESET',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}