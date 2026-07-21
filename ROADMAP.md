# 🧭 VideoSensei — Roadmap

This is the phased delivery plan for VideoSensei v1.0.0 and beyond.
Each phase has a clear definition of done.

---

## Phase 1 — Foundation ✅

**Goal**: Establish the project, branding, architecture, and planning.

**Deliverables**:
- [x] New GitHub account `JubairSenseiDev`
- [x] New repo `VideoSensei` created
- [x] Tech stack decided (Flutter + FFmpeg)
- [x] Branding guide (`BRANDING.md`)
- [x] Architecture document (`ARCHITECTURE.md`)
- [x] Feature matrix (`FEATURES.md`)
- [x] Compression strategy (`COMPRESSION.md`)
- [x] UI mockups document (`docs/ui-mockups.md`)
- [x] Codec strategy document (`docs/codec-strategy.md`)
- [x] This roadmap (`ROADMAP.md`)
- [x] MIT license
- [x] `.gitignore` for Flutter + Dart

**Definition of done**: All planning docs committed to `main`, README accurately reflects
the project, anyone reading the repo can understand what we're building.

---

## Phase 2 — Core Engine ✅

**Goal**: Build the compression pipeline as a runnable Flutter project (CLI-quality, no UI polish yet).

**Started**: 2026-07-21
**Completed**: 2026-07-21

**Deliverables**:
- [x] Flutter project scaffold at `videosensei/` with `pubspec.yaml` and all dependencies
- [x] Directory structure per `ARCHITECTURE.md`
- [x] Dependencies declared: `ffmpeg_kit_flutter_new`, `file_picker`, `riverpod`, `drift`, `flutter_animate`, `google_fonts`
- [x] **Domain layer** (pure Dart, platform-independent):
  - [x] `CodecChoice` enum — H.264 / H.265 / AV1 with metadata
  - [x] `CompressionPreset` model + `Presets` catalogue (Lite / Balanced / Crystal / Sensei / Custom)
  - [x] `VideoFile` / `VideoMetadata` models (with JSON factory)
  - [x] `CompressionResult` / `CompressionProgress` models (sealed status)
  - [x] `PresetStrategy` — preset → FFmpeg args mapping (all 5 presets, hvc1 tag, Opus, faststart)
  - [x] `SizePredictor` — pre-encode size estimation with codec + CRF factors
  - [x] `AutoStrategy` — smart mode: recommend preset from video metadata
  - [x] `CompressionError` sealed class hierarchy (7 error types)
- [x] **Data layer**:
  - [x] `FFmpegService` abstract interface
  - [x] `FFmpegServiceAndroid` — via `ffmpeg_kit_flutter_new`
  - [x] `FFmpegServiceDesktop` — via bundled binary (`Process.start`)
  - [x] `FFmpegParser` — stderr → `CompressionProgress` stream (frame/time/speed parsing)
  - [x] `FFmpegInstaller` — system PATH lookup → bundled asset extraction fallback
  - [x] `FilePickerService` — single / multi / folder picking + output path builder
  - [x] `AppDatabase` (Drift) — history schema with `HistoryEntries` table
  - [x] `HistoryRepository` — insert / getAll / deleteById / clearAll
  - [x] `SettingsRepository` — SharedPreferences-backed `AppSettings`
  - [x] `PlatformInfo` — Android / Linux / Windows detection
- [x] **Application layer** (Riverpod 2 providers):
  - [x] `CompressionController` — orchestrates probe → compress → persist pipeline
  - [x] `BatchController` — queue management with per-item status
  - [x] `HistoryController` — async notifier over `HistoryRepository`
  - [x] `SettingsController` — async notifier over `SettingsRepository`
- [x] **Presentation layer** (complete screen set):
  - [x] `SplashScreen` — animated ASCII logo, auto-advance
  - [x] `OnboardingScreen` — 3-screen PageView with dot indicator
  - [x] `HomeScreen` — greeting, primary CTA card, recent history tiles
  - [x] `PickerScreen` — file picker integration, loading state, format chips
  - [x] `ConfigureScreen` — video info card, smart recommendation badge, 5 preset cards with size prediction, output dir picker, CTA
  - [x] `ProcessingScreen` — live progress ring, stats (speed / ETA / elapsed), cancel button
  - [x] `ResultScreen` — before/after size pills, saved badge, stats card, FFmpeg command expander, share actions
  - [x] `HistoryScreen` — swipe-to-delete list, clear-all dialog
  - [x] `SettingsScreen` — theme, default preset, output dir, retention, about section
  - [x] `BatchScreen` — multi-file queue, per-preset override, run-all, cancel
