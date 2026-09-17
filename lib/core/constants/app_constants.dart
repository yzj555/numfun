import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = '数·趣';
  static const String appNameEn = 'NumFun';
  static const int boardSize = 9;
  static const int boxSize = 3;
  static const int maxHints = 3;
  static const int minClues = 22;

  static const List<Color> colorPalette = [
    Color(0xFF4A90D9),
    Color(0xFFE74C3C),
    Color(0xFF2ECC71),
    Color(0xFFF39C12),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF3498DB),
    Color(0xFFE91E63),
  ];

  static const Map<int, Color> numberColors = {
    1: Color(0xFF4A90D9),
    2: Color(0xFFE74C3C),
    3: Color(0xFF2ECC71),
    4: Color(0xFFF39C12),
    5: Color(0xFF9B59B6),
    6: Color(0xFF1ABC9C),
    7: Color(0xFFE67E22),
    8: Color(0xFF3498DB),
    9: Color(0xFFE91E63),
  };
}
