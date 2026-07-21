import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../domain/models/compression_result.dart';
import '../widgets/sensei_app_bar.dart';

class ResultScreen extends ConsumerWidget {
  final CompressionResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuccess = result.isSuccess;

    return Scaffold(
      appBar: SenseiAppBar(
        title: isSuccess ? 'Done!' : 'Failed',
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Status icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess ? AppColors.accentGreenMuted : AppColors.error.withOpacity(0.15),
              ),
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.error_outline_rounded,
                size: 40,
                color: isSuccess ? AppColors.accentGreen : AppColors.error,
              ),
            ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
          ),
          const SizedBox(height: 24),

          if (isSuccess) ...[
            // Size comparison
            Center(
              child: Column(
                children: [
                  Text('Compressed!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SizePill(
                        label: 'Before',
                        size: result.inputFile.size,
                        accent: AppColors.darkTextSecondary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward_rounded, color: AppColors.accentGreen),
                      ),
                      _SizePill(
                        label: 'After',
                        size: result.outputSize!,
                        accent: AppColors.accentGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Saved ${SizeFormatter.format(result.savedBytes!)}  (${SizeFormatter.reductionPercent(result.inputFile.size, result.outputSize!)})',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 28),

            // Output path
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(Icons.save_outlined, color: AppColors.accentGreen),
                title: Text('Saved to', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                subtitle: Text(
                  result.outputPath!,
                  style: const TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: Colors.white),
                  maxLines: 3,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.copy_rounded, color: AppColors.darkTextMuted, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result.outputPath!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Path copied')),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stats', style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: AppColors.darkTextMuted,
                      letterSpacing: 1,
                    )),
                    const SizedBox(height: 12),
                    _Row('Preset', '${result.preset.emoji} ${result.preset.name}'),
                    _Row('Codec', result.preset.codec.label),
                    if (result.encodingDuration != null)
                      _Row('Encode time', DurationFormatter.format(result.encodingDuration!)),
                    if (result.reductionRatio != null)
                      _Row('Reduction', '${(result.reductionRatio! * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            // FFmpeg command
            if (result.ffmpegCommand != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text('FFmpeg command', style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  color: AppColors.darkTextSecondary,
                )),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      result.ffmpegCommand!,
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
            ],
          ] else ...[
            // Error state
            Center(
              child: Text(
                result.errorMessage ?? 'Compression failed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 15),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Actions
          FilledButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/home', (r) => false,
            ),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Home'),
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/picker', (r) => r.settings.name == '/home',
            ),
            icon: const Icon(Icons.video_file_rounded),
            label: const Text('Compress another'),
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SizePill extends StatelessWidget {
  final String label;
  final int size;
  final Color accent;
  const _SizePill({required this.label, required this.size, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
        const SizedBox(height: 4),
        Text(SizeFormatter.format(size), style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: accent,
        )),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary)),
          Text(value, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
