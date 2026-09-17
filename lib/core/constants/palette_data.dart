import 'dart:ui';

class PaletteData {
  final String name;
  final List<Color> colors;

  const PaletteData({required this.name, required this.colors});

  Color colorFor(int digit) {
    assert(digit >= 1 && digit <= 9);
    return colors[digit - 1];
  }

  static const List<PaletteData> palettes = [
    PaletteData(
      name: '暖晖',
      colors: [
        Color(0xFFC62828),
        Color(0xFFE65100),
        Color(0xFFF9A825),
        Color(0xFF2E7D32),
        Color(0xFF00838F),
        Color(0xFF1565C0),
        Color(0xFF6A1B9A),
        Color(0xFFAD1457),
        Color(0xFF4E342E),
      ],
    ),
    PaletteData(
      name: '极光',
      colors: [
        Color(0xFF1B5E20),
        Color(0xFF00BFA5),
        Color(0xFF4A148C),
        Color(0xFFFF6F00),
        Color(0xFF00E676),
        Color(0xFF2979FF),
        Color(0xFFE040FB),
        Color(0xFF1A237E),
        Color(0xFF00838F),
      ],
    ),
    PaletteData(
      name: '霓虹',
      colors: [
        Color(0xFFFF1744),
        Color(0xFFFF6D00),
        Color(0xFFFFEA00),
        Color(0xFF00E676),
        Color(0xFF00B0FF),
        Color(0xFF651FFF),
        Color(0xFFFF4081),
        Color(0xFF76FF03),
        Color(0xFF2979FF),
      ],
    ),
    PaletteData(
      name: '糖果',
      colors: [
        Color(0xFFEF5350),
        Color(0xFFFFB74D),
        Color(0xFFFFF176),
        Color(0xFF81C784),
        Color(0xFF64B5F6),
        Color(0xFFBA68C8),
        Color(0xFFF48FB1),
        Color(0xFF4DD0E1),
        Color(0xFFA1887F),
      ],
    ),
    PaletteData(
      name: '海洋',
      colors: [
        Color(0xFF01579B),
        Color(0xFF00838F),
        Color(0xFF00ACC1),
        Color(0xFF00695C),
        Color(0xFFAED581),
        Color(0xFFFF8F00),
        Color(0xFF5C6BC0),
        Color(0xFFBBDEFB),
        Color(0xFF546E7A),
      ],
    ),
    PaletteData(
      name: '金属',
      colors: [
        Color(0xFFB71C1C),
        Color(0xFF1B5E20),
        Color(0xFF0D47A1),
        Color(0xFFE65100),
        Color(0xFF4A148C),
        Color(0xFF004D40),
        Color(0xFF880E4F),
        Color(0xFF3E2723),
        Color(0xFF37474F),
      ],
    ),
  ];
}
