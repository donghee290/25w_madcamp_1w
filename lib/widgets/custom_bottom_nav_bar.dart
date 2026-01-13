import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'design_system_buttons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onAlarmListTap;
  final VoidCallback onNewAlarmTap;
  final VoidCallback onGalleryTap;
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.onAlarmListTap,
    required this.onNewAlarmTap,
    required this.onGalleryTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Height: 103px as per Figma adaptation in previous code, 
    // Image shows distinct dark area.
    // Background: Primary Gradient (#6E6E7E -> #3E3E4E)
    // Buttons: 3 items (List, Add, Gallery)
    // Items are BlackMainButton (80x80)

    return Container(
      width: double.infinity,
      // Removed fixed height: 105
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      // Add bottom padding from MediaQuery to account for system navigation bar
      padding: EdgeInsets.only(
        top: 10,
        bottom: 15 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start, // Align top
        children: [
          BlackMainButton(
            label: '기상 목록',
            imagePath: 'assets/illusts/illust-list.png',
            onTap: onAlarmListTap,
            isSelected: currentIndex == 0,
          ),
          BlackMainButton(
            label: '새로운 알람',
            imagePath: 'assets/illusts/illust-alarm.png',
            onTap: onNewAlarmTap,
            isSelected: false, 
          ),
          BlackMainButton(
            label: '기상 갤러리',
            imagePath: 'assets/illusts/illust-gallery.png',
            onTap: onGalleryTap,
            isSelected: currentIndex == 1,
          ),
        ],
      ),
    );
  }
}
