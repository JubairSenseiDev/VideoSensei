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

## [1.2.0] — 2026-07-21

### 🚀 Modern distribution — single-binary via Bun compile

This release modernizes the distribution pipeline using **Bun's `--compile` flag**
to produce self-contained executables. Users no longer need Node.js installed.

### Added — Pre-built binaries (5 platforms)
- **`videosensei-linux-x64`** — most Linux desktops/servers
- **`videosensei-linux-arm64`** — Raspberry Pi 4, Termux on arm64 Android, Apple Silicon Linux VMs
- **`videosensei-darwin-x64`** — Intel Macs
- **`videosensei-darwin-arm64`** — Apple Silicon Macs (M1/M2/M3/M4)
- **`videosensei-windows-x64.exe`** — most Windows installations

Each binary is ~95 MB (contains Bun runtime + bundled app).
**Zero runtime dependencies** — just FFmpeg on the system.

### Changed — Installer (v1.1.0 → v1.2.0)
- Now downloads pre-built binary first (no Node.js needed!)
- Falls back to Node.js bundle if no binary for platform
- Detects platform + architecture automatically:
  - `linux-x64`, `linux-arm64`, `darwin-x64`, `darwin-arm64`, `windows-x64`
  - Termux detection: `termux-arm64`, `termux-x64`
- Sanity-checks downloaded binary actually runs before installing
- Clear messaging about which path was taken

### Changed — Build system
- Added `bun build --compile` scripts to package.json:
  - `build:bun:linux-x64`, `build:bun:linux-arm64`
  - `build:bun:darwin-x64`, `build:bun:darwin-arm64`
  - `build:bun:windows-x64`
  - `build:bun:all` (builds all 5)
- Renamed `build` → `build:bundle` (for Node.js fallback path)
- `BUILD_VERSION` compile-time constant injected via `--define`
- Binary knows its version without reading package.json

### Changed — CI workflow (`.github/workflows/ci.yml`)
- **6 jobs** in parallel:
  1. `build-node` — typecheck + esbuild bundle
  2. `build-binaries` — cross-compile 5 binaries (matrix strategy)
  3. `test-cli` — test Node bundle on Node 18/20/22
  4. `test-binary` — test linux-x64 binary on Linux
  5. `test-installer` — test installer on clean Ubuntu
  6. `release` — auto-publish GitHub Release with all artifacts on `v*` tag
- Uses `oven-sh/setup-bun@v2` action for Bun
- All artifacts uploaded to GitHub Release

### Removed
- Old `build` script (renamed to `build:bundle`)
- Single `build:cjs` script (unused, ESM is the default)

### Why Bun compile?
- **Zero runtime deps at user's machine** — just download + run
- **No PATH conflicts** with user's Node.js version
- **Faster startup** — Bun's startup is ~4x faster than Node.js
- **Self-contained** — no `node_modules`, no install scripts, no surprises
- **Cross-compile** — single Linux x64 runner builds all 5 platforms

### Install (one-liner, unchanged)
```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

### Manual binary download
```bash
# Linux x64
curl -fSL https://github.com/JubairSenseiDev/VideoSensei/releases/latest/download/videosensei-linux-x64 -o videosensei
chmod +x videosensei && sudo mv videosensei /usr/local/bin/

