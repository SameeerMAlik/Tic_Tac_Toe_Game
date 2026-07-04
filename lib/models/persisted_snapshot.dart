/// Serializable snapshot for SharedPreferences (ephemeral / TTL on read).
class PersistedSnapshot {
  const PersistedSnapshot({
    required this.boardSymbols,
    required this.currentPlayerSymbol,
    required this.modeIndex,
    required this.savedAtMillis,
  });

  final List<String?> boardSymbols;
  final String currentPlayerSymbol;
  final int modeIndex;
  final int savedAtMillis;

  Map<String, dynamic> toJson() => {
        'board': boardSymbols,
        'current': currentPlayerSymbol,
        'mode': modeIndex,
        'at': savedAtMillis,
      };

  static PersistedSnapshot? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final boardRaw = json['board'];
    final current = json['current'];
    final mode = json['mode'];
    final at = json['at'];
    if (boardRaw is! List ||
        current is! String ||
        mode is! int ||
        at is! int) {
      return null;
    }
    final symbols = boardRaw.map<String?>((e) => e as String?).toList();
    if (symbols.length != 9) return null;
    return PersistedSnapshot(
      boardSymbols: symbols,
      currentPlayerSymbol: current,
      modeIndex: mode,
      savedAtMillis: at,
    );
  }
}
