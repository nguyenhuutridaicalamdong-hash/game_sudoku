import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/game_record.dart';
import '../models/user_stats.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserStats _stats = UserStats();
  List<GameRecord> _history = [];
  bool _isLoaded = false;

  UserStats get stats => _stats;
  List<GameRecord> get history => _history;
  bool get isLoaded => _isLoaded;

  UserProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _stats = await StorageService.loadUserStats();
    _history = await StorageService.loadGameHistory();
    _syncAudio();
    _isLoaded = true;
    notifyListeners();
  }

  void _syncAudio() {
    AudioService.soundEnabled = _stats.soundEnabled;
    AudioService.hapticsEnabled = _stats.hapticsEnabled;
  }

  void setPlayerName(String name) {
    if (name.trim().isEmpty) return;
    _stats.playerName = name.trim();
    _save();
  }

  void toggleSound() {
    _stats.soundEnabled = !_stats.soundEnabled;
    _syncAudio();
    _save();
  }

  void toggleHaptics() {
    _stats.hapticsEnabled = !_stats.hapticsEnabled;
    _syncAudio();
    _save();
  }

  void toggleAutoRemoveNotes() {
    _stats.autoRemoveNotes = !_stats.autoRemoveNotes;
    _save();
  }

  void toggleHighlightPeers() {
    _stats.highlightPeers = !_stats.highlightPeers;
    _save();
  }

  void toggleHighlightMatchingNumbers() {
    _stats.highlightMatchingNumbers = !_stats.highlightMatchingNumbers;
    _save();
  }

  void recordGameResult({
    required Difficulty difficulty,
    required int timeSeconds,
    required int mistakes,
    required bool isVictory,
  }) {
    final expEarned = isVictory ? (mistakes == 0 ? 150 : 100) : 20;
    final baseScore = difficulty == Difficulty.expert
        ? 1200
        : difficulty == Difficulty.hard
            ? 900
            : difficulty == Difficulty.medium
                ? 650
                : 450;
    final timeBonus = (600 - timeSeconds).clamp(0, 600);
    final mistakePenalty = mistakes * 80;
    final totalScore = isVictory ? (baseScore + timeBonus - mistakePenalty).clamp(100, 3000) : 50;

    if (isVictory) {
      _stats.puzzlesCompleted += 1;
      if (mistakes == 0) {
        _stats.zeroMistakeGames += 1;
      }
      _stats.totalExp += expEarned;

      final prevBest = _stats.bestTimes[difficulty];
      if (prevBest == null || timeSeconds < prevBest) {
        _stats.bestTimes[difficulty] = timeSeconds;
      }
    }

    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      mistakes: mistakes,
      score: totalScore,
      isCompleted: isVictory,
    );

    _history.insert(0, record);
    if (_history.length > 50) {
      _history = _history.sublist(0, 50);
    }

    _save();
    StorageService.saveGameHistory(_history);
  }

  void resetAllData() {
    _stats = UserStats();
    _history.clear();
    _syncAudio();
    _save();
    StorageService.saveGameHistory(_history);
    StorageService.saveCurrentGame(null);
  }

  void _save() {
    StorageService.saveUserStats(_stats);
    notifyListeners();
  }
}
