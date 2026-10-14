import 'dart:async';
import 'package:flutter/material.dart';
import '../models/board_state.dart';
import '../models/difficulty.dart';
import '../models/sudoku_cell.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/sudoku_generator.dart';
import 'user_provider.dart';

class GameProvider extends ChangeNotifier {
  BoardState? _gameState;
  BoardState? _savedGame;
  bool _inGame = false;
  bool _showVictory = false;
  Timer? _timer;

  // Victory statistics
  int _victoryTime = 0;
  int _victoryMistakes = 0;
  Difficulty _victoryDifficulty = Difficulty.medium;
  bool _isNewBestTime = false;

  BoardState? get gameState => _gameState;
  BoardState? get savedGame => _savedGame;
  bool get inGame => _inGame;
  bool get showVictory => _showVictory;

  int get victoryTime => _victoryTime;
  int get victoryMistakes => _victoryMistakes;
  Difficulty get victoryDifficulty => _victoryDifficulty;
  bool get isNewBestTime => _isNewBestTime;

  GameProvider() {
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() async {
    _savedGame = await StorageService.loadSavedGame();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState != null && !_gameState!.isPaused && !_gameState!.isCompleted) {
        _gameState!.timeSeconds += 1;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void startGame(Difficulty difficulty) {
    _stopTimer();
    final cells = SudokuGenerator.generatePuzzle(difficulty);

    _gameState = BoardState(
      cells: cells,
      difficulty: difficulty,
      timeSeconds: 0,
      mistakes: 0,
      maxMistakes: 3,
      hintsRemaining: 3,
      isCompleted: false,
      isPaused: false,
      notesMode: false,
      selectedCellIndex: cells.indexWhere((c) => !c.isGiven),
      history: [],
    );

    _inGame = true;
    _showVictory = false;
    _savedGame = _gameState;
    StorageService.saveCurrentGame(_gameState);

    _startTimer();
    notifyListeners();
  }

  void resumeGame() {
    if (_savedGame != null) {
      _gameState = _savedGame;
      _inGame = true;
      _showVictory = false;
      _startTimer();
      notifyListeners();
    } else {
      startGame(Difficulty.medium);
    }
  }

  void selectCell(int index) {
    if (_gameState == null) return;
    AudioService.playTap();
    _gameState!.selectedCellIndex = index;
    notifyListeners();
  }

  void _pushHistory() {
    if (_gameState == null) return;
    final snapshot = HistorySnapshot(
      cells: _gameState!.cells.map((c) => c.copyWith()).toList(),
      mistakes: _gameState!.mistakes,
    );
    _gameState!.history.add(snapshot);
    if (_gameState!.history.length > 25) {
      _gameState!.history.removeAt(0);
    }
  }

  void inputDigit(int digit, UserProvider userProvider) {
    if (_gameState == null || _gameState!.selectedCellIndex == null) return;
    final idx = _gameState!.selectedCellIndex!;
    final cell = _gameState!.cells[idx];
    if (cell.isGiven) return;

    if (_gameState!.notesMode) {
      // Toggle note mode
      AudioService.playNoteToggle();
      _pushHistory();
      if (cell.notes.contains(digit)) {
        cell.notes.remove(digit);
      } else {
        cell.notes.add(digit);
      }
      _saveState();
      notifyListeners();
      return;
    }

    // Normal placement mode
    if (cell.value == digit) return;

    _pushHistory();
    final isCorrect = (digit == cell.solution);

    if (!isCorrect) {
      // Wrong digit!
      AudioService.playMistake();
      cell.value = digit;
      cell.isError = true;
      _gameState!.mistakes += 1;

      if (_gameState!.mistakes >= _gameState!.maxMistakes) {
        // Game Over!
        _stopTimer();
        userProvider.recordGameResult(
          difficulty: _gameState!.difficulty,
          timeSeconds: _gameState!.timeSeconds,
          mistakes: _gameState!.mistakes,
          isVictory: false,
        );
        _savedGame = null;
        StorageService.saveCurrentGame(null);
      } else {
        _saveState();
      }
      notifyListeners();
    } else {
      // Correct digit!
      AudioService.playPlaceNumber();
      cell.value = digit;
      cell.isError = false;
      cell.notes.clear();

      // Auto-remove notes in peers if enabled
      if (userProvider.stats.autoRemoveNotes) {
        final peers = SudokuGenerator.getPeerIndices(idx);
        for (final pIdx in peers) {
          _gameState!.cells[pIdx].notes.remove(digit);
        }
      }

      // Check win condition
      if (SudokuGenerator.isPuzzleSolved(_gameState!.cells)) {
        _handleVictory(userProvider);
        return;
      }

      _saveState();
      notifyListeners();
    }
  }

  void _handleVictory(UserProvider userProvider) {
    if (_gameState == null) return;
    _stopTimer();
    AudioService.playVictory();

    _victoryTime = _gameState!.timeSeconds;
    _victoryMistakes = _gameState!.mistakes;
    _victoryDifficulty = _gameState!.difficulty;

    final prevBest = userProvider.stats.bestTimes[_victoryDifficulty];
    _isNewBestTime = (prevBest == null || _victoryTime < prevBest);

    userProvider.recordGameResult(
      difficulty: _victoryDifficulty,
      timeSeconds: _victoryTime,
      mistakes: _victoryMistakes,
      isVictory: true,
    );

    _gameState!.isCompleted = true;
    _savedGame = null;
    StorageService.saveCurrentGame(null);

    _inGame = false;
    _showVictory = true;
    notifyListeners();
  }

  void erase() {
    if (_gameState == null || _gameState!.selectedCellIndex == null) return;
    final idx = _gameState!.selectedCellIndex!;
    final cell = _gameState!.cells[idx];
    if (cell.isGiven) return;
    if (cell.value == null && cell.notes.isEmpty) return;

    AudioService.playErase();
    _pushHistory();
    cell.value = null;
    cell.isError = false;
    cell.notes.clear();

    _saveState();
    notifyListeners();
  }

  void undo() {
    if (_gameState == null || _gameState!.history.isEmpty) return;
    AudioService.playTap();
    final previous = _gameState!.history.removeLast();
    _gameState!.cells = previous.cells;
    _gameState!.mistakes = previous.mistakes;

    _saveState();
    notifyListeners();
  }

  void toggleNotesMode() {
    if (_gameState == null) return;
    AudioService.playTap();
    _gameState!.notesMode = !_gameState!.notesMode;
    notifyListeners();
  }

  void hint(UserProvider userProvider) {
    if (_gameState == null || _gameState!.hintsRemaining <= 0) return;

    AudioService.playHint();
    int? targetIndex = _gameState!.selectedCellIndex;

    if (targetIndex == null ||
        _gameState!.cells[targetIndex].isGiven ||
        (_gameState!.cells[targetIndex].value == _gameState!.cells[targetIndex].solution &&
            !_gameState!.cells[targetIndex].isError)) {
      targetIndex = _gameState!.cells.indexWhere((c) =>
          c.value == null || (c.value != c.solution) || c.isError);
    }

    if (targetIndex == -1) return;

    _pushHistory();
    final targetCell = _gameState!.cells[targetIndex];
    targetCell.value = targetCell.solution;
    targetCell.isError = false;
    targetCell.notes.clear();

    _gameState!.hintsRemaining -= 1;
    _gameState!.selectedCellIndex = targetIndex;

    // Clean peer notes
    if (userProvider.stats.autoRemoveNotes) {
      final peers = SudokuGenerator.getPeerIndices(targetIndex);
      for (final pIdx in peers) {
        _gameState!.cells[pIdx].notes.remove(targetCell.solution);
      }
    }

    if (SudokuGenerator.isPuzzleSolved(_gameState!.cells)) {
      _handleVictory(userProvider);
      return;
    }

    _saveState();
    notifyListeners();
  }

  void togglePause() {
    if (_gameState == null) return;
    AudioService.playTap();
    _gameState!.isPaused = !_gameState!.isPaused;
    notifyListeners();
  }

  void quitGame() {
    _stopTimer();
    _inGame = false;
    _showVictory = false;
    notifyListeners();
  }

  void backToHome() {
    _showVictory = false;
    _inGame = false;
    notifyListeners();
  }

  void _saveState() {
    if (_gameState != null && !_gameState!.isCompleted) {
      _savedGame = _gameState;
      StorageService.saveCurrentGame(_gameState);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
