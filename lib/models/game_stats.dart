import 'package:flutter/material.dart';

class GameStats {
  static int gold = 1000;
  static int lives = 5;
  static const int maxLives = 5;
  static DateTime? nextLifeAt;
  static const Duration lifeRestoreDuration = Duration(minutes: 5);

  static void restoreLives() {
    if (lives >= maxLives || nextLifeAt == null) {
      return;
    }
    final now = DateTime.now();
    while (nextLifeAt != null && !now.isBefore(nextLifeAt!) && lives < maxLives) {
      lives++;
      nextLifeAt = lives < maxLives ? nextLifeAt!.add(lifeRestoreDuration) : null;
    }
  }

  static String getLifeStatusText() {
    restoreLives();
    if (lives >= maxLives || nextLifeAt == null) {
      return 'Can $lives/$maxLives';
    }
    final remaining = nextLifeAt!.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'Can $lives/$maxLives';
    }
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return 'Can $lives/$maxLives  +1 $minutes:$seconds';
  }

  static void spendLife() {
    if (lives <= 0) return;
    lives--;
    nextLifeAt ??= DateTime.now().add(lifeRestoreDuration);
  }
}
