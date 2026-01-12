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
      height: 105, 
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start, // Align top
        children: [
          BlackMainButton(
            label: '기상 목록',
            icon: Icons.assignment, // Or custom asset: 'assets/illusts/illust-list.png' ? 
            // Design doc says: "Icon(52x52)". Let's stick to Icons for now or generic.
            onTap: onAlarmListTap,
            isSelected: currentIndex == 0,
          ),
          BlackMainButton(
            label: '새로운 알람',
            icon: Icons.access_time_filled,
            onTap: onNewAlarmTap,
            isSelected: false, // Always action
          ),
          BlackMainButton(
            label: '기상 갤러리',
            icon: Icons.photo_library,
            onTap: onGalleryTap,
            isSelected: currentIndex == 1,
          ),
        ],
      ),
    );
  }
}
