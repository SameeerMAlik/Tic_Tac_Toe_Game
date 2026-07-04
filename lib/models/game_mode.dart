enum GameMode {
  playerVsPlayer,
  playerVsAiRandom,
  playerVsAiSmart,
}

extension GameModeLabel on GameMode {
  String get title => switch (this) {
        GameMode.playerVsPlayer => 'Player vs Player',
        GameMode.playerVsAiRandom => 'vs AI (random)',
        GameMode.playerVsAiSmart => 'vs AI (smart)',
      };

  String get subtitle => switch (this) {
        GameMode.playerVsPlayer => 'Two players take turns',
        GameMode.playerVsAiRandom => 'AI picks a random empty cell',
        GameMode.playerVsAiSmart => 'AI tries to win and block',
      };

  bool get isAiMode =>
      this == GameMode.playerVsAiRandom || this == GameMode.playerVsAiSmart;
}
