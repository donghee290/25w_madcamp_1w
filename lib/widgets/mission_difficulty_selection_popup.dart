import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';

class MissionDifficultySelectionPopup extends StatefulWidget {
  final MissionType type;
  final int initialDifficulty;
  final int initialCount;

  const MissionDifficultySelectionPopup({
    super.key,
    required this.type,
    required this.initialDifficulty,
    required this.initialCount,
  });

  @override
  State<MissionDifficultySelectionPopup> createState() =>
      _MissionDifficultySelectionPopupState();
}

class _MissionDifficultySelectionPopupState
    extends State<MissionDifficultySelectionPopup> {
  late int _difficulty;
  late int _count;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty;
    _count = widget.initialCount;

    final dOpts = _difficultyOptions(widget.type);
    if (!dOpts.any((e) => e.value == _difficulty)) {
      _difficulty = dOpts.isEmpty ? 0 : dOpts.first.value;
    }

    final cOpts = _countOptions(widget.type);
    if (!cOpts.any((e) => e.value == _count)) {
      _count = cOpts.first.value;
    }
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

  List<_Option> _difficultyOptions(MissionType type) {
    switch (type) {
      case MissionType.math:
        return const [
          _Option(1, "매우\n쉬움"),
          _Option(2, "쉬움"),
          _Option(3, "보통"),
          _Option(4, "어려움"),
          _Option(5, "매우\n어려움"),
        ];
      case MissionType.colors:
      case MissionType.write:
        return const [_Option(1, "쉬움"), _Option(2, "보통"), _Option(3, "어려움")];
      case MissionType.shake:
        return const [];
    }
  }

  List<_Option> _countOptions(MissionType type) {
    switch (type) {
      case MissionType.math:
      case MissionType.colors:
      case MissionType.write:
        return const [_Option(2, "2회"), _Option(3, "3회"), _Option(4, "4회")];
      case MissionType.shake:
        return const [
          _Option(5, "5회"),
          _Option(10, "10회"),
          _Option(15, "15회"),
          _Option(20, "20회"),
        ];
    }
  }

  Widget _exampleBox(MissionType type) {
    Widget inner;

    switch (type) {
      case MissionType.math:
        final String expr = switch (_difficulty) {
          1 => "3 + 4 =",
          2 => "23 + 17 =",
          3 => "43 x 9 =",
          4 => "(72 x 6) + 32 =",
          5 => "31 + (37 x 11) =",
          _ => "3 + 4 =",
        };
        inner = Text(
          expr,
          style: const TextStyle(
            fontFamily: 'HYkanB',
            fontSize: 22,
            color: Colors.black,
          ),
        );
        break;

      case MissionType.colors:
        final String img = switch (_difficulty) {
          1 => "assets/illusts/illust-colorsExample1.png",
          2 => "assets/illusts/illust-colorsExample2.png",
          3 => "assets/illusts/illust-colorsExample3.png",
          _ => "assets/illusts/illust-colorsExample1.png",
        };
        inner = Image.asset(img, height: 70, fit: BoxFit.contain);
        break;

      case MissionType.write:
        final String phrase = switch (_difficulty) {
          1 => "아이스크림",
          2 => "좋은 일만 있을 거예요.",
          3 => "동해물과 백두산이 마르고 닳도록\n하느님이 보우하사 우리나라 만세...",
          _ => "아이스크림",
        };
        final double writeExampleFontSize = switch (_difficulty) {
          1 => 24,
          2 => 20,
          3 => 16,
          _ => 24,
        };
        inner = Text(
          phrase,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'HYkanB',
            fontSize: writeExampleFontSize,
            color: Colors.black,
            height: 1.2,
          ),
        );
        break;

      case MissionType.shake:
        inner = const Text(
          "핸드폰을 흔드세요~!",
          style: TextStyle(
            fontFamily: 'HYkanB',
            fontSize: 18,
            color: Colors.black,
          ),
        );
        break;
    }

    return Container(
      height: type == MissionType.write
          ? 120
          : type == MissionType.shake
          ? 130
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: type == MissionType.shake
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
      ),
      child: type == MissionType.shake
          ? Center(child: inner)
          : Column(
              children: [
                const Text(
                  "예제",
                  style: TextStyle(
                    fontFamily: 'HYkanB',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: inner),
              ],
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'HYkanB',
          fontSize: 16,
          color: AppColors.baseWhite,
        ),
      ),
    );
  }

  Widget _optionRow({
    required List<_Option> options,
    required int selectedValue,
    required void Function(int v) onPick,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: options.map((o) {
          final selected = o.value == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => onPick(o.value)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E3E4E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? AppColors.baseYellow
                        : const Color(0xFF6E6E7E),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  o.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: selected ? 'HYkanB' : 'HYkanM',
                    fontSize: 12,
                    color: selected
                        ? AppColors.baseYellow
                        : const Color(0xFFD9D9D9),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    final difficultyOpts = _difficultyOptions(type);
    final countOpts = _countOptions(type);

    return PopupBig(
      height: 600, // Increased from 520
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
                child: Text(
                  _titleOf(type),
                  style: const TextStyle(
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

          const SizedBox(height: 8),
          _exampleBox(type),

          //mission difficulty
          if (difficultyOpts.isNotEmpty) ...[
            _sectionTitle("난이도"),
            _optionRow(
              options: difficultyOpts,
              selectedValue: _difficulty,
              onPick: (v) => _difficulty = v,
            ),
          ],

          //mission count
          _sectionTitle("미션 횟수"),
          _optionRow(
            options: countOpts,
            selectedValue: _count,
            onPick: (v) => _count = v,
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: YellowMainButton(
              label: "이 미션으로 결정하기",
              width: double.infinity,
              height: 50,
              onTap: () {
                Navigator.of(context).pop({
                  'missionType': type,
                  'missionDifficulty': difficultyOpts.isEmpty ? 0 : _difficulty,
                  'missionCount': _count,
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Option {
  final int value;
  final String label;
  const _Option(this.value, this.label);
}
