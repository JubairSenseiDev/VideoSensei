import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/compression_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../data/filepicker/file_picker_service.dart';
import '../../domain/models/video_file.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensei_app_bar.dart';

class PickerScreen extends ConsumerStatefulWidget {
  const PickerScreen({super.key});

  @override
  ConsumerState<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends ConsumerState<PickerScreen> {
  final _picker = const FilePickerService();
  bool _loading = false;

  Future<void> _pick() async {
    setState(() => _loading = true);
    try {
      final video = await _picker.pickSingleVideo();
      if (video == null || !mounted) return;

      // Probe metadata
      final controller = ref.read(compressionControllerProvider.notifier);
      final probed = await controller.probe(video);
      if (!mounted) return;

      Navigator.pushNamed(context, '/configure', arguments: probed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SenseiAppBar(title: 'Pick a Video'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Drop zone
          GlassCard(
            onTap: _loading ? null : _pick,
            child: _loading
                ? Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Reading video...',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(Icons.video_file_rounded,
                          size: 56, color: AppColors.accentGreen),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to browse',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'MP4, MKV, MOV, AVI, WebM, and more',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
          // Supported formats
          Text(
            'Supported formats',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'MP4', 'MKV', 'MOV', 'AVI', 'WebM', 'FLV', 'M4V', 'WMV', 'TS',
            ]
                .map(
                  (ext) => Chip(
                    label: Text(
                      ext,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    backgroundColor: AppColors.darkSurface,
                    side: BorderSide(color: AppColors.darkBorder),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
