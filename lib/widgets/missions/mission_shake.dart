import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MissionShake extends StatefulWidget {
  final VoidCallback onSuccess;
  final int difficulty;
  final int targetCount;

  const MissionShake({
    super.key,
    required this.onSuccess,
    this.difficulty = 1,
    this.targetCount = 20,
  });

  @override
  State<MissionShake> createState() => _MissionShakeState();
}

class _MissionShakeState extends State<MissionShake> {
  int _count = 20; // Default
  StreamSubscription? _accelerometerSubscription;
  bool _canShake = true;

  @override
  void initState() {
    super.initState();
    // Use targetCount passed from parent (which comes from alarm settings)
    _count = widget.targetCount;
    if (_count < 5) _count = 5; // Minimum safety

    _startListening();
  }

  void _startListening() {
    _accelerometerSubscription = userAccelerometerEventStream().listen((
      UserAccelerometerEvent event,
    ) {
      if (!_canShake) return;

      // Detection threshold
      const double shakeThreshold = 15.0; // Needs tuning
      if (event.x.abs() > shakeThreshold ||
          event.y.abs() > shakeThreshold ||
          event.z.abs() > shakeThreshold) {
        _handleShake();
      }
    });
  }

  Future<void> _handleShake() async {
    _canShake = false;

    // Haptic Feedback
    await HapticFeedback.heavyImpact();

    setState(() {
      _count--;
    });

    if (_count <= 0) {
      // Success
      _accelerometerSubscription?.cancel();
      widget.onSuccess();
    } else {
      // Debounce to prevent double counting
      await Future.delayed(const Duration(milliseconds: 200));
      _canShake = true;
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return Container directly to fill the Expanded parent in WakeupMissionScreen
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFF2E2E3E)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Text "마구 흔들어!"
          Positioned(
            top: 40,
            child: const Text(
              '마구 흔들어!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontFamily: 'HYkanM',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Image
          Positioned(
            bottom: 130,
            child: Container(
              width: 255,
              height: 245,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/illusts/illust-phoneShaking.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Count Text
          Positioned(
            top: 100,
            child: Text(
              '$_count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontFamily: 'HYkanB',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
