import 'package:flutter/services.dart';

class AudioFeedbackService {
  static void playRestTimerDone() {
    try {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static void playPrCelebration() {
    try {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }
}
