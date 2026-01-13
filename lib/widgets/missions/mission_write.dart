import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class MissionWrite extends StatefulWidget {
  final int difficulty;
  final VoidCallback onSuccess;

  const MissionWrite({
    super.key,
    required this.difficulty,
    required this.onSuccess,
  });

  @override
  State<MissionWrite> createState() => _MissionWriteState();
}

class _MissionWriteState extends State<MissionWrite> {
  final Random _rng = Random();
  final TextEditingController _c = TextEditingController();
  Timer? _feedbackTimer;

  late String _target;

  Color _borderColor = Colors.transparent;
  bool _lockInput = false;

  static const List<String> typingLevel1 = [
    "바나나",
    "아이스크림",
    "떡볶이",
    "대한민국",
    "스마트폰",
    "호랑이",
    "강아지",
    "고양이",
    "비빔밥",
    "아메리카노",
    "넷플릭스",
    "유튜브",
    "카카오톡",
    "초콜릿",
    "탕후루",
    "마라탕",
    "삼겹살",
    "치킨맥주",
    "햄버거",
    "다이어트",
    "크리스마스",
    "솜사탕",
    "무지개",
    "도서관",
    "운동장",
    "편의점",
    "코인노래방",
    "붕어빵",
    "제주도",
    "뽀로로",
  ];

  final List<String> typingLevel2 = [
    "좋은 일만 가득",
    "아기다리고기다리던",
    "니 얼굴 방구 뿡뿡",
    "오늘 점심 뭐 먹지",
    "치킨은 살 안 쪄",
    "살은 내가 쪄요",
    "월화수목금퇼",
    "퇴근하고 싶다",
    "넌 할 수 있어",
    "완전 럭키비키",
    "어쩔티비 저쩔티비",
    "폼 미쳤다",
    "내 꿈은 돈 많은 백수",
    "맛도리 인정",
    "야 너두? 야 나두",
    "킹받네 진짜",
    "숭구리당당 숭당당",
    "행복하자 아프지 말고",
    "오다가 주웠다",
    "너 T야? 난 F야",
    "중요한 건 꺾이지",
    "않는 마음",
    "와 샌즈 아시는구나",
    "ㅋㅋ루삥뽕",
    "멍멍이 귀여워",
    "배고파 밥 줘",
    "내일도 맑음",
    "꽃길만 걷자",
    "사랑해 3000만큼",
    "밥은 먹고 다니냐",
  ];

