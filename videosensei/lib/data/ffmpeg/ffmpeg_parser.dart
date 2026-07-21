import 'dart:async';
import '../../domain/models/compression_result.dart';

/// Parses FFmpeg's stderr output into [CompressionProgress] events.
///
/// FFmpeg writes progress lines like:
///   frame=  120 fps= 24 q=26.0 size=    1024kB time=00:00:05.00 bitrate=1678.0kbits/s speed=1.25x
class FFmpegParser {
  static final _progressRe = RegExp(
    r'frame=\s*(\d+).*?time=(\d{2}:\d{2}:\d{2}\.\d+).*?speed=\s*([\d.]+)x',
  );

  static final _durationRe = RegExp(
    r'Duration:\s+(\d{2}):(\d{2}):(\d{2})\.(\d+)',
  );

  /// Total duration of the input, extracted from the header block.
  Duration? _totalDuration;

  /// Feed a single stderr line; returns a [CompressionProgress] when parseable.
  CompressionProgress? parseLine(String line, {DateTime? startTime}) {
    // Extract total duration from the ffmpeg header (e.g. "Duration: 00:01:23.45")
    if (_totalDuration == null) {
      final dm = _durationRe.firstMatch(line);
      if (dm != null) {
        _totalDuration = Duration(
          hours: int.parse(dm.group(1)!),
          minutes: int.parse(dm.group(2)!),
          seconds: int.parse(dm.group(3)!),
          milliseconds: (double.parse('0.${dm.group(4)!}') * 1000).round(),
        );
        return null;
      }
    }

    final m = _progressRe.firstMatch(line);
    if (m == null) return null;

    final frame = m.group(1) ?? '0';
    final timeStr = m.group(2) ?? '00:00:00.00';
    final speed = double.tryParse(m.group(3) ?? '0') ?? 0;

    final elapsed = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    final currentSeconds = _parseTimecode(timeStr);
    final total = _totalDuration?.inSeconds.toDouble() ?? 0;

    final percent = (total > 0) ? (currentSeconds / total).clamp(0.0, 1.0) : 0.0;

    Duration? eta;
    if (elapsed != null && percent > 0 && percent < 1.0) {
      final totalEstSecs = elapsed.inSeconds / percent;
      final etaSecs = totalEstSecs - elapsed.inSeconds;
      if (etaSecs > 0) eta = Duration(seconds: etaSecs.round());
    }

    return CompressionProgress(
      percent: percent,
      speed: speed,
      elapsed: elapsed,
      eta: eta,
      currentFrame: frame,
      currentTime: timeStr,
    );
  }

  static double _parseTimecode(String tc) {
    final parts = tc.split(':');
    if (parts.length < 3) return 0;
    final h = double.tryParse(parts[0]) ?? 0;
    final m = double.tryParse(parts[1]) ?? 0;
    final s = double.tryParse(parts[2]) ?? 0;
    return h * 3600 + m * 60 + s;
  }

  void reset() => _totalDuration = null;
}
