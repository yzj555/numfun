import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../../domain/model/puzzle.dart';
import '../../domain/model/game_state.dart';
import '../theme/colors.dart';

class BoardWidget extends StatelessWidget {
  final GameProvider provider;

  const BoardWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final state = provider.state;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.darkThickBorder : AppColors.lightThickBorder,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final r = index ~/ 9;
            final c = index % 9;
            final cell = state.board[r][c];
            return _CellWidget(
              cell: cell,
              isSelected: state.selectedRow == r && state.selectedCol == c,
              isSameNumber: cell.value != 0 &&
                  state.selectedRow >= 0 &&
                  state.selectedCol >= 0 &&
                  state.board[state.selectedRow][state.selectedCol].value != 0 &&
                  cell.value == state.board[state.selectedRow][state.selectedCol].value,
              isSameRow: state.selectedRow == r,
              isSameCol: state.selectedCol == c,
              isSource: provider.isConflictSource(r, c),
              isFlashing: provider.isFlashCell(r, c),
              isRightBorder: (c + 1) % 3 == 0 && c != 8,
              isBottomBorder: (r + 1) % 3 == 0 && r != 8,
              isDark: isDark,
              notes: state.notes[r][c],
              onTap: () => provider.selectCell(r, c),
            );
          },
        ),
      ),
    );
  }
}

class _CellWidget extends StatelessWidget {
  final CellData cell;
  final bool isSelected;
  final bool isSameNumber;
  final bool isSameRow;
  final bool isSameCol;
  final bool isSource;
  final bool isFlashing;
  final bool isRightBorder;
  final bool isBottomBorder;
  final bool isDark;
  final Set<int> notes;
  final VoidCallback? onTap;

  const _CellWidget({
    required this.cell,
    required this.isSelected,
    required this.isSameNumber,
    required this.isSameRow,
    required this.isSameCol,
    required this.isSource,
    required this.isFlashing,
    required this.isRightBorder,
    required this.isBottomBorder,
    required this.isDark,
    required this.notes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRowColHighlight = (isSameRow || isSameCol) && !isSelected && !isSameNumber;

    final isError = cell.state == CellState.error;
    final isSourceOn = isSource && cell.value != 0;
    final isFlashOn = isFlashing && cell.value != 0;
    final needsRedBg = isError || isFlashOn;

    Color bgColor;
    if (isSelected) {
      bgColor = isDark ? AppColors.darkSelected : AppColors.lightSelected;
    } else if (isSameNumber) {
      bgColor = isDark ? AppColors.darkSameNumber : AppColors.lightSameNumber;
    } else if (isRowColHighlight) {
      bgColor = isDark ? AppColors.darkRowCol : AppColors.lightRowCol;
    } else {
      bgColor = isDark ? AppColors.darkCell : AppColors.lightCell;
    }

    if (needsRedBg) {
      bgColor = Color.lerp(bgColor, Colors.red, 0.30)!;
    }

    Color textColor;
    FontWeight fontWeight;
    if (cell.value == 0) {
      textColor = isDark ? AppColors.darkInitial : AppColors.lightInitial;
      fontWeight = FontWeight.normal;
    } else if (isSourceOn || isError || isFlashOn) {
      textColor = isDark ? AppColors.darkError : AppColors.lightError;
      fontWeight = cell.state == CellState.initial ? FontWeight.bold : FontWeight.w500;
    } else {
      switch (cell.state) {
        case CellState.initial:
          textColor = isDark ? AppColors.darkInitial : AppColors.lightInitial;
          fontWeight = FontWeight.bold;
          break;
        case CellState.userInput:
          textColor = isDark ? AppColors.darkUserInput : AppColors.lightUserInput;
          fontWeight = FontWeight.w500;
          break;
        case CellState.error:
          textColor = isDark ? AppColors.darkError : AppColors.lightError;
          fontWeight = FontWeight.w500;
          break;
        case CellState.hint:
          textColor = isDark ? AppColors.darkHint : AppColors.lightHint;
          fontWeight = FontWeight.w500;
          break;
        default:
          textColor = isDark ? AppColors.darkInitial : AppColors.lightInitial;
          fontWeight = FontWeight.normal;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(
              color: isRightBorder
                  ? (isDark ? AppColors.darkThickBorder : AppColors.lightThickBorder)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isRightBorder ? 2.0 : 0.3,
            ),
            bottom: BorderSide(
              color: isBottomBorder
                  ? (isDark ? AppColors.darkThickBorder : AppColors.lightThickBorder)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isBottomBorder ? 2.0 : 0.3,
            ),
          ),
        ),
        child: Stack(
          children: [
            if (cell.value != 0)
              Positioned.fill(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      '${cell.value}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              )
            else if (notes.isNotEmpty)
              Positioned.fill(
                child: _NotesWidget(notes: notes),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotesWidget extends StatelessWidget {
  final Set<int> notes;
  const _NotesWidget({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        children: List.generate(9, (i) {
          final num = i + 1;
          return Center(
            child: Text(
              notes.contains(num) ? '$num' : '',
              style: const TextStyle(fontSize: 8, color: AppColors.lightNote),
            ),
          );
        }),
      ),
    );
  }
}
