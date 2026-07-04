enum Player {
  x,
  o,
}

extension PlayerDisplay on Player {
  String get symbol => this == Player.x ? 'X' : 'O';

  Player get opponent => this == Player.x ? Player.o : Player.x;
}