  final List<String> typingLevel3 = [
    "간장 공장 공장장은 강 공장장이고 된장 공장 공장장은 장 공장장이다",
    "내가 그린 기린 그림은 잘 그린 기린 그림이고 네가 그린 그림은 못 그린 그림이다",
    "경찰청 철창살은 외철창살이고 검찰청 철창살은 쌍철창살이다",
    "저기 저 뜀틀 위에 올라간 말이 말이야 정말 말도 안 되게 높다",
    "닭 쫓던 개가 지붕을 쳐다보며 왜 내가 여기까지 왔나 후회하고 있다",
    "밟지 말고 사뿐히 즈려밟고 가시옵소서라는 말은 참으로 어렵다",
    "늴리리야 늴리리야 니나노를 정확히 입력하려면 정신을 차려야 한다",
    "괜찮아 다 잘 될 거야라고 쓰려다 보면 꼭 한 글자를 빼먹게 된다",
    "왜 안 돼와 외않되를 헷갈리지 않는 사람은 생각보다 많지 않다",
    "깎아지른 절벽 끝에 핀 꽃 한 송이가 오늘따라 유난히 눈에 밟힌다",
    "볶음밥에 깍두기 국물은 국룰인지 아닌지 매번 논쟁이 벌어진다",
    "쌍쌍바를 반으로 쪼개 먹다 보면 꼭 한쪽이 더 크게 느껴진다",
    "뙤약볕 아래서 땀을 뻘뻘 흘리며 타이핑하는 건 쉽지 않은 일이다",
    "얽히고설킨 생각들이 머릿속에서 엉켜 도무지 풀리지 않는다",
    "코코팜 포도맛 젤리를 씹으며 키보드를 치는 상상을 해보자",
    "쿵쿵따리 쿵쿵따 신나는 노래에 맞춰 손가락도 춤을 춘다",
    "습관처럼 쓰던 문장도 막상 정확히 입력하려면 생각보다 어렵다",
    "짧은 인생 즐겁게 살아야지라고 쓰면서도 오타가 난다",
    "갉아먹은 사과 모양 로고는 전 세계 어디서나 한눈에 알아볼 수 있다",
    "오늘 할 일을 내일로 미루지 말자는 말은 참 쉽고도 어렵다",
    "쌉가능이라고 쓰려다 보면 손이 먼저 불가능을 입력한다",
    "맑은 하늘 아래 밝은 웃음을 타이핑으로 표현하는 건 쉽지 않다",
    "내일의 나에게 부끄럽지 않도록 오늘의 문장을 정확히 쓰자",
    "익숙한 문장일수록 방심하면 오타가 나기 마련이다",
    "지금 이 문장을 끝까지 틀리지 않고 입력하면 꽤 대단한 것이다",
    "아무 생각 없이 쓰던 문장도 천천히 보면 맞춤법이 틀린 경우가 꽤 많다",
    "손은 알고 있는데 뇌가 잠깐 멈추는 순간 오타는 어김없이 튀어나온다",
    "이 문장을 정확히 입력하는 동안 다른 생각은 전혀 하면 안 된다",
    "익숙함이 방심을 낳고 방심은 결국 키 하나를 빼먹게 만든다",
    "지금 이 타이핑이 끝나면 알람도 꺼지고 하루가 제대로 시작된다",
  ];

  @override
  void initState() {
    super.initState();
    _pickNewText();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  List<String> _poolByDifficulty(int d) {
    final dd = d.clamp(1, 3);
    if (dd == 1) return typingLevel1;
    if (dd == 2) return typingLevel2;
    return typingLevel3;
  }

  void _pickNewText() {
    final pool = _poolByDifficulty(widget.difficulty);
    setState(() {
      _target = pool[_rng.nextInt(pool.length)];
      _borderColor = Colors.transparent;
      _lockInput = false;
    });
    _c.text = "";
  }

  void _submit() async {
    final typed = _c.text;

    _feedbackTimer?.cancel();

    if (typed == _target) {
      await HapticFeedback.heavyImpact();
      setState(() {
        _borderColor = AppColors.scoreGood;
        _lockInput = true;
      });

      _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        widget.onSuccess();
      });
      return;
    }

    //오답
    await HapticFeedback.heavyImpact();
    setState(() => _borderColor = AppColors.baseRed);

    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _borderColor = Colors.transparent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int d = widget.difficulty.clamp(1, 3);

    final double boxHeight = switch (d) {
      1 => 90,
      2 => 120,
      _ => 160,
    };

    final double targetFontSize = switch (d) {
      1 => 24,
      2 => 20,
      _ => 16,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const SizedBox(height: 8),

          //문제 박스
          Container(
            width: double.infinity,
            height: boxHeight,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _target,
              textAlign: TextAlign.center,
              maxLines: d == 3 ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'HYkanB',
                fontSize: targetFontSize,
                color: Colors.black,
                height: 1.25,
              ),
            ),
          ),

          const SizedBox(height: 14),

          //입력창
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor, width: 3),
            ),
            child: TextField(
              controller: _c,
              enabled: !_lockInput,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: 'HYkanM',
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "텍스트를 똑같이 입력해주세요.",
                hintStyle: TextStyle(
                  fontFamily: 'HYkanM',
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          //버튼
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.baseYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "제출하기",
                style: TextStyle(
                  fontFamily: 'HYkanB',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
