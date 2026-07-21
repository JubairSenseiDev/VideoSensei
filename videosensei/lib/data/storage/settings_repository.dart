import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool onboardingComplete;
  final String defaultPresetKey;
  final String? defaultOutputDir;
  final int historyRetentionDays;
  final bool showFfmpegCommand;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.onboardingComplete = false,
    this.defaultPresetKey = 'balanced',
    this.defaultOutputDir,
    this.historyRetentionDays = AppConstants.historyDefaultRetentionDays,
    this.showFfmpegCommand = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? onboardingComplete,
    String? defaultPresetKey,
    String? defaultOutputDir,
    int? historyRetentionDays,
    bool? showFfmpegCommand,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      defaultPresetKey: defaultPresetKey ?? this.defaultPresetKey,
      defaultOutputDir: defaultOutputDir ?? this.defaultOutputDir,
      historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
      showFfmpegCommand: showFfmpegCommand ?? this.showFfmpegCommand,
    );
  }
}

class SettingsRepository {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  AppSettings load() {
    final themeName = _prefs.getString('theme_mode') ?? 'dark';
    return AppSettings(
      themeMode: _parseThemeMode(themeName),
      onboardingComplete:
          _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false,
      defaultPresetKey: _prefs.getString('default_preset') ?? 'balanced',
      defaultOutputDir: _prefs.getString('default_output_dir'),
      historyRetentionDays: _prefs.getInt('history_retention_days') ??
          AppConstants.historyDefaultRetentionDays,
      showFfmpegCommand: _prefs.getBool('show_ffmpeg_command') ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _prefs.setString('theme_mode', _themeModeToString(settings.themeMode)),
      _prefs.setBool(
          AppConstants.onboardingCompleteKey, settings.onboardingComplete),
      _prefs.setString('default_preset', settings.defaultPresetKey),
      if (settings.defaultOutputDir != null)
        _prefs.setString('default_output_dir', settings.defaultOutputDir!)
      else
        _prefs.remove('default_output_dir'),
      _prefs.setInt(
          'history_retention_days', settings.historyRetentionDays),
      _prefs.setBool('show_ffmpeg_command', settings.showFfmpegCommand),
    ]);
  }

  ThemeMode _parseThemeMode(String value) => switch (value) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };

  String _themeModeToString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
        _ => 'dark',
      };
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);
