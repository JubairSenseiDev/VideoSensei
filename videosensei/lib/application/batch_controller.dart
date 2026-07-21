import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/video_file.dart';
import '../domain/models/compression_preset.dart';
import '../domain/models/compression_result.dart';
import 'compression_controller.dart';
import '../data/filepicker/file_picker_service.dart';

enum BatchItemStatus { pending, running, done, failed, cancelled }

class BatchItem {
  final VideoFile video;
  final CompressionPreset preset;
  final BatchItemStatus status;
  final CompressionResult? result;
  final String? error;

  const BatchItem({
    required this.video,
    required this.preset,
    this.status = BatchItemStatus.pending,
    this.result,
    this.error,
  });

  BatchItem copyWith({
    BatchItemStatus? status,
    CompressionResult? result,
    String? error,
  }) {
    return BatchItem(
      video: video,
      preset: preset,
      status: status ?? this.status,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class BatchState {
  final List<BatchItem> queue;
  final int currentIndex;
  final bool isRunning;

  const BatchState({
    this.queue = const [],
    this.currentIndex = -1,
    this.isRunning = false,
  });

  BatchState copyWith({
    List<BatchItem>? queue,
    int? currentIndex,
    bool? isRunning,
  }) {
    return BatchState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  int get pendingCount =>
      queue.where((i) => i.status == BatchItemStatus.pending).length;
  int get doneCount =>
      queue.where((i) => i.status == BatchItemStatus.done).length;
  bool get isDone => !isRunning && queue.isNotEmpty && pendingCount == 0;
}

class BatchController extends Notifier<BatchState> {
  @override
  BatchState build() => const BatchState();

  void addVideos(List<VideoFile> videos, CompressionPreset preset) {
    final newItems = videos
        .map((v) => BatchItem(video: v, preset: preset))
        .toList();
    state = state.copyWith(queue: [...state.queue, ...newItems]);
  }

  void removeAt(int index) {
    final updated = List<BatchItem>.from(state.queue)..removeAt(index);
    state = state.copyWith(queue: updated);
  }

  void clear() => state = const BatchState();

  Future<void> runAll(String? outputDir) async {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);

    final picker = const FilePickerService();
    final compression = ref.read(compressionControllerProvider.notifier);

    for (var i = 0; i < state.queue.length; i++) {
      final item = state.queue[i];
      if (item.status != BatchItemStatus.pending) continue;

      _updateItem(i, item.copyWith(status: BatchItemStatus.running));
      state = state.copyWith(currentIndex: i);

      try {
        final probed = await compression.probe(item.video);
        final outputPath = picker.buildOutputPath(
          probed.path,
          outputDir: outputDir,
        );
        await compression.compress(
          video: probed,
          preset: item.preset,
          outputPath: outputPath,
        );

        final compState = ref.read(compressionControllerProvider);
        if (compState is CompressionDone) {
          _updateItem(i, item.copyWith(
            status: BatchItemStatus.done,
            result: compState.result,
          ));
        } else {
          _updateItem(i, item.copyWith(status: BatchItemStatus.failed));
        }
      } catch (e) {
        _updateItem(i, item.copyWith(
          status: BatchItemStatus.failed,
          error: e.toString(),
        ));
      }
    }

    state = state.copyWith(isRunning: false, currentIndex: -1);
  }

  Future<void> cancel() async {
    await ref.read(compressionControllerProvider.notifier).cancel();
    state = state.copyWith(isRunning: false);
  }

  void _updateItem(int index, BatchItem item) {
    final updated = List<BatchItem>.from(state.queue);
    updated[index] = item;
    state = state.copyWith(queue: updated);
  }
}

final batchControllerProvider =
    NotifierProvider<BatchController, BatchState>(BatchController.new);
