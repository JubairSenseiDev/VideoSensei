import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/compression_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../domain/models/video_file.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_result.dart';
import '../widgets/progress_ring.dart';
import '../widgets/sensei_app_bar.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final VideoFile video;
  final CompressionPreset preset;
  final String outputPath;

  const ProcessingScreen({
    super.key,
    required this.video,
    required this.preset,
    required this.outputPath,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    await ref.read(compressionControllerProvider.notifier).compress(
          video: widget.video,
          preset: widget.preset,
          outputPath: widget.outputPath,
        );

    if (!mounted) return;
    final state = ref.read(compressionControllerProvider);
    if (state is CompressionDone) {
      Navigator.pushReplacementNamed(context, '/result', arguments: state.result);
    }
  }

  Future<void> _cancel() async {
    await ref.read(compressionControllerProvider.notifier).cancel();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compressionControllerProvider);
    final progress = state is CompressionRunning ? state.progress : null;
    final percent = progress?.percent ?? 0.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: SenseiAppBar(
          title: 'Compressing…',
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress ring
                ProgressRing(percent: percent)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 40),

                // File name
                Text(
                  widget.video.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.preset.emoji} ${widget.preset.name}',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats row
                if (progress != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBadge(
                        label: 'Speed',
                        value: progress.speed != null
                            ? '${progress.speed!.toStringAsFixed(2)}×'
                            : '—',
                      ),
                      const SizedBox(width: 16),
                      _StatBadge(
                        label: 'ETA',
                        value: progress.eta != null
                            ? DurationFormatter.format(progress.eta!)
                            : '—',
                      ),
                      const SizedBox(width: 16),
                      _StatBadge(
                        label: 'Elapsed',
                        value: progress.elapsed != null
                            ? DurationFormatter.format(progress.elapsed!)
                            : '—',
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  Text(
                    progress.currentTime ?? '',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: AppColors.darkTextMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                // Cancel button
                OutlinedButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(180, 48),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          color: AppColors.darkTextMuted,
        )),
      ],
    );
  }
}
