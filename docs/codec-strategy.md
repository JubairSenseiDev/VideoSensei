# 🎬 VideoSensei — Codec Strategy

Decision tree and technical reasoning for codec selection.
Companion document to `COMPRESSION.md`.

---

## 1. Codec Comparison Matrix

| Property            | H.264 (AVC)  | H.265 (HEVC) | AV1                | VP9         |
| ------------------- | ------------ | ------------ | ------------------ | ----------- |
| Year                | 2003         | 2013         | 2018               | 2013        |
| Compression eff.    | 1.0× (base)  | 0.5× size    | 0.35× size         | 0.5× size   |
| Encode speed        | 🟢 very fast | 🟡 medium    | 🔴 slow (CPU)      | 🟡 medium   |
| Decode support      | 🟢 universal | 🟡 most modern | 🔴 still spotty  | 🟡 web only |
| Hardware encode     | 🟢 all       | 🟢 most       | 🟡 newer only      | 🟡 some     |
| Hardware decode     | 🟢 all       | 🟢 most       | 🟡 2020+ devices   | 🟡 some     |
| Royalty-free        | ❌           | ❌           | ✅                 | ✅          |
| HDR support         | ❌           | ✅           | ✅                 | ⚠️ partial  |
| Best container      | MP4 / MKV    | MP4 / MKV    | MKV / WebM         | WebM        |

**TL;DR**:
- H.264 = compatibility king
- H.265 = best balance today
- AV1 = best compression, future-facing
- VP9 = skip (AV1 is strictly better)

---

## 2. Decision Tree (which codec to use)

```
START
  │
  ▼
┌─────────────────────────────┐
│ Q1: Is source already AV1?  │
└─────────────────────────────┘
  │
  ├─ Yes ──► COPY (don't re-encode) ✅
  │
  ▼ No
┌─────────────────────────────┐
│ Q2: Target is web (WebM)?   │
└─────────────────────────────┘
  │
  ├─ Yes ──► AV1 (libsvtav1) in WebM
  │
  ▼ No
┌─────────────────────────────┐
│ Q3: Target device is old    │
│     (pre-2018, low-end)?    │
└─────────────────────────────┘
  │
  ├─ Yes ──► H.264 (Lite preset) ✅
  │
  ▼ No
┌─────────────────────────────┐
│ Q4: User wants absolute     │
│     smallest size, accepts  │
│     slow encode?            │
└─────────────────────────────┘
  │
  ├─ Yes ──► AV1 (Sensei preset) ✅
  │
  ▼ No
┌─────────────────────────────┐
│ Q5: Source has HDR?         │
└─────────────────────────────┘
  │
  ├─ Yes ──► H.265 (Crystal preset, preserve HDR) ✅
  │
  ▼ No
┌─────────────────────────────┐
│ Q6: Default — balanced      │
└─────────────────────────────┘
  │
  ▼
H.265 (Balanced preset) ✅
```

---

## 3. CRF Reference Table

CRF (Constant Rate Factor) is the quality knob. Lower = better quality, larger file.

### H.264 (libx264) — CRF scale 0–51
| CRF | Quality              | Use case                       |
| --- | -------------------- | ------------------------------ |
| 0   | Lossless             | Don't use (huge files)         |
| 18  | Visually lossless    | Pro masters                    |
| 23  | Default (good)       | General use                    |
| 28  | Lower quality        | Casual sharing                 |
| 30+ | Noticeable quality loss | Mobile preview, thumbnails  |
| 51  | Worst                | Don't use                      |

### H.265 (libx265) — CRF scale 0–51 (different scale!)
| CRF | Quality              | Compared to H.264 CRF          |
| --- | -------------------- | ------------------------------ |
| 18  | Visually lossless    | ≈ H.264 CRF 14                 |
| 22  | Excellent            | ≈ H.264 CRF 18                 |
| 26  | Good (default)       | ≈ H.264 CRF 22                 |
| 30  | Acceptable           | ≈ H.264 CRF 26                 |
| 32+ | Noticeable loss      |                                |

**Key insight**: H.265 CRF 26 ≈ H.264 CRF 22 in quality, but ~50% smaller file.
Don't compare CRF numbers across codecs!

### AV1 (libsvtav1) — CRF scale 0–63 (yet another scale!)
| CRF | Quality              | Compared to H.265 CRF          |
| --- | -------------------- | ------------------------------ |
| 20  | Visually lossless    | ≈ H.265 CRF 18                 |
| 28  | Excellent            | ≈ H.265 CRF 22                 |
| 32  | Good (default)       | ≈ H.265 CRF 26                 |
| 40+ | Noticeable loss      |                                |

---

## 4. Preset Speed (Encoder Preset, not VideoSensei Preset)

Both libx264 and libx265 support `-preset`:
`ultrafast → superfast → veryfast → faster → fast → medium → slow → slower → veryslow → placebo`

| Preset     | Speed vs realtime | Quality at same CRF | File size at same CRF |
| ---------- | ----------------- | ------------------- | --------------------- |
| ultrafast  | 8×                | worst               | +20% vs medium        |
| veryfast   | 4×                | fair                | +10% vs medium        |
| fast       | 2×                | good                | +5% vs medium         |
| medium     | 1×                | good (default)      | baseline              |
| slow       | 0.4×              | better              | -5% vs medium         |
| slower     | 0.2×              | better still        | -8% vs medium         |
| veryslow   | 0.1×              | best practical      | -10% vs medium        |
| placebo    | 0.05×             | marginal gain       | -11% vs medium        |

**Rule of thumb**: `placebo` is rarely worth it. Stop at `veryslow`.

