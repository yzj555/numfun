import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/home/home_page.dart';
import 'presentation/level/level_select_page.dart';
import 'presentation/profile/profile_page.dart';

class NumFunApp extends StatefulWidget {
  const NumFunApp({super.key});

  @override
  State<NumFunApp> createState() => _NumFunAppState();
}

class _NumFunAppState extends State<NumFunApp> {
  ThemeMode _themeMode = ThemeMode.light;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark') ?? false;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void _toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', newMode == ThemeMode.dark);
    setState(() => _themeMode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final gp = GameProvider();
        gp.initLevelProgress();
        gp.initStats();
        gp.initNumPadLayout();
        return gp;
      },
      child: MaterialApp(
        title: '数·趣',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        home: _MainShell(
          themeMode: _themeMode,
          onToggleTheme: _toggleTheme,
          currentTab: _currentTab,
          onTabChanged: (i) => setState(() => _currentTab = i),
        ),
      ),
    );
  }
}

class _MainShell extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const _MainShell({
    required this.themeMode,
    required this.onToggleTheme,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(key: ValueKey('home')),
      const LevelSelectPage(key: ValueKey('level')),
      ProfilePage(key: const ValueKey('profile'), onToggleTheme: onToggleTheme),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: '关卡'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
