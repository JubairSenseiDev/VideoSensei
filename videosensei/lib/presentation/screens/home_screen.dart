import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/history_controller.dart';
import '../../application/compression_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensei_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: SenseiAppBar(
        title: 'VideoSensei',
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Greeting
          Text(
            'Hello, Sensei. 🥋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            'Ready to compress?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          // Primary CTA
          GlassCard(
            onTap: () => Navigator.pushNamed(context, '/picker'),
            child: Column(
              children: [
                Icon(Icons.folder_open_rounded,
                    size: 48, color: AppColors.accentGreen),
                const SizedBox(height: 16),
                Text(
                  'Pick a video',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'From file manager or drag and drop',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Browse files',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBg,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Batch shortcut
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/batch'),
            icon: const Icon(Icons.playlist_add_rounded),
            label: const Text('Batch mode — multiple files'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkTextSecondary,
              side: BorderSide(color: AppColors.darkBorder),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),

          // Recent history section
          if (history.hasValue && history.value!.isNotEmpty) ...[
            Text(
              'Recent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 12),
            ...history.value!.take(5).map((entry) => _HistoryTile(entry: entry)),
          ],
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final saved = (entry.inputSize - (entry.outputSize ?? entry.inputSize));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: entry.status == 'success'
                ? AppColors.accentGreenMuted
                : AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            entry.status == 'success'
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: entry.status == 'success'
                ? AppColors.accentGreen
                : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          entry.inputName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: entry.status == 'success' && entry.outputSize != null
            ? Text(
                '${SizeFormatter.format(entry.inputSize)} → ${SizeFormatter.format(entry.outputSize!)}  (${SizeFormatter.reductionPercent(entry.inputSize, entry.outputSize!)})',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: AppColors.accentGreen,
                ),
              )
            : Text(
                entry.status,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextMuted,
                ),
              ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.darkTextMuted),
      ),
    );
  }
}
