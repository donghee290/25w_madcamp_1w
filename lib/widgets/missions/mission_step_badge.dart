import 'package:flutter/material.dart';

class MissionStepBadge extends StatelessWidget {
  final int step;
  final bool isActive;

  const MissionStepBadge({
    super.key,
    required this.step,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return _buildActive();
    } else {
      return _buildInactive();
    }
  }

  Widget _buildActive() {
    return SizedBox(
      width: 37,
      height: 37,
      child: Stack(
        children: [
          // Outer Border/Gradient
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 37,
              height: 37,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.50),
                  end: Alignment(0.00, 0.50),
                  colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
                ),
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Inner Gradient (Purple)
          Positioned(
            left: 1,
            top: 1,
            child: Container(
              width: 35,
              height: 35,
              decoration: const ShapeDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.40, 0.39),
                  radius: 0.41,
                  colors: [
                    Color(0xFFCA76FF),
                    Color(0xFFAE49ED),
                    Color(0xFF7500BF),
                  ],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
          // Text
          Center(
            child: Text(
              step.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactive() {
    return SizedBox(
      width: 37,
      height: 37,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 37,
              height: 37,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1.00, 0.50),
                  end: Alignment(0.00, 0.50),
                  colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
                ),
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 1,
            top: 1,
            child: Container(
              width: 35,
              height: 35,
              decoration: const ShapeDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.40, 0.39),
                  radius: 0.41,
                  colors: [
                    Color(0xFFF9EFFF),
                    Color(0xFFEFD7FF),
                    Color(0xFFD6A9F2),
                  ],
                ),
                shape: OvalBorder(),
              ),
            ),
          ),
          // Text
          Center(
            child: Text(
              step.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3E3E4E),
                fontSize: 18,
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
