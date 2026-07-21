import 'package:equatable/equatable.dart';

/// Metadata extracted from the input video via ffprobe.
class VideoMetadata extends Equatable {
  final int width;
  final int height;
  final double fps;
  final double duration; // seconds
  final String codec;
  final int bitrate; // bps
  final String audioCodec;
  final int audioBitrate; // bps

  const VideoMetadata({
    required this.width,
    required this.height,
    required this.fps,
    required this.duration,
    required this.codec,
    required this.bitrate,
    required this.audioCodec,
    required this.audioBitrate,
  });

  String get resolution => '${width}x$height';

  String get resolutionLabel {
    if (height >= 2160) return '4K';
    if (height >= 1440) return '1440p';
    if (height >= 1080) return '1080p';
    if (height >= 720) return '720p';
    if (height >= 480) return '480p';
    return '${height}p';
  }

  @override
  List<Object?> get props => [width, height, fps, duration, codec, bitrate];

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    final vStream = json['video'] as Map<String, dynamic>? ?? {};
    final aStream = json['audio'] as Map<String, dynamic>? ?? {};
    return VideoMetadata(
      width: (vStream['width'] as num?)?.toInt() ?? 0,
      height: (vStream['height'] as num?)?.toInt() ?? 0,
      fps: (vStream['fps'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      codec: vStream['codec'] as String? ?? 'unknown',
      bitrate: (json['bitrate'] as num?)?.toInt() ?? 0,
      audioCodec: aStream['codec'] as String? ?? 'unknown',
      audioBitrate: (aStream['bitrate'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Represents an input video file selected by the user.
class VideoFile extends Equatable {
  final String path;
  final String name;
  final int size; // bytes
  final VideoMetadata? metadata;

  const VideoFile({
    required this.path,
    required this.name,
    required this.size,
    this.metadata,
  });

  VideoFile withMetadata(VideoMetadata meta) =>
      VideoFile(path: path, name: name, size: size, metadata: meta);

  @override
  List<Object?> get props => [path];
}
