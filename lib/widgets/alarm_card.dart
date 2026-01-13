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

  String missionIconOf(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
  }

  Widget _buildDaysRow() {
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        final int weekdayId = (index == 0)
            ? 7
            : index; // Sunday=7, others=index

        final isSelected = alarm.weekdays.contains(weekdayId);

        final color = isSelected ? AppColors.baseYellow : AppColors.baseWhite;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            days[index],
            style: TextStyle(
              color: color,
              fontSize: 18,
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
            border: Border.all(color: const Color(0xFFD9D9D9), width: 2),
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
      onTap: isDeleteMode
          ? () => onSelectionChanged?.call(!isSelectedToDelete)
          : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ), // Reduced Padding 10->8
        decoration: ShapeDecoration(
          gradient: AppColors.primaryGradient,
          shape: const Border(
            bottom: BorderSide(width: 2, color: AppColors.lightBorder),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
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
                child: isDeleteMode ? _buildCustomCheckbox() : const SizedBox(),
              ),
            ),

            // [Content]
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Days + Time + Label
                  Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _buildDaysRow(),
                        ),
                        const SizedBox(height: 2), // Slightly more space
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "$strHour:$strMinute",
                                style: const TextStyle(
                                  color: AppColors.baseWhite,
                                  fontSize: 42,
                                  fontFamily: 'HYcysM',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                amPm,
                                style: const TextStyle(
                                  color:
                                      AppColors.baseWhite, // Consistent white
                                  fontSize: 22,
                                  fontFamily: 'HYcysM',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4), // More space before label
                        Text(
                          alarm.label.isEmpty ? '알람' : alarm.label,
                          style: const TextStyle(
                            color: AppColors.baseWhite,
                            fontSize: 18,

                            fontFamily: 'HYkanM',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 5), // Reduced gap 10->5
                  // Right: Icon + Switch
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Illustration
                      Image.asset(
                        missionIconOf(alarm.missionType),
                        width: 60, // 체크박스 고려
                        height: 60, // 체크박스 고려
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.extension,
                          color: Colors.orange,
                          size: 40,
                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
