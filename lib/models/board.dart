import 'player.dart';
import 'game_outcome.dart';

/// Immutable 3×3 board: indices 0–8 row-major.
class Board {
  Board._(List<Player?> cells)
      : _cells = List<Player?>.unmodifiable(cells);

  factory Board.empty() => Board._(List<Player?>.filled(9, null));

  final List<Player?> _cells;

  List<Player?> get cells => _cells;

  static const List<List<int>> winLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  Player? operator [](int index) => _cells[index];

  bool get isFull => _cells.every((c) => c != null);

  List<int> get emptyIndices {
    final list = <int>[];
    for (var i = 0; i < 9; i++) {
      if (_cells[i] == null) list.add(i);
    }
    return list;
  }

  GameOutcome get outcome {
    if (winningLine != null) {
      final p = _cells[winningLine!.first];
      return p == Player.x ? GameOutcome.xWins : GameOutcome.oWins;
    }
    if (isFull) return GameOutcome.draw;
    return GameOutcome.ongoing;
  }

  /// Indices of the winning line when [outcome] is a win; otherwise null.
  List<int>? get winningLine {
    for (final line in winLines) {
      final a = _cells[line[0]];
      final b = _cells[line[1]];
      final c = _cells[line[2]];
      if (a != null && a == b && b == c) {
        return line;
      }
    }
    return null;
  }

  Board place(int index, Player player) {
    if (index < 0 || index > 8) {
      throw RangeError.index(index, this, 'index', null, 8);
    }
    if (_cells[index] != null) {
      throw StateError('Cell $index is already occupied.');
    }
    final next = List<Player?>.from(_cells);
    next[index] = player;
    return Board._(next);
  }
}
