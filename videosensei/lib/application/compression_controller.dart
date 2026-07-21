import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/ffmpeg/ffmpeg_service.dart';
import '../data/filepicker/file_picker_service.dart';
import '../data/storage/history_repository.dart';
import '../domain/models/video_file.dart';
import '../domain/models/compression_preset.dart';
import '../domain/models/compression_result.dart';
import '../domain/strategy/preset_strategy.dart';
import '../domain/exceptions/compression_error.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class CompressionState {
  const CompressionState();
}

class CompressionIdle extends CompressionState {
  const CompressionIdle();
}

class CompressionProbing extends CompressionState {
  const CompressionProbing();
}

class CompressionRunning extends CompressionState {
  final CompressionProgress progress;
  const CompressionRunning(this.progress);
}

class CompressionDone extends CompressionState {
  final CompressionResult result;
  const CompressionDone(this.result);
}

class CompressionFailed extends CompressionState {
  final String message;
  const CompressionFailed(this.message);
}

// ── Controller ────────────────────────────────────────────────────────────────

class CompressionController extends Notifier<CompressionState> {
  late final FFmpegService _ffmpeg;
  late final FilePickerService _picker;
  late final PresetStrategy _strategy;
  StreamSubscription<CompressionProgress>? _sub;

  @override
  CompressionState build() {
    _ffmpeg = FFmpegService.forPlatform();
    _picker = const FilePickerService();
    _strategy = const PresetStrategy();
    ref.onDispose(() => _sub?.cancel());
    return const CompressionIdle();
  }

  /// Probes [video] and returns an updated [VideoFile] with metadata.
  Future<VideoFile> probe(VideoFile video) async {
    state = const CompressionProbing();
    try {
      final meta = await _ffmpeg.probe(video.path);
      return video.withMetadata(meta);
    } catch (e) {
      state = CompressionFailed(e.toString());
      rethrow;
    }
  }

  /// Starts compression and streams progress to state.
  Future<void> compress({
    required VideoFile video,
    required CompressionPreset preset,
    required String outputPath,
  }) async {
    await _sub?.cancel();
    state = const CompressionRunning(CompressionProgress(percent: 0));

    final args = _strategy.buildArgs(
      preset: preset,
      meta: video.metadata,
    );
    final command = _strategy.buildCommandString(
      inputPath: video.path,
      outputPath: outputPath,
      preset: preset,
      meta: video.metadata,
    );

    final startTime = DateTime.now();
    final stream = _ffmpeg.compress(
      input: video.path,
      output: outputPath,
      ffmpegArgs: args,
    );

    final completer = Completer<void>();

    _sub = stream.listen(
      (progress) {
        state = CompressionRunning(progress);
      },
      onDone: () async {
        final elapsed = DateTime.now().difference(startTime);
        final outputFile = File(outputPath);
        final outputSize =
            outputFile.existsSync() ? outputFile.lengthSync() : 0;

        final result = CompressionResult.success(
          inputFile: video,
          preset: preset,
          outputPath: outputPath,
          outputSize: outputSize,
          encodingDuration: elapsed,
          ffmpegCommand: command,
        );

        // Persist to history
        final repo = ref.read(historyRepositoryProvider);
        await repo.insert(result);

        state = CompressionDone(result);
        completer.complete();
      },
      onError: (Object e) async {
        CompressionResult result;
        if (e is UserCancelledError) {
          result = CompressionResult.cancelled(
              inputFile: video, preset: preset);
        } else {
          result = CompressionResult.failure(
            inputFile: video,
            preset: preset,
            errorMessage: e.toString(),
          );
          await ref.read(historyRepositoryProvider).insert(result);
          state = CompressionFailed(e.toString());
        }
        completer.complete();
      },
    );

    await completer.future;
  }

  Future<void> cancel() async {
    await _ffmpeg.cancel();
    state = const CompressionIdle();
  }

  void reset() => state = const CompressionIdle();
}

final compressionControllerProvider =
    NotifierProvider<CompressionController, CompressionState>(
  CompressionController.new,
);
