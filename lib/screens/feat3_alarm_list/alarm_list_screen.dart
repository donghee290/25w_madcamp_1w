import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/next_alarm_provider.dart';
import '../../models/alarm_model.dart'; 
import '../feat2_creat_alarm/create_alarm_screen.dart';
import '../../widgets/alarm_card.dart';
import '../../widgets/design_system_buttons.dart';
import '../../theme/app_colors.dart';
import '../../widgets/delete_confirm_popup.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  bool _isDeleteMode = false;
  final Set<String> _selectedAlarmIds = {};

  void _toggleDeleteMode() {
    if (_isDeleteMode) {
      // In delete mode: Button press means "Confirm Delete" if selection exists
      if (_selectedAlarmIds.isNotEmpty) {
        _deleteSelectedAlarms();
      } else {
        // Exit delete mode if nothing selected
        setState(() {
          _isDeleteMode = false;
        });
      }
    } else {
      // Enter delete mode
      setState(() {
        _isDeleteMode = true;
        _selectedAlarmIds.clear();
      });
    }
  }

  void _deleteSelectedAlarms() {
    // Show Popup Confirmation
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    final count = _selectedAlarmIds.length;

    if (count == 0) return;

    // Get name for popup
    // If 1 item: "[Name] 알람을"
    // If >1 items: "[Name] 외 N개 알람을"
    String targetName = "";
    final firstId = _selectedAlarmIds.first;
    final firstAlarm = provider.alarms.firstWhere(
      (a) => a.id == firstId,
      orElse: () => Alarm(
        id: '',
        hour: 0,
        minute: 0,
        label: '',
        isEnabled: false,
        weekdays: [],
        isVibration: false,
        duration: 0,
        snoozeCount: 0,
        missionType: MissionType.math,
        missionDifficulty: 1,
      ),
    ); // Dummy fallback
    final firstName = firstAlarm.label.isEmpty
        ? "평일"
        : firstAlarm.label; // Default name logic

    if (count == 1) {
      targetName = "「$firstName」";
    } else {
      targetName = "「$firstName」 외 ${count - 1}개";
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Force user choice
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return DeleteConfirmPopup(
          title: "정말 $targetName 알람을\n삭제하시겠습니까?", // Popup handles newline
          onConfirm: () {
            // Actual Delete
            for (var id in _selectedAlarmIds) {
              provider.deleteAlarm(id);
            }
            setState(() {
              _isDeleteMode = false;
              _selectedAlarmIds.clear();
            });
            Navigator.of(context).pop(); // Close Popup
          },
          onCancel: () {
            setState(() {
              _isDeleteMode = false; // Exit delete mode on cancel?
              // Logic choice: User might want to change selection.
              // Request implies: "Cancel -> Back to normal?"
              // Usually cancel just closes popup. But strict flow "Select -> Delete"
              // If cancel, maybe stay in delete mode?
              // "아니요 gray button" -> Just close popup.
              // Let's just close popup and keep delete mode?
              // Or exit delete mode? Usually "Cancel" means "Don't delete".
              // I will keep Delete Mode active so they can change selection.
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _onAddPressed() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateAlarmScreen()));
  }

  // Header Widget based on Figma/Image
  Widget _buildHeader(int alarmCount) {
    return Column(
      children: [
        // Part 1: Top Bar (Gradient + Title)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 0, bottom: 0), // Remove internal padding
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Top Spacing
              const Text(
                '기상 목록',
                style: TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 32,
                  fontFamily: 'HYcysM',
                ),
              ),
              const SizedBox(height: 20), // Bottom Spacing (Equal to Top)
              const Divider(color: Colors.black, thickness: 2, height: 2),
            ],
          ),
        ),

        // Part 2: Bottom Area (Body Color + Buttons)
        Container(
          width: double.infinity,
          color: const Color(0xFF2E2E3E), // Match Body Color
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              //Subtitle (Time remaining)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Consumer<NextAlarmProvider>(
                    builder: (context, nextAlarmProvider, _) {
                      return Text(
                        nextAlarmProvider.label,
                        style: const TextStyle(
                          color: AppColors.baseWhite,
                          fontSize: 20,
                          fontFamily: 'HYcysM',
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // DELETE Button (Toggle Label/Style)
                    if (_isDeleteMode)
                      _selectedAlarmIds.isEmpty
                          ? BlackSubButton(label: '취소', onTap: _toggleDeleteMode)
                          : RedSubButton(label: '삭제', onTap: _toggleDeleteMode)
                    else
                      BlackSubButton(label: '선택', onTap: _toggleDeleteMode),

                    // ADD Button
                    BlackSubButton(label: '추가', onTap: _onAddPressed),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E), // Corrected bg color
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(alarmProvider.alarms.length),
            Expanded(
              child: alarmProvider.alarms.isEmpty
                  ? Center(
                      child: Text(
                        "알람이 없습니다.\n'추가' 버튼을 눌러 추가해주세요.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: alarmProvider.alarms.length,
                      padding:
                          EdgeInsets.zero, // Padding handled by cards/header
                      itemBuilder: (context, index) {
                        final alarm = alarmProvider.alarms[index];
                        final isSelected = _selectedAlarmIds.contains(alarm.id);

                        return AlarmCard(
                          alarm: alarm,
                          isDeleteMode: _isDeleteMode,
                          isSelectedToDelete: isSelected,
                          onSelectionChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedAlarmIds.add(alarm.id);
                              } else {
                                _selectedAlarmIds.remove(alarm.id);
                              }
                            });
                          },
                          onTap: () {
                            if (_isDeleteMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedAlarmIds.remove(alarm.id);
                                } else {
                                  _selectedAlarmIds.add(alarm.id);
                                }
                              });
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateAlarmScreen(alarm: alarm),
                                ),
                              );
                            }
                          },
                          onToggle: (bool newValue) {
                            if (!_isDeleteMode) {
                              alarmProvider.updateAlarm(
                                alarm.copyWith(isEnabled: newValue),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
