import 'package:flutter/material.dart';

class AppColors {
  // Primary Icy Blue Accent
  static const Color primary = Color(0xFF4FA6E0);
  static const Color primaryDark = Color(0xFF2C7DA0);
  static const Color primaryLight = Color(0xFFBEE9E8);
  static const Color primarySubtleLight = Color(0xFFEBF5FB);
  static const Color primarySubtleDark = Color(0xFF162638);

  // Heatmap shades (0%, 1-25%, 26-50%, 51-75%, 76-100%)
  static const List<Color> heatmapLight = [
    Color(0xFFEBEEF2), // 0%
    Color(0xFFC7E2F7), // 1-25%
    Color(0xFF8EC4EC), // 26-50%
    Color(0xFF4FA6E0), // 51-75%
    Color(0xFF1E78B5), // 76-100%
  ];

  static const List<Color> heatmapDark = [
    Color(0xFF1E232B), // 0%
    Color(0xFF194364), // 1-25%
    Color(0xFF206393), // 26-50%
    Color(0xFF358CC6), // 51-75%
    Color(0xFF4FA6E0), // 76-100%
  ];

  // Neutrals - Light
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Neutrals - Dark
  static const Color backgroundDark = Color(0xFF121417);
  static const Color surfaceDark = Color(0xFF181C22);
  static const Color cardDark = Color(0xFF1E232B);
  static const Color borderDark = Color(0xFF2A313D);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Functional Colors
  static const Color flameOrange = Color(0xFFFF7A00);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
}

class AppDefaults {
  static const double borderRadius = 14.0;
  static const double cardPadding = 16.0;
  static const double minTapTarget = 48.0;

  static const List<Map<String, dynamic>> presetGoals = [
    {
      'title': 'Workout & Training',
      'icon': '🏋️',
      'targetValue': 45,
      'unit': 'mins',
    },
    {
      'title': 'Water Intake',
      'icon': '💧',
      'targetValue': 3000,
      'unit': 'ml',
    },
    {
      'title': 'Sleep 7-8 hrs',
      'icon': '🛌',
      'targetValue': 8,
      'unit': 'hrs',
    },
    {
      'title': 'No Junk Food',
      'icon': '🥗',
      'targetValue': null,
      'unit': null,
    },
    {
      'title': 'Read / Deep Study',
      'icon': '📖',
      'targetValue': 30,
      'unit': 'pages',
    },
    {
      'title': 'Meditation & Breathwork',
      'icon': '🧘',
      'targetValue': 15,
      'unit': 'mins',
    },
    {
      'title': 'Daily Steps',
      'icon': '🚶‍♂️',
      'targetValue': 10000,
      'unit': 'steps',
    },
  ];

  static const List<String> availableEmojis = [
    '🏋️', '💧', '🛌', '🥗', '📖', '🧘', '🚶‍♂️', '🏃', '🚴',
    '⚡', '🧠', '🎯', '💻', '✍️', '🍎', '🚫', '❄️', '🔥',
    '🥑', '🍵', '🚿', '💪', '⏰', '🛡️', '🏆', '⭐', '🎧'
  ];
}