- [x] **Widgets**: `GlassCard`, `SenseiAppBar`, `PresetCard`, `ProgressRing`, `GlassCard`
- [x] **Core**: `AppTheme` (Material 3, dark/light), `AppColors`, `AppTypography`, `SizeFormatter`, `DurationFormatter`, `StringExtensions`, `AppConstants`
- [x] **Localization**: English (`app_en.arb`) + Bengali (`app_bn.arb`) — full string coverage
- [x] **Unit tests** (domain layer — 80%+ coverage target):
  - [x] `preset_strategy_test.dart` — all 5 presets, args correctness, hvc1, Opus
  - [x] `auto_strategy_test.dart` — 8 decision-tree cases
  - [x] `size_predictor_test.dart` — 7 prediction correctness cases
  - [x] `ffmpeg_parser_test.dart` — 5 stderr parsing cases
- [x] **GitHub Actions CI/CD** (`.github/workflows/build.yml`):
  - [x] `test` job — analyze + test on every push/PR
  - [x] `build-android` — APK (arm64-v8a) on main/release
  - [x] `build-linux` — tar.gz bundle on main/release
  - [x] `build-windows` — zip bundle on main/release
  - [x] Auto-attach artifacts to GitHub Releases on `v*.*.*` tags

**Definition of done**: Full Flutter project with all Dart code written and tested.
Domain layer has comprehensive unit tests. Full screen set covers the entire user flow
from onboarding → pick → configure → compress → result → history.
GitHub Actions CI validates on every push.

> ⚠️ **Platform scaffold note**: The `android/`, `linux/`, `windows/` directories
> need to be generated by running `flutter create --platforms=android,linux,windows .`
> inside `videosensei/` on a machine with Flutter installed.
> All Dart application code is complete and tested.

---

## Phase 3 — Modern UI / UX ⏳

**Goal**: Build the 2026-style Material 3 UI on top of the working engine.

**Deliverables**:
- [ ] Polish animations — hero transitions, staggered lists, shimmer loaders
- [ ] Glassmorphism refinements — per-screen backdrop blur tuning
- [ ] Before/after video preview (side-by-side scrub using `media_kit`)
- [ ] Drag-and-drop on desktop (file drop zones)
- [ ] Folder picker for batch (recursive scan)
- [ ] Custom CRF slider + codec picker in Custom preset screen
- [ ] Onboarding re-entry from Settings
- [ ] Localization wiring (use ARB strings throughout UI, currently hardcoded)
- [ ] Loading shimmers for async data (history, metadata probing)

**Definition of done**: App looks and feels like a 2026 product. Navigating the full flow
(pick → configure → process → result) is smooth, animated, and intuitive. No placeholder text.

**Estimated effort**: 4–6 focused sessions.

---

## Phase 4 — Platform Builds & Integration 🟡 (CI scaffolding done; native integration pending)

**Goal**: Produce installable artifacts for Android, Linux, Windows, macOS, and Web.

**Deliverables**:
- [x] **GitHub Actions CI/CD matrix** — see `.github/workflows/build.yml`:
  - [x] On push/PR: `flutter analyze` + `flutter test`
  - [x] On tag `v*.*.*`: build all platforms, upload to Releases
  - [x] Auto-generates Flutter platform scaffolds inside the runner (`flutter create --platforms=...`)
  - [x] Runs Drift codegen (`dart run build_runner`) before tests + builds
  - [x] Runs `flutter gen-l10n` so ARB strings are wired
- [x] **Android**:
  - [x] APK for `arm64-v8a`, `armeabi-v7a`, `x86_64` (split-per-ABI)
  - [x] Universal APK
  - [x] App Bundle (.aab) for Play Store submission
  - [ ] Adaptive app icon (foreground + background)
  - [ ] `WRITE_MEDIA_VIDEO` permission via `MediaStore`
  - [ ] Foreground service for long-running encodes
  - [ ] Notification with progress + cancel action
  - [ ] Share-to-app intent filter (receive video from other apps)
  - [ ] Share-from-app (send result via share sheet)
  - [ ] Signed release APK (currently unsigned debug-signed)
- [x] **Linux**:
  - [x] tar.gz bundle (x64 + arm64)
  - [x] `.deb` package (x64) with `.desktop` + MimeType + hicolor icon
  - [ ] AppImage build
  - [ ] hicolor icons (16/32/48/64/128/256/512) — only 256 currently
