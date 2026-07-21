# 📋 Phase 2 — Core Engine Summary

**Date**: 2026-07-21
**Status**: ✅ Complete
**Repo**: https://github.com/JubairSenseiDev/VideoSensei

---

## What was done

Phase 2 delivers the complete Flutter project for VideoSensei — all Dart application code,
unit tests, GitHub Actions CI, and English + Bengali localizations.

### Flutter project structure

The Flutter project lives at `videosensei/` in the repository root.

```
videosensei/
├── pubspec.yaml                      ← All dependencies declared
├── analysis_options.yaml             ← Strict lint rules
├── lib/
│   ├── main.dart                     ← App entry point + ProviderScope
│   ├── app.dart                      ← MaterialApp + named routing
│   ├── core/
│   │   ├── theme/app_theme.dart      ← Material 3 dark/light themes, AppColors, AppTypography
│   │   ├── constants/app_constants.dart
│   │   ├── utils/size_formatter.dart ← SizeFormatter, DurationFormatter
│   │   └── extensions/string_extensions.dart
│   ├── domain/                       ← Pure Dart, zero Flutter dependency
│   │   ├── models/                   ← CodecChoice, CompressionPreset, VideoFile, CompressionResult
│   │   ├── strategy/                 ← PresetStrategy, AutoStrategy, SizePredictor
│   │   └── exceptions/               ← CompressionError sealed hierarchy
│   ├── data/
│   │   ├── ffmpeg/                   ← FFmpegService (abstract + Android + Desktop), FFmpegParser, FFmpegInstaller
│   │   ├── filepicker/               ← FilePickerService
│   │   ├── storage/                  ← AppDatabase (Drift), HistoryRepository, SettingsRepository
│   │   └── platform/                 ← PlatformInfo
│   ├── application/                  ← Riverpod 2 controllers
│   │   ├── compression_controller.dart
│   │   ├── batch_controller.dart
│   │   ├── history_controller.dart
│   │   └── settings_controller.dart
│   ├── presentation/
│   │   ├── screens/                  ← 10 screens (Splash, Onboarding, Home, Picker, Configure, Processing, Result, History, Settings, Batch)
│   │   └── widgets/                  ← GlassCard, SenseiAppBar, PresetCard, ProgressRing
│   └── l10n/
│       ├── app_en.arb                ← Full English string set
│       └── app_bn.arb                ← Full Bengali string set
└── test/
    ├── domain/
    │   ├── preset_strategy_test.dart  ← FFmpeg args correctness for all presets
    │   ├── auto_strategy_test.dart    ← Smart mode decision tree
    │   └── size_predictor_test.dart   ← Pre-encode size estimation
    └── data/
        └── ffmpeg_parser_test.dart    ← stderr progress parsing
```

### Key decisions made

1. **Dual FFmpeg bridge**: Android uses `ffmpeg_kit_flutter_new`; Linux/Windows use
   bundled binary via `Process.start`. Unified behind `FFmpegService` abstract interface.

2. **FFmpeg installer strategy**: On desktop, tries system PATH first (user may already
   have ffmpeg installed), then falls back to extracting bundled binary from Flutter assets.

3. **Riverpod 2 sealed state**: `CompressionState` is a sealed class
   (`Idle / Probing / Running / Done / Failed`) — UI rebuilds are surgical, no polling.

4. **`PresetStrategy` is the single source of truth** for all FFmpeg argument generation.
   Every preset's command matches COMPRESSION.md exactly (hvc1 tag, Opus, faststart, metadata).

5. **`AutoStrategy` mirrors CLI logic**: Decision tree identical to the Node.js CLI's
   `recommendPreset()` — ensures consistent behavior across CLI and GUI.

6. **`SizePredictor` codec factors**: H.264 = 0.60×, H.265 = 0.50×, AV1 = 0.35× —
   matches the JavaScript CLI implementation.

7. **Drift for history**: Drift over Hive for history because it supports SQL queries
   (date range, search, count) without custom indexes. Hive deferred to Phase 3 evaluation.

8. **Bengali localization from day 1**: `app_bn.arb` is fully populated — no English
   fallbacks. The app is bilingual at launch, honoring the Jubair Sensei Bangla community.

9. **`ProgressRing` custom painter**: Draws track + glow + arc natively in Canvas — no
   external package dependency for the key animation on the processing screen.

---

## What is NOT done yet (Phase 3)

- ❌ Platform scaffold (`android/`, `linux/`, `windows/` dirs — needs `flutter create`)
- ❌ Hero transitions and shared element animations
- ❌ Before/after video preview (`media_kit`)
- ❌ Drag-and-drop (desktop)
- ❌ Custom preset CRF slider UI
- ❌ Localization wiring (ARB strings currently hardcoded in widgets — Phase 3)
- ❌ Loading shimmers

---

## How to run Phase 2 on a Flutter machine

```bash
# 1. Clone the repo
git clone https://github.com/JubairSenseiDev/VideoSensei.git
cd VideoSensei/videosensei

# 2. Generate platform scaffold (one-time, needs Flutter installed)
flutter create --platforms=android,linux,windows .

# 3. Install dependencies + run codegen
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 4. Run tests
flutter test

# 5. Run on a device
flutter run
```

---

## Open questions for Phase 3

1. **AV1 encode time on mid-range Android** — show warning dialog before starting Sensei preset?
2. **Localization wiring** — use `AppLocalizations` generated from ARBs, or keep hardcoded strings for now?
3. **media_kit for preview** — add as Phase 3 dependency or defer to Phase 4?
4. **Custom preset UI** — full slider sheet or inline expansion in `ConfigureScreen`?
5. **History search** — simple `ListView` filter or Drift SQL `LIKE` query?
