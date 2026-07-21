import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Supported output codecs.
enum CodecChoice {
  h264(
    label: 'H.264',
    ffmpegLib: 'libx264',
    description: 'Maximum compatibility',
    badgeColor: AppColors.presetLiteCyan,
  ),
  h265(
    label: 'H.265',
    ffmpegLib: 'libx265',
    description: 'Best balance',
    badgeColor: AppColors.presetBalancedGreen,
  ),
  av1(
    label: 'AV1',
    ffmpegLib: 'libsvtav1',
    description: 'Future-proof',
    badgeColor: AppColors.presetSenseiPurple,
  );

  const CodecChoice({
    required this.label,
    required this.ffmpegLib,
    required this.description,
    required this.badgeColor,
  });

  final String label;
  final String ffmpegLib;
  final String description;
  final Color badgeColor;

  /// True if this codec requires `-tag:v hvc1` for QuickTime compat.
  bool get requiresHvc1Tag => this == h265;

  /// True if audio should default to Opus instead of AAC.
  bool get prefersOpus => this == av1;
}
