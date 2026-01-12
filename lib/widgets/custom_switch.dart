import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    // Design based on User's detailed spec:
    // Layer 1 (Outer Rim): 55x28px, Gradient: Bottom(Light)->Top(Dark) (Concave feel)
    // Layer 2 (Track): Inner fill. AppColors.baseYellow(ON) / AppColors.baseGray(OFF)
    // Layer 3 (Thumb/Knob): 24x24px, Gradient: Top(Light)->Bottom(Dark) (Convex feel)
    
    // Rim Gradient: AppColors.toggleRimGradient (Top(Dark)->Bottom(Light) is WRONG based on "Bottom is Light, Top is Dark"
    // Wait, "Rim: 아래쪽이 밝고 위쪽이 어두움". Bottom=Light, Top=Dark. So Gradient Begin(Top) is Dark, End(Bottom) is Light.
    // My previous AppColors.toggleRimGradient definition: colors: [Color(0xFF737373), Color(0xFFD9D9D9)]
    // 737373 is SilverDark, D9D9D9 is SilverLight. So Top=Dark, Bottom=Light. Correct.
    
    // Thumb Gradient: "위쪽이 밝고 아래쪽이 어두움". Top=Light, Bottom=Dark.
    // My AppColors.toggleThumbGradient definition: colors: [Color(0xFFD9D9D9), Color(0xFF737373)].
    // Top=Light, Bottom=Dark. Correct.

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Layer 1: Rim (Outer)
          Container(
            width: 55,
            height: 28,
            decoration: const ShapeDecoration(
              gradient: AppColors.toggleRimGradient,
              shape: RoundedRectangleBorder(
                // BorderRadius should be high enough for capsule shape
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              // Shadow? Spec didn't mention shadow for Rim, but "Concave feel" comes from gradient.
            ),
          ),
          
          // 2. Layer 2: Track (Inner)
          // Needs to be slightly smaller to show the Rim.
          // Rim 55x28. Let's make Track match the rim minus a border thickness.
          // Spec: "Layer 1 (Outer Rim): 55x28px... Layer 2 (Track): 내부를 채우는 색상."
          // Usually implies the Rim is a border.
          // Let's assume Rim width is ~2px visual?
          // 55 - 4 = 51, 28 - 4 = 24. 
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 51, 
            height: 24, 
            decoration: ShapeDecoration(
              color: value ? AppColors.baseYellow : AppColors.baseGray,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),

          // 3. Layer 3: Thumb (Knob)
          // 24x24px.
          // Animation: Left <-> Right.
          // Container width 55. Thumb 24. 
          // Center is 27.5. Thumb center is 12.
          // Max movement range: 55 - 24 = 31px total free space?
          // Wait, Padding?
          // Let's use AnimatedAlign with a padded area.
          SizedBox(
            width: 55, 
            height: 28,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              // alignment -1.0 is far left edge. 1.0 is far right edge.
              // We need it slightly inside.
              alignment: value ? const Alignment(0.85, 0.0) : const Alignment(-0.85, 0.0), 
              child: Container(
                width: 24,
                height: 24,
                decoration: const ShapeDecoration(
                  gradient: AppColors.toggleThumbGradient,
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: AppColors.shadowColor,
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
