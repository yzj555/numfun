import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';

class NumberPad extends StatelessWidget {
  final GameProvider provider;

  const NumberPad({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final layout = provider.numPadLayout;

    switch (layout) {
      case 0:
        return _buildGridLayout(isDark);
      case 1:
        return _buildThreeRowLayout(isDark);
      default:
        return _buildSingleRowLayout(isDark);
    }
  }

  static const _toolDefs = <_PadButton>[
    _PadButton(Icons.edit, '笔记', _Action.toggleNote),
    _PadButton(Icons.undo, '撤销', _Action.undo),
    _PadButton(Icons.redo, '重做', _Action.redo),
    _PadButton(Icons.auto_awesome, '提示', _Action.hint),
    _PadButton(Icons.backspace, '擦除', _Action.erase),
  ];

  static const _layoutIcons = [
    Icons.vertical_split,
    Icons.grid_on,
    Icons.dehaze,
  ];

  static const _layoutNames = [
    '左右并排',
    '顺序混排',
    '经典分行',
  ];

  Widget _buildGridLayout(bool isDark) {
    const gap = SizedBox(width: 4);
    Widget numberCell(int num) {
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1.3,
          child: _NumberCell(
            number: num,
            isDark: isDark,
            onTap: () => provider.inputNumber(num),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(child: _ToolCell(def: _toolDefs[0], isDark: isDark, provider: provider)),
              gap,
              Expanded(child: _ToolCell(def: _toolDefs[1], isDark: isDark, provider: provider)),
              gap,
              numberCell(1),
              gap,
              numberCell(2),
              gap,
              numberCell(3),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(child: _ToolCell(def: _toolDefs[2], isDark: isDark, provider: provider)),
              gap,
              Expanded(child: _ToolCell(def: _toolDefs[3], isDark: isDark, provider: provider)),
              gap,
              numberCell(4),
              gap,
              numberCell(5),
              gap,
              numberCell(6),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(child: _ToolCell(def: _toolDefs[4], isDark: isDark, provider: provider)),
              gap,
              Expanded(
                child: _LayoutToggleCell(
                  isDark: isDark,
                  provider: provider,
                  currentIcon: _layoutIcons[provider.numPadLayout],
                ),
              ),
              gap,
              numberCell(7),
              gap,
              numberCell(8),
              gap,
              numberCell(9),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildThreeRowLayout(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: _toolDefs.map((def) => Expanded(
              child: _ToolCell(def: def, isDark: isDark, provider: provider),
            )).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: _LayoutToggleCell(
                  isDark: isDark,
                  provider: provider,
                  currentIcon: _layoutIcons[provider.numPadLayout],
                ),
              ),
              for (int i = 1; i <= 4; i++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: _NumberCell(
                      number: i,
                      isDark: isDark,
                      onTap: () => provider.inputNumber(i),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(5, (i) {
              final num = i + 5;
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: _NumberCell(
                    number: num,
                    isDark: isDark,
                    onTap: () => provider.inputNumber(num),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSingleRowLayout(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              for (final def in _toolDefs)
                Expanded(
                  child: _ToolCell(def: def, isDark: isDark, provider: provider),
                ),
              Expanded(
                child: _LayoutToggleCell(
                  isDark: isDark,
                  provider: provider,
                  currentIcon: _layoutIcons[provider.numPadLayout],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.count(
            crossAxisCount: 9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
            children: List.generate(9, (i) {
              final num = i + 1;
              return _NumberCell(
                number: num,
                isDark: isDark,
                onTap: () => provider.inputNumber(num),
              );
            }),
          ),
        ),
      ],
    );
  }
}

enum _Action { toggleNote, undo, redo, hint, erase }

class _PadButton {
  final IconData icon;
  final String label;
  final _Action action;
  const _PadButton(this.icon, this.label, this.action);
}

class _ToolCell extends StatelessWidget {
  final _PadButton def;
  final bool isDark;
  final GameProvider provider;

  const _ToolCell({
    required this.def,
    required this.isDark,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final active = def.action == _Action.toggleNote && provider.state.isNoteMode;
    final enabled = _isEnabled(provider);
    final color = enabled
        ? (active
            ? (isDark ? AppColors.darkAccent : AppColors.lightAccent)
            : (isDark ? AppColors.darkInitial : AppColors.lightInitial))
        : (isDark ? AppColors.darkNote : AppColors.lightNote);

    return Material(
      color: active ? (isDark ? AppColors.darkAccent : AppColors.lightAccent).withValues(alpha: 0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? () => _execute(provider) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(def.icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                def.action == _Action.hint ? '提示(${provider.state.maxHints - provider.state.hintsUsed})' : def.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkNote : AppColors.lightNote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isEnabled(GameProvider provider) {
    switch (def.action) {
      case _Action.toggleNote:
        return true;
      case _Action.undo:
        return provider.state.undoStack.isNotEmpty;
      case _Action.redo:
        return provider.state.redoStack.isNotEmpty;
      case _Action.hint:
        return provider.state.hintsUsed < provider.state.maxHints;
      case _Action.erase:
        return true;
    }
  }

  void _execute(GameProvider provider) {
    switch (def.action) {
      case _Action.toggleNote:
        provider.toggleNoteMode();
      case _Action.undo:
        provider.undo();
      case _Action.redo:
        provider.redo();
      case _Action.hint:
        provider.useHint();
      case _Action.erase:
        provider.eraseCell();
    }
  }
}

class _LayoutToggleCell extends StatelessWidget {
  final bool isDark;
  final GameProvider provider;
  final IconData currentIcon;

  const _LayoutToggleCell({
    required this.isDark,
    required this.provider,
    required this.currentIcon,
  });

  void _showLayoutSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
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
                '选择布局',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                ListTile(
                  leading: Icon(
                    NumberPad._layoutIcons[i],
                    color: i == provider.numPadLayout
                        ? (isDark ? Colors.blueAccent : Colors.blue)
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                  title: Text(
                    NumberPad._layoutNames[i],
                    style: TextStyle(
                      fontWeight: i == provider.numPadLayout ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: i == provider.numPadLayout
                      ? Icon(Icons.check, color: isDark ? Colors.blueAccent : Colors.blue, size: 20)
                      : null,
                  onTap: () {
                    provider.setNumPadLayout(i);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _showLayoutSheet(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentIcon,
                size: 20,
                color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
              ),
              const SizedBox(height: 2),
              Text(
                '布局',
                style: TextStyle(
                  fontSize: 10,
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

class _NumberCell extends StatelessWidget {
  final int number;
  final bool isDark;
  final VoidCallback onTap;

  const _NumberCell({
    required this.number,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkBoard : AppColors.lightBoard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkInitial : AppColors.lightInitial,
            ),
          ),
        ),
      ),
    );
  }
}
