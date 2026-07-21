import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/models/video_file.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_result.dart';
import '../../domain/exceptions/compression_error.dart';
import 'ffmpeg_service.dart';
import 'ffmpeg_parser.dart';
import 'ffmpeg_installer.dart';

/// FFmpeg service backed by a bundled binary (Linux / Windows).
class FFmpegServiceDesktop implements FFmpegService {
  Process? _process;
  final _parser = FFmpegParser();

  @override
  Future<VideoMetadata> probe(String path) async {
    final ffprobe = await FFmpegInstaller.ffprobePath();
    final result = await Process.run(ffprobe, [
      '-v', 'quiet',
      '-print_format', 'json',
      '-show_format',
      '-show_streams',
      path,
    ]);
    if (result.exitCode != 0) throw ProbeError(path);

    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final streams = (json['streams'] as List? ?? []).cast<Map<String, dynamic>>();
    final format = json['format'] as Map<String, dynamic>? ?? {};

    final videoStream = streams.firstWhere(
      (s) => s['codec_type'] == 'video',
      orElse: () => throw ProbeError(path),
    );
    final audioStream = streams.firstWhere(
      (s) => s['codec_type'] == 'audio',
      orElse: () => <String, dynamic>{},
    );

    return VideoMetadata(
      width: videoStream['width'] as int? ?? 0,
      height: videoStream['height'] as int? ?? 0,
      fps: _parseFps(videoStream['avg_frame_rate'] as String? ?? '0/1'),
      duration: double.tryParse(format['duration']?.toString() ?? '0') ?? 0,
      codec: videoStream['codec_name'] as String? ?? 'unknown',
      bitrate: int.tryParse(format['bit_rate']?.toString() ?? '0') ?? 0,
      audioCodec: audioStream['codec_name'] as String? ?? 'unknown',
      audioBitrate:
          int.tryParse(audioStream['bit_rate']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  Stream<CompressionProgress> compress({
    required String input,
    required String output,
    required List<String> ffmpegArgs,
  }) {
    final controller = StreamController<CompressionProgress>();
    final startTime = DateTime.now();
    _parser.reset();

    _runProcess(input, output, ffmpegArgs, controller, startTime);
    return controller.stream;
  }

  Future<void> _runProcess(
    String input,
    String output,
    List<String> ffmpegArgs,
    StreamController<CompressionProgress> controller,
    DateTime startTime,
  ) async {
    try {
      final ffmpeg = await FFmpegInstaller.ffmpegPath();
      final args = ['-y', '-i', input, ...ffmpegArgs, output];

      _process = await Process.start(ffmpeg, args);

      // FFmpeg writes progress to stderr
      _process!.stderr
          .transform(const SystemEncoding().decoder)
          .transform(const LineSplitter())
          .listen((line) {
        final progress = _parser.parseLine(line, startTime: startTime);
        if (progress != null && !controller.isClosed) {
          controller.add(progress);
        }
      });

      final exitCode = await _process!.exitCode;
      _process = null;

      if (exitCode == 0) {
        controller.add(const CompressionProgress(percent: 1.0));
        await controller.close();
      } else if (exitCode == 255 || exitCode == -1) {
        controller.addError(const UserCancelledError());
        await controller.close();
      } else {
        controller.addError(EncodingError(exitCode: exitCode, stderr: ''));
        await controller.close();
      }
    } catch (e) {
      controller.addError(e);
      await controller.close();
    }
  }

  @override
  Future<bool> verify(String outputPath) async {
    final file = File(outputPath);
    return file.existsSync() && file.lengthSync() > 0;
  }

  @override
  Future<void> cancel() async {
    _process?.kill(ProcessSignal.sigterm);
    _process = null;
  }

  double _parseFps(String raw) {
    if (raw.contains('/')) {
      final parts = raw.split('/');
      final n = double.tryParse(parts[0]) ?? 0;
      final d = double.tryParse(parts[1]) ?? 1;
      return d > 0 ? n / d : 0;
    }
    return double.tryParse(raw) ?? 0;
  }
}
