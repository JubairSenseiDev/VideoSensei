import '../models/video_file.dart';
import '../models/compression_preset.dart';
import '../models/codec_choice.dart';

/// Predicts the output file size before encoding starts.
///
/// Uses a heuristic based on:
/// - Source bitrate
/// - Codec compression factor (H.265 ≈ 0.5×, AV1 ≈ 0.35×)
/// - CRF factor (higher CRF = lower bitrate = smaller file)
class SizePredictor {
  const SizePredictor();

  static const _codecFactors = {
    CodecChoice.h264: 0.60, // ~40% smaller than source
    CodecChoice.h265: 0.50, // ~50% smaller
    CodecChoice.av1: 0.35, // ~65% smaller
  };

  /// Returns a [SizePrediction] or `null` if metadata is insufficient.
  SizePrediction? predict({
    required VideoFile video,
    required CompressionPreset preset,
  }) {
    final meta = video.metadata;
    if (meta == null) return null;
    if (meta.bitrate <= 0 || meta.duration <= 0) return null;
    if (preset.key == PresetKey.custom) return null;

    final codecFactor = _codecFactors[preset.codec] ?? 0.5;

    // CRF factor: CRF 18 → 0.7 (high quality, bigger), CRF 32 → 1.4
    // Linear interpolation: factor = (crf - 18) / 14 + 0.7
    final crfFactor = (preset.crf - 18) / 14.0 + 0.7;

    final targetBitrate = meta.bitrate * codecFactor * crfFactor;
    final predictedBytes = (targetBitrate * meta.duration / 8).round();

    // Clamp to sane range
    final clampedBytes = predictedBytes.clamp(
      (video.size * 0.05).round(), // never predict < 5% of source
      video.size,                   // never predict bigger than source
    );

    return SizePrediction(
      originalBytes: video.size,
      predictedBytes: clampedBytes,
      codecFactor: codecFactor,
    );
  }
}

class SizePrediction {
  final int originalBytes;
  final int predictedBytes;
  final double codecFactor;

  const SizePrediction({
    required this.originalBytes,
    required this.predictedBytes,
    required this.codecFactor,
  });

  double get reductionRatio =>
      originalBytes > 0 ? 1.0 - predictedBytes / originalBytes : 0;

  int get savedBytes => originalBytes - predictedBytes;

  /// e.g. "−47%"
  String get reductionLabel {
    final pct = (reductionRatio * 100).round();
    return '−$pct%';
  }
}
