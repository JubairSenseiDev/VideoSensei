import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/batch_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../data/filepicker/file_picker_service.dart';
import '../../domain/models/compression_preset.dart';
import '../widgets/sensei_app_bar.dart';

class BatchScreen extends ConsumerStatefulWidget {
  const BatchScreen({super.key});

  @override
  ConsumerState<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends ConsumerState<BatchScreen> {
  final _picker = const FilePickerService();
  CompressionPreset _preset = Presets.balanced;

  Future<void> _addFiles() async {
    final files = await _picker.pickMultipleVideos();
    if (files.isEmpty) return;
    ref.read(batchControllerProvider.notifier).addVideos(files, _preset);
  }

  Future<void> _runAll() async {
    final outputDir = await _picker.pickOutputDirectory();
    await ref.read(batchControllerProvider.notifier).runAll(outputDir);
  }

  @override
  Widget build(BuildContext context) {
    final batch = ref.watch(batchControllerProvider);

    return Scaffold(
      appBar: SenseiAppBar(
        title: 'Batch Mode',
        actions: [
          if (batch.queue.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => ref.read(batchControllerProvider.notifier).clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Preset selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text('Preset for all:', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14)),
                const SizedBox(width: 12),
                DropdownButton<CompressionPreset>(
                  value: _preset,
                  dropdownColor: AppColors.darkSurface,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Satoshi'),
                  items: Presets.all
                      .where((p) => p.key != PresetKey.custom)
                      .map((p) => DropdownMenuItem(value: p, child: Text('${p.emoji} ${p.name}')))
                      .toList(),
                  onChanged: (p) {
                    if (p != null) setState(() => _preset = p);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Queue list
          Expanded(
            child: batch.queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_add_rounded, size: 56, color: AppColors.darkTextMuted),
                        const SizedBox(height: 16),
                        Text('No files added yet', style: TextStyle(color: AppColors.darkTextSecondary)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _addFiles, child: const Text('Add files')),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: batch.queue.length,
                    itemBuilder: (_, i) {
                      final item = batch.queue[i];
                      final statusColor = switch (item.status) {
                        BatchItemStatus.done => AppColors.accentGreen,
                        BatchItemStatus.failed => AppColors.error,
                        BatchItemStatus.running => AppColors.presetLiteCyan,
                        _ => AppColors.darkTextMuted,
                      };
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: item.status == BatchItemStatus.running
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.presetLiteCyan),
                                )
                              : Icon(
                                  _statusIcon(item.status),
                                  color: statusColor,
                                  size: 20,
                                ),
                          title: Text(
                            item.video.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: Colors.white),
                          ),
                          subtitle: Text(
                            '${SizeFormatter.format(item.video.size)}  •  ${item.preset.emoji} ${item.preset.name}',
                            style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                          ),
                          trailing: batch.isRunning
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  color: AppColors.darkTextMuted,
                                  onPressed: () =>
                                      ref.read(batchControllerProvider.notifier).removeAt(i),
                                ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!batch.isRunning) ...[
              if (batch.queue.isNotEmpty)
                Text(
                  '${batch.queue.length} file(s) — ${batch.pendingCount} pending',
                  style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addFiles,
                      icon: const Icon(Icons.add),
                      label: const Text('Add files'),
                    ),
                  ),
                  if (batch.queue.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: batch.pendingCount == 0 ? null : _runAll,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Run all'),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Text(
                'Processing ${batch.currentIndex + 1} / ${batch.queue.length}',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref.read(batchControllerProvider.notifier).cancel(),
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Cancel batch'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(BatchItemStatus status) => switch (status) {
        BatchItemStatus.done => Icons.check_circle_outline_rounded,
        BatchItemStatus.failed => Icons.error_outline_rounded,
        BatchItemStatus.cancelled => Icons.cancel_outlined,
        BatchItemStatus.running => Icons.pending_outlined,
        BatchItemStatus.pending => Icons.radio_button_unchecked_rounded,
      };
}