- [x] **Windows**:
  - [x] zip bundle (x64)
  - [ ] MSIX or NSIS installer
  - [ ] File association (.mp4, .mkv, .mov)
  - [ ] Start menu shortcut
  - [ ] Code-signed `.exe` (if cert available; self-signed otherwise)
- [x] **macOS**:
  - [x] universal `.zip` (Intel + Apple Silicon)
  - [ ] `.dmg` (using `create-dmg` action; currently zip-only)
  - [ ] Code-signed + notarized (needs Apple Developer cert)
- [x] **Web**:
  - [x] Web tar.gz bundle (PWA-ready)
  - [x] GitHub Pages auto-deploy on tag (`peaceiris/actions-gh-pages`)
- [x] **Termux** — `.github/workflows/termux-build.yml` + `TERMUX.md`:
  - [x] CLI linux-arm64 binary (runs inside Termux)
  - [x] Flutter arm64 APK (built on `ubuntu-22.04-arm` as Termux fallback)
  - [x] Self-hosted Termux runner support (when user registers one)
  - [x] Copy-paste phone build instructions (`TERMUX.md`)
- [x] **Master workflow** — `.github/workflows/build-all.yml`:
  - [x] Single dispatch entry with flavor picker (`all` / `cli-only` / `flutter-only` / `termux-only`)
  - [x] Nightly schedule (`0 2 * * *` UTC)
  - [x] Reuses `ci.yml` + `build.yml` + `termux-build.yml` via `workflow_call`
  - [x] Generates a `MANIFEST.md` listing every artifact produced
- [ ] Hardware acceleration (still pending):
  - [ ] NVENC detection on Windows
  - [ ] VAAPI detection on Linux
  - [ ] MediaCodec on Android (if `ffmpeg_kit_flutter_new` supports)

**Definition of done**: User can download an installer for their platform, install with one
click, and the app works out of the box without needing to install FFmpeg separately.
**Status**: CI scaffolding is fully wired — every artifact can be built by pushing a `v*.*.*` tag.
The remaining items are native platform integration (notifications, share intents, installers,
code signing). **Estimated remaining effort**: 2–3 focused sessions.

---

## Phase 5 — Polish & v1.0.0 Release ⏳

**Goal**: Ship a v1.0.0 that's stable, polished, and ready for public release.

**Deliverables**:
- [ ] Bug bash — 1 week of focused QA
- [ ] Performance profiling (cold start, memory, encode speed)
- [ ] Crash reporting via Sentry (opt-in)
- [ ] Play Store listing (screenshots, feature graphic, description)
- [ ] GitHub Release with proper release notes
- [ ] Demo video (60 seconds) showing the full flow
- [ ] Landing page (single-page static site, GitHub Pages)
- [ ] Documentation site (_mkdocs_ or _docusaurus_) — user guide + FAQ
- [ ] v1.0.0 tag + release

**Definition of done**: v1.0.0 is publicly downloadable. README points to releases.
Crash rate < 0.5%. 90%+ of test corpus compresses without intervention.

**Estimated effort**: 2–3 focused sessions.

---

## Phase 6 — Post-1.0 (P2 features) ⏳

After v1.0.0 is stable, consider:

- **Pro features**: trim, thumbnail, GIF maker, audio extractor, speed changer
- **macOS support**: VideoToolbox + .dmg build
- **iOS support**: App Store submission
- **Per-title CRF**: Netflix-style content-adaptive encoding
- **VMAF scoring**: objective quality measurement in result screen
- **Plugin system**: allow user-defined FFmpeg presets
- **CLI companion**: optional `videosensei` CLI for power users (rebirth of the original tool, but as a sibling, not the primary UX)

---

## Milestone Tracking

| Phase | Status                       | Started       | Completed     |
| ----- | ---------------------------- | ------------- | ------------- |
| 1     | ✅ Complete                  | 2026-07-21    | 2026-07-21    |
| 2     | ✅ Complete                  | 2026-07-21    | 2026-07-21    |
| 3     | ⏳ Planned                   | _—_           | _+3 weeks_    |
| 4     | 🟡 CI scaffolding done       | 2026-07-22    | _+5 weeks_    |
| 5     | ⏳ Planned                   | _—_           | _+7 weeks_    |

---

## How to Move Between Phases

- Each phase ends with a PR review against this roadmap's "Definition of done"
- Phase X cannot start until Phase X-1's "Definition of done" is met
- New feature requests during a phase go into `FEATURES.md` P1/P2 backlog, not the current phase
- Bugs found during a phase are fixed in-phase if critical, deferred if cosmetic
