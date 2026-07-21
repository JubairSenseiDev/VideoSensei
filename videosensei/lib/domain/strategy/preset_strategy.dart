import '../models/compression_preset.dart';
import '../models/codec_choice.dart';
import '../models/video_file.dart';

/// Converts a [CompressionPreset] into a list of FFmpeg CLI arguments.
/// This is the single source of truth for how presets map to FFmpeg commands.
class PresetStrategy {
  const PresetStrategy();

  /// Returns the full FFmpeg argument list (everything after `ffmpeg -i input`).
  /// Does NOT include `-i input` or the output path — caller adds those.
  List<String> buildArgs({
    required CompressionPreset preset,
    required VideoMetadata? meta,
    VideoResolution? targetResolution,
  }) {
    final args = <String>[];

    // ── Video codec ────────────────────────────────────────────────────────
    args.addAll(['-c:v', preset.codec.ffmpegLib]);

    // CRF
    args.addAll(['-crf', preset.crf.toString()]);

    // Encoder preset
    if (preset.codec == CodecChoice.av1) {
      // SVT-AV1 uses -preset (integer)
      args.addAll(['-preset', preset.encoderPreset]);
    } else {
      args.addAll(['-preset', preset.encoderPreset]);
    }

    // Pixel format (required for broad compat)
    args.addAll(['-pix_fmt', 'yuv420p']);

    // QuickTime / iOS compat tag for H.265
    if (preset.codec.requiresHvc1Tag) {
      args.addAll(['-tag:v', 'hvc1']);
    }

    // ── Resolution scale ───────────────────────────────────────────────────
    if (targetResolution != null) {
      args.addAll(['-vf', 'scale=${targetResolution.width}:${targetResolution.height}']);
    }

    // ── Audio ─────────────────────────────────────────────────────────────
    switch (preset.audioCodec) {
      case AudioCodec.aac:
        args.addAll(['-c:a', 'aac', '-b:a', '${preset.audioBitrate}k']);
      case AudioCodec.opus:
        args.addAll(['-c:a', 'libopus', '-b:a', '${preset.audioBitrate}k']);
      case AudioCodec.copy:
        args.addAll(['-c:a', 'copy']);
      case AudioCodec.drop:
        args.add('-an');
    }

    // ── Container optimisations ───────────────────────────────────────────
    // moov atom at front → web streaming
    args.addAll(['-movflags', '+faststart']);

    // ── Metadata ──────────────────────────────────────────────────────────
    args.addAll([
      '-metadata', 'title=Compressed by VideoSensei (${preset.name})',
      '-metadata', 'comment=https://jubairsensei.com',
    ]);

    return args;
  }

  /// Returns the full FFmpeg command string for display in history log.
  String buildCommandString({
    required String inputPath,
    required String outputPath,
    required CompressionPreset preset,
    VideoMetadata? meta,
    VideoResolution? targetResolution,
  }) {
    final args = buildArgs(preset: preset, meta: meta, targetResolution: targetResolution);
    final allParts = ['ffmpeg', '-i', '"$inputPath"', ...args, '"$outputPath"'];
    return allParts.join(' ');
  }
}

/// Target resolution for downscaling (optional).
class VideoResolution {
  final int width;
  final int height;

  const VideoResolution(this.width, this.height);

  static const p1080 = VideoResolution(1920, 1080);
  static const p720 = VideoResolution(1280, 720);
  static const p480 = VideoResolution(854, 480);

  @override
  String toString() => '${height}p';
}
