import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // 인스턴스화 방지

  // ===========================================================================
  // 1. Solid Colors (단색)
  // ===========================================================================
  static const Color baseYellow = Color(0xFFF9E000);
  static const Color baseBlue = Color(0xFF396DA9);
  static const Color baseGray = Color(0xFF3E3E4E); // Outer border, OFF Track 등
  static const Color lightGray = Color(
    0xFFD9D9D9,
  ); // Gray Button Inner, YellowGray Outer
  static const Color baseBlack = Color(0xFF1E1E1E);
  static const Color baseRed = Color(0xFFFF0000);
  static const Color baseWhite = Color(0xFFFFFFFF);

  // Black Buttons 전용 테두리
  static const Color blackButtonBorder = Color(0xFF0E0E1E); // Main (진함)
  static const Color subButtonBorder = Color(0xFF2E2E3E); // Sub (약간 밝음)

  // Toggle Switch 전용 금속 색상
  static const Color silverLight = Color(0xFFD9D9D9);
  static const Color silverDark = Color(0xFF737373);

  static final Color transparentBlack = const Color(
    0xFF000000,
  ).withValues(alpha: 0.75);

  // ===========================================================================
  // 2. Gradients (Theme Definition: 중단점 엄수)
  // ===========================================================================

  // Primary Gradient (위 -> 아래, 39% 중단점)
  // 사용: PopupBig, PopupSmall, BlackSubButton
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.39],
    colors: [Color(0xFF6E6E7E), Color(0xFF3E3E4E)],
  );

  // Secondary Gradient (위 -> 아래, 39% 중단점 - 노란색 계열)
  // 사용: YellowMainButton, YellowGrayButton
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.39],
    colors: [Color(0xFFFFFACC), Color(0xFFDAC400)],
  );

  // Skyblue Gradient (위 -> 아래, 24% 중단점)
  // 사용: SkyblueListItem
  static const LinearGradient gradSkyblue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.24],
    colors: [Color(0xFFF9FDFF), Color(0xFFBAE2FF)],
  );

  // Black Main Button Gradient (위 -> 아래, 별도 정의)
  static const LinearGradient blackMainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4E4E5E), Color(0xFF2E2E3E)],
  );

  // Toggle Rim Gradient (아래 -> 위: 들어간 느낌)
  static const LinearGradient toggleRimGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [silverLight, silverDark],
  );

  // Toggle Thumb Gradient (위 -> 아래: 튀어나온 느낌)
  static const LinearGradient toggleThumbGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [silverLight, silverDark],
  );

  // (참고) 기타 Radial Gradients
  static const RadialGradient gradPurple = RadialGradient(
    center: Alignment.center,
    radius: 0.5,
    stops: [0.0, 0.39, 1.0],
    colors: [Color(0xFFCB77FF), Color(0xFFAF4AEE), Color(0xFF7600BF)],
  );
  static const RadialGradient gradWhitePurple = RadialGradient(
    center: Alignment.center,
    stops: [0.0, 0.39, 1.0],
    colors: [Color(0xFFF9F0FF), Color(0xFFF0D7FF), Color(0xFFD6A9F2)],
  );
}
