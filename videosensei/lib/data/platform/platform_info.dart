import 'dart:io';

/// Detects the current platform and exposes helpers.
abstract class PlatformInfo {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isLinux => Platform.isLinux;
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isDesktop => isLinux || isWindows || isMacOS;
  static bool get isMobile => isAndroid;

  static String get name {
    if (isAndroid) return 'android';
    if (isLinux) return 'linux';
    if (isWindows) return 'windows';
    if (isMacOS) return 'macos';
    return 'unknown';
  }

  /// Path separator for the current platform.
  static String get sep => Platform.pathSeparator;
}
