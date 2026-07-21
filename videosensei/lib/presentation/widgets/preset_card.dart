import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/strategy/size_predictor.dart';

class PresetCard extends StatelessWidget {
  final CompressionPreset preset;
  final bool isSelected;
  final SizePrediction? prediction;
  final VoidCallback onTap;

  const PresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
    this.prediction,
  });

  Color get _accentColor => switch (preset.key) {
        PresetKey.lite => AppColors.presetLiteCyan,
        PresetKey.balanced => AppColors.presetBalancedGreen,
        PresetKey.crystal => AppColors.presetCrystalBlue,
        PresetKey.sensei => AppColors.presetSenseiPurple,
        PresetKey.custom => AppColors.darkTextSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withOpacity(0.1) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.darkBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji + selection indicator
            Text(preset.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),

            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _accentColor : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.description,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.compatibility,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      color: AppColors.darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Codec chip + prediction
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CodecChip(label: preset.codec.label, color: _accentColor),
                if (prediction != null && isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    prediction!.reductionLabel,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? _accentColor : AppColors.darkBorder,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodecChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CodecChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
