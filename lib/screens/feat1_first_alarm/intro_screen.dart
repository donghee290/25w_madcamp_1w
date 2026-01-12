import 'package:flutter/material.dart';
import 'package:bullshit/theme/app_colors.dart';
import 'package:bullshit/screens/feat1_first_alarm/first_alarm_step1_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  //1. illust-lesson: opacity 25%
  double _lessonOpacity = 0.25;

  //2. light(animation)
  bool _showLight = false;
  late final AnimationController _blinkController;
  late final Animation<double> _lightOpacityAnim;

  //3. button
  bool _showStartButton = false;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), //blink speed
    );

    _lightOpacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _blinkController, curve: Curves.linear));

    Future<void> blinkTwiceThenOn() async {
      _blinkController.value = 0.0;

      for (int i = 0; i < 2; i++) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }

      _blinkController.value = 1.0; // 최종 ON
      if (!mounted) return;

      setState(() => _lessonOpacity = 1.0);

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() => _showStartButton = true);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _showLight = true);
      blinkTwiceThenOn();
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _onStartPressed() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FirstAlarmStep1Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseGray,
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //illust-lesson
              Positioned(
                top: 300,
                child: AnimatedOpacity(
                  opacity: _lessonOpacity,
                  duration: const Duration(milliseconds: 250),
                  child: Image.asset(
                    'assets/illusts/illust-lesson.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              //illust-lightd
              Positioned(
                top: -100,
                child: _showLight
                    ? FadeTransition(
                        opacity: _lightOpacityAnim,
                        child: Image.asset(
                          'assets/illusts/illust-light.png',
                          width: 700,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              //button
              Positioned(
                bottom: 120,
                child: AnimatedOpacity(
                  opacity: _showStartButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _showStartButton
                        ? Offset.zero
                        : const Offset(0, 0.12),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: SizedBox(
                      width: 220,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _showStartButton ? _onStartPressed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2C100),
                          foregroundColor: const Color(0xFF222222),
                          disabledBackgroundColor: const Color(0xFFE2C100),
                          disabledForegroundColor: const Color(0xFF222222),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('굿모닝은개뿔 시작하기'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
