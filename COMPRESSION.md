# 🗜️ VideoSensei — Compression Strategy

This is the technical heart of VideoSensei.
The goal: **shrink file size dramatically, keep the picture indistinguishable from the source.**

---

## 1. Core Philosophy

> "Compression you can't see is compression done right."

Three principles:

1. **Perceptual quality over PSNR** — we optimize for what the human eye sees, not what math measures.
2. **Right codec for the right job** — H.264 for compat, H.265 for balance, AV1 for future.
3. **Transparency by default** — show every FFmpeg flag in the history log. No magic.

---

## 2. Codec Decision Matrix

| Source codec | Recommended output | Why                                          |
| ------------ | ------------------ | -------------------------------------------- |
| H.264 (old)  | H.265              | Modern, 50% smaller at same quality          |
| H.265        | H.265 (re-encode only if high bitrate) | Don't re-encode already-compressed unless wasteful |
| VP9          | AV1                | Better compression than VP9                  |
| AV1          | AV1 (copy)         | Don't re-encode — already best-in-class      |
| MPEG-2 / MPEG-4 | H.264 (Lite)    | Old codecs → modern, big wins                |
| ProRes / DNxHR | H.265 (Crystal)  | Pro production → distribution quality        |
| Anything 4K@60fps | H.265 (Balanced) | Smooth balance of size & encode time     |

**Smart mode** runs this matrix automatically, then applies per-title analysis.

---

## 3. Quality Presets — Deep Dive

### 🪶 Lite — "Quick share, max compat"
```
ffmpeg -i input.mp4 \
  -c:v libx264 -crf 30 -preset veryfast -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart \
  output.mp4
```
- **Codec**: H.264 (plays everywhere, including old devices)
- **CRF 30**: visually lossless for casual content
- **Preset `veryfast`**: ~5× realtime encoding
- **Audio**: AAC 128k (transparent for speech, fine for music)
- **`+faststart`**: web-streamable (moov atom at front)
- **Best for**: WhatsApp/Telegram share, email attachments

### ⚖️ Balanced — "Daily default"
```
ffmpeg -i input.mp4 \
  -c:v libx265 -crf 26 -preset medium -pix_fmt yuv420p \
  -c:a aac -b:a 128k -tag:v hvc1 -movflags +faststart \
  output.mp4
```
- **Codec**: H.265 / HEVC (50% smaller than H.264 at same quality)
- **CRF 26**: visually lossless for most content
- **Preset `medium`**: ~1× realtime (good speed/quality balance)
- **`-tag:v hvc1`**: required for QuickTime/iOS compatibility
- **Best for**: General use, cloud storage, archive

### 💎 Crystal — "Archive quality"
```
ffmpeg -i input.mp4 \
  -c:v libx265 -crf 22 -preset slow -pix_fmt yuv420p \
  -c:a aac -b:a 192k -tag:v hvc1 -movflags +faststart \
  output.mp4
```
- **Codec**: H.265
- **CRF 22**: perceptually transparent for nearly all content
- **Preset `slow`**: ~0.3× realtime (worth it for archival)
- **Audio**: AAC 192k (transparent for critical listening)
- **Best for**: Archiving family videos, masters, high-value content

### 🥋 Sensei — "Future-proof master"
```
ffmpeg -i input.mp4 \
  -c:v libsvtav1 -crf 32 -preset 6 -pix_fmt yuv420p \
  -c:a libopus -b:a 96k -movflags +faststart \
  output.mp4
```
- **Codec**: AV1 (next-gen, 30% smaller than H.265)
- **CRF 32**: AV1 CRF scale differs from H.264/H.265 (32 ≈ H.265 CRF 24)
- **SVT-AV1 preset 6**: ~0.15× realtime — slow but incredible ratio
- **Audio**: Opus 96k (transparent, smaller than AAC)
- **Best for**: Future-proofing, web delivery, maximum compression

> ⚠️ AV1 encoding is slow. On mid-range Android, expect ~0.05× realtime.
> The UI will warn users and recommend Balanced for casual use.

### 🎯 Custom — "Full control"

User picks:
- Codec (H.264 / H.265 / AV1)
- CRF (0–51, slider with live recommendation)
- Preset (ultrafast → placebo)
- Resolution (original / 4K / 1080p / 720p / 480p / custom)
- FPS (original / 60 / 30 / 24)
- Audio codec (AAC / Opus / copy / drop)
- Audio bitrate (64k / 96k / 128k / 192k / 256k / custom)
- Container (MP4 / MKV / WebM)
- HDR preservation (on/off)
- Hardware acceleration (auto / forced / disabled)

---

## 4. Pre-Encode Size Prediction

Before encoding, we estimate the output size using:

```
estimated_size_mb = (target_bitrate_kbps × duration_sec) / 8 / 1024

target_bitrate_kbps = (
  source_bitrate_kbps
  × codec_efficiency_factor    // 1.0 for H.264, 0.5 for H.265, 0.35 for AV1
  × crf_factor                 // derived from CRF (lower CRF = higher bitrate)
  × motion_factor              // 0.8–1.2 based on sample probe
)
```

This gives a **±15% accurate estimate** before encoding starts — shown to the user
on the configure screen as "≈ 42 MB (vs 187 MB source, ~78% smaller)".

---

## 5. Smart Mode (Auto) Algorithm

