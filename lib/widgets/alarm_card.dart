import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_colors.dart';
import 'custom_switch.dart';

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final Function(bool) onToggle;
  final bool isDeleteMode; 
  final bool isSelectedToDelete; 
  final Function(bool?)? onSelectionChanged;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    this.isDeleteMode = false,
    this.isSelectedToDelete = false,
    this.onSelectionChanged,
  });

  Widget _buildDaysRow() {
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        final int weekdayId = (index == 0) ? 7 : index; // Sunday=7, others=index

        final isSelected = alarm.weekdays.contains(weekdayId);
        
        // Color logic from Figma:
        // Weekdays (Mon-Fri): Yellow if selected? 
        // Sunday/Saturday: White/Red usually, but Figma code shows:
        // Mon-Fri: Yellow (#F9E000) for "월 화 수 목 금" in the example?
        // Sun, Sat: White.
        // Let's stick to: Selected = Yellow, Unselected = White (or Grey/Transparent).
        // Actually the Figma example shows '월 화 수 목 금' as Yellow and '일', '토' as White. 
        // It seems to be highlighting the active days.
        final color = isSelected ? const Color(0xFFF9E000) : Colors.white;
        
        return Padding(
          padding: const EdgeInsets.only(right: 8), // Spacing roughly 14.29 width - text width
          child: Text(
            days[index],
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontFamily: isSelected ? 'HYkanB' : 'HYkanM', 
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }),
    );
  }

  // Custom Checkbox implementation
  Widget _buildCustomCheckbox() {
    return GestureDetector(
      onTap: () {
        if (onSelectionChanged != null) {
          onSelectionChanged!(!isSelectedToDelete);
        }
      },
      child: Container(
        width: 30, // Area size
        height: 30,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10),
        child: Container(
          width: 24, 
          height: 24,
          decoration: BoxDecoration(
            color: Colors.transparent, 
            border: Border.all(
              color: const Color(0xFFD9D9D9), 
              width: 2,
            ),
          ),
          child: isSelectedToDelete
              ? const Center(
                  child: Icon(Icons.check, size: 20, color: AppColors.baseRed), 
                )
              : null, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hour = alarm.hour;
    final minute = alarm.minute;
    final amPm = hour < 12 ? 'AM' : 'PM';
    final itemsHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final strHour = itemsHour.toString().padLeft(2, '0');
    final strMinute = minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: isDeleteMode ? () => onSelectionChanged?.call(!isSelectedToDelete) : onTap,
      child: Container(
        width: double.infinity,
        // Removed fixed height to prevent overflow. Added padding for spacing.
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const ShapeDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.50, 0.00),
              end: Alignment(0.50, 1.00),
              colors: [Color(0xFF6E6E7E), Color(0xFF3E3E4E)],
            ),
          shape: Border(
            bottom: BorderSide(
               width: 2,
               color: Color(0xFFD1D1D1), // Border bottom as per Figma
            )
          ),
          // Shadows removed for list item look, or keep minimal?
          // Figma code shows box shadow.
           shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 2,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // [Delete Checkbox Area]
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isDeleteMode ? 40 : 0, 
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(), 
                child: isDeleteMode
                  ? _buildCustomCheckbox()
                  : const SizedBox(),
              ),
            ),
            
            // [Content]
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // Left: Days + Time + Label
                   Flexible( // Allow text to not push right side out
                     fit: FlexFit.tight,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.center,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         _buildDaysRow(),
                         const SizedBox(height: 1), // Spacing
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.baseline,
                           textBaseline: TextBaseline.alphabetic,
                           children: [
                             Text(
                               "$strHour:$strMinute",
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 32,
                                 fontFamily: 'HYcysM', 
                                 fontWeight: FontWeight.w400,
                               ),
                             ),
                             const SizedBox(width: 5),
                             Text(
                               amPm,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 24,
                                 fontFamily: 'HYcysM', 
                                 fontWeight: FontWeight.w400,
                               ),
                             )
                           ],
                         ),
                         const SizedBox(height: 2),
                         Text(
                           alarm.label.isEmpty ? '평일' : alarm.label, // Default label example
                           style: const TextStyle(
                             color: Colors.white,
                             fontSize: 20,
                             fontFamily: 'HYkanM',
                             fontWeight: FontWeight.w400,
                           ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(width: 10),

                   // Right: Icon + Switch
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       // Illustration
                       Image.asset(
                         'assets/illusts/illust-list.png', // Fallback illustration
                         width: 54,
                         height: 54, // Adjusted size
                         fit: BoxFit.contain,
                         errorBuilder: (c,e,s) => const Icon(Icons.extension, color: Colors.orange, size: 40),
                       ),
                       const SizedBox(width: 15),
                       
                       // Custom Switch
                       CustomSwitch(
                         value: alarm.isEnabled,
                         onChanged: (val) {
                           if (!isDeleteMode) onToggle(val);
                         },
                       ),
                     ],
                   )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
