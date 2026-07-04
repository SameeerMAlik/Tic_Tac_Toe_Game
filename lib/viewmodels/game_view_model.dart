import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/board.dart';
import '../models/game_mode.dart';
import '../models/game_outcome.dart';
import '../models/player.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel({
    required StorageService storage,
    required GameMode mode,
    AiService? aiService,
  })  : _storage = storage,
        _mode = mode,
        _ai = aiService ?? AiService() {
    _loadScores();
    _tryRestoreSnapshot();
  }

  final StorageService _storage;
  final AiService _ai;

  final GameMode _mode;
  Board _board = Board.empty();
  Player _current = Player.x;
  GameOutcome _outcome = GameOutcome.ongoing;
  bool _aiThinking = false;
  int _scoreX = 0;
  int _scoreO = 0;
  int _scoreDraw = 0;

  /// Human is always X in AI modes; O is the AI.
  static const Player humanPlayer = Player.x;
  static const Player aiPlayer = Player.o;

  GameMode get mode => _mode;
  Board get board => _board;
  Player get currentPlayer => _current;
  GameOutcome get outcome => _outcome;
  bool get aiThinking => _aiThinking;
  int get scoreX => _scoreX;
  int get scoreO => _scoreO;
  int get scoreDraw => _scoreDraw;

  bool get gameOver => _outcome != GameOutcome.ongoing;

  String get statusLine {
    if (_outcome != GameOutcome.ongoing) {
      return _outcome.message;
    }
    if (_mode.isAiMode && _current == aiPlayer && _aiThinking) {
      return 'AI is thinking…';
    }
    final label = _mode.isAiMode && _current == aiPlayer
        ? 'AI (${aiPlayer.symbol})'
        : _current.symbol;
    return 'Turn: $label';
  }

  void _loadScores() {
    final s = _storage.loadScores();
    _scoreX = s.x;
    _scoreO = s.o;
    _scoreDraw = s.draw;
  }

  void _tryRestoreSnapshot() {
    final snap = _storage.readSnapshotIfFresh();
    if (snap == null) return;
    if (snap.modeIndex < 0 ||
        snap.modeIndex >= GameMode.values.length) {
      return;
    }
    final restoredMode = GameMode.values[snap.modeIndex];
    if (restoredMode != _mode) return;

    Player? parseCell(String? s) {
      if (s == null || s.isEmpty) return null;
      switch (s.toUpperCase()) {
        case 'X':
          return Player.x;
        case 'O':
          return Player.o;
        default:
          return null;
      }
    }

    final cells = snap.boardSymbols.map(parseCell).toList();
    if (cells.length != 9) return;

    final currentSym = snap.currentPlayerSymbol;
    final current = currentSym == 'X'
        ? Player.x
        : currentSym == 'O'
            ? Player.o
            : null;
    if (current == null) return;

    try {
      var b = Board.empty();
      for (var i = 0; i < 9; i++) {
        final p = cells[i];
        if (p != null) {
          b = b.place(i, p);
        }
      }
      final oc = b.outcome;
      if (oc != GameOutcome.ongoing) return;

      _board = b;
      _current = current;
      _outcome = GameOutcome.ongoing;

      if (_mode.isAiMode && _current == aiPlayer) {
        unawaited(_playAiMove());
      }
      notifyListeners();
    } catch (_) {
      // Ignore corrupt snapshot
    }
  }

  Future<void> _persistSnapshot() async {
    if (_outcome != GameOutcome.ongoing) {
      await _storage.clearSnapshot();
      return;
    }
    await _storage.saveSnapshot(
      board: _board,
      current: _current,
      mode: _mode,
    );
  }

  Future<void> _persistScores() async {
    await _storage.saveScores(x: _scoreX, o: _scoreO, draw: _scoreDraw);
  }

  Future<void> _feedbackTap() async {
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.lightImpact();
  }

  Future<void> onCellTapped(int index) async {
    if (gameOver || _aiThinking) return;
    if (_mode.isAiMode && _current == aiPlayer) return;
    if (_board[index] != null) return;

    await _feedbackTap();

    _board = _board.place(index, _current);
    _outcome = _board.outcome;

    if (_outcome != GameOutcome.ongoing) {
      await _applyOutcome();
      notifyListeners();
      return;
    }

    _current = _current.opponent;
    await _persistSnapshot();
    notifyListeners();

    if (_mode.isAiMode && _current == aiPlayer) {
      await _playAiMove();
    }
  }

  Future<void> _playAiMove() async {
    if (gameOver || !_mode.isAiMode) return;

    _aiThinking = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 280));

    final move = _mode == GameMode.playerVsAiRandom
        ? _ai.randomMove(_board)
        : _ai.bestMove(_board, ai: aiPlayer);

    await _feedbackTap();

    _board = _board.place(move, aiPlayer);
    _outcome = _board.outcome;
    _aiThinking = false;

    if (_outcome != GameOutcome.ongoing) {
      await _applyOutcome();
    } else {
      _current = humanPlayer;
      await _persistSnapshot();
    }
    notifyListeners();
  }

  Future<void> _applyOutcome() async {
    switch (_outcome) {
      case GameOutcome.xWins:
        _scoreX++;
        await _storage.saveLastResult('X wins!');
      case GameOutcome.oWins:
        _scoreO++;
        await _storage.saveLastResult('O wins!');
      case GameOutcome.draw:
        _scoreDraw++;
        await _storage.saveLastResult('Draw!');
      case GameOutcome.ongoing:
        break;
    }
    await _persistScores();
    await _storage.clearSnapshot();
  }

  Future<void> restartGame() async {
    await _feedbackTap();
    _board = Board.empty();
    _current = Player.x;
    _outcome = GameOutcome.ongoing;
    _aiThinking = false;
    await _storage.clearSnapshot();
    notifyListeners();

    if (_mode.isAiMode && _current == aiPlayer) {
      await _playAiMove();
    }
  }

  Future<void> resetScores() async {
    _scoreX = 0;
    _scoreO = 0;
    _scoreDraw = 0;
    await _persistScores();
    notifyListeners();
  }
}
