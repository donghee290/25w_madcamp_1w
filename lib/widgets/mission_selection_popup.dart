import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';

class MissionSelectionPopup extends StatefulWidget {
  final MissionType initialType;
  final String? initialPayload;
  final int initialDifficulty;

  const MissionSelectionPopup({
    super.key,
    required this.initialType,
    required this.initialPayload,
    required this.initialDifficulty,
  });

  @override
  State<MissionSelectionPopup> createState() => _MissionSelectionPopupState();
}

class _MissionSelectionPopupState extends State<MissionSelectionPopup> {
  late MissionType _selectedType;
  String? _selectedPayload;
  late int _selectedDifficulty;

  late final List<_MissionOption> _options = [
    _MissionOption(
      title: "수학 문제",
      type: MissionType.math,
      payload: "mission=math",
      defaultDifficulty: 1,
    ),
    _MissionOption(
      title: "색깔 타일 찾기",
      type: MissionType.colors,
      payload: "mission=colors",
      defaultDifficulty: 1,
    ),
    _MissionOption(
      title: "따라쓰기",
      type: MissionType.write,
      payload: "mission=write",
      defaultDifficulty: 1,
    ),
    _MissionOption(
      title: "흔들기",
      type: MissionType.shake,
      payload: "mission=shake",
      defaultDifficulty: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedPayload = widget.initialPayload;
    _selectedDifficulty = widget.initialDifficulty;
  }

  bool _isSelected(_MissionOption opt) {
    return opt.type == _selectedType;
  }

  String _iconOf(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
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
                children: _options.map((opt) {
                  final selected = _isSelected(opt);

                  return SkyblueListItem(
                    onTap: () {
                      setState(() {
                        _selectedType = opt.type;
                        _selectedPayload = opt.payload;
                        _selectedDifficulty = opt.defaultDifficulty;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Image.asset(
                                _iconOf(opt.type),
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  opt.title,
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

                        // 선택 강조선 (원하시면 제거 가능)
                        if (selected)
                          Container(
                            color: const Color(
                              0xFF396DA9,
                            ).withValues(alpha: 0.5),
                            height: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),

                        // 난이도 UI가 필요하면 여기서 확장 가능
                        // (현재 디자인 스샷에는 없어서 기본값만 세팅)
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          //Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: YellowMainButton(
              label: "이 미션으로 결정하기",
              width: double.infinity,
              height: 50,
              onTap: () {
                Navigator.of(context).pop({
                  'missionType': _selectedType,
                  'missionDifficulty': _selectedDifficulty,
                  'payload': _selectedPayload,
                  'missionName': _selectedMissionName(),
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _selectedMissionName() {
    //UI 표시용 이름
    for (final o in _options) {
      if (_isSelected(o)) return o.title;
    }
    return "미션을 선택해주세요.";
  }
}

class _MissionOption {
  final String title;
  final MissionType type;
  final String? payload;
  final int defaultDifficulty;

  _MissionOption({
    required this.title,
    required this.type,
    required this.payload,
    required this.defaultDifficulty,
  });
}
