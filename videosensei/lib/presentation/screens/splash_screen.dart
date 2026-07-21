import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_controller.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings == null || !settings.onboardingComplete) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated ASCII logo
            Text(
              '╱━━━━━━━╲\n╱  ┃█┃  ╲\n╱  ┃█┃  ╲\n╲  ┃█┃  ╱\n╲━━━━━╱',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                color: AppColors.accentGreen,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 28),
            Text(
              'VIDEOSENSEI',
              style: TextStyle(
                fontFamily: 'CabinetGrotesk',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Master your video. Sensei-grade clarity.',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                color: AppColors.darkTextSecondary,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentGreen,
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
