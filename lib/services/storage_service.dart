import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/board.dart';
import '../models/persisted_snapshot.dart';

/// Local persistence: scores, theme, guest flag, ephemeral game snapshot (TTL).
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyGuest = 'guest_entered';
  static const _keyDarkMode = 'dark_mode';
  static const _keyScoreX = 'score_x';
  static const _keyScoreO = 'score_o';
  static const _keyScoreDraw = 'score_draw';
  static const _keyLastResult = 'last_result';
  static const _keySnapshot = 'game_snapshot';

  /// Max age for restoring an in-progress game from prefs (session-ish).
  static const snapshotTtl = Duration(minutes: 30);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  bool get guestEntered => _prefs.getBool(_keyGuest) ?? false;

  Future<void> setGuestEntered(bool value) =>
      _prefs.setBool(_keyGuest, value);

  /// Defaults to dark (black theme) on first install.
  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? true;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);

  Future<void> saveScores({required int x, required int o, required int draw}) async {
    await _prefs.setInt(_keyScoreX, x);
    await _prefs.setInt(_keyScoreO, o);
    await _prefs.setInt(_keyScoreDraw, draw);
  }

  ({int x, int o, int draw}) loadScores() {
    final x = _prefs.getInt(_keyScoreX) ?? 0;
    final o = _prefs.getInt(_keyScoreO) ?? 0;
    final draw = _prefs.getInt(_keyScoreDraw) ?? 0;
    return (x: x, o: o, draw: draw);
  }

  Future<void> saveLastResult(String line) async {
    await _prefs.setString(_keyLastResult, line);
  }

  String? takeLastResult() {
    final v = _prefs.getString(_keyLastResult);
    if (v != null) {
      _prefs.remove(_keyLastResult);
    }
    return v;
  }

  /// Clears stale snapshot on cold start (TTL) and optional full wipe of snapshot.
  Future<void> pruneEphemeralOnLaunch() async {
    final raw = _prefs.getString(_keySnapshot);
    if (raw == null) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      await _prefs.remove(_keySnapshot);
      return;
    }
    final snap = PersistedSnapshot.fromJson(decoded);
    if (snap == null) {
      await _prefs.remove(_keySnapshot);
      return;
    }
    final age = DateTime.now().millisecondsSinceEpoch - snap.savedAtMillis;
    if (age > snapshotTtl.inMilliseconds) {
      await _prefs.remove(_keySnapshot);
    }
  }

  Future<void> clearSnapshot() => _prefs.remove(_keySnapshot);

  Future<void> saveSnapshot({
    required Board board,
    required Player current,
    required GameMode mode,
  }) async {
    final symbols = board.cells
        .map((p) => p == null ? null : (p == Player.x ? 'X' : 'O'))
        .toList();
    final snap = PersistedSnapshot(
      boardSymbols: symbols,
      currentPlayerSymbol: current == Player.x ? 'X' : 'O',
      modeIndex: mode.index,
      savedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _prefs.setString(_keySnapshot, jsonEncode(snap.toJson()));
  }

  /// Returns null if missing, invalid, or expired.
  PersistedSnapshot? readSnapshotIfFresh() {
    final raw = _prefs.getString(_keySnapshot);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final snap = PersistedSnapshot.fromJson(decoded);
    if (snap == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - snap.savedAtMillis;
    if (age > snapshotTtl.inMilliseconds) return null;
    return snap;
  }
}
