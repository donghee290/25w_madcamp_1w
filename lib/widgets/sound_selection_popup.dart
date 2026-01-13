import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart';
import 'package:bullshit/widgets/recording_overlay.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/sound_constants.dart';
import 'package:file_picker/file_picker.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> _soundOptions = SoundConstants.soundOptions;

  @override
  void initState() {
    super.initState();
    // Start with no selection per user request
    _selectedSound = '';
    _volume = widget.initialVolume;

    // We don't pre-select logic anymore
    // but we can keep _customRecordingPath null
    _customRecordingPath = null;
    _customAudioPath = null;

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
      } else if (soundName == SoundConstants.myAudioKey) {
        if (_customAudioPath != null) {
          await _audioPlayer.play(DeviceFileSource(_customAudioPath!));
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
                  final isRecording =
                      sound == SoundConstants.customRecordingKey;
                  final isMyAudio = sound == SoundConstants.myAudioKey;

                  final iconAsset = (isRecording || isMyAudio)
                      ? "assets/illusts/illust-record.png"
                      : "assets/illusts/illust-sound.png";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10), // Keep vertical spacing
                    child: SkyblueListItem(
                      onTap: () {
                        if (isRecording) {
                          _showRecordingOverlay();
                        } else if (isMyAudio) {
                          _pickAudioFromDevice();
                        } else {
                          if (isSelected) {
                            // Toggle Off Logic: Stop and Deselect
                            _audioPlayer.stop();
                            setState(() {
                              _selectedSound = ''; // Deselect
                              _customRecordingPath = null;
                              _customAudioPath = null;
                            });
                          } else {
                            // Select and Play
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

                if (resultSound.isEmpty) {
                  resultSound = widget.initialSound;
                } else if (_selectedSound ==
                        SoundConstants.customRecordingKey &&
                    _customRecordingPath != null) {
                  resultSound = _customRecordingPath!;
                } else if (_selectedSound == SoundConstants.myAudioKey &&
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
      mainAxisAlignment: MainAxisAlignment.center,
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
    // Draw thumb centered
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


