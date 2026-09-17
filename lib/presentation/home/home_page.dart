import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../../domain/model/puzzle.dart';
import '../../core/constants/palette_data.dart';
import '../game/game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _startGame(BuildContext context, Difficulty diff) {
    final provider = context.read<GameProvider>();
    final progress = provider.levelProgress;
    final level = (progress[diff] ?? 0) + 1;
    provider.newGame(diff, GameMode.classic, level: level);
    provider.setLevel(level > 1000 ? 1000 : level);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  void _startPortalGame(BuildContext context) {
    final provider = context.read<GameProvider>();
    final index = Random().nextInt(PaletteData.palettes.length);
    provider.newGame(Difficulty.easy, GameMode.portal, pixelArtIndex: index);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  void _startDebugGame(BuildContext context) {
    final provider = context.read<GameProvider>();
    provider.newGame(Difficulty.easy, GameMode.debug);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = context.watch<GameProvider>().levelProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数·趣'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(isDark: isDark, onPlay: () => _startGame(context, Difficulty.easy)),
            const SizedBox(height: 24),
            Text(
              '快速开始',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
              ),
            ),
            const SizedBox(height: 12),
            _DifficultyGrid(progress: progress, onPlay: (diff) => _startGame(context, diff)),
            const SizedBox(height: 24),
            Text(
              '趣味模式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
              ),
            ),
            const SizedBox(height: 12),
            _FunModeCard(
              icon: Icons.door_back_door,
              title: '数独任意门',
              subtitle: '推门而入，每局皆新',
              color: const Color(0xFF7C4DFF),
              isDark: isDark,
              onTap: () => _startPortalGame(context),
            ),
            const SizedBox(height: 12),
            _FunModeCard(
              icon: Icons.remove_red_eye,
              title: '纠错大师',
              subtitle: '全盘已填，找出隐藏错误',
              color: const Color(0xFFFF6F00),
              isDark: isDark,
              onTap: () => _startDebugGame(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPlay;
  const _HeaderCard({required this.isDark, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF1976D2), const Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎来到数·趣',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '每日一题，锻炼大脑\n趣味变体，乐在其中',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始游戏'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyGrid extends StatelessWidget {
  final Map<Difficulty, int> progress;
  final void Function(Difficulty) onPlay;
  const _DifficultyGrid({required this.progress, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final difficulties = Difficulty.values;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: difficulties.length,
      itemBuilder: (_, i) => _DifficultyCard(
        difficulty: difficulties[i],
        level: (progress[difficulties[i]] ?? 0) + 1,
        onTap: () => onPlay(difficulties[i]),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final int level;
  final VoidCallback onTap;

  const _DifficultyCard({required this.difficulty, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = {
      Difficulty.easy: const Color(0xFF43A047),
      Difficulty.medium: const Color(0xFFF39C12),
      Difficulty.hard: const Color(0xFFE67E22),
      Difficulty.expert: const Color(0xFFE53935),
    };
    final icons = {
      Difficulty.easy: Icons.sentiment_satisfied,
      Difficulty.medium: Icons.sentiment_neutral,
      Difficulty.hard: Icons.sentiment_dissatisfied,
      Difficulty.expert: Icons.flash_on,
    };
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[difficulty], color: colors[difficulty], size: 28),
              const SizedBox(height: 8),
              Text(
                difficulty.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors[difficulty],
                ),
              ),
              Text(
                '第${level > 1000 ? 1000 : level}关',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FunModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FunModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? AppColors.darkNote : AppColors.lightNote),
            ],
          ),
        ),
      ),
    );
  }
}
