import 'package:flutter/material.dart';

import '../models/game_outcome.dart';
import '../models/player.dart';

class GameBoardGrid extends StatelessWidget {
  const GameBoardGrid({
    super.key,
    required this.boardSize,
    required this.cells,
    required this.enabled,
    required this.highlightWinner,
    required this.outcome,
    required this.onTap,
  });

  final double boardSize;
  final List<Player?> cells;
  final bool enabled;
  final bool highlightWinner;
  final GameOutcome outcome;
  final Future<void> Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gap = boardSize * 0.03;
    final cell = (boardSize - gap * 2) / 3;

    List<int>? winningLine;
    if (highlightWinner &&
        (outcome == GameOutcome.xWins || outcome == GameOutcome.oWins)) {
      for (final line in BoardWinLines.lines) {
        final a = cells[line[0]];
        final b = cells[line[1]];
        final c = cells[line[2]];
        if (a != null && a == b && b == c) {
          winningLine = line;
          break;
        }
      }
    }

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? cs.primary.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isDark ? 28 : 18,
              spreadRadius: isDark ? 1 : 0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(gap),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final row = index ~/ 3;
              final col = index % 3;
              final showRight = col < 2;
              final showBottom = row < 2;

              final isWinCell =
                  winningLine != null && winningLine.contains(index);

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: showRight
                        ? BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.45),
                          )
                        : BorderSide.none,
                    bottom: showBottom
                        ? BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.45),
                          )
                        : BorderSide.none,
                  ),
                ),
                child: _CellButton(
                  player: cells[index],
                  size: cell - gap * 0.4,
                  enabled: enabled && cells[index] == null,
                  emphasize: isWinCell,
                  onTap: () => onTap(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Duplicate of [Board.winLines] for UI layer without importing board validity.
abstract final class BoardWinLines {
  static const List<List<int>> lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
}

class _CellButton extends StatefulWidget {
  const _CellButton({
    required this.player,
    required this.size,
    required this.enabled,
    required this.emphasize,
    required this.onTap,
  });

  final Player? player;
  final double size;
  final bool enabled;
  final bool emphasize;
  final Future<void> Function() onTap;

  @override
  State<_CellButton> createState() => _CellButtonState();
}

class _CellButtonState extends State<_CellButton>
    with SingleTickerProviderStateMixin {
  double _pressed = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mark = widget.player;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.enabled
            ? () async {
                setState(() => _pressed = 1);
                await widget.onTap();
                if (mounted) setState(() => _pressed = 0);
              }
            : null,
        borderRadius: BorderRadius.circular(18),
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: cs.primary.withValues(alpha: 0.06),
        child: Center(
          child: AnimatedScale(
            scale: 1 - (_pressed * 0.06),
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(widget.size * 0.12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: widget.emphasize
                    ? cs.primaryContainer.withValues(alpha: 0.55)
                    : Colors.transparent,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: mark == null
                    ? SizedBox(
                        key: const ValueKey('empty'),
                        width: widget.size * 0.5,
                        height: widget.size * 0.5,
                      )
                    : Text(
                        mark.symbol,
                        key: ValueKey(mark),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              fontSize: widget.size * 0.42,
                              color: mark == Player.x ? cs.primary : cs.secondary,
                            ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
