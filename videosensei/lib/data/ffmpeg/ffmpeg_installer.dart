import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../data/platform/platform_info.dart';
import '../../domain/exceptions/compression_error.dart';

/// Resolves the path to the bundled FFmpeg / FFprobe binaries.
///
/// On Android: delegates to ffmpeg_kit_flutter_new — no extraction needed.
/// On Linux/Windows: extracts the binary from Flutter assets on first run.
abstract class FFmpegInstaller {
  static String? _cachedFfmpegPath;
  static String? _cachedFfprobePath;

  static Future<String> ffmpegPath() async {
    if (_cachedFfmpegPath != null) return _cachedFfmpegPath!;
    _cachedFfmpegPath = await _resolve(isProbe: false);
    return _cachedFfmpegPath!;
  }

  static Future<String> ffprobePath() async {
    if (_cachedFfprobePath != null) return _cachedFfprobePath!;
    _cachedFfprobePath = await _resolve(isProbe: true);
    return _cachedFfprobePath!;
  }

  static Future<String> _resolve({required bool isProbe}) async {
    // On desktop, first try system PATH (user may already have ffmpeg)
    final systemPath = await _findOnPath(isProbe ? 'ffprobe' : 'ffmpeg');
    if (systemPath != null) return systemPath;

    // Fall back to bundled binary extracted from assets
    return _extractBundled(isProbe: isProbe);
  }

  static Future<String?> _findOnPath(String name) async {
    try {
      final whichCmd = PlatformInfo.isWindows ? 'where' : 'which';
      final result = await Process.run(whichCmd, [name]);
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty) return path;
      }
    } catch (_) {}
    return null;
  }

  static Future<String> _extractBundled({required bool isProbe}) async {
    final assetPath = _assetPath(isProbe: isProbe);
    final appDir = await getApplicationSupportDirectory();
    final binDir = Directory(p.join(appDir.path, 'ffmpeg'));
    await binDir.create(recursive: true);

    final binaryName = isProbe
        ? (PlatformInfo.isWindows ? 'ffprobe.exe' : 'ffprobe')
        : (PlatformInfo.isWindows ? 'ffmpeg.exe' : 'ffmpeg');
    final dest = File(p.join(binDir.path, binaryName));

    // Only extract if not already present
    if (!dest.existsSync()) {
      final data = await rootBundle.load(assetPath);
      await dest.writeAsBytes(data.buffer.asUint8List(), flush: true);
      // Make executable on Unix
      if (!PlatformInfo.isWindows) {
        await Process.run('chmod', ['+x', dest.path]);
      }
    }

    if (!dest.existsSync()) throw const FFmpegNotFoundError();
    return dest.path;
  }

  static String _assetPath({required bool isProbe}) {
    if (PlatformInfo.isLinux) {
      return isProbe
          ? 'assets/ffmpeg/linux/x64/ffprobe'
          : FFmpegAssets.linuxX64;
    }
    if (PlatformInfo.isWindows) {
      return isProbe
          ? 'assets/ffmpeg/windows/x64/ffprobe.exe'
          : FFmpegAssets.windowsX64;
    }
    throw const FFmpegNotFoundError();
  }
}
