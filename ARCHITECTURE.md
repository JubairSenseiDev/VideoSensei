# 🏗️ VideoSensei — Architecture

This document describes the technical architecture of VideoSensei.

---

## 1. High-Level Design

VideoSensei follows a **clean layered architecture**:

```
┌──────────────────────────────────────────────────────────┐
│                     Presentation Layer                    │
│  (Flutter widgets, screens, animations, theming)         │
└──────────────────────────────────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│                      Application Layer                   │
│  (Riverpod providers, controllers, view models)          │
└──────────────────────────────────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│                        Domain Layer                      │
│  (Pure Dart: compression strategy, presets, models)      │
└──────────────────────────────────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│                     Infrastructure Layer                 │
│  (FFmpeg bridge, file IO, storage, platform channels)    │
└──────────────────────────────────────────────────────────┘
```

**Why layered?** Domain logic (compression strategy) stays pure Dart — testable in
isolation, no Flutter dependency. UI can swap out without touching business rules.

---

## 2. Module Layout (Flutter project)

```
videosensei/
├── lib/
│   ├── main.dart                      # App entry, theme setup
│   ├── app.dart                       # MaterialApp, routing
│   │
│   ├── core/                          # Cross-cutting concerns
│   │   ├── theme/                     # Material 3 themes, colors, typography
│   │   ├── constants/                 # App-wide constants
│   │   ├── utils/                     # Helpers (size formatting, etc.)
│   │   └── extensions/                # Dart extensions
│   │
│   ├── data/                          # Infrastructure layer
│   │   ├── ffmpeg/
│   │   │   ├── ffmpeg_service.dart        # FFmpeg bridge (process exec)
│   │   │   ├── ffmpeg_parser.dart         # Parse stderr → progress %
│   │   │   └── ffmpeg_installer.dart      # Bundle/path resolution
│   │   ├── filepicker/
│   │   │   └── file_picker_service.dart   # Native picker wrapper
│   │   ├── storage/
│   │   │   ├── history_repository.dart    # Past operations (Drift/Hive)
│   │   │   └── settings_repository.dart   # User prefs
│   │   └── platform/
│   │       └── platform_info.dart         # Android/Linux/Windows detect
│   │
│   ├── domain/                        # Pure Dart business logic
│   │   ├── models/
│   │   │   ├── video_file.dart            # Input video metadata
│   │   │   ├── compression_preset.dart    # Lite/Balanced/Crystal/Sensei/Custom
│   │   │   ├── compression_result.dart    # Output + stats
│   │   │   └── codec_choice.dart          # H.264/H.265/AV1 enum
│   │   ├── strategy/
│   │   │   ├── preset_strategy.dart       # Preset → FFmpeg args mapping
│   │   │   ├── auto_strategy.dart         # Smart mode: pick best preset
│   │   │   └── size_predictor.dart        # Pre-encode size estimation
│   │   └── exceptions/
│   │       └── compression_error.dart
│   │
│   ├── application/                   # Riverpod providers / controllers
│   │   ├── compression_controller.dart    # Orchestrates compress flow
│   │   ├── batch_controller.dart          # Batch queue management
│   │   ├── history_controller.dart
│   │   └── settings_controller.dart
│   │
│   ├── presentation/                  # UI layer
│   │   ├── screens/
│   │   │   ├── home_screen.dart           # Dashboard, recent files
│   │   │   ├── picker_screen.dart         # File selection
│   │   │   ├── configure_screen.dart      # Preset & options
│   │   │   ├── processing_screen.dart     # Live progress UI
│   │   │   ├── result_screen.dart         # Before/after, save/share
│   │   │   ├── batch_screen.dart          # Batch queue manager
│   │   │   ├── history_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/                       # Reusable components
│   │   │   ├── sensei_app_bar.dart
│   │   │   ├── preset_card.dart
│   │   │   ├── progress_ring.dart
│   │   │   ├── size_comparison_badge.dart
│   │   │   ├── glass_card.dart            # Glassmorphism container
│   │   │   └── codec_chip.dart
│   │   └── animations/
│   │       ├── hero_transitions.dart
│   │       └── shimmer_loaders.dart
│   │
│   └── l10n/                          # Bengali + English localizations
│
├── assets/
│   ├── ffmpeg/                        # Bundled FFmpeg binaries per platform
│   │   ├── android/arm64-v8a/
│   │   ├── linux/x64/
│   │   └── windows/x64/
│   ├── fonts/
│   ├── icons/
│   └── images/
│
├── android/                           # Android-specific (Gradle, manifest)
├── linux/                             # Linux-specific (CMake, .desktop)
├── windows/                           # Windows-specific (CMake, .exe runner)
├── test/                              # Unit + widget tests
├── integration_test/                  # E2E tests with real FFmpeg
└── docs/                              # This documentation
```

---

## 3. Compression Pipeline (data flow)

