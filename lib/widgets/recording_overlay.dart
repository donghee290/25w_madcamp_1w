import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bullshit/widgets/design_system_buttons.dart';
import 'package:bullshit/services/recording_service.dart';
import 'package:bullshit/widgets/design_system_layouts.dart';
import 'package:bullshit/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';

enum RecordingStateStep { countdown, recording, review }

class RecordingOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String path) onComplete;

  const RecordingOverlay({
    super.key,
    required this.onClose,
    required this.onComplete,
  });

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  RecordingStateStep _step = RecordingStateStep.countdown;
  final RecordingService _recordingService = RecordingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Countdown State
  int _countdown = 3;
  Timer? _timer;

  // Recording State
  String? _recordedPath;

  // Review State
  bool _isPlaying = false;
  double _volume = 0.5;
  ui.Image? _sliderThumbImage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _loadSliderThumbImage();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
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

  @override
  void dispose() {
    _timer?.cancel();
    _recordingService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _step = RecordingStateStep.countdown;
      _countdown = 3;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    debugPrint("Start Recording");
    setState(() {
      _step = RecordingStateStep.recording;
    });
    // Ensure permission before starting (should be handled by service or beforehand)
    if (await _recordingService.hasPermission()) {
      await _recordingService.startRecording();
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recordingService.stopRecording();
    if (path != null) {
      setState(() {
        _recordedPath = path;
        _step = RecordingStateStep.review;
      });
      // Setup audio player source
      await _audioPlayer.setSourceDeviceFile(_recordedPath!);
      await _audioPlayer.setVolume(_volume);
    }
  }

  Future<void> _cancelRecording() async {
    await _recordingService.cancelRecording();
    widget.onClose();
  }

  Future<void> _retryRecording() async {
    // Delete current temp file if exists?
    // Start countdown again
    _startCountdown();
  }

  Future<void> _confirmRecording() async {
    if (_recordedPath == null) return;

    // Move file to permanent storage?
    // Or just pass the path. Usually better to move if it's in temp.
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'alarm_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final newPath = '${appDir.path}/$fileName';

      final file = File(_recordedPath!);
      if (await file.exists()) {
        await file.copy(newPath);
        // Optionally delete temp
        // await file.delete();
        widget.onComplete(newPath);
      } else {
        widget.onComplete(_recordedPath!);
      }
    } catch (e) {
      debugPrint("Error saving recording: $e");
      widget.onComplete(_recordedPath!);
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Opacity Overlay
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.75)),
          ),

          // 2. Content based on step
          if (_step == RecordingStateStep.countdown)
            Positioned.fill(child: _buildCountdownUI()),

          if (_step == RecordingStateStep.recording)
            Positioned.fill(child: _buildRecordingUI()),

          if (_step == RecordingStateStep.review)
            Positioned.fill(child: _buildReviewUI()),
        ],
      ),
    );
  }

  Widget _buildCountdownUI() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center Countdown Number
        Image.asset(
          'assets/illusts/illust-count$_countdown.png',
          width: 100, // Adjust size as needed
          fit: BoxFit.contain,
        ),

        // Bottom Popup
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: PopupSmall(
            height: 240, // Increased from 200
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "곧 녹음을 시작합니다.",
                  style: TextStyle(
                    fontFamily: 'HYkanM',
                    fontSize: 16,
                    color: AppColors.baseWhite,
                  ),
                ),
                const SizedBox(height: 20),
                GrayButton(
                  label: "돌아가기",
                  width: 120,
                  height: 48,
                  onTap: () {
                    _timer?.cancel();
                    widget.onClose();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center Record Button
        GestureDetector(
          onTap: _stopRecording,
          child: Image.asset(
            'assets/illusts/illust-record.png',
            width: 160, // Adjust size
            height: 160,
          ),
        ),

        // Top Right Close Button (Custom placement)
        // User requested: "illust-record.png 오른쪽 위에 x표시 넣음" -> Usually relative to the image?
        // Or screen top right? "오른쪽 위에 x표를 누르면" -> Usually screen.
        // But prompt says "illust-record.png 오른쪽 위에".
        // Let's put it on top right of the screen for better UX, or closely relative to the image.
        // I will put it relative to the center image to match description literally.
        Positioned(
          left: MediaQuery.of(context).size.width / 2 + 50, // approx
          top: MediaQuery.of(context).size.height / 2 - 100,
          child: GestureDetector(
            onTap: _cancelRecording,
            child: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PopupSmall(
          height: 360, // Increased from 320
          child: Column(
            children: [
              // Header Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _cancelRecording,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.close,
                      color: AppColors.baseWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Title
              const Text(
                "녹음이 완료되었습니다.\n기상 사운드로 등록할까요?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HYkanM',
                  fontSize: 16,
                  color: AppColors.baseWhite,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Play Toggle
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: AppColors.baseYellow,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Volume Slider
                    Expanded(child: _buildSlider()),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GrayButton(
                        label: "다시 녹음",
                        height: 45,
                        onTap: _retryRecording,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: YellowMainButton(
                        label: "네!",
                        height: 45,
                        onTap: _confirmRecording,
                        // Reusing YellowMainButton with smaller dimensions
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Track
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)],
            ),
            borderRadius: BorderRadius.circular(8),
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
          child: Slider(value: _volume, onChanged: _updateVolume),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final ui.Image? image;
  _CustomThumbShape({this.image});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(30, 30);

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
      final Paint paint = Paint()..color = Colors.white;
      canvas.drawCircle(center, 10, paint);
      return;
    }

    final Canvas canvas = context.canvas;
    // Smaller thumb for this popup compared to create screen
    final dst = Rect.fromCenter(center: center, width: 28, height: 28);
    final src = Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );

    canvas.drawImageRect(image!, src, dst, Paint());
  }
}
