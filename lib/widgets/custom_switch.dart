import 'package:flutter/material.dart';


class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Design based on User's Figma Dump & Image
    // Layer 1: Rim (55x28) - Silver Gradient (D9D9D9 -> 737373)
    // Layer 2: Inner Track (45x22) - Yellow (ON) or Dark Grey (OFF)
    // Layer 3: Thumb (24x24) - Silver Gradient + Shadow
    
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Rim
          Container(
            width: 55,
            height: 28,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.50, 1.00),
                end: Alignment(0.50, 0.00),
                colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
             // shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2))], 
             // Shadow removed or kept minimal? Image shows mostly flat looking rim or slight depth.
             // Figma dump shows shadow on the container, let's keep it minimal if needed.
            ),
          ),
          
          // 2. Track
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 47, // Slightly smaller than 55 - (border*2)
            height: 22, // Slightly smaller than 28
            decoration: ShapeDecoration(
              color: value ? const Color(0xFFF9E000) : const Color(0xFF3E3E4E), // Yellow / BaseGray
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // 3. Thumb (Animated Position)
          SizedBox(
            width: 55, // Wrapper to control alignment range
            height: 28,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              // Adjust alignment to fit within the track visually
              // -1.0 is left, 1.0 is right. 
              // Need to pad slightly so it doesn't touch the rim edge?
              alignment: value ? const Alignment(0.85, 0.0) : const Alignment(-0.85, 0.0), 
              child: Container(
                width: 24,
                height: 24,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, -0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0xFFEEEEEE), Color(0xFFCCCCCC)], // Silver Light
                  ),
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
