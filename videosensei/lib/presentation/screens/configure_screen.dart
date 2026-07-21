import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../data/filepicker/file_picker_service.dart';
import '../../domain/models/video_file.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/strategy/auto_strategy.dart';
import '../../domain/strategy/size_predictor.dart';
import '../widgets/preset_card.dart';
import '../widgets/sensei_app_bar.dart';

class ConfigureScreen extends ConsumerStatefulWidget {
  final VideoFile video;
  const ConfigureScreen({super.key, required this.video});

  @override
  ConsumerState<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends ConsumerState<ConfigureScreen> {
  final _autoStrategy = const AutoStrategy();
  final _sizePredictor = const SizePredictor();
  final _picker = const FilePickerService();

  late CompressionPreset _selected;
  String? _customOutputDir;

  @override
  void initState() {
    super.initState();
    // Auto-recommend preset based on video metadata
    final meta = widget.video.metadata;
    if (meta != null) {
      final key = _autoStrategy.recommend(meta) ?? PresetKey.balanced;
      _selected = Presets.byKey(key);
    } else {
      _selected = Presets.balanced;
    }
  }

  Future<void> _pickOutputDir() async {
    final dir = await _picker.pickOutputDirectory();
    if (dir != null) setState(() => _customOutputDir = dir);
  }

  void _compress() {
    final outputPath = _picker.buildOutputPath(
      widget.video.path,
      outputDir: _customOutputDir,
    );
    Navigator.pushNamed(
      context,
      '/processing',
      arguments: {
        'video': widget.video,
        'preset': _selected,
        'outputPath': outputPath,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.video.metadata;
    final prediction = _sizePredictor.predict(
      video: widget.video,
      preset: _selected,
    );

    return Scaffold(
      appBar: SenseiAppBar(title: widget.video.name),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Video info card
          if (meta != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Source', style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: AppColors.darkTextMuted,
                      letterSpacing: 1,
                    )),
                    const SizedBox(height: 10),
                    _InfoRow('Size', SizeFormatter.format(widget.video.size)),
                    _InfoRow('Resolution', '${meta.resolution} (${meta.resolutionLabel})'),
                    _InfoRow('Codec', meta.codec.toUpperCase()),
                    _InfoRow('Duration', DurationFormatter.formatSeconds(meta.duration)),
                    _InfoRow('Bitrate', '${(meta.bitrate / 1000).round()} kbps'),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),
          ],

          // Smart recommendation badge
          if (meta != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreenMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sensei recommends: ${_selected.emoji} ${_selected.name} — ${_autoStrategy.explain(meta, _selected.key)}',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 20),
          ],

          // Preset selection
          Text('Choose a preset', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
          )),
          const SizedBox(height: 12),
          ...Presets.all.map(
            (preset) => PresetCard(
              preset: preset,
              isSelected: _selected.key == preset.key,
              prediction: prediction,
              onTap: () => setState(() => _selected = preset),
            ).animate().fadeIn(delay: Duration(milliseconds: 200 + Presets.all.indexOf(preset) * 60)),
          ),
          const SizedBox(height: 24),

          // Output dir
          Card(
            child: ListTile(
              leading: Icon(Icons.folder_outlined, color: AppColors.accentGreen),
              title: Text(
                _customOutputDir ?? 'Same folder as input',
                style: const TextStyle(fontFamily: 'Satoshi', fontSize: 14, color: Colors.white),
              ),
              subtitle: Text('Output directory', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
              trailing: Icon(Icons.edit_outlined, color: AppColors.darkTextMuted, size: 18),
              onTap: _pickOutputDir,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),

          // Size prediction badge
          if (prediction != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated output', style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    color: AppColors.darkTextSecondary,
                  )),
                  Row(
                    children: [
                      Text(SizeFormatter.format(prediction.predictedBytes), style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreenMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(prediction.reductionLabel, style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w600,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _compress,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start compression'),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary)),
          Text(value, style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 13,
            color: Colors.white,
          )),
        ],
      ),
    );
  }
}
