import 'package:equatable/equatable.dart';
import 'video_file.dart';
import 'compression_preset.dart';

enum CompressionStatus { success, failed, cancelled }

/// Describes progress during an active compression job.
class CompressionProgress extends Equatable {
  final double percent; // 0.0 – 1.0
  final double? speed; // multiplier, e.g. 1.5 = 1.5× realtime
  final Duration? elapsed;
  final Duration? eta;
  final String? currentFrame;
  final String? currentTime; // HH:MM:SS.ms

  const CompressionProgress({
    required this.percent,
    this.speed,
    this.elapsed,
    this.eta,
    this.currentFrame,
    this.currentTime,
  });

  @override
  List<Object?> get props => [percent];
}

/// The final output of a compression job.
class CompressionResult extends Equatable {
  final CompressionStatus status;
  final VideoFile inputFile;
  final CompressionPreset preset;

  // Success fields
  final String? outputPath;
  final int? outputSize; // bytes
  final Duration? encodingDuration;
  final String? ffmpegCommand;

  // Error field
  final String? errorMessage;

  const CompressionResult({
    required this.status,
    required this.inputFile,
    required this.preset,
    this.outputPath,
    this.outputSize,
    this.encodingDuration,
    this.ffmpegCommand,
    this.errorMessage,
  });

  bool get isSuccess => status == CompressionStatus.success;

  double? get reductionRatio {
    if (outputSize == null || inputFile.size <= 0) return null;
    return 1.0 - outputSize! / inputFile.size;
  }

  /// Saved bytes (positive = smaller output).
  int? get savedBytes {
    if (outputSize == null) return null;
    return inputFile.size - outputSize!;
  }

  @override
  List<Object?> get props => [outputPath, status];

  factory CompressionResult.success({
    required VideoFile inputFile,
    required CompressionPreset preset,
    required String outputPath,
    required int outputSize,
    required Duration encodingDuration,
    required String ffmpegCommand,
  }) {
    return CompressionResult(
      status: CompressionStatus.success,
      inputFile: inputFile,
      preset: preset,
      outputPath: outputPath,
      outputSize: outputSize,
      encodingDuration: encodingDuration,
      ffmpegCommand: ffmpegCommand,
    );
  }

  factory CompressionResult.failure({
    required VideoFile inputFile,
    required CompressionPreset preset,
    required String errorMessage,
  }) {
    return CompressionResult(
      status: CompressionStatus.failed,
      inputFile: inputFile,
      preset: preset,
      errorMessage: errorMessage,
    );
  }

  factory CompressionResult.cancelled({
    required VideoFile inputFile,
    required CompressionPreset preset,
  }) {
    return CompressionResult(
      status: CompressionStatus.cancelled,
      inputFile: inputFile,
      preset: preset,
    );
  }
}
