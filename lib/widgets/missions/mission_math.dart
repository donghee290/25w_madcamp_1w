import 'dart:math';
import 'package:flutter/material.dart';

class MissionMath extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;

  const MissionMath({
    super.key,
    required this.difficulty,
    required this.onSuccess,
  });

  @override
  State<MissionMath> createState() => _MissionMathState();
}

class _MissionMathState extends State<MissionMath> {
  final Random _rng = Random();

  late String _expressionText; // 화면에 보여줄 식
  late int _answer; // 정답
  String _input = "";

  @override
  void initState() {
    super.initState();
    _newProblem();
  }

  void _newProblem() {
    final p = _generateProblem(widget.difficulty);
    setState(() {
      _expressionText = p.text;
      _answer = p.answer;
      _input = "";
    });
  }

  void _append(String v) => setState(() => _input += v);
  void _clear() => setState(() => _input = "");
  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _submit() {
    final n = int.tryParse(_input);
    if (n == _answer) {
      widget.onSuccess();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("틀렸습니다. 다시 입력하세요.")));
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          // 문제 박스
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _expressionText,
              style: const TextStyle(
                fontFamily: 'HYkanB',
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 입력 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _input.isEmpty ? "문제를 풀어주세요." : _input,
              style: TextStyle(
                fontFamily: 'HYkanM',
                fontSize: 16,
                color: _input.isEmpty ? Colors.black45 : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Keypad(
            onNumber: _append,
            onClear: _clear,
            onBackspace: _backspace,
            onSubmit: _submit,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _Problem _generateProblem(int difficulty) {
    final d = difficulty.clamp(1, 5);

    int randInt(int min, int maxInclusive) =>
        min + _rng.nextInt(maxInclusive - min + 1);

    switch (d) {
      case 1:
        {
          final a = randInt(1, 9);
          final b = randInt(1, 9);
          return _Problem("$a + $b =", a + b);
        }
      case 2:
        {
          final a = randInt(10, 99);
          final b = randInt(10, 99);
          return _Problem("$a + $b =", a + b);
        }
      case 3:
        {
          final a = randInt(10, 99);
          final b = randInt(2, 9);
          return _Problem("$a x $b =", a * b);
        }
      case 4:
        {
          final a = randInt(10, 99);
          final b = randInt(2, 9);
          final c = randInt(10, 99);
          final ans = (a * b) + c;
          return _Problem("($a x $b) + $c =", ans);
        }
      case 5:
        {
          final a = randInt(10, 99);
          final b = randInt(10, 99);
          final c = randInt(10, 99);
          final ans = a + (b * c);
          return _Problem("$a + ($b x $c) =", ans);
        }
      default:
        {
          final a = randInt(1, 9);
          final b = randInt(1, 9);
          return _Problem("$a + $b =", a + b);
        }
    }
  }
}

class _Problem {
  final String text;
  final int answer;
  _Problem(this.text, this.answer);
}

class _Keypad extends StatelessWidget {
  final void Function(String) onNumber;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  const _Keypad({
    required this.onNumber,
    required this.onClear,
    required this.onBackspace,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFDCDCE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'HYkanB',
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Row numRow(List<String> nums) {
      return Row(
        children: nums.map((n) => key(n, onTap: () => onNumber(n))).toList(),
      );
    }

    return Column(
      children: [
        numRow(["1", "2", "3"]),
        numRow(["4", "5", "6"]),
        numRow(["7", "8", "9"]),
        Row(
          children: [
            key("지우기", onTap: onBackspace),
            key("0", onTap: () => onNumber("0")),
            key("입력", onTap: onSubmit),
          ],
        ),
      ],
    );
  }
}
