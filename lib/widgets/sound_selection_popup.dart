import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bullshit/widgets/recording_overlay.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/sound_constants.dart';

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
  String? _customRecordingPath;
  String? _customAudioPath;

  final List<String> _soundOptions = [
    "엘지 굿모닝송",
    "일어나셔야 합니다",
    "군대 기상 나팔",
    "이성을 끌어당기는 주파수",
    "성적이 오르는 주파수",
    "일어나는 건 박수받아 마땅함",
    "직접 녹음하기",
    "내 오디오 가져오기",
  ];

  @override
  void initState() {
    super.initState();
    // Start with no selection per user request
    _selectedSound = ''; 
    _volume = widget.initialVolume;

    // Check if initial sound is likely a file path
    if (_selectedSound.contains('/') || _selectedSound.contains('\\')) {
      _customRecordingPath = _selectedSound;
      _selectedSound = "직접 녹음하기";
    }

    _loadSliderThumbImage();
  }

  @override
  void dispose() {
    // Safe disposal
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
          // DeviceFileSource needs string path
          await _audioPlayer.play(DeviceFileSource(_customRecordingPath!));
        }
      } else {
        // Map to asset file
        final fileName = SoundConstants.soundFileMap[soundName];
        if (fileName != null) {
          // Users need to put files in assets/sounds/
          await _audioPlayer.play(AssetSource("sounds/$fileName"));
        } else {
          debugPrint("No file mapped for: $soundName");
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
                  _selectedSound = "직접 녹음하기";
                });
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
      _selectedSound = "내 오디오 가져오기";
    });
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
            child: SingleChildScrollView(
              child: Column(
                children: _soundOptions.map((sound) {
                  final isSelected = sound == _selectedSound;
                  final isRecordIcon =
                      sound == "직접 녹음하기" || sound == "내 오디오 가져오기";
                  final iconAsset = isRecordIcon
                      ? "assets/illusts/illust-record.png"
                      : "assets/illusts/illust-sound.png";

                  return SkyblueListItem(
                    onTap: () {
                      if (sound == "직접 녹음하기") {
                        _showRecordingOverlay();
                      } else if (sound == "내 오디오 가져오기") {
                        _pickAudioFromDevice();
                      } else {
                        setState(() {
                          _selectedSound = sound;
                          _customRecordingPath = null;
                          _customAudioPath = null;
                        });
                      }
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
                            color: const Color(
                              0xFF396DA9,
                            ).withValues(alpha: 0.5),
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                          ),
                          SizedBox(height: 40, child: _buildSlider()),
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
                // If "직접 녹음하기" is selected, return the local path.
                // Otherwise return selected sound name.
                // If nothing selected (empty), return initial sound (User cancelled selection effectively, or kept same)
                // User request: "Modify to ... nothing selected state". 
                // Context: If they click "Confirm" without selecting anything, should it keep old sound? 
                // Yes, usually "Confirm" means "Apply changes". If no change, keep old.
                
                String resultSound = _selectedSound;
                if (_selectedSound == "직접 녹음하기" &&
                    _customRecordingPath != null) {
                  resultSound = _customRecordingPath!;
                }
                if (_selectedSound == "내 오디오 가져오기" &&
                    _customAudioPath != null) {
                  resultSound = _customAudioPath!;
                }

                Navigator.of(
                  context,
                ).pop({'soundName': resultSound, 'volume': _volume});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Row(
      children: [
        // Background Track
        Container(
          height: 24, // Slightly smaller than create screen
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)],
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
