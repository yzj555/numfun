import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../game/game_page.dart';
import '../providers/game_provider.dart';
import '../../domain/model/puzzle.dart';

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key});

  void _startLevel(BuildContext context, Difficulty diff, int level) {
    final provider = context.read<GameProvider>();
    provider.newGame(diff, GameMode.classic, level: level);
    provider.setLevel(level);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = context.watch<GameProvider>().levelProgress;

    return DefaultTabController(
      length: Difficulty.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('关卡选择'),
          bottom: TabBar(
            isScrollable: false,
            tabs: Difficulty.values.map((d) => Tab(text: d.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: Difficulty.values.map((diff) =>
            _LevelGrid(
              difficulty: diff,
              completed: progress[diff] ?? 0,
              isDark: isDark,
              onPlay: (level) => _startLevel(context, diff, level),
            )
          ).toList(),
        ),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final Difficulty difficulty;
  final int completed;
  final bool isDark;
  final void Function(int) onPlay;

  const _LevelGrid({
    required this.difficulty,
    required this.completed,
    required this.isDark,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final levels = List.generate(1000, (i) => i + 1);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: levels.length,
      itemBuilder: (_, i) {
        final level = levels[i];
        final isCompleted = level <= completed;
        final isLocked = level > completed + 1;
        return _LevelCell(
          number: level,
          completed: isCompleted,
          locked: isLocked,
          isDark: isDark,
          onTap: isLocked ? null : () => onPlay(level),
        );
      },
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int number;
  final bool completed;
  final bool locked;
  final bool isDark;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.number,
    required this.completed,
    required this.locked,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: locked
          ? (isDark ? AppColors.darkBoard : AppColors.lightBoard)
          : (completed
              ? (isDark ? AppColors.darkCorrect : AppColors.lightCorrect).withValues(alpha: 0.2)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              locked ? Icons.lock_outline : (completed ? Icons.check_circle_outline : Icons.circle_outlined),
              size: 24,
              color: locked
                  ? (isDark ? AppColors.darkNote : AppColors.lightNote)
                  : (completed
                      ? (isDark ? AppColors.darkCorrect : AppColors.lightCorrect)
                      : (isDark ? AppColors.darkAccent : AppColors.lightAccent)),
            ),
            const SizedBox(height: 4),
            Text(
              '$number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: locked
                    ? (isDark ? AppColors.darkNote : AppColors.lightNote)
                    : (isDark ? AppColors.darkInitial : AppColors.lightInitial),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
