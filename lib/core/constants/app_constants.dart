/// App-wide constants: channel names, storage keys and hard limits.
class AppConstants {
  AppConstants._();

  static const String appName = 'For Anis';
  static const String partnerName = 'Anis';

  // Platform channels shared with the native Android layer.
  static const String methodChannel = 'com.sirine.for_anis/focus';
  static const String eventChannel = 'com.sirine.for_anis/focus_events';

  // Hard limits on a focus session.
  static const Duration minSessionDuration = Duration(minutes: 15);
  static const Duration maxSessionDuration = Duration(hours: 8);

  // SharedPreferences keys (Flutter side).
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyBlockedPackages = 'blocked_packages';

  // Stats keys.
  static const String keyTotalFocusMs = 'stats_total_focus_ms';
  static const String keySessionsCompleted = 'stats_sessions_completed';
  static const String keyCurrentStreak = 'stats_current_streak';
  static const String keyLongestStreak = 'stats_longest_streak';
  static const String keyLastSessionDay = 'stats_last_session_day';
}

/// Package names for the "Social media" preset in the app picker.
class SocialPreset {
  SocialPreset._();

  static const List<String> packages = [
    'com.instagram.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.facebook.katana',
    'com.snapchat.android',
    'com.twitter.android', // X / Twitter (legacy)
    'com.x.android',
    'com.google.android.youtube',
    'com.reddit.frontpage',
    'org.telegram.messenger',
    // WhatsApp is optional and intentionally left out of the default preset.
  ];

  /// Packages we must never block, no matter what, for safety.
  static const List<String> neverBlock = [
    'com.sirine.for_anis', // this app
    'com.android.dialer',
    'com.google.android.dialer',
    'com.android.phone',
    'com.android.server.telecom',
    'com.android.mms',
    'com.google.android.apps.messaging',
    'com.android.emergency',
  ];
}
