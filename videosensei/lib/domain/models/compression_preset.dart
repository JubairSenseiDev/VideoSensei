import 'package:equatable/equatable.dart';
import 'codec_choice.dart';

/// Audio codec options.
enum AudioCodec { aac, opus, copy, drop }

/// Represents one of the five VideoSensei quality presets.
enum PresetKey { lite, balanced, crystal, sensei, custom }

class CompressionPreset extends Equatable {
  final PresetKey key;
  final String name;
  final String emoji;
  final String description;
  final CodecChoice codec;
  final int crf;

  /// FFmpeg preset string (e.g. "veryfast", "medium") or SVT-AV1 preset int.
  final String encoderPreset;

  final AudioCodec audioCodec;
  final int audioBitrate; // kbps
  final String compatibility;

  const CompressionPreset({
    required this.key,
    required this.name,
    required this.emoji,
    required this.description,
    required this.codec,
    required this.crf,
    required this.encoderPreset,
    required this.audioCodec,
    required this.audioBitrate,
    required this.compatibility,
  });

  @override
  List<Object?> get props => [key];

  CompressionPreset copyWith({
    CodecChoice? codec,
    int? crf,
    String? encoderPreset,
    AudioCodec? audioCodec,
    int? audioBitrate,
  }) {
    return CompressionPreset(
      key: key,
      name: name,
      emoji: emoji,
      description: description,
      codec: codec ?? this.codec,
      crf: crf ?? this.crf,
      encoderPreset: encoderPreset ?? this.encoderPreset,
      audioCodec: audioCodec ?? this.audioCodec,
      audioBitrate: audioBitrate ?? this.audioBitrate,
      compatibility: compatibility,
    );
  }
}

/// Canonical preset catalogue — single source of truth.
abstract class Presets {
  static const lite = CompressionPreset(
    key: PresetKey.lite,
    name: 'Lite',
    emoji: '🪶',
    description: 'Quick share, max compat',
    codec: CodecChoice.h264,
    crf: 30,
    encoderPreset: 'veryfast',
    audioCodec: AudioCodec.aac,
    audioBitrate: 128,
    compatibility: 'All devices & players',
  );

  static const balanced = CompressionPreset(
    key: PresetKey.balanced,
    name: 'Balanced',
    emoji: '⚖️',
    description: 'Daily default, ~50% smaller',
    codec: CodecChoice.h265,
    crf: 26,
    encoderPreset: 'medium',
    audioCodec: AudioCodec.aac,
    audioBitrate: 128,
    compatibility: 'Modern devices (2017+)',
  );

  static const crystal = CompressionPreset(
    key: PresetKey.crystal,
    name: 'Crystal',
    emoji: '💎',
    description: 'Archive quality, near-lossless',
    codec: CodecChoice.h265,
    crf: 22,
    encoderPreset: 'slow',
    audioCodec: AudioCodec.aac,
    audioBitrate: 192,
    compatibility: 'Modern devices (2017+)',
  );

  static const sensei = CompressionPreset(
    key: PresetKey.sensei,
    name: 'Sensei',
    emoji: '🥋',
    description: 'Future-proof, smallest file',
    codec: CodecChoice.av1,
    crf: 32,
    encoderPreset: '6', // SVT-AV1 preset 6
    audioCodec: AudioCodec.opus,
    audioBitrate: 96,
    compatibility: 'Cutting-edge players only',
  );

  /// Custom preset starts as a copy of Balanced — user modifies it.
  static const custom = CompressionPreset(
    key: PresetKey.custom,
    name: 'Custom',
    emoji: '🎯',
    description: 'Full manual control',
    codec: CodecChoice.h265,
    crf: 26,
    encoderPreset: 'medium',
    audioCodec: AudioCodec.aac,
    audioBitrate: 128,
    compatibility: 'Depends on your settings',
  );

  static const all = [lite, balanced, crystal, sensei, custom];

  static CompressionPreset byKey(PresetKey key) =>
      all.firstWhere((p) => p.key == key);
}
