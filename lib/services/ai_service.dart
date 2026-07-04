import 'dart:math';

import '../models/board.dart';
import '../models/game_outcome.dart';
import '../models/player.dart';

/// AI moves: random empty cell or minimax-style optimal play for 3×3.
class AiService {
  AiService([Random? random]) : _random = random ?? Random();

  final Random _random;

  int randomMove(Board board) {
    final empties = board.emptyIndices;
    if (empties.isEmpty) throw StateError('No moves left');
    return empties[_random.nextInt(empties.length)];
  }

  /// Unbeatable minimax for classic tic-tac-toe when [ai] plays optimally.
  int bestMove(Board board, {required Player ai}) {
    final empties = board.emptyIndices;
    if (empties.isEmpty) throw StateError('No moves left');

    var bestScore = -1000;
    var bestIndex = empties.first;

    for (final i in empties) {
      final next = board.place(i, ai);
      final score = _minimax(
        next,
        maximizing: false,
        ai: ai,
        human: ai.opponent,
      );
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  int _minimax(
    Board board, {
    required bool maximizing,
    required Player ai,
    required Player human,
  }) {
    final outcome = board.outcome;
    switch (outcome) {
      case GameOutcome.xWins:
        return ai == Player.x ? 10 : -10;
      case GameOutcome.oWins:
        return ai == Player.o ? 10 : -10;
      case GameOutcome.draw:
        return 0;
      case GameOutcome.ongoing:
        break;
    }

    if (maximizing) {
      var best = -1000;
      for (final i in board.emptyIndices) {
        final next = board.place(i, ai);
        final score = _minimax(next, maximizing: false, ai: ai, human: human);
        if (score > best) best = score;
      }
      return best;
    } else {
      var best = 1000;
      for (final i in board.emptyIndices) {
        final next = board.place(i, human);
        final score = _minimax(next, maximizing: true, ai: ai, human: human);
        if (score < best) best = score;
      }
      return best;
    }
  }
}
