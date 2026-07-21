# Changelog

All notable changes to VideoSensei will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Native Flutter app (Android/Linux/Windows) — Phase 2-4 of roadmap
- macOS support (VideoToolbox + .dmg)
- iOS support (App Store submission)
- Per-title CRF analysis (smart mode v2)
- VMAF scoring in result screen

---

## [1.0.2] — 2026-07-21

### Fixed
- **Installer**: Detect broken Node.js/FFmpeg binaries (ABI mismatch), not just missing
- **Installer**: Auto-run `pkg upgrade -y` on Termux when ABI mismatch detected
- **Installer**: Force reinstall packages after upgrade
- **Installer**: Clear manual-fix instructions if auto-fix fails
- **CLI**: Edge case where output file deletion prompt caused crash with `-y` flag

### Added
- `detect_abi_mismatch()` function in installer — recognizes common Termux/Linux linker errors
- `termux_fix_abi_mismatch()` function — automatic recovery flow
- `termux_reinstall_pkg()` function — force reinstall helper
- GitHub Actions CI workflow (`.github/workflows/ci.yml`)
  - Lints bash scripts with shellcheck
  - Tests installer on Ubuntu (clean container)
  - Tests CLI end-to-end on Node 18/20/22 with all 5 presets
  - Auto-creates GitHub Release on `v*` tag

### Changed
- `check_node()` now returns exit code 2 for broken binaries (vs 1 for missing)
- `check_ffmpeg()` same return-code convention
- Installer version bumped 1.0.1 → 1.0.2

---

## [1.0.1] — 2026-07-21

### Fixed
- **Installer**: Color codes printed as literal text on Termux (echo vs printf)
  - Root cause: `echo` on Termux bash doesn't interpret `\033` by default
  - Fix: replaced all `echo` with `printf %b` (POSIX-compliant, works everywhere)
- **Installer**: Termux mirror selection issues
  - Fix: `termux_setup_mirror()` auto-sets `packages-cf.termux.dev` if missing
  - Fix: `termux_install_pkg()` retries up to 3 times with different mirrors
  - Fix: graceful fallback with manual-fix instructions if all retries fail
- **Installer**: Better error messages with copy-paste commands

---

## [1.0.0] — 2026-07-21

### Added — Initial release 🎉

#### Logo & Branding
- SVG source: neon green brush "S" with play triangle on near-black
- PNG variants: 32/64/128/256/512/1024 px (cairosvg generated)
- Branded per `THEME.md` tokens extracted from [jubairsensei.com](https://jubairsensei.com)

#### CLI (`cli/videosensei.js`)
- Node.js single-file CLI (~1000 lines, zero dependencies)
- 5 quality presets:
  - 🪶 **Lite** — H.264 CRF 30 (max compat, quick share)
  - ⚖️ **Balanced** — H.265 CRF 26 (daily default, 50% smaller)
  - 💎 **Crystal** — H.265 CRF 22 (archive, near-lossless)
  - 🥋 **Sensei** — AV1 CRF 32 (future-proof, smallest)
  - 🎯 **Custom** — full manual control (codec/crf/audio)
- Smart mode: auto-recommends preset based on source bitrate/codec/resolution
- Size prediction before encoding
- Animated progress bar with neon green glow
- History log (`~/.videosensei/history.json`, last 100 entries)
- Batch processing (multiple files)
- Fallback: if H.265/AV1 fails, auto-fallback to H.264 Lite
- Smart auto-delete: if output is larger than source, deletes output and warns
- Full theme: truecolor neon green on near-black, matching jubairsensei.com
- Interactive + non-interactive modes
- Works on Linux, macOS, Termux, Windows (Git Bash/WSL)

#### Installer (`installer/installer.sh`)
- Cross-platform: Linux / macOS / Termux / Windows (Git Bash)
- Auto-detects platform
- Checks + installs Node.js if missing
- Checks + installs FFmpeg if missing
- Downloads CLI from GitHub main branch
- Installs launcher to `/usr/local/bin` (or `~/.local/bin`, or `$PREFIX/bin` on Termux)
- PATH warning if bin dir not in PATH
- `--uninstall`, `--version`, `--help` flags

#### Documentation
- `README.md` — project intro, install, links
- `ARCHITECTURE.md` — layered design, FFmpeg bridge API, module layout
- `BRANDING.md` — name, logo, color system, voice
- `THEME.md` — design tokens extracted from jubairsensei.com
- `FEATURES.md` — full feature matrix (P0/P1/P2)
- `COMPRESSION.md` — codec strategy, CRF logic, presets deep-dive
- `ROADMAP.md` — 5-phase delivery plan
- `docs/ui-mockups.md` — wireframe layouts for 9 screens
- `docs/codec-strategy.md` — codec decision tree, CRF tables, FFmpeg templates
- `cli/README.md` — CLI quick-start guide
- `LICENSE` — MIT
- `.gitignore` — Flutter + Dart + per-platform ignores

#### Tested
- All 5 presets verified working
- History persistence verified
- Smart auto-delete verified when output > source
- AV1 (Sensei) verified — 10.8% reduction on already-compressed source
- Installer verified on Linux clean container

---

[Unreleased]: https://github.com/JubairSenseiDev/VideoSensei/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/JubairSenseiDev/VideoSensei/releases/tag/v1.0.2
[1.0.1]: https://github.com/JubairSenseiDev/VideoSensei/releases/tag/v1.0.1
[1.0.0]: https://github.com/JubairSenseiDev/VideoSensei/releases/tag/v1.0.0
