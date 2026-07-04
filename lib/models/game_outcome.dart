enum GameOutcome {
  ongoing,
  draw,
  xWins,
  oWins,
}

extension GameOutcomeMessage on GameOutcome {
  String get message {
    switch (this) {
      case GameOutcome.ongoing:
        return '';
      case GameOutcome.draw:
        return 'Draw!';
      case GameOutcome.xWins:
        return 'X wins!';
      case GameOutcome.oWins:
        return 'O wins!';
    }
  }
}
