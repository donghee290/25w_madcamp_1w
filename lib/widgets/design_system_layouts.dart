import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PopupSmall extends StatelessWidget {
  final Widget child; // Content inside popup
  final double? width;
  final double? height;

  const PopupSmall({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Background: primaryGradient
    // Border: White 3px
    // Radius: 30px
    // Shadow: Black 25% Y+4 Blur 4
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20), // Default padding
      decoration: ShapeDecoration(
        gradient: AppColors.primaryGradient,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3, color: AppColors.baseWhite),
          borderRadius: BorderRadius.circular(30),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
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
    // Radius: Top 30px, Bottom 0px (Bottom Sheet style)
    // Shadow: Black 25% Y+4 Blur 4
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        gradient: AppColors.primaryGradient,
        shape: const RoundedRectangleBorder(
          side: BorderSide(width: 3, color: AppColors.baseWhite),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      // Typically content needs scrolling or structure
      child: child,
    );
  }
}

class SkyblueListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SkyblueListItem({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Height: 50px (flexible)
    // Background: gradSkyblue (#F9FDFF -> #BAE2FF)
    // Border: 2px baseBlue (#396DA9)
    // Shadow: Bottom 2px (blur 2)
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // height: 50, // Making it flexible height min 50
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: ShapeDecoration(
          gradient: AppColors.gradSkyblue,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: AppColors.baseBlue),
            borderRadius: BorderRadius.zero, // List item implies rect usually, or maybe slightly rounded?
            // "Skyblue List Item... Border 2px... Radius not specified in prompt text summary, assuming rect or small."
            // Assuming Rect for list items. 
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 2,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
