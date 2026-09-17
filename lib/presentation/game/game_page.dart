import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/model/puzzle.dart';
import '../theme/colors.dart';
import 'board_widget.dart';
import 'number_pad.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  Timer? _timer;
  bool _shownComplete = false;
  bool _checkedSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSavedGame());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    context.read<GameProvider>().saveCurrentGame();
    super.dispose();
  }

  Future<void> _checkSavedGame() async {
    if (_checkedSaved) return;
    _checkedSaved = true;
    final provider = context.read<GameProvider>();
    final state = provider.state;
    final saved = await provider.findSavedGame(
      state.puzzle.mode.name,
      state.puzzle.difficulty.name,
    );
    if (saved == null || !mounted) return;

    // Skip dialog if no user action was taken
    final savedPuzzle = Puzzle.fromJson(saved['puzzle'] as Map<String, dynamic>);
    final savedBoard = (saved['board'] as List).map((row) =>
      (row as List).map((c) => (c as Map<String, dynamic>)['v'] as int? ?? 0).toList()
    ).toList();
    bool hasAction = false;
    for (int r = 0; r < 9 && !hasAction; r++) {
      for (int c = 0; c < 9 && !hasAction; c++) {
        if (savedBoard[r][c] != savedPuzzle.initialBoard[r][c]) {
          hasAction = true;
        }
      }
    }
    if (!hasAction) {
      await provider.deleteSavedGame();
      return;
    }

    final diffLabel = savedPuzzle.difficulty.label;
    final modeLabel = savedPuzzle.mode.label;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('发现存档'),
        content: Text('检测到您有未完成的$diffLabel$modeLabel，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('新的一局'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('继续'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      provider.restoreGame(saved);
    } else if (result == false && mounted) {
      await provider.deleteSavedGame();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<GameProvider>().saveCurrentGame();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        context.read<GameProvider>().tick();
      }
    });
  }

  void _checkCompletion(GameProvider provider) {
    if (provider.state.isComplete && !_shownComplete) {
      _shownComplete = true;
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCompleteDialog(provider);
      });
    }
  }

  void _showCompleteDialog(GameProvider provider) {
    final state = provider.state;
    final level = provider.currentLevel;
    final isLevelMode = level > 0;
    provider.deleteSavedGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('恭喜完成！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLevelMode ? '${state.puzzle.difficulty.label} 第$level关' : '🎉 ${state.puzzle.mode.label}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultRow(label: '用时', value: _formatTime(state.elapsedSeconds)),
            _ResultRow(label: '得分', value: '${state.score}'),
            _ResultRow(label: '提示使用', value: '${state.hintsUsed}/${state.maxHints}'),
            _ResultRow(label: '难度', value: state.puzzle.difficulty.label),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('返回'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('复盘'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _shownComplete = false;
              final diff = state.puzzle.difficulty;
              final mode = state.puzzle.mode;
              if (isLevelMode) {
                final nextLevel = level < 1000 ? level + 1 : level;
                provider.newGame(diff, mode, level: nextLevel);
                provider.setLevel(nextLevel);
              } else {
                provider.newGame(diff, mode);
              }
              _startTimer();
            },
            child: Text(isLevelMode && level < 1000 ? '下一关' : '再来一局'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _checkCompletion(provider);

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _timer?.cancel();
              provider.saveCurrentGame();
              Navigator.of(context).pop();
            },
          ),
        title: Text(
          provider.currentLevel > 0
              ? '${state.puzzle.difficulty.label} 第${provider.currentLevel}关'
              : state.puzzle.mode.label,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          _GameInfo(
            icon: Icons.timer_outlined,
            value: _formatTime(state.elapsedSeconds),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _GameInfo(
            icon: Icons.stars_outlined,
            value: '${state.score}',
            isDark: isDark,
          ),
          const SizedBox(width: 4),
          if (state.isCompleted) ...[
            IconButton(
              icon: Icon(provider.currentLevel > 0 ? Icons.skip_next : Icons.replay),
              tooltip: provider.currentLevel > 0 ? '下一关' : '再来一局',
              onPressed: () {
                final diff = state.puzzle.difficulty;
                final mode = state.puzzle.mode;
                if (provider.currentLevel > 0) {
                  final next = provider.currentLevel < 1000 ? provider.currentLevel + 1 : provider.currentLevel;
                  provider.newGame(diff, mode, level: next);
                  provider.setLevel(next);
                } else {
                  provider.newGame(diff, mode);
                }
                _shownComplete = false;
                _startTimer();
              },
            ),
          ] else ...[
            Builder(builder: (context) {
              final debug = state.puzzle.mode == GameMode.debug;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    tooltip: debug ? '检查(${state.remainingChecks})' : '检查',
                    onPressed: () => provider.checkBoard(),
                  ),
                  if (debug)
                    Text(
                      '${state.remainingChecks}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                      ),
                    ),
                ],
              );
            }),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _ProgressBar(progress: state.progress, isDark: isDark),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: BoardWidget(provider: provider),
                ),
              ),
            ),
            const SizedBox(height: 8),
            NumberPad(provider: provider),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _GameInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;

  const _GameInfo({
    required this.icon,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.darkAccent : AppColors.lightAccent),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _ProgressBar({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: isDark ? AppColors.darkBoard : AppColors.lightBoard,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
        ),
      ),
    );
  }
}