```
User picks file (file_picker)
        │
        ▼
┌─────────────────────┐
│ Probe with ffprobe  │  ← extract: codec, resolution, bitrate, duration, fps
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ Run auto-strategy   │  ← analyze motion / complexity → recommend preset
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ Predict output size │  ← bitrate × duration × codec factor
└─────────────────────┘
        │
        ▼
   User confirms preset
        │
        ▼
┌─────────────────────┐
│ Build FFmpeg args   │  ← preset → codec + CRF + preset + audio
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ Spawn FFmpeg process│  ← stream stderr → parser → progress %
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ Verify output       │  ← ffprobe output file, compare sizes
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ Save to history     │  ← Drift/Hive record with all stats
└─────────────────────┘
        │
        ▼
   Show result screen (before/after preview)
```

---

## 4. FFmpeg Integration Strategy

### 4.1 Per-Platform Bundling

| Platform | Strategy                                          | Binary size |
| -------- | ------------------------------------------------- | ----------- |
| Android  | `ffmpeg_kit_flutter_new` (min-gpl, arm64+arm32)  | ~25 MB      |
| Linux    | Bundle static `ffmpeg` binary in `assets/ffmpeg/` | ~15 MB      |
| Windows  | Bundle `ffmpeg.exe` in `assets/ffmpeg/`           | ~20 MB      |
| macOS    | (future) Bundle static binary                     | ~15 MB      |

### 4.2 Why bundle (not system FFmpeg)?

- **Zero setup** — user installs app, it just works
- **Version consistency** — we control exactly which codecs/features are available
- **No PATH issues** — common Windows pain point eliminated
- **Trade-off**: Larger app size, but worth it for UX

### 4.3 FFmpeg Bridge API

```dart
abstract class FFmpegService {
  Future<VideoMetadata> probe(String path);
  Stream<CompressionProgress> compress({
    required String input,
    required String output,
    required CompressionPreset preset,
  });
  Future<CompressionResult> verify(String outputPath);
  Future<void> cancel();
}
```

- `compress()` returns a `Stream<CompressionProgress>` — UI subscribes for live %
- Stderr parsing extracts `frame=`, `time=`, `bitrate=`, `speed=` lines
- Cancel kills the process via PID

---

## 5. State Management — Riverpod 2

Chosen over BLoC/Provider for:
- Compile-safe (no runtime ProviderNotFoundException)
- Testable without boilerplate
- Async providers built-in (perfect for FFmpeg streams)
- DevTools integration

Key providers:
- `compressionControllerProvider` — Notifier that wraps FFmpeg service
- `historyProvider` — Future provider reading from Drift
- `settingsProvider` — Notifier for user prefs
- `batchQueueProvider` — Notifier managing batch state

---

## 6. Theming System

Material 3 with custom `ColorScheme.fromSeed()`:
- Seed: `#1E1B4B` (deep indigo)
- Primary: `#4F46E5`
- Secondary: `#06B6D4` (neon cyan)
- Surface: dynamic — glassmorphism on dark, paper on light

Typography:
- Headlines: Inter / SF Pro Display
- Body: Inter
- Stats/numbers: JetBrains Mono (tabular)

See `BRANDING.md` for full design system.

---

## 7. Testing Strategy

| Layer        | Type              | Tool                          |
| ------------ | ----------------- | ----------------------------- |
| Domain       | Unit tests        | `package:test`                |
| Application  | Provider tests    | `riverpod` test utils         |
| Presentation | Widget tests      | `flutter_test`                |
| E2E          | Integration tests | `integration_test` + real FFmpeg |
| Performance  | Benchmark         | `flutter drive`               |

Target coverage: **80%+ for domain layer** (compression strategy is critical).

---

## 8. Platform-Specific Considerations

### Android
- `minSdkVersion`: 24 (Android 7.0) — covers 95%+ devices
- `targetSdkVersion`: 35 (Android 15)
- Storage access via SAF (Storage Access Framework) — no more `/sdcard` hack
- `MediaStore` API for output to gallery
- Permissions: `READ_MEDIA_VIDEO`, no `WRITE_EXTERNAL_STORAGE` needed

### Linux
- Target: Ubuntu 22.04+, Fedora 38+, Debian 12+
- Distribution: `.deb` + AppImage + Flatpak (later)
- Desktop integration: `.desktop` file with MimeType registration
- File picker: GTK via `file_picker` Linux plugin

### Windows
- Target: Windows 10 1809+ (64-bit)
- Distribution: NSIS installer + portable `.zip`
- File picker: Windows common dialog via `file_picker`
- Hardware accel: NVENC detection at runtime

---

## 9. CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/build.yml
on: [push, pull_request, tag]
jobs:
  build-android:    # → APK (arm64-v8a) uploaded to releases
  build-linux:      # → .deb + AppImage
  build-windows:    # → .exe NSIS installer
  test:             # → unit + widget tests
  analyze:          # → flutter analyze (lint)
```

Releases auto-published on `v*.*.*` tags.
