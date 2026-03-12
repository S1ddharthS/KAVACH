import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  KAVACH — App Constants
// ─────────────────────────────────────────────

// ── Palette ──────────────────────────────────
class KavachColors {
  KavachColors._();

  static const Color background   = Color(0xFF0D0D1A);
  static const Color surface      = Color(0xFF16162A);
  static const Color surfaceCard  = Color(0xFF1E1E38);
  static const Color primary      = Color(0xFFE8417A);   // vivid rose
  static const Color primaryDark  = Color(0xFFB02D5C);
  static const Color primaryGlow  = Color(0x55E8417A);
  static const Color accent       = Color(0xFF7B61FF);   // violet accent
  static const Color accentGlow   = Color(0x557B61FF);
  static const Color safe         = Color(0xFF2DD4A0);   // teal "safe" state
  static const Color warning      = Color(0xFFFFA726);
  static const Color danger       = Color(0xFFFF3B3B);
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFFB0B0CC);
  static const Color divider      = Color(0xFF2A2A45);

  // SOS ring gradient stops
  static const List<Color> sosGradient = [
    Color(0xFFFF3B3B),
    Color(0xFFE8417A),
    Color(0xFFB02D5C),
  ];

  // Background gradient
  static const List<Color> bgGradient = [
    Color(0xFF0D0D1A),
    Color(0xFF16102A),
  ];
}

// ── Typography ────────────────────────────────
class KavachTextStyles {
  KavachTextStyles._();

  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: KavachColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: KavachColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: KavachColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: KavachColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: KavachColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static const TextStyle sosLabel = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: KavachColors.textPrimary,
    letterSpacing: 3,
  );

  static const TextStyle sosSubLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xCCFFFFFF),
    letterSpacing: 1.5,
  );
}

// ── Spacing & Sizing ──────────────────────────
class KavachSizes {
  KavachSizes._();

  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge  = 24.0;
  static const double radiusXL     = 32.0;

  static const double paddingXS    = 6.0;
  static const double paddingS     = 12.0;
  static const double paddingM     = 16.0;
  static const double paddingL     = 24.0;
  static const double paddingXL    = 32.0;

  static const double sosBtnSize   = 180.0;
  static const double iconSize     = 26.0;
}

// ── Named Routes ──────────────────────────────
class KavachRoutes {
  KavachRoutes._();

  static const String dashboard = '/';
  static const String map       = '/map';
  static const String safeWalk  = '/safe-walk';
  static const String fakeCall  = '/fake-call';
  static const String report    = '/report';
  static const String community = '/community';
}

// ── Strings ───────────────────────────────────
class KavachStrings {
  KavachStrings._();

  static const String appName          = 'KAVACH';
  static const String sosHold          = 'HOLD FOR SOS';
  static const String sosSending       = 'SENDING ALERT…';
  static const String dashboardGreeting = 'Stay Safe Today';

  // Nav labels
  static const String navMap       = 'Map';
  static const String navSafeWalk  = 'Safe Walk';
  static const String navFakeCall  = 'Fake Call';
  static const String navReport    = 'Report';
  static const String navCommunity = 'Community';
}

// ── Durations ─────────────────────────────────
class KavachDurations {
  KavachDurations._();

  static const Duration fast    = Duration(milliseconds: 200);
  static const Duration normal  = Duration(milliseconds: 400);
  static const Duration slow    = Duration(milliseconds: 700);
  static const Duration sosPulse = Duration(milliseconds: 1200);
}
