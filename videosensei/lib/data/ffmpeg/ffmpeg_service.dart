import '../../domain/models/video_file.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_result.dart';
import '../platform/platform_info.dart';
import 'ffmpeg_service_android.dart';
import 'ffmpeg_service_desktop.dart';

/// Abstract FFmpeg bridge — platform implementations vary.
abstract class FFmpegService {
  /// Probe video metadata via ffprobe / ffmpeg -i.
  Future<VideoMetadata> probe(String path);

  /// Run compression, yielding progress events.
  Stream<CompressionProgress> compress({
    required String input,
    required String output,
    required List<String> ffmpegArgs,
  });

  /// Verify the output file exists and has non-zero size.
  Future<bool> verify(String outputPath);

  /// Cancel any in-progress compression.
  Future<void> cancel();

  /// Factory — returns the correct implementation for the current platform.
  factory FFmpegService.forPlatform() {
    if (PlatformInfo.isAndroid) return FFmpegServiceAndroid();
    return FFmpegServiceDesktop();
  }
}
