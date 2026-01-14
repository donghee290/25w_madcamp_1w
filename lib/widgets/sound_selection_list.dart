import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  State<SoundSelectionList> createState() => SoundSelectionListState();
}

class SoundSelectionListState extends State<SoundSelectionList> {
  late String _selectedSound;
  late double _volume;
  String? _customRecordingPath;
  String? _customAudioPath;

  bool _sliderOpened = false;

  ui.Image? _sliderThumbImage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _soundOptions = SoundConstants.soundOptions;

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume;
    _loadSliderThumbImage();

    String initSound = widget.initialSound;

    // Parse formatted strings
    if (initSound.startsWith("녹음한 음원 : ")) {
      _selectedSound = SoundConstants.customRecordingKey;
      _customRecordingPath = initSound.replaceFirst("녹음한 음원 : ", "");
    } else if (initSound.startsWith("나의 음원 : ")) {
      _selectedSound = SoundConstants.myAudioKey;
      _customAudioPath = initSound.replaceFirst("나의 음원 : ", "");
    } else if (_soundOptions.contains(initSound)) {
      _selectedSound = initSound;
    } else {
      // Legacy handling or empty
      if (initSound.isNotEmpty && File(initSound).existsSync()) {
        // Assume My Audio if it's a file path but not formatted
        _selectedSound = SoundConstants.myAudioKey;
        _customAudioPath = initSound;
      } else {
        _selectedSound = "";
      }
    }

    _sliderOpened = false;
  }
  
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _sliderOpened = false;
      });
    }
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
    // Resolve effective sound string with Prefix
    String resultSound = _selectedSound;
    
    if (_selectedSound == SoundConstants.customRecordingKey &&
        _customRecordingPath != null) {
      resultSound = _customRecordingPath!;
    } else if (_selectedSound == SoundConstants.myAudioKey &&
        _customAudioPath != null) {
      resultSound = _customAudioPath!;
    }

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

    try {
      final File tempFile = File(path);
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      final String originalName = path.split(Platform.pathSeparator).last;
      final String extension = originalName.split('.').last;
      final String nameWithoutExt = originalName.substring(
        0,
        originalName.lastIndexOf('.'),
      );

      // Sanitize name just in case? unique enough with timestamp.
      final String fileName =
          '${nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String newPath = '${appDocDir.path}/$fileName';

      // Copy the file to app storage
      await tempFile.copy(newPath);

      // Use the new persistent path
      _updateSelection(SoundConstants.myAudioKey, audioPath: newPath);
    } catch (e) {
      debugPrint("Error copying imported file: $e");
      // Fallback to original path if copy fails
      _updateSelection(SoundConstants.myAudioKey, audioPath: path);
    }
  }

  String _getDisplayName(String soundKey) {
    if (soundKey == SoundConstants.myAudioKey) {
      if (_customAudioPath != null && _customAudioPath!.isNotEmpty) {
        try {
          // Extract filename from path
          String fileName = _customAudioPath!
              .split(Platform.pathSeparator)
              .last;

          final RegExp regex = RegExp(r'^(.*)_(\d+)\.([^.]+)$');
          final match = regex.firstMatch(fileName);
          if (match != null) {
            return "${match.group(1)}.${match.group(3)}"; // name.ext
          }
          return fileName;
        } catch (e) {
          return soundKey;
        }
      }
    }
    return soundKey;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _soundOptions.map((sound) {
        final isSelected = sound == _selectedSound;
        final isRecording = sound == SoundConstants.customRecordingKey;
        final isMyAudio = sound == SoundConstants.myAudioKey;
        final showSlider = isSelected && _sliderOpened;

        final iconAsset = (isRecording || isMyAudio)
            ? "assets/illusts/illust-record.png"
            : "assets/illusts/illust-sound.png";

        // Determine label text
        String labelText = sound;
        if (isMyAudio && _customAudioPath != null) {
          labelText = _getDisplayName(sound);
        }

        return SkyblueListItem(
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
                  _sliderOpened = false;
                });
                widget.onSelectionChanged('', _volume);
              } else {
                _updateSelection(sound);
                setState(() {
                  _sliderOpened = true;
                });
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
                        labelText,
                        style: const TextStyle(
                          fontFamily: 'HYkanB',
                          fontSize: 18,
                          color: Color(0xFF5882B4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: showSlider
                    ? Column(
                        children: [SizedBox(height: 40, child: _buildSlider())],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider() {
    return Row(
      children: [
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
                  min: 0.0,
                  max: 1.0,
                  value: _volume.clamp(0.0, 1.0),
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
