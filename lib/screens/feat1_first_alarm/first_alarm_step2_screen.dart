import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme/app_colors.dart';
import '../../widgets/design_system_layouts.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/missions/mission_step_badge.dart';
import '../../widgets/recording_overlay.dart';
import '../../constants/sound_constants.dart';
import 'first_alarm_step3_screen.dart';

class FirstAlarmStep2Screen extends StatefulWidget {
  final int hour;
  final int minute;

  const FirstAlarmStep2Screen({
    super.key,
    required this.hour,
    required this.minute,
  });

  @override
  State<FirstAlarmStep2Screen> createState() => _FirstAlarmStep2ScreenState();
}

class _FirstAlarmStep2ScreenState extends State<FirstAlarmStep2Screen> {
  // Sound Selection State
  String _selectedSound = "일어나셔야 합니다"; // Default as per create_alarm_screen
  double _volume = 0.5;
  String? _customRecordingPath;
  String? _customAudioPath;

  ui.Image? _sliderThumbImage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _soundOptions = SoundConstants.soundOptions;

  @override
  void initState() {
    super.initState();
    _loadSliderThumbImage();
  }

  @override
  void dispose() {
    _audioPlayer.stop().catchError((e) {
      debugPrint("Error stopping audio on dispose: $e");
    });
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSliderThumbImage() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/illusts/illust-controller.png',
      );
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
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

  Future<void> _playSound(String soundName) async {
    try {
      await _audioPlayer.stop();

      if (soundName == SoundConstants.customRecordingKey) {
        if (_customRecordingPath != null) {
          await _audioPlayer.play(DeviceFileSource(_customRecordingPath!));
        }
      } else if (soundName == SoundConstants.myAudioKey) {
        if (_customAudioPath != null) {
          await _audioPlayer.play(DeviceFileSource(_customAudioPath!));
        }
      } else {
        final fileName = SoundConstants.soundFileMap[soundName];
        if (fileName != null) {
          await _audioPlayer.play(AssetSource("sounds/$fileName"));
        }
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _showRecordingOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            RecordingOverlay(
              onClose: () => Navigator.of(context).pop(),
              onComplete: (path) {
                Navigator.of(context).pop();
                setState(() {
                  _customRecordingPath = path;
                  _selectedSound = SoundConstants.customRecordingKey;
                });
                _playSound(SoundConstants.customRecordingKey);
              },
            ),
      ),
    );
  }

  Future<void> _pickAudioFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _customAudioPath = path;
      _customRecordingPath = null;
      _selectedSound = SoundConstants.myAudioKey;
    });
    _playSound(SoundConstants.myAudioKey);
  }

  void _onNext() {
    _audioPlayer.stop();
    
    // Resolve final sound path/name
    String resultSound = _selectedSound;
    if (_selectedSound == SoundConstants.customRecordingKey && _customRecordingPath != null) {
      resultSound = _customRecordingPath!;
    } else if (_selectedSound == SoundConstants.myAudioKey && _customAudioPath != null) {
      resultSound = _customAudioPath!;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FirstAlarmStep3Screen(
          hour: widget.hour,
          minute: widget.minute,
          soundName: resultSound,
          volume: _volume,
        ),
      ),
    );
  }

  Widget _buildStepBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MissionStepBadge(step: 1, isActive: false),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 2, isActive: true),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 3, isActive: false),
      ],
    );
  }

  Widget _buildSlider() {
    return Row(
      children: [
        const Text(
          "0",
          style: TextStyle(
            color: Color(0xFFC8C8C8),
            fontSize: 12,
            fontFamily: 'HYkanM',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Track
              Container(
                height: 12, // 24 -> 12 (Half)
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)],
                  ),
                  borderRadius: BorderRadius.circular(6), // 12 -> 6
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
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _audioPlayer.setVolume(v);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "100",
          style: TextStyle(
            color: Color(0xFFC8C8C8),
            fontSize: 12,
            fontFamily: 'HYkanM',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Badges
            _buildStepBadges(),
            const SizedBox(height: 40),
            
            // Title
            const Text(
              "기상 사운드는 뭘로 해줄까?",
              style: TextStyle(
                color: AppColors.baseWhite,
                fontSize: 24,
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),

            // Sound List (Expanded)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Removed horizontal padding
                children: _soundOptions.map((sound) {
                  final isSelected = sound == _selectedSound;
                  final isRecording = sound == SoundConstants.customRecordingKey;
                  final isMyAudio = sound == SoundConstants.myAudioKey;
                  
                  final iconAsset = (isRecording || isMyAudio)
                      ? "assets/illusts/illust-record.png"
                      : "assets/illusts/illust-sound.png";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0), // Removed bottom margin between items if full width is desired? User said "full width", but didn't say "no gap". 
                    // Usually full width list items don't have side gaps. 
                    // If they want "width to cover screen sides", side padding must go.
                    // I'll keep bottom padding if they are separate cards, but if they want "list item" style, maybe 0.
                    // Let's assume Card style full width but valid vertical spacing.
                    // Actually, "skybluelistitem" has a border. If they touch, borders will be double custom.
                    // The user said "width to cover screen sides".
                    // I'll remove ListView padding. Pushing items to edges.
                    
                    child: Column(
                      children: [
                        SkyblueListItem(
                          onTap: () {
                            if (isRecording) {
                              _showRecordingOverlay();
                            } else if (isMyAudio) {
                              _pickAudioFromDevice();
                            } else {
                              if (isSelected) {
                                _audioPlayer.stop();
                                setState(() {
                                  _selectedSound = ''; // Deselect
                                });
                              } else {
                                setState(() {
                                  _selectedSound = sound;
                                  _customRecordingPath = null;
                                  _customAudioPath = null;
                                });
                                _playSound(sound);
                              }
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
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
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: isSelected
                                    ? Column(
                                        children: [
                                          // Blue Divider REMOVED
                                          SizedBox(height: 40, child: _buildSlider()),
                                          const SizedBox(height: 5),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                         const SizedBox(height: 10), // Adding spacing externally if I remove it from padding
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Next Button
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
               child: YellowMainButton(
                 label: "다음",
                 onTap: _onNext,
                 width: double.infinity,
                 height: 60,
               ),
             ),
          ],
        ),
      ),
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
    final src = Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );

    canvas.drawImageRect(image!, src, dst, Paint());
  }
}