### SVT-AV1 preset (separate scale, 0–13)
| Preset | Speed              | Use case                       |
| ------ | ------------------ | ------------------------------ |
| 0      | Slowest, best      | Archival (hours per minute)    |
| 4      | Slow               | Pro encode                     |
| 6      | Balanced           | **VideoSensei Sensei preset**  |
| 8      | Fast               | Mobile-friendly                |
| 10+    | Very fast          | Live streaming, not archival   |

---

## 5. Pixel Format

Always use `-pix_fmt yuv420p` unless you have a specific reason not to.

- `yuv420p` = 4:2:0 chroma subsampling (universal compat)
- `yuv444p` = full chroma (4× size, only for pro use)
- `yuv420p10le` = 10-bit (for HDR, must pair with HDR metadata)

For HDR content:
```
-pix_fmt yuv420p10le -color_primaries bt2020 -color_trc smpte2084 -colorspace bt2020nc
```

---

## 6. Audio Codec Decision

```
START
  │
  ▼
┌─────────────────────────────┐
│ Source audio codec?         │
└─────────────────────────────┘
  │
  ├─ Opus (any bitrate)
  │     │
  │     ▼
  │   Keep as Opus (-c:a copy) — already optimal
  │
  ├─ AAC (any bitrate)
  │     │
  │     ▼
  │   If bitrate ≤ 128k → copy
  │   If bitrate > 128k → re-encode to AAC 128k (or Opus 96k for AV1)
  │
  ├─ AC3 / DTS / EAC3 (5.1+)
  │     │
  │     ▼
  │   Downmix to stereo AAC 192k (unless user requests 5.1)
  │
  ├─ FLAC / PCM (lossless)
  │     │
  │     ▼
  │   Encode to AAC 192k (Crystal) or Opus 96k (Sensei)
  │
  └─ None
        │
        ▼
      Skip audio (-an)
```

---

## 7. Hardware Encoder Equivalents

When hardware acceleration is enabled, swap the codec:

| Software encoder     | NVIDIA (NVENC)   | Intel (QSV)     | AMD (AMF)      | Linux (VAAPI)  | macOS (VT)        | Android (MC)        |
| -------------------- | ---------------- | --------------- | -------------- | -------------- | ----------------- | ------------------- |
| libx264              | h264_nvenc       | h264_qsv        | h264_amf      | h264_vaapi     | h264_videotoolbox | (MediaCodec API)    |
| libx265              | hevc_nvenc       | hevc_qsv        | hevc_amf      | hevc_vaapi     | hevc_videotoolbox | (MediaCodec API)    |
| libsvtav1            | av1_nvenc        | av1_qsv         | av1_amf       | (not yet)      | av1_videotoolbox  | (limited devices)   |

**Quality note**: Hardware encoders are typically 5–15% less efficient than software
at the same target quality. For Sensei (AV1) preset, we keep software encoding.

---

## 8. Container Format Decision

| Codec(s) inside           | Container  | Why                              |
| ------------------------- | ---------- | -------------------------------- |
| H.264 + AAC               | MP4        | Universal compat                 |
| H.265 + AAC               | MP4        | iOS/macOS compat (`-tag:v hvc1`) |
| AV1 + Opus                | MKV or WebM | WebM for web; MKV for files    |
| H.264 + multiple audio    | MKV        | MP4 doesn't support many tracks  |
| HDR (any codec)           | MKV        | Better metadata support          |

---

## 9. FFmpeg Command Templates

### Lite (H.264)
```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 30 -preset veryfast -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -movflags +faststart \
  -metadata title="Compressed by VideoSensei" \
  output.mp4
```

### Balanced (H.265)
```bash
ffmpeg -i input.mp4 \
  -c:v libx265 -crf 26 -preset medium -pix_fmt yuv420p \
  -x265-params log-level=error \
  -c:a aac -b:a 128k \
  -tag:v hvc1 \
  -movflags +faststart \
  -metadata title="Compressed by VideoSensei" \
  output.mp4
```

### Crystal (H.265 high quality)
```bash
ffmpeg -i input.mp4 \
  -c:v libx265 -crf 22 -preset slow -pix_fmt yuv420p \
  -x265-params log-level=error \
  -c:a aac -b:a 192k \
  -tag:v hvc1 \
  -movflags +faststart \
  -metadata title="Compressed by VideoSensei" \
  output.mp4
```

### Sensei (AV1)
```bash
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -crf 32 -preset 6 -pix_fmt yuv420p \
  -c:a libopus -b:a 96k \
  -movflags +faststart \
  -metadata title="Compressed by VideoSensei" \
  output.mkv
```

### Custom (full control)
User-selected flags appended to base:
```bash
ffmpeg -i input.mp4 \
  -c:v {codec} -crf {crf} -preset {preset} -pix_fmt yuv420p \
  [-vf scale={width}:-2] [-r {fps}] \
  -c:a {audio_codec} -b:a {audio_bitrate} \
  [-tag:v hvc1] \
  -movflags +faststart \
  output.{container}
```

---

## 10. Future Considerations

- **VVC (H.266)** — finalized 2022, encoders maturing. Watch in 2026–2027.
  When ready, add as "🚀 Future" preset.
- **JPEG XL for thumbnails** — better than JPEG, supported in modern ffmpeg
- **APV (Adobe Pro Video)** — pro-grade mezzanine codec, 2025
- **LCEVC** — enhancement layer codec, can sit on top of H.264/H.265/AV1
  for additional 20–40% compression. Watch for encoder support.

We will revisit this document when any of the above become practical.
