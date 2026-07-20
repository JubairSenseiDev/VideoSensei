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

## Phase 2 — Core Engine (next) 🚧

**Goal**: Build the compression pipeline as a runnable Flutter project (CLI-quality, no UI polish yet).

**Deliverables**:
- [ ] `flutter create` the project with `--platforms=android,linux,windows`
- [ ] Set up directory structure per `ARCHITECTURE.md`
- [ ] Add dependencies: `ffmpeg_kit_flutter_new`, `file_picker`, `riverpod`, `drift`, `media_kit`
- [ ] Implement `domain/` layer (pure Dart, fully unit-tested):
  - [ ] `CompressionPreset` model
  - [ ] `VideoFile` / `VideoMetadata` models
  - [ ] `PresetStrategy` — preset → FFmpeg args mapping (all 5 presets)
  - [ ] `SizePredictor` — pre-encode size estimation
  - [ ] `AutoStrategy` — smart mode recommendation
- [ ] Implement `data/ffmpeg/` layer:
  - [ ] `FFmpegService` interface
  - [ ] `FFmpegService` implementation (using `ffmpeg_kit_flutter_new` on Android)
  - [ ] `FFmpegParser` — stderr → progress stream
  - [ ] Linux/Windows: bundle FFmpeg binary in `assets/ffmpeg/`, exec via `Process.run`
- [ ] Implement `data/filepicker/` — wrap `file_picker` package
- [ ] Implement `data/storage/` — Drift schema for history
- [ ] Write a minimal smoke-test UI (file → preset → run → result), no polish
- [ ] Verify end-to-end on Android emulator + Linux desktop

**Definition of done**: User can pick a video, choose "Balanced" preset, see live progress,
get an output file. All five presets functional. Domain layer has 80%+ test coverage.

**Estimated effort**: 3–5 focused sessions.

---

## Phase 3 — Modern UI / UX ⏳

**Goal**: Build the 2026-style Material 3 UI on top of the working engine.

**Deliverables**:
- [ ] Custom theme (`core/theme/`) — Material 3 with indigo/cyan palette
- [ ] Typography setup (Inter + JetBrains Mono + Noto Sans Bengali)
- [ ] Glassmorphism card widget
- [ ] Screen: **Home** — recent files, quick action, sensei mark
- [ ] Screen: **Picker** — native file picker integration, drag-drop (desktop)
- [ ] Screen: **Configure** — preset cards, advanced controls, size prediction badge
- [ ] Screen: **Processing** — animated progress ring, live stats, cancel button
- [ ] Screen: **Result** — before/after size badge, output preview, save/share
- [ ] Screen: **Batch** — queue manager, per-file preset override
- [ ] Screen: **History** — searchable, filterable list
- [ ] Screen: **Settings** — theme, language, defaults
- [ ] Onboarding (3-screen intro, first-launch only)
- [ ] Localization: Bengali (bn) + English (en)
- [ ] Hero transitions between screens
- [ ] Loading shimmers for async data

**Definition of done**: App looks and feels like a 2026 product. Navigating the full flow
(pick → configure → process → result) is smooth, animated, and intuitive. No placeholder text.

**Estimated effort**: 4–6 focused sessions.

---

## Phase 4 — Platform Builds & Integration ⏳

**Goal**: Produce installable artifacts for Android, Linux, and Windows.

**Deliverables**:
- [ ] **Android**:
  - [ ] Adaptive app icon (foreground + background)
  - [ ] `WRITE_MEDIA_VIDEO` permission via `MediaStore`
  - [ ] Foreground service for long-running encodes
  - [ ] Notification with progress + cancel action
  - [ ] Share-to-app intent filter (receive video from other apps)
  - [ ] Share-from-app (send result via share sheet)
  - [ ] Signed APK (arm64-v8a) for release
  - [ ] App Bundle (.aab) for Play Store submission
- [ ] **Linux**:
  - [ ] `.desktop` file with MimeType registration
  - [ ] AppImage build
  - [ ] `.deb` package with proper dependencies
  - [ ] hicolor icons (16/32/48/64/128/256/512)
- [ ] **Windows**:
  - [ ] MSIX or NSIS installer
  - [ ] File association (.mp4, .mkv, .mov)
  - [ ] Start menu shortcut
  - [ ] Code-signed `.exe` (if cert available; self-signed otherwise)
- [ ] **GitHub Actions CI**:
  - [ ] On push: `flutter analyze` + `flutter test`
  - [ ] On tag `v*.*.*`: build all 3 platforms, upload to Releases
- [ ] Hardware acceleration:
  - [ ] NVENC detection on Windows
  - [ ] VAAPI detection on Linux
  - [ ] MediaCodec on Android (if `ffmpeg_kit_flutter_new` supports)

**Definition of done**: User can download an installer for their platform, install with one
click, and the app works out of the box without needing to install FFmpeg separately.

**Estimated effort**: 3–4 focused sessions.

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

| Phase | Status      | Started       | Target completion |
| ----- | ----------- | ------------- | ----------------- |
| 1     | ✅ Complete  | 2026-07-21    | 2026-07-21        |
| 2     | 🚧 Next     | _pending_     | _+1 week_         |
| 3     | ⏳ Planned  | _—_           | _+3 weeks_        |
| 4     | ⏳ Planned  | _—_           | _+5 weeks_        |
| 5     | ⏳ Planned  | _—_           | _+7 weeks_        |

(All dates are approximate; this is a side project, not a sprint.)

---

## How to Move Between Phases

- Each phase ends with a PR review against this roadmap's "Definition of done"
- Phase X cannot start until Phase X-1's "Definition of done" is met
- New feature requests during a phase go into `FEATURES.md` P1/P2 backlog, not the current phase
- Bugs found during a phase are fixed in-phase if critical, deferred if cosmetic