```
1. Probe source with ffprobe
   → codec, resolution, fps, bitrate, duration, audio

2. Decision tree:
   if source_bitrate < 500kbps:
       recommend: "Source already small. Skip compression."
   elif source_codec == AV1:
       recommend: "Copy (already optimal)"
   elif duration < 30s:
       recommend: Lite (quick share)
   elif resolution >= 4K:
       recommend: Balanced (downscale to 1080p optional)
   elif source_bitrate > 5Mbps and motion == high:
       recommend: Crystal (preserve detail)
   else:
       recommend: Balanced

3. Sample probe (2-second encode at recommended preset)
   → measure actual bitrate reduction
   → if reduction < 30%, suggest trying Sensei (AV1) instead
```

---

## 6. Hardware Acceleration

### Detection (runtime)
- **Windows**: check for NVIDIA GPUs via `nvenc` codec availability
- **Linux**: check `/dev/dri/renderD128` for VAAPI
- **Android**: query `MediaCodecList` for HEVC/AV1 encoders
- **macOS** (future): always available via VideoToolbox

### Encoding flags

| Platform | Encoder flag                                          |
| -------- | ----------------------------------------------------- |
| Windows (NVENC H.264) | `h264_nvenc -rc vbr -cq 26 -preset p5`  |
| Windows (NVENC H.265) | `hevc_nvenc -rc vbr -cq 28 -preset p5`  |
| Linux (VAAPI H.264)   | `h264_vaapi -qp 26`                     |
| Linux (VAAPI H.265)   | `hevc_vaapi -qp 28`                     |
| Android (MediaCodec)  | via `media_kit` or `ffmpeg-kit` MediaCodec module |

### Trade-off
- **Pros**: 5–20× faster, lower battery use on mobile
- **Cons**: Slightly lower quality than software encoder at same CRF
- **Default**: Auto-detect, user can force-disable in Settings

---

## 7. Audio Strategy

| Source audio      | Lite       | Balanced   | Crystal    | Sensei   |
| ----------------- | ---------- | ---------- | ---------- | -------- |
| AAC 320k stereo   | AAC 128k   | AAC 128k   | AAC 192k   | Opus 96k |
| AAC 128k stereo   | AAC 128k   | AAC 128k   | AAC 192k   | Opus 96k |
| Opus any          | AAC 128k   | Opus copy  | Opus copy  | Opus copy|
| AC3 / DTS         | AAC 128k   | AAC 128k   | AAC 192k   | Opus 96k |
| 5.1 surround      | AAC 128k stereo | AAC 192k stereo | AAC 256k 5.1 | Opus 128k 5.1 |
| No audio          | (skip)     | (skip)     | (skip)     | (skip)   |

Rules:
- Never upscale audio (don't 128k → 192k)
- Prefer Opus for new encodes (better compression)
- Preserve surround channels when source has them
- Drop audio entirely if user picks "video only" mode

---

## 8. Pre-Processing (safety checks)

Before encoding, VideoSensei does:

1. **Stream copy probe**: try `ffmpeg -i input -c copy output` first
   - If success and output is smaller than 50% of source → just remux (no re-encode)
   - This handles "MP4 with bad container but good streams"
2. **Resolution sanity**: don't upscale (output ≤ source)
3. **FPS sanity**: don't add frames (output ≤ source, unless user wants 60fps interpolation)
4. **HDR detection**: if source has HDR, preserve `master-display` and `max-cll` metadata
5. **Corrupt frame skip**: `-err_detect ignore_err` to survive bad frames

---

## 9. Error Handling

| Failure mode              | Behavior                                              |
| ------------------------- | ----------------------------------------------------- |
| FFmpeg exits non-zero     | Show last 10 lines of stderr, offer "Try Crystal"     |
| Output larger than source | Auto-delete output, suggest "Lite" preset             |
| Disk full mid-encode      | Clean up partial output, surface clear error          |
| Source is DRM-protected   | Detect early, refuse with explanation                 |
| Audio decode failure      | Re-encode with `-an` (drop audio), warn user          |
| Out of memory             | Drop to `ultrafast` preset, retry                     |

---

## 10. Benchmark Targets

Test corpus: 5 videos, each 60 seconds, 1080p H.264 (~50 MB each)
- Talking head (low motion)
- Sports clip (high motion)
- Screen recording (text-heavy)
- Nature shot (gradient-heavy)
- Animation (flat colors)

Expected results on a mid-range laptop (Ryzen 5 5500U):

| Preset  | Avg time | Avg size reduction | Avg SSIM |
| ------- | -------- | ------------------ | -------- |
| Lite    | 12s      | 65%                | 0.96     |
| Balanced| 55s      | 78%                | 0.97     |
| Crystal | 4m 10s   | 60%                | 0.99     |
| Sensei  | 8m 30s   | 85%                | 0.97     |

These are baseline targets for v1.0.0 release validation.

---

## 11. Open Questions (to resolve in Phase 2)

- [ ] AV1 encode time on Android mid-range — is it acceptable, or gate Sensei preset behind a warning?
- [ ] Should we offer VMAF scoring in the result screen (requires Netflix VMAF model)?
- [ ] CRF → bitrate estimation is approximate; should we run a real 2-second probe always?
- [ ] HDR support in `ffmpeg_kit_flutter_new` — need to verify libsvtav1 build flags
- [ ] Bundling FFmpeg size budget — can we strip unused codecs to save 5–10 MB?
