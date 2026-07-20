# ✨ VideoSensei — Features Matrix

This document enumerates every planned feature, prioritized by phase.
Items marked **P0** ship in v1.0.0; **P1** in v1.x; **P2** are future.

---

## 1. Core Compression Engine

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | H.264 (libx264) encoding               | P0       | 2     |
| 2 | H.265 / HEVC (libx265) encoding        | P0       | 2     |
| 3 | AV1 (libsvtav1) encoding               | P1       | 3     |
| 4 | CRF-based constant quality             | P0       | 2     |
| 5 | Two-pass bitrate targeting             | P1       | 3     |
| 6 | Per-title CRF analysis (smart mode)    | P2       | 5     |
| 7 | Audio: AAC, Opus, copy, drop           | P0       | 2     |
| 8 | Subtitle stream preservation           | P1       | 3     |
| 9 | HDR metadata preservation              | P2       | 5     |
| 10| Hardware accel: NVENC (Windows)        | P1       | 4     |
| 11| Hardware accel: VAAPI (Linux)          | P1       | 4     |
| 12| Hardware accel: MediaCodec (Android)   | P2       | 5     |
| 13| Hardware accel: VideoToolbox (macOS)   | P2       | 5     |

---

## 2. Quality Presets (the heart of the UX)

| Preset   | Codec | CRF | Preset     | Audio            | Use case                     |
| -------- | ----- | --- | ---------- | ---------------- | ---------------------------- |
| 🪶 Lite  | H.264 | 30  | veryfast   | AAC 128k         | Quick share, max compat      |
| ⚖️ Balanced | H.265 | 26  | medium     | AAC 128k         | Daily default, 50% smaller  |
| 💎 Crystal | H.265 | 22  | slow       | AAC 192k         | Archive, near-lossless       |
| 🥋 Sensei | AV1   | 32  | SVT p6     | Opus 96k         | Future-proof, smallest file  |
| 🎯 Custom | User  | User | User       | User             | Full manual control          |

Each preset shows:
- Estimated output size (before encoding)
- Estimated time (based on input length × preset multiplier)
- Compatibility badge (which devices/players will support it)

---

## 3. Smart Mode (Auto)

