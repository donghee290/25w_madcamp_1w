import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import '../theme/app_colors.dart';

class BlackMainButton extends StatelessWidget {
  final IconData icon; 
  final String label;
  final VoidCallback onTap;
  final bool isSelected; 
  final double width;
  final double height;

  const BlackMainButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.width = 80,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    // 크기: 기본 80x80 px
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          gradient: AppColors.blackMainGradient, // #4E4E5E -> #2E2E3E
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
             width: 2,
             color: isSelected ? AppColors.baseYellow : AppColors.blackButtonBorder,
          ),
          boxShadow: const [
             // Drop Shadow (Outer) is NOT specified in recent "inner shadow" request, 
             // but previous code had Drop Shadow offset(2,2). 
             // User's request: "BlackMainButton에 x=4 y=4 blur=5, x=-4 y=-4 blur=5의 inner shadow 2개 들어가 있고"
             // Assuming ONLY these inner shadows or adding to existing?
             // Usually implies these ARE the shadows.
             BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 5,
              offset: Offset(4, 4),
              inset: true,
            ),
             BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 5,
              offset: Offset(-4, -4),
              inset: true,
            )
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Icon(
                icon,
                size: 52, 
                color: AppColors.baseWhite,
              ),
              const SizedBox(height: 3), 
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 10,
                  fontFamily: 'HYkanM',
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

class BlackSubButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  const BlackSubButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 95,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width, 
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Spec: #6E6E7E -> #3E3E4E (same as primaryGradient)
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 1,
            color: AppColors.subButtonBorder, // #2E2E3E
          ),
          boxShadow: const [
             BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 2,
              offset: Offset(2, 2),
              inset: true,
            ),
             BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 2,
              offset: Offset(-2, -2),
              inset: true,
            )
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.baseWhite,
              fontSize: 12,
              fontFamily: 'HYkanM',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class RedSubButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  const RedSubButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 95,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    // Same style as BlackSubButton but Red
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppColors.redButtonGradient,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: AppColors.lightGray),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 4),
                // Drop Shadow first?
                // User spec: BlackSubButton had inner x=2 y=2.
                // Should RedSubButton be Flat with Inner? Or Drop with Inner?
                // Spec for RedSubButton wasn't explicit. 
                // But let's add Inner for consistency with "SubButton" style if BlackSubButton has it.
                // However, RedSubButton originally had Drop Shadow only.
                // If I change to Inner, it changes design.
                // Let's STICK to Drop Shadow but FIX THE FIT issue.
                // "오류 수정" might just be about the FittedBox/Overflow.
                // I will NOT add Inner Shadow arbitrarily if not requested. BlackSubButton specific spec was given.
              )
            ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.baseWhite,
              fontSize: 12,
              fontFamily: 'HYkanM',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class YellowMainButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry contentPadding;

  const YellowMainButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    // Structure: Double Layer
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.baseGray,
          borderRadius: BorderRadius.circular(5),
          // Outer shadow? Spec says "Inner Box has shadow".
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
               BoxShadow(
                color: AppColors.shadowColor, 
                blurRadius: 2, 
                offset: Offset(2, 2)
              ),
              BoxShadow(
                color: AppColors.shadowColor, 
                blurRadius: 2, 
                offset: Offset(-2, -2)
              )
            ],
          ),
          padding: contentPadding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.baseBlue,
                fontSize: 16,
                fontFamily: 'HYkanB',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GrayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry contentPadding;

  const GrayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.baseGray,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: contentPadding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'HYkanM',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class YellowGrayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry contentPadding;

  const YellowGrayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: contentPadding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.baseBlue,
                fontSize: 16,
                fontFamily: 'HYkanB',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
