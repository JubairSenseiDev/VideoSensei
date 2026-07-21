import 'dart:async';
import 'dart:convert';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../../domain/models/video_file.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_result.dart';
import '../../domain/exceptions/compression_error.dart';
import 'ffmpeg_service.dart';
import 'ffmpeg_parser.dart';

/// FFmpeg service backed by ffmpeg_kit_flutter_new (Android).
class FFmpegServiceAndroid implements FFmpegService {
  FFmpegSession? _activeSession;
  final _parser = FFmpegParser();

  @override
  Future<VideoMetadata> probe(String path) async {
    final session = await FFprobeKit.getMediaInformationAsync(path);
    final info = session.getMediaInformation();
    if (info == null) throw ProbeError(path);

    final streams = info.getStreams() ?? [];
    final videoStream = streams.firstWhere(
      (s) => s.getType() == 'video',
      orElse: () => throw ProbeError(path),
    );
    final audioStream = streams.firstWhere(
      (s) => s.getType() == 'audio',
      orElse: () => streams.first,
    );

    final props = info.getAllProperties() ?? {};
    final format = props['format'] as Map? ?? {};

    return VideoMetadata(
      width: int.tryParse(videoStream.getWidth()?.toString() ?? '0') ?? 0,
      height: int.tryParse(videoStream.getHeight()?.toString() ?? '0') ?? 0,
      fps: _parseFps(videoStream.getAverageFrameRate() ?? '0/1'),
      duration: double.tryParse(info.getDuration() ?? '0') ?? 0,
      codec: videoStream.getCodec() ?? 'unknown',
      bitrate: int.tryParse(format['bit_rate']?.toString() ?? '0') ?? 0,
      audioCodec: audioStream.getCodec() ?? 'unknown',
      audioBitrate:
          int.tryParse(audioStream.getBitrate()?.toString() ?? '0') ?? 0,
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

    final args = ['-y', '-i', input, ...ffmpegArgs, output];
    final argStr = args.join(' ');

    FFmpegKit.executeAsync(
      argStr,
      (session) async {
        final rc = await session.getReturnCode();
        if (ReturnCode.isSuccess(rc)) {
          controller.add(const CompressionProgress(percent: 1.0, speed: 0));
          await controller.close();
        } else if (ReturnCode.isCancel(rc)) {
          controller.addError(const UserCancelledError());
          await controller.close();
        } else {
          final log = await session.getOutput() ?? '';
          controller.addError(EncodingError(exitCode: rc?.getValue() ?? -1, stderr: log));
          await controller.close();
        }
        _activeSession = null;
      },
      (log) {
        final progress = _parser.parseLine(log.getMessage(), startTime: startTime);
        if (progress != null && !controller.isClosed) {
          controller.add(progress);
        }
      },
    ).then((session) => _activeSession = session);

    return controller.stream;
  }

  @override
  Future<bool> verify(String outputPath) async {
    final session = await FFprobeKit.getMediaInformationAsync(outputPath);
    return session.getMediaInformation() != null;
  }

  @override
  Future<void> cancel() async {
    await _activeSession?.cancel();
    _activeSession = null;
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
