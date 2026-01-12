import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';

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
  late String _selectedSound;
  late double _volume;
  ui.Image? _sliderThumbImage;

  final List<String> _soundOptions = [
    "엘지 굿모닝송",
    "일어나셔야 합니다",
    "군대 기상 나팔",
    "이성을 끌어당기는 주파수",
    "성적이 오르는 주파수",
    "일어나는 건 박수받아 마땅함",
    "직접 녹음하기"
  ];

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.initialSound;
    // If initial sound is not in list, default to first? 
    if (!_soundOptions.contains(_selectedSound)) {
      // If it's a custom recording or unknown, maybe handling?
      // For now, if not found, just keep as is or select first.
      // Let's assume it matches one or is "일어나셔야 합니다" default.
    }
    _volume = widget.initialVolume;
    _loadSliderThumbImage();
  }

  Future<void> _loadSliderThumbImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/illusts/illust-controller.png');
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _sliderThumbImage = fi.image;
        });
      }
    } catch (e) {
      debugPrint("Error loading slider thumb: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupBig(
      height: 520, 
      width: double.infinity, // Fill width
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
                    child: const Icon(Icons.close, color: AppColors.baseWhite, size: 24),
                  ),
                )
              ],
            ),
            
            // List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _soundOptions.map((sound) {
                    final isSelected = sound == _selectedSound;
                    final isRecording = sound == "직접 녹음하기";
                    final iconAsset = isRecording 
                        ? "assets/illusts/illust-record.png" 
                        : "assets/illusts/illust-sound.png"; 

                    return SkyblueListItem(
                      onTap: () {
                        setState(() {
                          _selectedSound = sound;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50, // Base height of item row
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(iconAsset, width: 24, height: 24),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    sound,
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
                          if (isSelected) ...[
                             Container(
                                color: const Color(0xFF396DA9).withValues(alpha: 0.5), 
                                height: 1, 
                                margin: const EdgeInsets.symmetric(vertical: 5),
                              ),
                              SizedBox(
                                height: 40,
                                child: _buildSlider(),
                              ),
                              const SizedBox(height: 5),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
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
                  Navigator.of(context).pop({
                    'soundName': _selectedSound,
                    'volume': _volume,
                  });
                },
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildSlider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Track
        Container(
           height: 24, // Slightly smaller than create screen
           width: double.infinity,
           decoration: BoxDecoration(
             gradient: const LinearGradient(
               begin: Alignment.topCenter, end: Alignment.bottomCenter,
               colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)]
             ),
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: const Color(0xFF6E6E7E)),
           ),
        ),
        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbShape: _CustomThumbShape(image: _sliderThumbImage), 
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: _volume,
            onChanged: (v) => setState(() => _volume = v),
          ),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final ui.Image? image;
  _CustomThumbShape({this.image});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    if (image == null) {
       final Canvas canvas = context.canvas;
       final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE0E0E0), Color(0xFF808080)],
      ).createShader(Rect.fromCircle(center: center, radius: 15));
      canvas.drawCircle(center, 15, paint);
      return;
    }

    final Canvas canvas = context.canvas;
    final dst = Rect.fromCenter(center: center, width: 36, height: 36);
    final src = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
    
    canvas.drawImageRect(image!, src, dst, Paint());
  }
}
