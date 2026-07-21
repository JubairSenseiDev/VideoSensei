import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../widgets/sensei_app_bar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: SenseiAppBar(
        title: 'History',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  title: const Text('Clear history?', style: TextStyle(color: Colors.white)),
                  content: const Text('This will remove all compression history.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(historyControllerProvider.notifier).clearAll();
              }
            },
          ),
        ],
      ),
      body: history.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.darkTextMuted),
                  const SizedBox(height: 16),
                  Text('No compression history yet.', style: TextStyle(color: AppColors.darkTextSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final entry = entries[i];
              final isSuccess = entry.status == 'success';
              return Dismissible(
                key: Key(entry.id.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    ref.read(historyControllerProvider.notifier).delete(entry.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSuccess ? AppColors.accentGreenMuted : AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_rounded : Icons.close_rounded,
                        color: isSuccess ? AppColors.accentGreen : AppColors.error,
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
                    subtitle: isSuccess && entry.outputSize != null
                        ? Text(
                            SizeFormatter.summarize(entry.inputSize, entry.outputSize!),
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              color: AppColors.accentGreen,
                            ),
                          )
                        : Text(
                            entry.errorMessage ?? entry.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                    trailing: Text(
                      _formatDate(entry.createdAt),
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        color: AppColors.darkTextMuted,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 40)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
