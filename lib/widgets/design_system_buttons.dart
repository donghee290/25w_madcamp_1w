import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BlackMainButton extends StatelessWidget {
  final IconData icon; // 디자인 명세: 아이콘(52x52)
  final String label;
  final VoidCallback onTap;
  final bool isSelected; // 선택 여부에 따른 테두리 색상 변경 등이 필요할 수 있음

  const BlackMainButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // 크기: 80x80 px
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(0), 
        decoration: ShapeDecoration(
          gradient: AppColors.blackMainGradient, // #4E4E5E -> #2E2E3E
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              // 선택되면 노란색, 아니면 #0E0E1E
              color: isSelected ? AppColors.baseYellow : AppColors.blackButtonBorder,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          shadows: const [
             BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vert
          children: [
            // 아이콘(52x52) - Icon 위젯 사이즈 조절
            Icon(
              icon,
              size: 40, 
              color: AppColors.baseWhite,
            ),
            const SizedBox(height: 3), // 간격 3px
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
    );
  }
}

class BlackSubButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const BlackSubButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 크기: 95 x 38 px
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95, 
        height: 38,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          gradient: AppColors.primaryGradient,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: AppColors.subButtonBorder,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          shadows: const [
             BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 2,
              offset: Offset(1, 1),
            )
          ],
        ),
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
    );
  }
}

class RedSubButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const RedSubButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 38,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFA3A3), Color(0xFFC40000)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF550000), // Darker red border
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          shadows: const [
             BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 2,
              offset: Offset(1, 1),
            )
          ],
        ),
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
    );
  }
}

class YellowMainButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const YellowMainButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Structure: Double Layer
    // Outer: baseGray (#3E3E4E)
    // Inner: secondaryGradient (Yellow)
    // Radius: 5px
    // Padding: Horizontal 4.5, Vertical 2.0
    // Font: HYkanB, 16px, baseBlue (#396DA9)
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.baseGray,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
             BoxShadow(
              color: Color(0x3F000000), 
              blurRadius: 2, offset: Offset(2, 2)
            )
          ]
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            gradient: AppColors.secondaryGradient,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
    );
  }
}

class GrayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GrayButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Outer: baseGray
    // Inner: lightGray
    // Font: HYkanM, 16px, Black
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.baseGray,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: AppColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
    );
  }
}

class YellowGrayButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const YellowGrayButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Outer: lightGray
    // Inner: secondaryGradient
    // Font: HYkanB, 16px, baseBlue
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            gradient: AppColors.secondaryGradient,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
    );
  }
}
