import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import '../theme/app_colors.dart';

class PopupSmall extends StatelessWidget {
  final Widget child; 
  final double? width;
  final double? height;

  const PopupSmall({super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    // Background: primaryGradient
    // Border: White 3px
    // Radius: 30px
    // Shadows: 
    //   1. Drop: Off(0,4), Blur 4, Spread 0 (Outer)
    //   2. Inner: Off(0,4), Blur 8, Spread 4 (Inner)
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 3, color: AppColors.baseWhite),
        boxShadow: const [
          // Drop Shadow (Outer)
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
            inset: false, // Explicitly false for clarity
          ),
          // Inner Shadow
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
            spreadRadius: 4,
            inset: true,
          ),
        ],
      ),
      child: child,
    );
  }
}

class PopupBig extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const PopupBig({
    super.key,
    required this.child,
    this.width = 360,
    this.height = 518,
  });

  @override
  Widget build(BuildContext context) {
    // Background: primaryGradient
    // Border: White 3px
    // Radius: Top 30px, Bottom 0px
    // Shadows:
    //   1. Drop: Off(0,4), Blur 4 (Outer)
    //   2. Inner: Off(0,4), Blur 8, Spread 4 (Inner)
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        // BoxDecoration border applies to all sides if using Border.all.
        // If we want top rounded and border on all sides? 
        // RoundedRectangleBorder handled this elegantly.
        // BoxDecoration with border supports it too.
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
        ),
        border: Border.all(width: 3, color: AppColors.baseWhite),
        boxShadow: const [
           // Drop
           BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 4),
            inset: false,
          ),
          // Inner
           BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
            spreadRadius: 4, // Spread 4 as requested
            inset: true,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SkyblueListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SkyblueListItem({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Height: Flexible (min 50)
    // Background: gradSkyblue (#F9FDFF -> #BAE2FF)
    // Border: 2px baseBlue (#396DA9)
    // Shadow: Bottom 2px (blur 2)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.gradSkyblue,
          border: Border.all(width: 2, color: AppColors.baseBlue),
          // No borderRadius specified -> Zero implicitly
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
