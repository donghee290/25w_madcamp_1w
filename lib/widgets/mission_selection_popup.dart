import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'mission_difficulty_selection_popup.dart';

class MissionSelectionPopup extends StatefulWidget {
  final MissionType initialType;
  final String? initialPayload;
  final int initialDifficulty;
  final int initialCount;

  const MissionSelectionPopup({
    super.key,
    required this.initialType,
    required this.initialPayload,
    required this.initialDifficulty,
    required this.initialCount,
  });

  @override
  State<MissionSelectionPopup> createState() => _MissionSelectionPopupState();
}

class _MissionSelectionPopupState extends State<MissionSelectionPopup> {
  late MissionType _selectedType;
  late int _selectedDifficulty;
  late int _selectedCount;

  final List<MissionType> _types = const [
    MissionType.math,
    MissionType.colors,
    MissionType.write,
    MissionType.shake,
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedDifficulty = widget.initialDifficulty;
    _selectedCount = widget.initialCount;
  }

  String _titleOf(MissionType type) {
    switch (type) {
      case MissionType.math:
        return "수학 문제";
      case MissionType.colors:
        return "색깔 타일 찾기";
      case MissionType.write:
        return "따라쓰기";
      case MissionType.shake:
        return "흔들기";
    }
  }

  String _iconOf(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
  }

  Future<void> _openDetail(MissionType type) async {
    setState(() {
      _selectedType = type;
    });

    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MissionDifficultySelectionPopup(
        type: type,
        initialDifficulty: _selectedDifficulty,
        initialCount: _selectedCount,
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map) {
      final MissionType newType = result['missionType'] as MissionType? ?? type;
      final int newDifficulty =
          result['missionDifficulty'] as int? ?? _selectedDifficulty;
      final int newCount = result['missionCount'] as int? ?? _selectedCount;
      final String? newPayload = result['payload'] as String?;

      Navigator.of(context).pop({
        'missionType': newType,
        'missionDifficulty': newDifficulty,
        'missionCount': newCount,
        'payload': newPayload,
        'missionName': _titleOf(newType),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupBig(
      height: 520,
      width: double.infinity,
      child: Column(
        children: [
          //Header
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 25, bottom: 15),
                alignment: Alignment.center,
                child: const Text(
                  "기상 미션",
                  style: TextStyle(
                    fontFamily: 'HYcysM',
                    fontSize: 22,
                    color: AppColors.baseWhite,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.baseWhite,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          //List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _types.map((type) {
                  final selected = type == _selectedType;
                  return SkyblueListItem(
                    onTap: () => _openDetail(type),
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Image.asset(_iconOf(type), width: 28, height: 28),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  _titleOf(type),
                                  style: const TextStyle(
                                    fontFamily: 'HYkanB',
                                    fontSize: 16,
                                    color: Color(0xFF5882B4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Container(
                            color: const Color(
                              0xFF396DA9,
                            ).withValues(alpha: 0.5),
                            height: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
