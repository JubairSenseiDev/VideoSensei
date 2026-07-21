import '../models/video_file.dart';
import '../models/compression_preset.dart';

/// Smart mode: analyses input video metadata and recommends the best preset.
///
/// Decision logic mirrors the Node.js CLI's `recommendPreset()` function.
class AutoStrategy {
  const AutoStrategy();

  /// Returns a recommended [PresetKey], or `null` if the video should not be
  /// re-encoded (e.g. already AV1 at low bitrate).
  PresetKey? recommend(VideoMetadata meta) {
    final codec = meta.codec.toLowerCase();
    final bitrate = meta.bitrate;
    final duration = meta.duration;
    final height = meta.height;

    // Already AV1 → don't re-encode
    if (codec == 'av1' || codec == 'libsvtav1') return null;

    // Already tiny → don't bother
    if (bitrate > 0 && bitrate < 500 * 1000) return null;

    // Short clip (< 30 s) → Lite (fast, good enough)
    if (duration > 0 && duration < 30) return PresetKey.lite;

    // 4K content → Balanced (H.265, respects encode time)
    if (height >= 2160) return PresetKey.balanced;

    // Very high bitrate (> 5 Mbps) → Crystal for archive quality
    if (bitrate > 5 * 1000 * 1000) return PresetKey.crystal;

    // Old codec → Lite for maximum compat improvement
    if (codec == 'mpeg2video' || codec == 'mpeg4' || codec == 'h263') {
      return PresetKey.lite;
    }

    // ProRes / DNxHR (production formats) → Crystal
    if (codec.contains('prores') || codec.contains('dnx')) {
      return PresetKey.crystal;
    }

    // Default → Balanced
    return PresetKey.balanced;
  }

  /// Human-readable explanation of why a preset was chosen.
  String explain(VideoMetadata meta, PresetKey? key) {
    if (key == null) {
      return 'Video is already optimally compressed — re-encoding would not save space.';
    }
    return switch (key) {
      PresetKey.lite => 'Short clip or low bitrate detected — Lite gives the fastest result.',
      PresetKey.balanced => 'H.265 Balanced is the best trade-off for this video.',
      PresetKey.crystal =>
        'High-quality source detected — Crystal preserves maximum detail.',
      PresetKey.sensei => 'AV1 Sensei gives the smallest file for this content.',
      PresetKey.custom => 'Custom preset selected.',
    };
  }
}
