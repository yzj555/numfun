import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/model/achievement.dart';
import '../theme/colors.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const ProfilePage({super.key, this.onToggleTheme});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final stats = provider.stats;
    final achievements = provider.unlockedAchievements;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightAccent,
              child: const Text(
                '趣',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '数·趣玩家',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
              ),
            ),
            const SizedBox(height: 24),
            _StatsRow(
              totalGames: stats.totalGames,
              completedGames: stats.completedGames,
              totalScore: stats.totalScore,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _DetailStats(stats: stats, isDark: isDark),
            const SizedBox(height: 24),
            _AchievementSection(achievements: achievements, isDark: isDark),
            _MenuItem(
              icon: Icons.dark_mode_outlined,
              title: '黑暗模式',
              trailing: Switch(
                value: isDark,
                onChanged: (_) => widget.onToggleTheme?.call(),
              ),
              isDark: isDark,
              onTap: () => widget.onToggleTheme?.call(),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: '关于',
              subtitle: 'v1.0.0',
              isDark: isDark,
              onTap: () => showAboutDialog(
                context: context,
                applicationName: '数·趣',
                applicationVersion: 'v1.0.0',
                applicationLegalese: '趣味数独游戏',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalGames;
  final int completedGames;
  final int totalScore;
  final bool isDark;

  const _StatsRow({
    required this.totalGames,
    required this.completedGames,
    required this.totalScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: '总对局',
          value: '$totalGames',
          icon: Icons.grid_on,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: '已完成',
          value: '$completedGames',
          icon: Icons.check_circle_outline,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: '总得分',
          value: '$totalScore',
          icon: Icons.stars_outlined,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon,
                size: 24,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkNote : AppColors.lightNote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStats extends StatelessWidget {
  final dynamic stats;
  final bool isDark;

  const _DetailStats({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final diffLabels = {
      'easy': '简单', 'medium': '普通', 'hard': '困难', 'expert': '专家',
    };
    final perDiff = stats.perDifficulty as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('详细统计',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
              ),
            ),
            const SizedBox(height: 12),
            _StatRow(label: '提示总数', value: '${stats.totalHints}', isDark: isDark),
            _StatRow(label: '累计时间', value: _formatTime(stats.totalTimeSec), isDark: isDark),
            _StatRow(label: '任意门对局', value: '${stats.totalPortalGames}', isDark: isDark),
            _StatRow(label: '纠错对局', value: '${stats.totalDebugGames}', isDark: isDark),
            const Divider(height: 20),
            for (final diff in ['easy', 'medium', 'hard', 'expert'])
              ..._buildDiffStats(diffLabels[diff] ?? diff, perDiff[diff]),
          ],
        ),
      ),
    );
  }

  String _formatTime(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    if (h > 0) return '${h}时${m}分';
    return '${m}分${sec % 60}秒';
  }

  List<Widget> _buildDiffStats(String label, dynamic d) {
    if (d == null) return [];
    return [
      Text(label, style: TextStyle(fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkInitial : AppColors.lightInitial)),
      const SizedBox(height: 4),
      _StatRow(label: '  对局', value: '${d.gamesPlayed}', isDark: isDark),
      _StatRow(label: '  完成', value: '${d.gamesCompleted}', isDark: isDark),
      _StatRow(label: '  最高分', value: '${d.bestScore}', isDark: isDark),
      _StatRow(label: '  最快', value: '${d.bestTimeSec}秒', isDark: isDark),
      const SizedBox(height: 8),
    ];
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkNote : AppColors.lightNote,
          )),
          Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
          )),
        ],
      ),
    );
  }
}

class _AchievementSection extends StatefulWidget {
  final List<Achievement> achievements;
  final bool isDark;

  const _AchievementSection({required this.achievements, required this.isDark});

  @override
  State<_AchievementSection> createState() => _AchievementSectionState();
}

class _AchievementSectionState extends State<_AchievementSection> {
  void _showAllAchievements(BuildContext context) {
    final isDark = widget.isDark;
    final achievements = widget.achievements;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                '全部成就 (${achievements.length}/${Achievement.all.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                mainAxisSpacing: 2,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: Achievement.all.map((a) {
                    final unlocked = achievements.any((ua) => ua.id == a.id);
                    return _AchievementBadge(
                      achievement: a,
                      unlocked: unlocked,
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final achievements = widget.achievements;
    final showAll = Achievement.all;
    final preview = showAll.length > 8 ? showAll.sublist(0, 8) : showAll;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('成就徽章',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
                  ),
                ),
                InkWell(
                  onTap: () => _showAllAchievements(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '更多',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16,
                          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 2,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: preview.map((a) {
                final unlocked = achievements.any((ua) => ua.id == a.id);
                return _AchievementBadge(
                  achievement: a,
                  unlocked: unlocked,
                  isDark: isDark,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final bool isDark;

  const _AchievementBadge({
    required this.achievement,
    required this.unlocked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    return Tooltip(
      message: a.description,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      verticalOffset: 60,
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: const _BubbleWithArrow(),
      ),
      textStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.grey.shade200 : Colors.white,
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      constraints: const BoxConstraints(maxWidth: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: unlocked
                  ? a.color.withValues(alpha: 0.2)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              border: unlocked
                  ? Border.all(color: a.color, width: 1.5)
                  : null,
            ),
            child: Icon(
              unlocked ? a.icon : Icons.lock_outline,
              color: unlocked ? a.color : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: unlocked
                  ? (isDark ? AppColors.darkInitial : AppColors.lightInitial)
                  : (isDark ? AppColors.darkNote : AppColors.lightNote),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon,
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 12))
            : null,
        trailing: trailing ?? Icon(Icons.chevron_right,
          color: isDark ? AppColors.darkNote : AppColors.lightNote,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BubbleWithArrow extends ShapeBorder {
  const _BubbleWithArrow();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.bottom - 6),
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
      );
    final cx = rect.left + rect.width / 2;
    path.moveTo(cx - 6, rect.bottom - 6);
    path.lineTo(cx, rect.bottom);
    path.lineTo(cx + 6, rect.bottom - 6);
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
