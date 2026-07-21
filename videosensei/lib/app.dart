import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'application/settings_controller.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/picker_screen.dart';
import 'presentation/screens/configure_screen.dart';
import 'presentation/screens/processing_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/batch_screen.dart';
import 'domain/models/video_file.dart';
import 'domain/models/compression_preset.dart';
import 'domain/models/compression_result.dart';

class VideoSenseiApp extends ConsumerWidget {
  const VideoSenseiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final themeMode = settings.valueOrNull?.themeMode ?? ThemeMode.dark;

    return MaterialApp(
      title: 'VideoSensei',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/picker':
        return MaterialPageRoute(builder: (_) => const PickerScreen());
      case '/configure':
        final video = settings.arguments as VideoFile;
        return MaterialPageRoute(
          builder: (_) => ConfigureScreen(video: video),
        );
      case '/processing':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            video: args['video'] as VideoFile,
            preset: args['preset'] as CompressionPreset,
            outputPath: args['outputPath'] as String,
          ),
        );
      case '/result':
        final result = settings.arguments as CompressionResult;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        );
      case '/history':
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/batch':
        return MaterialPageRoute(builder: (_) => const BatchScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
