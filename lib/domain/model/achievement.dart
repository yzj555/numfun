import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  static const List<Achievement> all = [
    Achievement(
      id: 'first_blood',
      name: '初试锋芒',
      description: '完成第一局游戏',
      icon: Icons.emoji_events,
      color: Color(0xFFFFA000),
    ),
    Achievement(
      id: 'speed_demon',
      name: '极速传说',
      description: '2分钟内完成一局',
      icon: Icons.bolt,
      color: Color(0xFFFFD600),
    ),
    Achievement(
      id: 'no_hints',
      name: '完美无瑕',
      description: '不用提示完成一局',
      icon: Icons.diamond,
      color: Color(0xFF00BCD4),
    ),
    Achievement(
      id: 'perfect_check',
      name: '百发百中',
      description: '一次检查全对，零错误',
      icon: Icons.my_location,
      color: Color(0xFF4CAF50),
    ),
    Achievement(
      id: 'portal_master',
      name: '穿越者',
      description: '完成一局数独任意门',
      icon: Icons.door_sliding,
      color: Color(0xFF9C27B0),
    ),
    Achievement(
      id: 'debug_master',
      name: '火眼金睛',
      description: '完成一局纠错大师',
      icon: Icons.remove_red_eye,
      color: Color(0xFFFF6F00),
    ),
    Achievement(
      id: 'streak_3',
      name: '连胜三局',
      description: '连续完成3局游戏',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF5722),
    ),
    Achievement(
      id: 'easy_complete',
      name: '简单之王',
      description: '完成简单全部1000关',
      icon: Icons.stars,
      color: Color(0xFF66BB6A),
    ),
    Achievement(
      id: 'all_levels',
      name: '全面征服',
      description: '完成全部4000关',
      icon: Icons.workspace_premium,
      color: Color(0xFFFFD700),
    ),
    Achievement(
      id: 'max_score',
      name: '满分达人',
      description: '单局得分达到800',
      icon: Icons.auto_awesome,
      color: Color(0xFFE91E63),
    ),
    Achievement(
      id: 'heavy_hints',
      name: '步步为营',
      description: '累计使用100次提示',
      icon: Icons.lightbulb,
      color: Color(0xFFFF9800),
    ),
    Achievement(
      id: 'one_hour',
      name: '耐心玩家',
      description: '累计游戏时间超过1小时',
      icon: Icons.access_time,
      color: Color(0xFF607D8B),
    ),
    Achievement(
      id: 'score_5000',
      name: '闪耀新星',
      description: '累计总分达到5000',
      icon: Icons.trending_up,
      color: Color(0xFF2196F3),
    ),
  ];

  static Achievement? findById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
