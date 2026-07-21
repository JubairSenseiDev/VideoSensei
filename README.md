# 🥋 VideoSensei

> **Master your video. Sensei-grade clarity.**
> *Hack the size. Keep the clarity.*

A modern, cross-platform **video compression suite** built for 2026.
Shrink file sizes dramatically — keep the picture crystal clear.

Native apps for **Android**, **Linux**, and **Windows** from a single codebase.
No CLI gymnastics. No terminal fear. Just open, pick a file, and let the Sensei work.

> 🟢 Part of the **[Jubair Sensei](https://jubairsensei.com)** brand — *Hack, learn, dominate.*

---

## 🎯 Why VideoSensei?

The original VideoSensi (2019–2024) was a Termux-only bash tool — powerful but locked behind a terminal.
VideoSensei is a full rebuild for the modern era:

| Old (VideoSensi)                    | New (VideoSensei)                              |
| ----------------------------------- | ---------------------------------------------- |
| Bash CLI, Termux-only               | Native GUI on Android / Linux / Windows        |
| System FFmpeg required              | FFmpeg bundled — zero setup                    |
| `/sdcard` hardcoded paths           | Native file picker — pick from anywhere        |
| ASCII-art menus                     | Material 3 / glassmorphism UI, 60fps           |
| Single codec (H.264/H.265)          | H.264 / H.265 / **AV1** + smart auto-mode      |
| Misspelled brand "Sensi"            | Properly branded **Sensei** 🥋                  |
| Manual CRF guesswork                | Predictive sizing + per-title CRF analysis     |

---

## ✨ Core Features

- 🗂️ **Native file picker** — pick videos straight from your file manager
- 🪶 **Smart compression** — auto-detects best codec & CRF for each video
- 🎚️ **5 quality presets** — Lite / Balanced / Crystal / Sensei / Custom
- 📊 **Predictive sizing** — see estimated output size *before* you encode
- 🔄 **Batch processing** — queue dozens of files, walk away
- 🎬 **Codec chooser** — H.264 (compat) · H.265 (balanced) · AV1 (future-proof)
- ⚡ **Hardware acceleration** — NVENC / VAAPI / VideoToolbox / MediaCodec
- 🆚 **Before/after preview** — scrub both clips side by side
- 📝 **History log** — every operation tracked, undoable, exportable
- 🌗 **Adaptive theme** — Material 3, dynamic color, dark mode by default
- 📱 **Mobile-first UX** — designed for touch, scaled up for desktop

See [`FEATURES.md`](./FEATURES.md) for the full feature matrix.

---

## 🎨 Theme

The visual identity is inherited from [jubairsensei.com](https://jubairsensei.com) —
a **terminal-inspired, dark-first** aesthetic with **neon green** as the signature accent.

| Mode  | Background  | Accent (signature)   | Headlines           | Body      | Numbers           |
| ----- | ----------- | -------------------- | ------------------- | --------- | ----------------- |
| Dark  | `#0A0A0B`   | `#00FF88` 🟢         | Cabinet Grotesk     | Satoshi   | JetBrains Mono    |
| Light | `#F0F0EC`   | `#008246` 🌲         | Cabinet Grotesk     | Satoshi   | JetBrains Mono    |

Dark mode is the default — honoring the bash-CLI heritage of the original VideoSensi.
Full token reference: [`THEME.md`](./THEME.md). Brand guide: [`BRANDING.md`](./BRANDING.md).

---

## 🏗️ Tech Stack

| Layer        | Choice                                         | Why                                  |
| ------------ | ---------------------------------------------- | ------------------------------------ |
| UI framework | **Flutter 3.x** (Dart)                         | Single codebase, all 3 platforms     |
| Video engine | **FFmpeg** (bundled via `ffmpeg_kit_flutter`)  | Zero setup, full codec support       |
| Playback     | **`media_kit`** (libmpv)                       | Smooth preview, all formats          |
| File picking | **`file_picker`**                              | Native pickers per platform          |
| State mgmt   | **Riverpod 2**                                 | Testable, scalable, modern           |
| Storage      | **Hive / Drift**                               | Fast local history & settings        |
| Theme        | Custom tokens from `THEME.md`                  | Matches jubairsensei.com exactly     |
| CI/CD        | **GitHub Actions**                             | Auto-build APK / .deb / .exe / AppImage |

See [`ARCHITECTURE.md`](./ARCHITECTURE.md) for module design.

---

## 📦 Install

### CLI (available now)

**One-line install** (Linux / macOS / Termux / Git Bash):

```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

Then (v1.1.0+ — auto-everything, zero prompts):
```bash
videosensei                          # picker + smart + compress (auto)
videosensei video.mp4                # smart preset, auto-compress
videosensei video.mp4 -p sensei      # AV1 master
videosensei -i                       # interactive menu (old behavior)
videosensei --help                   # see all options
```

📖 **Full CLI guide**: [`cli/README.md`](./cli/README.md)

### Native apps (coming soon)

| Platform | Format                | Status |
| -------- | --------------------- | ------ |
| Android  | `.apk` (arm64-v8a)    | 🚧 Flutter build in progress |
| Linux    | `.deb` + AppImage     | 🚧 Flutter build in progress |
| Windows  | `.exe` (NSIS)         | 🚧 Flutter build in progress |

---

## 🧭 Roadmap

See [`ROADMAP.md`](./ROADMAP.md). Short version:

- **Phase 1** ✅ Foundation — repo, branding, architecture, planning docs
- **Phase 2** 🚧 Core engine — Flutter project + compression pipeline
- **Phase 3** ⏳ Modern UI — Material 3 screens, animations, theming
- **Phase 4** ⏳ Platform builds — Android APK, Linux .deb, Windows .exe
- **Phase 5** ⏳ Polish & release — icons, store listings, v1.0.0

---

## 📚 Documentation

- [`THEME.md`](./THEME.md) — 🎨 Design tokens (colors, fonts, spacing) extracted from jubairsensei.com
- [`BRANDING.md`](./BRANDING.md) — Name, logo, color system, voice
- [`ARCHITECTURE.md`](./ARCHITECTURE.md) — Module design & data flow
- [`FEATURES.md`](./FEATURES.md) — Full feature matrix with priorities
- [`COMPRESSION.md`](./COMPRESSION.md) — Codec strategy, CRF logic, presets
- [`ROADMAP.md`](./ROADMAP.md) — Phased delivery plan
- [`docs/ui-mockups.md`](./docs/ui-mockups.md) — Screen layouts & flows
- [`docs/codec-strategy.md`](./docs/codec-strategy.md) — Codec decision tree

---

## 👤 Author

**Jubair Sensei** — *Hack, learn, dominate.*
- 🌐 [jubairsensei.com](https://jubairsensei.com) — Bangla tech community
- 📧 jubairsensei@gmail.com
- 🐙 [github.com/JubairSenseiDev](https://github.com/JubairSenseiDev)
- 💬 Telegram: [@JubairSensei](https://t.me/JubairSensei)
- ▶️ YouTube: [@JubairSensei](https://youtube.com/@JubairSensei)

## 📜 License

MIT — see [`LICENSE`](./LICENSE).

## 🙏 Acknowledgements

Built on the shoulders of giants: **FFmpeg**, **Flutter**, **Dart**, **libmpv**.
Original concept (VideoSensi v3.3.1, 2019–2024) by Jubair bro.
