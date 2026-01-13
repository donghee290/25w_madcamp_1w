import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class MissionColors extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;

  const MissionColors({
    super.key,
    required this.difficulty,
    required this.onSuccess,
  });

  @override
  State<MissionColors> createState() => _MissionColorsState();
}

class _MissionColorsState extends State<MissionColors> {
  final Random _rng = Random();

  late int _grid;
  late int _need;
  late Set<int> _targets;
  final Set<int> _pickedCorrect = {};

  bool _isRevealing = true;
  bool _revealWrong = false;
  bool _revealSuccess = false;
  int _countdown = 3;

  Timer? _countdownTimer;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _newBoard(startReveal: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _newBoard({required bool startReveal}) {
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();

    final d = widget.difficulty.clamp(1, 3);
    if (d == 1) {
      _grid = 3;
      _need = 4;
    } else if (d == 2) {
      _grid = 4;
      _need = 5;
    } else {
      _grid = 5;
      _need = 7;
    }

    final total = _grid * _grid;

    final targets = <int>{};
    while (targets.length < _need) {
      targets.add(_rng.nextInt(total));
    }

    setState(() {
      _targets = targets;
      _pickedCorrect.clear();
      _isRevealing = startReveal;
      _revealWrong = false;
      _revealSuccess = false;
      _countdown = 3;
    });

    if (startReveal) _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 1) {
        t.cancel();
        setState(() {
          _countdown = 0;
          _isRevealing = false;
        });
        return;
      }
      setState(() => _countdown--);
    });
  }

  Future<void> _handleTap(int idx) async {
    if (_revealWrong) return;
    if (_isRevealing) return;
    if (_pickedCorrect.contains(idx)) return;

    //정답
    if (_targets.contains(idx)) {
      _pickedCorrect.add(idx);

      await HapticFeedback.heavyImpact();

      if (_pickedCorrect.length >= _need) {
        _feedbackTimer?.cancel();
        setState(() => _revealSuccess = true);

        _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          widget.onSuccess();
        });
      } else {
        setState(() {});
      }
      return;
    }

    //오답
    await HapticFeedback.heavyImpact();
    setState(() => _revealWrong = true);

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _newBoard(startReveal: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _grid * _grid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              _isRevealing ? "타일의 위치를 외우세요!" : "색 타일 $_need개를 찾아보세요!",
              style: const TextStyle(
                fontFamily: 'HYkanB',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: Center(
              child: (_isRevealing && _countdown > 0)
                  ? Image.asset(
                      'assets/illusts/illust-count$_countdown.png',
                      fit: BoxFit.contain,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 20),

          //보드
          Container(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: total,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _grid,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final bool shouldShowTarget =
                    _isRevealing && _targets.contains(i);
                final bool isSolved = _pickedCorrect.contains(i);

                final Color tileColor;
                if (_revealSuccess && _targets.contains(i)) {
                  tileColor = AppColors.scoreGood;
                } else if (_revealWrong && _targets.contains(i)) {
                  tileColor = AppColors.baseRed;
                } else if (shouldShowTarget) {
                  tileColor = AppColors.baseYellow;
                } else if (isSolved) {
                  tileColor = AppColors.scoreGood;
                } else {
                  tileColor = AppColors.lightGray;
                }

                return GestureDetector(
                  onTap: () => _handleTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
