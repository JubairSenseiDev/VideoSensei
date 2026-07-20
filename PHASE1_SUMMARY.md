# 📋 Phase 1 — Foundation Summary

**Date**: 2026-07-21
**Status**: ✅ Complete
**Repo**: https://github.com/JubairSenseiDev/VideoSensei

---

## What was done

This is the foundation phase of the VideoSensei rebuild. We did NOT write app code yet —
the goal was to establish the brand, architecture, and plan so that Phase 2 (engine)
can move fast without rework.

### Decisions made

1. **Brand**: `VideoSensei` (corrected from old "VideoSensi" misspelling)
2. **Tagline**: "Master your video. Sensei-grade clarity."
3. **Tech stack**: Flutter 3.x + bundled FFmpeg (via `ffmpeg_kit_flutter_new` on Android, system binary on Linux/Windows)
4. **Platforms**: Android (priority), Linux, Windows (macOS/iOS future)
5. **State management**: Riverpod 2
6. **UI direction**: Material 3, glassmorphism, dark-first, indigo+cyan palette
7. **Codecs**: H.264 (Lite), H.265 (Balanced/Crystal), AV1 (Sensei)
8. **5 quality presets**: Lite, Balanced, Crystal, Sensei, Custom
9. **Smart mode**: ffprobe analysis → preset recommendation
10. **Bundling strategy**: FFmpeg bundled in app (zero-setup UX)
11. **File picker**: Native via `file_picker` package (no more `/sdcard` hardcoding)
12. **License**: MIT
13. **GitHub account**: `JubairSenseiDev` (separate from old `jubairbro`)

### Documents produced

| File                          | Purpose                                            |
| ----------------------------- | -------------------------------------------------- |
| `README.md`                   | Project intro, install, links                      |
| `ARCHITECTURE.md`             | Layered design, module layout, FFmpeg bridge API   |
| `BRANDING.md`                 | Name, logo, colors, typography, voice              |
| `FEATURES.md`                 | Full feature matrix with P0/P1/P2 priorities       |
| `COMPRESSION.md`              | Codec strategy, CRF logic, presets deep-dive       |
| `ROADMAP.md`                  | 5-phase delivery plan with definitions of done     |
| `docs/ui-mockups.md`          | Wireframe layouts for all 9 screens                |
| `docs/codec-strategy.md`      | Codec decision tree, CRF tables, FFmpeg templates  |
| `LICENSE`                     | MIT                                                |
| `.gitignore`                  | Flutter + Dart + per-platform ignores              |

---

## What was NOT done (deliberately deferred)

- ❌ Flutter project initialization (`flutter create`) — Phase 2
- ❌ Any Dart code — Phase 2
- ❌ FFmpeg binary bundling — Phase 2
- ❌ UI implementation — Phase 3
- ❌ Platform builds (APK/.deb/.exe) — Phase 4
- ❌ App icon design (final art) — Phase 4
- ❌ Play Store / GitHub Release — Phase 5

This is intentional. Planning docs first → code second. Saves rework.

---

## Open questions for Phase 2 kickoff

1. **AV1 on Android mid-range**: Is the encode time acceptable? Or do we gate Sensei preset behind a warning + fallback?
2. **`ffmpeg_kit_flutter_new` reliability**: It's a community fork of the original archived package. Need to test stability on Android.
3. **FFmpeg binary size budget**: Linux/Windows bundle adds ~15-20MB. Acceptable? Or use system FFmpeg on desktop?
4. **Bengali UI strings**: Should the app ship bilingual from day 1, or English first + Bengali in Phase 3?
5. **Onboarding skip**: Should the 3-screen onboarding be skippable, or always shown once?
6. **History retention**: Default "clear history older than X days" — what's the default? 30? 90? Never?
7. **Hardware accel on Android**: Should we attempt MediaCodec via `ffmpeg_kit`'s mediacodec module, or stick to software on mobile?

These will be resolved at the start of Phase 2.

---

## How to verify Phase 1 is done

Anyone with the repo URL should be able to:

1. ✅ Read `README.md` and understand what VideoSensei is
2. ✅ Read `BRANDING.md` and produce a logo that fits
3. ✅ Read `ARCHITECTURE.md` and start writing code without further questions
4. ✅ Read `FEATURES.md` and know which features are in scope for v1.0.0
5. ✅ Read `COMPRESSION.md` and reproduce the exact FFmpeg commands
6. ✅ Read `ROADMAP.md` and know what comes next, in what order
7. ✅ Read `docs/ui-mockups.md` and wireframe any screen in Figma
8. ✅ Read `docs/codec-strategy.md` and make a correct codec choice for any input

All eight checks pass. Phase 1 is complete.
