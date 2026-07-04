import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_mode.dart';
import '../models/game_outcome.dart';
import '../models/player.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/game_board_grid.dart';
import '../widgets/styled_top_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: StyledTopBar.game(
        context: context,
        modeTitle: mode.title,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: [
              cs.secondary.withValues(alpha: 0.06),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.biggest.shortestSide * 0.82;
              final boardSize = side.clamp(260.0, 420.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Container(
                      key: ValueKey(vm.statusLine),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: vm.gameOver
                            ? cs.secondaryContainer.withValues(alpha: 0.65)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            vm.gameOver
                                ? Icons.flag_rounded
                                : Icons.auto_awesome_motion,
                            color: cs.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vm.statusLine,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GameBoardGrid(
                      boardSize: boardSize,
                      cells: vm.board.cells,
                      enabled: !vm.gameOver && !vm.aiThinking,
                      highlightWinner: vm.gameOver &&
                          (vm.outcome == GameOutcome.xWins ||
                              vm.outcome == GameOutcome.oWins),
                      outcome: vm.outcome,
                      onTap: vm.onCellTapped,
                    ),
                  ),
                  if (mode.isAiMode) ...[
                    const SizedBox(height: 14),
                    Text(
                      'You are ${GameViewModel.humanPlayer.symbol}. '
                      'AI plays ${GameViewModel.aiPlayer.symbol}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: vm.aiThinking ? null : () => vm.restartGame(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Restart'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
