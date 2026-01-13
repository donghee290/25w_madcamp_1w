import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';
import 'sound_selection_list.dart';

class SoundSelectionPopup extends StatefulWidget {
  final String initialSound;
  final double initialVolume;

  const SoundSelectionPopup({
    super.key,
    required this.initialSound,
    required this.initialVolume,
  });

  @override
  State<SoundSelectionPopup> createState() => _SoundSelectionPopupState();
}

class _SoundSelectionPopupState extends State<SoundSelectionPopup> {
  late String _currentSound;
  late double _currentVolume;

  @override
  void initState() {
    super.initState();
    _currentSound = ""; // Start with no selection visually, per previous logic
    _currentVolume = widget.initialVolume;
  }

  @override
  Widget build(BuildContext context) {
    return PopupBig(
      height: 520,
      width: double.infinity,
      child: Column(
        children: [
          // Header
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 25, bottom: 15),
                alignment: Alignment.center,
                child: const Text(
                  "기상 사운드",
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

          // List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SoundSelectionList(
                initialSound: _currentSound,
                initialVolume: _currentVolume,
                onSelectionChanged: (sound, volume) {
                  _currentSound = sound;
                  _currentVolume = volume;
                },
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: YellowMainButton(
              label: "이 사운드로 결정하기",
              width: double.infinity,
              height: 50,
              onTap: () {
                String result = _currentSound;
                if (result.isEmpty) {
                  result = widget.initialSound;
                }
                Navigator.of(context).pop({'soundName': result, 'volume': _currentVolume});
              },
            ),
          ),
        ],
      ),
    );
  }
}
