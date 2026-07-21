# 🧭 VideoSensei — Roadmap

This is the phased delivery plan for VideoSensei.

---

## Branches

| Branch | Contents | Audience |
| ------ | -------- | -------- |
| `main` | **CLI + installer** — what users install via the one-liner | End users |
| `flutter-app` | Flutter GUI app source + multi-platform CI | Contributors / devs |

---

## v1.x — CLI era ✅

**Goal**: Single-binary CLI that runs anywhere — including Termux on Android.

**Deliverables**:
- [x] v1.0 — Original Bash CLI (Termux-only, 2019–2024)
- [x] v1.1 — TypeScript rewrite + auto-everything (zero prompts)
- [x] v1.2 — Bun-compiled single binaries (linux-x64/arm64, darwin-x64/arm64, windows-x64)
- [x] v1.2.1 — Termux support via [bd-loser/bun-termux](https://github.com/bd-loser/bun-termux)
- [x] v1.3.0 — Simplified installer + big ASCII banner + cleaner fallback chain

**Definition of done**: `curl | bash` works on every supported platform. **Met.**

---

## v2.x — Flutter GUI (in `flutter-app` branch) 🚧

**Goal**: Native GUI app on Android / Linux / Windows / macOS / Web.

**Deliverables** (on `flutter-app` branch):
- [x] Phase 1 — Foundation (repo, branding, architecture, planning docs)
- [x] Phase 2 — Core engine (Flutter project + domain layer + tests)
- [ ] Phase 3 — Modern UI (Material 3, glassmorphism, animations)
- [ ] Phase 4 — Platform builds (Android APK, Linux .deb, Windows .exe, macOS, Web)
- [ ] Phase 5 — Polish & v2.0.0 release

See the `flutter-app` branch's [`ROADMAP.md`](https://github.com/JubairSenseiDev/VideoSensei/blob/flutter-app/ROADMAP.md) for the full phase-by-phase plan.

---

## v3.x — Future ideas ⏳

- **Pro features**: trim, thumbnail, GIF maker, audio extractor, speed changer
- **macOS support**: VideoToolbox + .dmg build
- **iOS support**: App Store submission
- **Per-title CRF**: Netflix-style content-adaptive encoding
- **VMAF scoring**: objective quality measurement in result screen
- **Plugin system**: allow user-defined FFmpeg presets

---

## Milestone Tracking

| Version | Status       | Notes |
| ------- | ------------ | ----- |
| v1.0–1.2.1 | ✅ Shipped  | CLI + Bun single binaries + Termux support |
| v1.3.0  | ✅ Shipped    | Simplified installer + ASCII banner |
| v2.0    | 🚧 In progress (flutter-app branch) | Flutter GUI |

---

*Hack the size. Keep the clarity.* 🥋