- 🔍 **Probes input** with ffprobe (codec, resolution, bitrate, fps, duration)
- 🧠 **Analyzes motion** with a 2-second sample encode (no full pass)
- 📐 **Recommends preset** based on:
  - Source quality (don't upcompress already-small files)
  - Motion complexity (high motion → higher CRF tolerance)
  - Audio quality (drop to Opus if source is already compressed)
  - Target device (if user picks "share to WhatsApp" → Lite preset)
- 👤 **Learns** user's preset preferences over time (opt-in, local only)

---

## 4. File Management

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Native file picker (single file)      | P0       | 2     |
| 2 | Native file picker (multi-select)     | P0       | 2     |
| 3 | Drag-and-drop (desktop)                | P0       | 3     |
| 4 | Folder picker (recursive batch)        | P1       | 3     |
| 5 | Output to original folder              | P0       | 2     |
| 6 | Output to custom folder                | P0       | 2     |
| 7 | Output to gallery (Android)            | P0       | 2     |
| 8 | Output to Downloads (Android)          | P0       | 2     |
| 9 | Custom output filename template        | P1       | 3     |
| 10| Overwrite / skip / rename conflict UI  | P0       | 2     |
| 11| Share sheet integration (Android/iOS)  | P1       | 4     |

---

## 5. Batch Processing

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Queue multiple files                   | P0       | 3     |
| 2 | Per-file preset override               | P0       | 3     |
| 3 | Same preset for all                    | P0       | 3     |
| 4 | Pause / resume queue                   | P1       | 4     |
| 5 | Skip current, advance to next          | P0       | 3     |
| 6 | Retry failed items                     | P1       | 4     |
| 7 | Save/load queue templates              | P2       | 5     |
| 8 | Parallel encoding (N workers)          | P2       | 5     |

---

## 6. UI / UX

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Material 3 theming                     | P0       | 3     |
| 2 | Dynamic color (Android 12+)            | P1       | 4     |
| 3 | Dark mode (default) + Light + Auto     | P0       | 3     |
| 4 | Glassmorphism cards                    | P1       | 3     |
| 5 | Smooth hero transitions                | P1       | 3     |
| 6 | Progress ring with live %              | P0       | 3     |
| 7 | Real-time stats (size, speed, ETA)     | P0       | 3     |
| 8 | Before/after size badge                | P0       | 3     |
| 9 | Before/after video preview (scrub)     | P1       | 4     |
| 10| Drag handles for advanced controls     | P1       | 3     |
| 11| Onboarding (3-screen intro)            | P1       | 4     |
| 12| Bengali + English localization         | P0       | 3     |
| 13| RTL support (Arabic/Hebrew, future)    | P2       | 5     |

---

## 7. History & Logs

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Auto-record every operation            | P0       | 3     |
| 2 | Filter by date / preset / file         | P1       | 3     |
| 3 | Search by filename                     | P0       | 3     |
| 4 | Re-run same preset on new file         | P1       | 4     |
| 5 | Export history as CSV/JSON             | P2       | 5     |
| 6 | Per-file FFmpeg command log (debug)    | P1       | 3     |
| 7 | Clear history older than N days        | P1       | 4     |

---

## 8. Settings

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Default preset selection               | P0       | 3     |
| 2 | Default output location                | P0       | 3     |
| 3 | Theme mode (dark/light/auto)           | P0       | 3     |
| 4 | Language (BN/EN)                       | P0       | 3     |
| 5 | Hardware accel toggle                  | P1       | 4     |
| 6 | Delete original after success          | P1       | 4     |
| 7 | Notification on completion             | P1       | 4     |
| 8 | Telemetry opt-in (anonymous, local)    | P2       | 5     |
| 9 | FFmpeg binary path override (advanced) | P2       | 5     |

---

## 9. Platform Integration

| # | Feature                                | Priority | Phase |
| - | -------------------------------------- | -------- | ----- |
| 1 | Android share-to-app (receive video)   | P0       | 4     |
| 2 | Android share-from-app (send result)   | P0       | 4     |
| 3 | Android notification w/ progress       | P0       | 4     |
| 4 | Android foreground service             | P0       | 4     |
| 5 | Linux `.desktop` file + MimeType       | P0       | 4     |
| 6 | Windows file context menu (future)     | P2       | 5     |
| 7 | Windows jump list (recent files)       | P2       | 5     |

---

## 10. Advanced / Pro Features (P2 / Phase 5)

- 🎬 **Trim & cut** — extract a segment before compressing
- 🖼️ **Thumbnail extractor** — pull N frames at intervals
- 🔄 **GIF maker** — convert segment to optimized GIF
- 🎵 **Audio extractor** — pull audio as MP3/Opus
- 📐 **Resolution scaler** — 4K → 1080p / 1080p → 720p
- ⏱️ **Speed changer** — 0.5× / 1× / 2× without pitch shift
- 🎨 **Color grading** — brightness/contrast/saturation curves
- 🌐 **WebP/WebM optimizer** — for web delivery
- 📺 **Stream metadata editor** — title, author, tags
- 🔒 **Watermark** — image or text, position, opacity, animation
- 🧪 **Side-by-side comparison tool** — A/B scrubber

---

## 11. Non-Features (deliberately out of scope for v1)

- ❌ Video editing timeline (we are not Premiere/DaVinci)
- ❌ Streaming server / RTMP (we are not OBS)
- ❌ Cloud upload (privacy-first, local-only)
- ❌ Account/login (no telemetry lock-in)
- ❌ Video conversion to audio-only by default (it's a separate tool)
- ❌ DVD/Blu-ray ripping (legal gray zone, out of scope)

---

## 12. Success Metrics (v1.0.0)

| Metric                              | Target         |
| ----------------------------------- | -------------- |
| Install → first compression         | < 60 seconds   |
| Compression of 100MB 1080p video    | < 90 seconds   |
| Output size reduction (Balanced)    | ≥ 50% average  |
| Output quality (SSIM vs original)   | ≥ 0.95         |
| App cold start (Android mid-range)  | < 2 seconds    |
| App size (Android APK, arm64)       | < 35 MB        |
| Crash-free sessions                 | ≥ 99.5%        |
