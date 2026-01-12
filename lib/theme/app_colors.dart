import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // 인스턴스화 방지

  // ===========================================================================
  // 1. Solid Colors (단색)
  // ===========================================================================
  static const Color baseYellow = Color(0xFFF9E000);
  static const Color baseBlue = Color(0xFF396DA9);
  static const Color baseGray = Color(0xFF3E3E4E); // Outer border, OFF Track 등
  static const Color baseBlack = Color(0xFF1E1E1E);
  static const Color baseRed = Color(0xFFFF0000);
  static const Color baseWhite = Color(0xFFFFFFFF);
  
  // Additional Colors from spec or existing usage
  static const Color lightGray = Color(0xFFD9D9D9);
  static const Color blackButtonBorder = Color(0xFF0E0E1E); 
  static const Color subButtonBorder = Color(0xFF2E2E3E); 

  static final Color transparentBlack = const Color(0xFF000000).withValues(alpha: 0.75);
  
  // Shadows
  static const Color shadowColor = Color(0x3F000000);

  // Borders
  static const Color lightBorder = Color(0xFFD1D1D1); 

  // Score Colors
  static const Color scorePerfect = Color(0xFF2196F3); // Blue
  static const Color scoreGood = Color(0xFF4CAF50);    // Green
  static const Color scoreNormal = Color(0xFFFF9800);  // Orange
  static const Color scoreBad = Color(0xFFFF5722);    // DeepOrange
  static const Color scoreWorst = Color(0xFFF44336);   // Red
  static const Color scoreText = Color(0xFF9E9E9E);    // Grey


  // ===========================================================================
  // 2. Gradients (Theme Definition: 중단점 엄수)
  // ===========================================================================

  // Primary Gradient (위 -> 아래, 39% 중단점): #6E6E7E -> #3E3E4E
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.39],
    colors: [Color(0xFF6E6E7E), Color(0xFF3E3E4E)],
  );

  // Secondary Gradient (위 -> 아래, 39% 중단점): #FFFACC -> #DAC400
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.39],
    colors: [Color(0xFFFFFACC), Color(0xFFDAC400)],
  );

  // Grad Skyblue (위 -> 아래, 24% 중단점): #F9FDFF -> #BAE2FF
  static const LinearGradient gradSkyblue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.24],
    colors: [Color(0xFFF9FDFF), Color(0xFFBAE2FF)],
  );

  // Grad Purple (Radial): #CB77FF(0%) -> #AF4AEE(39%) -> #7600BF(100%)
  static const RadialGradient gradPurple = RadialGradient(
    center: Alignment.center,
    radius: 0.5, // Default radius approximation
    stops: [0.0, 0.39, 1.0],
    colors: [Color(0xFFCB77FF), Color(0xFFAF4AEE), Color(0xFF7600BF)],
  );

  // Grad White Purple (Radial): #F9F0FF(0%) -> #F0D7FF(39%) -> #D6A9F2(100%)
  static const RadialGradient gradWhitePurple = RadialGradient(
    center: Alignment.center,
    radius: 0.5,
    stops: [0.0, 0.39, 1.0],
    colors: [Color(0xFFF9F0FF), Color(0xFFF0D7FF), Color(0xFFD6A9F2)],
  );

  // Grad Gray (오른쪽 -> 왼쪽): #D9D9D9 -> #737373
  // Assuming Horizontal Right to Left (Start at Right?) Or is it specific logic?
  // Usually "Gradient Direction" spec implies Visual flow. 
  // Let's use CenterRight to CenterLeft if it says Right/Left.
  static const LinearGradient gradGray = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
  );

  // Grad White (위 -> 아래): #FFFFFF -> #D1D1D1
  static const LinearGradient gradWhite = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFD1D1D1)],
  );

  // Black Main Button Gradient (위 -> 아래): #4E4E5E -> #2E2E3E
  static const LinearGradient blackMainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4E4E5E), Color(0xFF2E2E3E)],
  );
  
  // Toggle Rim (아래->위 밝음->어두움 for concave? No, spec says:
  // "테두리(Rim): 아래쪽이 밝고 위쪽이 어두움 (움푹 들어간 느낌)"
  // So Bottom is Light, Top is Dark. Gradient Begin(Top) -> End(Bottom).
  // If Top is Dark and Bottom is Light: Dark -> Light.
  // SilverDark(#737373) -> SilverLight(#D9D9D9).
  static const LinearGradient toggleRimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF737373), Color(0xFFD9D9D9)],
  );

  // Toggle Thumb (위->아래 밝음->어두움 for convex)
  // Top Light, Bottom Dark.
  // SilverLight(#D9D9D9) -> SilverDark(#737373).
  static const LinearGradient toggleThumbGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
  );
  static const LinearGradient redButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFA3A3), Color(0xFFC40000)],
  );
  
}