# Termux (Android arm64)
curl -fSL https://github.com/JubairSenseiDev/VideoSensei/releases/latest/download/videosensei-linux-arm64 -o $PREFIX/bin/videosensei
chmod +x $PREFIX/bin/videosensei
```

---

## [1.1.0] — 2026-07-21

### 🎉 Major rewrite — TypeScript + auto-everything

This release addresses two pieces of user feedback:
1. **"Why not TypeScript for best terminal management?"** — Now TypeScript.
2. **"Why not all are auto?"** — Now zero prompts by default.

### Changed — Architecture
- **Rewritten in TypeScript** with strict typing
- 10 modular files: `types.ts`, `theme.ts`, `presets.ts`, `probe.ts`, `ffmpeg.ts`, `history.ts`, `smart.ts`, `ui.ts`, `filepicker.ts`, `main.ts`
- Bundled to single ~50KB file with **esbuild** (`cli/dist/videosensei.js`)
- `node_modules/` no longer needed at runtime — bundle has zero deps
- Updated Node.js requirement: 16 → 18 (ESM + modern syntax)

### Changed — UX (auto-everything)
- **Default mode is now AUTO**: zero prompts unless user opts in
  - `videosensei` → picker → smart preset → compress (no menu, no confirm)
  - `videosensei file.mp4` → smart preset → compress (no confirm)
  - `videosensei file.mp4 -p sensei` → specific preset → compress (no confirm)
- **Smart mode is default ON** — auto-picks best preset based on source
- **`--confirm` flag** — opt-in to confirmation prompts (old behavior)
- **`-i, --interactive` flag** — opt-in to old menu (power users)
- **`--no-smart` flag** — disable smart mode (use Balanced by default)

### Fixed — Smart mode logic
- No longer auto-skips small/low-bitrate videos (was too aggressive)
- Only returns null if source is **AV1** (truly optimal codec)
- Low-bitrate videos now get **Lite** preset (was: skipped entirely)
- AV1 sources show clear message: "Source is already AV1 — re-encoding won't help"

### Added — New flags
- `-i, --interactive` — show old menu (pick / type / batch / history / help)
- `--confirm` — ask before compressing (default: skip)
- `--smart` — explicit smart mode (already default)
- `--no-smart` — disable smart mode

### Changed — File picker
- Built into bundled CLI (no separate `filepicker.js` download)
- Same backends: Termux:API / macOS / Linux (zenity/kdialog) / Windows / fzf
- Pure-Node arrow-key browser fallback (no install needed)

### Changed — Installer
- Now downloads ONE file: `cli/dist/videosensei.js` (was: two files)
- Version bumped 1.0.3 → 1.1.0
- Smaller, simpler install flow

### Removed
- `cli/videosensei.js` (legacy plain JS, replaced by `cli/dist/videosensei.js`)
- `cli/filepicker.js` (merged into bundle via esbuild)
- Separate "file picker download" step in installer

### One-liner install
```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

### Auto-mode usage
```bash
videosensei                    # picker + smart + compress (zero prompts)
videosensei video.mp4          # smart + compress (zero prompts)
videosensei video.mp4 -p sensei # specific preset (zero prompts)
videosensei -i                 # interactive menu (old behavior)
```

---

## [1.0.3] — 2026-07-21

### Added
- **File picker** — multiple picker backends auto-detected:
  - Termux: `termux-file-picker` (after `pkg install termux-api`)
  - macOS: built-in `osascript`
  - Linux: `zenity` (GTK) or `kdialog` (KDE)
  - Windows: PowerShell (.NET WinForms)
  - Any: `fzf` (terminal fuzzy finder)
  - Fallback: **pure-Node arrow-key browser** (no install needed)
- **`--pick` / `-P` flag** — open file picker directly from command line
- **Friendly main menu** (old VideoSensi style) when running `videosensei` without args:
  1. 🎬 Pick a video and compress (file picker)
  2. 📂 Type path manually (paste path)
  3. 📦 Batch compress (multiple files)
  4. 📜 View history (past compressions)
  5. ❓ Help (show all options)
  q. Quit
- **`install.sh`** — minimal entry point for `curl | bash` one-liner
- New module `cli/filepicker.js` (~500 lines, zero dependencies)

### Changed
- Installer now downloads BOTH `videosensei.js` AND `filepicker.js`
- Interactive mode rewritten with friendly menu (was just "Video path:" prompt)
- `--help` output includes FILE PICKERS section
- Installer version bumped 1.0.2 → 1.0.3

### One-liner install
```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

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
