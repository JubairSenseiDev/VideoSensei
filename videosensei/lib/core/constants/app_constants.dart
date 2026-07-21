/// Application-wide constants for VideoSensei.
abstract class AppConstants {
  static const String appName = 'VideoSensei';
  static const String appVersion = '0.2.0';
  static const String tagline = 'Master your video. Sensei-grade clarity.';
  static const String authorUrl = 'https://jubairsensei.com';
  static const String repoUrl = 'https://github.com/JubairSenseiDev/VideoSensei';

  // History
  static const int historyDefaultRetentionDays = 90;
  static const int maxHistoryItems = 1000;

  // Compression
  static const List<String> supportedExtensions = [
    'mp4', 'mkv', 'mov', 'avi', 'webm', 'flv', 'm4v', 'wmv', 'ts',
  ];

  static const Map<String, String> mimeTypes = {
    'mp4': 'video/mp4',
    'mkv': 'video/x-matroska',
    'mov': 'video/quicktime',
    'avi': 'video/x-msvideo',
    'webm': 'video/webm',
  };

  // Output
  static const String outputSuffix = '_sensei';
  static const String outputExtension = '.mp4';

  // Progress polling
  static const Duration progressPollInterval = Duration(milliseconds: 500);

  // Onboarding
  static const String onboardingCompleteKey = 'onboarding_complete';
}

/// FFmpeg binary asset paths (bundled for Linux/Windows)
abstract class FFmpegAssets {
  static const String linuxX64 = 'assets/ffmpeg/linux/x64/ffmpeg';
  static const String windowsX64 = 'assets/ffmpeg/windows/x64/ffmpeg.exe';
}
