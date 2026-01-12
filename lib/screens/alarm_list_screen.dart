import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import 'create_alarm_screen.dart';
import '../widgets/alarm_card.dart';
import '../widgets/design_system_buttons.dart';
import '../theme/app_colors.dart';

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
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    for (var id in _selectedAlarmIds) {
      provider.deleteAlarm(id);
    }
    setState(() {
      _isDeleteMode = false;
      _selectedAlarmIds.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("선택한 알람이 삭제되었습니다.")));
  }

  void _onAddPressed() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateAlarmScreen()));
  }

  // Header Widget based on Figma/Image
  Widget _buildHeader(int alarmCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      // Image shows a "Header" block that looks blended or same gradient as bg.
      // But distinct from list.
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 1), // Separator line
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            '기상 목록',
            style: TextStyle(
              color: AppColors.baseWhite,
              fontSize: 20, // Looking large
              fontFamily: 'HYcysM',
            ),
          ),
          const SizedBox(height: 20),

          // Subtitle (Time remaining - Placeholder for now)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '7시간 56분 뒤 기상이다.',
              style: TextStyle(
                color: AppColors.baseWhite,
                fontSize: 18,
                fontFamily: 'HYcysM',
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // DELETE Button
              RedSubButton(label: '삭제', onTap: _toggleDeleteMode),

              // ADD Button
              BlackSubButton(label: '추가', onTap: _onAddPressed),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.baseBlack, // Fallback bg
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
