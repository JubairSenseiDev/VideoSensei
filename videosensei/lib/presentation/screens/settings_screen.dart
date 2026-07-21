import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/settings_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/filepicker/file_picker_service.dart';
import '../../domain/models/compression_preset.dart';
import '../widgets/sensei_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final s = settings.valueOrNull;
    if (s == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: const SenseiAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme', style: TextStyle(color: Colors.white)),
                  trailing: DropdownButton<ThemeMode>(
                    value: s.themeMode,
                    dropdownColor: AppColors.darkSurface,
                    underline: const SizedBox.shrink(),
                    style: TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Satoshi'),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    ],
                    onChanged: (mode) => ref
                        .read(settingsControllerProvider.notifier)
                        .update((s) => s.copyWith(themeMode: mode)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Compression ─────────────────────────────────────────────────
          _SectionHeader('Compression'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Default preset', style: TextStyle(color: Colors.white)),
                  trailing: DropdownButton<String>(
                    value: s.defaultPresetKey,
                    dropdownColor: AppColors.darkSurface,
                    underline: const SizedBox.shrink(),
                    style: TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Satoshi'),
                    items: Presets.all
                        .where((p) => p.key != PresetKey.custom)
                        .map((p) => DropdownMenuItem(
                              value: p.key.name,
                              child: Text('${p.emoji} ${p.name}'),
                            ))
                        .toList(),
                    onChanged: (key) => ref
                        .read(settingsControllerProvider.notifier)
                        .update((s) => s.copyWith(defaultPresetKey: key)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Output directory', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    s.defaultOutputDir ?? 'Same as input',
                    style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
                  ),
                  trailing: Icon(Icons.edit_outlined, color: AppColors.darkTextMuted, size: 18),
                  onTap: () async {
                    final dir = await const FilePickerService().pickOutputDirectory();
                    if (dir != null) {
                      ref.read(settingsControllerProvider.notifier)
                          .update((s) => s.copyWith(defaultOutputDir: dir));
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: s.showFfmpegCommand,
                  onChanged: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .update((s) => s.copyWith(showFfmpegCommand: v)),
                  title: const Text('Show FFmpeg command', style: TextStyle(color: Colors.white)),
                  subtitle: Text('In result screen', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                  activeColor: AppColors.accentGreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── History ─────────────────────────────────────────────────────
          _SectionHeader('History'),
          Card(
            child: ListTile(
              title: const Text('Retention', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<int>(
                value: s.historyRetentionDays,
                dropdownColor: AppColors.darkSurface,
                underline: const SizedBox.shrink(),
                style: TextStyle(color: AppColors.darkTextSecondary, fontFamily: 'Satoshi'),
                items: [30, 90, 180, 365]
                    .map((d) => DropdownMenuItem(value: d, child: Text('$d days')))
                    .toList(),
                onChanged: (days) => ref
                    .read(settingsControllerProvider.notifier)
                    .update((s) => s.copyWith(historyRetentionDays: days)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── About ───────────────────────────────────────────────────────
          _SectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Text('🥋', style: const TextStyle(fontSize: 24)),
                  title: const Text('VideoSensei', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text('v${AppConstants.appVersion} — ${AppConstants.tagline}',
                      style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.open_in_new_rounded, color: AppColors.darkTextMuted),
                  title: const Text('jubairsensei.com', style: TextStyle(color: Colors.white)),
                  subtitle: Text('by Jubair Sensei', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                  onTap: () => launchUrl(Uri.parse(AppConstants.authorUrl)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code_rounded, color: AppColors.darkTextMuted),
                  title: const Text('GitHub', style: TextStyle(color: Colors.white)),
                  subtitle: Text('View source', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                  onTap: () => launchUrl(Uri.parse(AppConstants.repoUrl)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          color: AppColors.darkTextMuted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
