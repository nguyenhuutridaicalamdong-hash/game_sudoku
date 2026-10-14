import 'package:flutter/services.dart';

class AudioService {
  static bool soundEnabled = true;
  static bool hapticsEnabled = true;

  static void playTap() {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void playPlaceNumber() {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void playNoteToggle() {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  static void playMistake() {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static void playErase() {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void playHint() {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void playVictory() {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
