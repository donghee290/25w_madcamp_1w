import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

import '../constants/sound_constants.dart';
import 'design_system_layouts.dart';
import 'recording_overlay.dart';

class SoundSelectionList extends StatefulWidget {
  final String initialSound;
  final double initialVolume;
  final Function(String sound, double volume) onSelectionChanged;

  const SoundSelectionList({
    super.key,
    required this.initialSound,
    required this.initialVolume,
    required this.onSelectionChanged,
  });

  @override
  State<SoundSelectionList> createState() => _SoundSelectionListState();
}

class _SoundSelectionListState extends State<SoundSelectionList> {
  late String _selectedSound;
  late double _volume;
  String? _customRecordingPath;
  String? _customAudioPath;

  ui.Image? _sliderThumbImage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _soundOptions = SoundConstants.soundOptions;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.initialSound;
    _volume = widget.initialVolume;
    _loadSliderThumbImage();
  }

  @override
  void dispose() {
    _audioPlayer.stop().catchError((e) {
      debugPrint("Error stopping audio: $e");
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

      // Resolve path
      String? sourceUrl;
      if (soundName == SoundConstants.customRecordingKey) {
        sourceUrl = _customRecordingPath;
      } else if (soundName == SoundConstants.myAudioKey) {
        sourceUrl = _customAudioPath;
      } else {
        final fileName = SoundConstants.soundFileMap[soundName];
        if (fileName != null) {
          await _audioPlayer.play(AssetSource("sounds/$fileName"));
          return;
        }
      }

      if (sourceUrl != null) {
        await _audioPlayer.play(DeviceFileSource(sourceUrl));
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _notifyChange() {
    // Resolve effective sound string
    String resultSound = _selectedSound;
    if (_selectedSound == SoundConstants.customRecordingKey &&
        _customRecordingPath != null) {
      resultSound = _customRecordingPath!;
    } else if (_selectedSound == SoundConstants.myAudioKey &&
        _customAudioPath != null) {
      resultSound = _customAudioPath!;
    }

    // If selecting 'recording' but no path yet, pass Key (parent handles or waits?)
    // Actually parent usually waits for Next/Confirm.
    // We pass the current internal state "key" or "path" if resolved?
    // Let's pass the KEY if it's special, or the resolved path?
    // The previous logic resolved it at the end.
    // Let's pass the key, but also maybe the resolved path if available.
    // For simplicity, let's behave like the UI state: Key.
    // The parent can resolve it, or we resolve it.
    // Let's stick to what _onNext/Confirm did:
    // They checked `if (_selectedSound == Key)`.
    // So we just update the parent with `_selectedSound` (which might be a key).
    // BUT, the parent needs the file path if it is Key.

    // Better idea: Pass the RESOLVED sound string to the parent immediately?
    // If I pick "Record", and haven't recorded, value is "RecordKey".
    // Parent receives "RecordKey".
    // If I record, `_customRecordingPath` updates.
    // I should call `widget.onSelectionChanged` with the resolved path?
    // Step 2 logic:
    // `if (_selectedSound == RecordKey && path != null) result = path`
    // So yes, I should invoke callback whenever selection or path or volume changes.

    widget.onSelectionChanged(resultSound, _volume);
  }

  void _updateSelection(
    String sound, {
    String? recordingPath,
    String? audioPath,
  }) {
    setState(() {
      _selectedSound = sound;
      if (recordingPath != null) _customRecordingPath = recordingPath;
      if (audioPath != null) _customAudioPath = audioPath;

      // Clear others if switching types?
      // Previous logic didn't strictly clear paths when switching away,
      // but did separate them.
      // We'll keep it simple.
    });
    _notifyChange();
    _playSound(sound);
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
                _updateSelection(
                  SoundConstants.customRecordingKey,
                  recordingPath: path,
                );
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

    _updateSelection(SoundConstants.myAudioKey, audioPath: path);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _soundOptions.map((sound) {
        final isSelected = sound == _selectedSound;
        final isRecording = sound == SoundConstants.customRecordingKey;
        final isMyAudio = sound == SoundConstants.myAudioKey;

        final iconAsset = (isRecording || isMyAudio)
            ? "assets/illusts/illust-record.png"
            : "assets/illusts/illust-sound.png";

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkyblueListItem(
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
                  widget.onSelectionChanged('', _volume);
                } else {
                  _updateSelection(sound);
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
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6E6E7E)),
                ),
              ),
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
                    _notifyChange(); // Notify volume change
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
