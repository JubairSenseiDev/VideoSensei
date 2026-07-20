# 🎨 VideoSensei — Branding Guide

This document defines the **VideoSensei** brand identity.
All product decisions — UI, copy, marketing, packaging — should align with this.

---

## 1. Brand Name

> **VideoSensei** — one word, two capital letters, no spaces, no hyphens.

### Meaning
- **Video** — what we touch
- **Sensei** (先生) — Japanese for "master/teacher"; a person who has mastered their craft

### Tagline options (ranked)
1. 🥇 **"Master your video. Sensei-grade clarity."**
2. "The master's touch for every pixel."
3. "Compress like a master. Deliver like a sensei."
4. "Small file. Master-class clarity."

### Voice
- **Confident, not arrogant** — like a calm master, not a loud marketer
- **Technical when needed, plain otherwise** — explain *why*, not just *what*
- **Respectful of the user's time** — show numbers, not adjectives

---

## 2. Logo Direction

### Concept
A fusion mark combining:
- The Japanese kanji **"技"** (waza = skill/technique) OR Latin **"S"** for Sensei
- A subtle play-arrow / video-frame silhouette
- A brush-stroke aesthetic (sumi-e calligraphy influence)

### Construction
```
   ╱━━━━━╲
  ╱  ┃█┃  ╲       ← Brushed "S" with play triangle negative space
  ╲  ┃█┃  ╱
   ╲━━━━━╱
   VIDEOSENSEI
```

### Variants
- **Primary mark**: indigo-on-cream
- **App icon (Android)**: full-bleed indigo background, cream mark
- **App icon (Linux/Windows)**: rounded square with subtle gradient
- **Monochrome**: for footer /合作伙伴 placements
- **Animated logo**: brush stroke draws in 1.2s on app launch

### Don't
- ❌ Don't spell as "VideoSensi" (the old misspelling)
- ❌ Don't use a literal sensei/teacher illustration (too literal, ages poorly)
- ❌ Don't use a video camera icon (too generic)
- ❌ Don't use red sun/rising sun motif (cultural sensitivity)

---

## 3. Color System

### Primary Palette

| Token             | Hex        | Usage                              |
| ----------------- | ---------- | ---------------------------------- |
| `indigo.900`      | `#1E1B4B`  | App bar, primary surfaces (dark)   |
| `indigo.700`      | `#3730A3`  | Pressed states, hovers             |
| `indigo.600`      | `#4F46E5`  | Primary buttons, active states     |
| `indigo.500`      | `#6366F1`  | Links, secondary buttons           |

### Accent Palette

| Token             | Hex        | Usage                              |
| ----------------- | ---------- | ---------------------------------- |
| `cyan.400`        | `#22D3EE`  | Accent highlights, progress bars   |
| `cyan.500`        | `#06B6D4`  | Neon accent, glow effects          |
| `cyan.300`        | `#67E8F9`  | Subtle accents on dark             |

### Neutral Palette

| Token             | Hex        | Usage                              |
| ----------------- | ---------- | ---------------------------------- |
| `cream.50`        | `#FAFAF9`  | Light-mode background              |
| `cream.100`       | `#F5F5F4`  | Light-mode cards                   |
| `ink.900`         | `#0F0F14`  | Dark-mode background               |
| `ink.800`         | `#1A1A22`  | Dark-mode cards                    |
| `ink.700`         | `#2A2A35`  | Dark-mode elevated surfaces        |

### Semantic Colors

| Token    | Hex        | Usage                      |
| -------- | ---------- | -------------------------- |
| success  | `#10B981`  | Compression complete       |
| warning  | `#F59E0B`  | Slow preset, large file    |
| error    | `#EF4444`  | FFmpeg failure             |
| info     | `#3B82F6`  | Tips, hints                |

### Glow / Glassmorphism
- Card surfaces use `backdrop-filter: blur(20px)` + `rgba(30, 27, 75, 0.6)`
- Progress rings use cyan glow `box-shadow: 0 0 20px #06B6D4`
- Buttons hover with subtle indigo bloom

---

## 4. Typography

### Font Stack

| Role           | Font                    | Weights      |
| -------------- | ----------------------- | ------------ |
| Headlines      | **Inter** (or SF Pro)   | 600, 700, 800 |
| Body           | **Inter**               | 400, 500     |
| Numbers / Stats| **JetBrains Mono**      | 500, 700     |
| Code / FFmpeg  | **JetBrains Mono**      | 400          |
| Bengali support| **Noto Sans Bengali**   | 400, 500, 700 |

### Scale (Material 3 tokens)

| Token          | Size  | Line height |
| -------------- | ----- | ----------- |
| displayLarge   | 57px  | 64px        |
| displayMedium  | 45px  | 52px        |
| headlineLarge  | 32px  | 40px        |
| headlineSmall  | 24px  | 32px        |
| titleLarge     | 22px  | 28px        |
| bodyLarge      | 16px  | 24px        |
| bodyMedium     | 14px  | 20px        |
| labelLarge     | 14px  | 20px        |

### Rules
- Numbers in stats / file sizes → **JetBrains Mono with tabular figures**
- Headlines use **Inter 700** with `-0.02em` letter-spacing
- Bengali text: enable `font-feature-settings: "kern", "liga"`

---

## 5. Iconography

- **System**: Material Symbols (Rounded variant) — consistent with Material 3
- **Style**: Rounded, 2px stroke equivalent
- **Sizes**: 20 / 24 / 32 / 48 px
- **Custom icons** (for unique features): hand-drawn brush style, matching logo

Required custom icons:
- 🥋 Sensei badge (for "Sensei" preset)
- 🪶 Feather (for "Lite" preset)
- ⚖️ Scale (for "Balanced" preset)
- 💎 Diamond (for "Crystal" preset)
- 🎯 Target (for "Custom" preset)

---

## 6. Tone of Voice — Microcopy

### Do
- ✅ "Sensei recommends **Balanced** — halves file size, keeps quality sharp."
- ✅ "Done in 1m 23s. Saved 187 MB (74% smaller)."
- ✅ "Pick a video to begin"

### Don't
- ❌ "Our amazing AI-powered compression engine will…"
- ❌ "Compression successful!!!" (no exclamation spam)
- ❌ "Please select a file from your storage device" (overly formal)

### Empty states
- "No videos yet. Pick one to start your journey. 🥋"
- "History is empty. Your sensei will remember every video you master."

### Errors
- "FFmpeg couldn't process this file. Want to try a different preset?"
- "This codec isn't supported on your device. Falling back to H.264."

---

## 7. Application Icon (per platform)

### Android
- Adaptive icon: foreground = Sensei mark, background = indigo gradient
- Round icon: same, masked to circle
- Legacy icon: full-bleed indigo with cream mark
- Size: 512×512 master, scaled to 48/72/96/144/192

### Linux
- 512×512 PNG + SVG
- Follows [freedesktop.org icon spec](https://specifications.freedesktop.org/icon-theme-spec/)
- Place in `hicolor/512x512/apps/videosensei.png`

### Windows
- ICO with multiple sizes (16/24/32/48/64/128/256)
- Use [RealFaviconGenerator](https://realfavicongenerator.net/) rules

---

## 8. Packaging Aesthetics

### Android (Play Store listing)
- Feature graphic: 1024×500, indigo→cyan gradient, large Sensei mark, tagline
- Phone screenshot 1: Home screen — shows recent + quick action
- Phone screenshot 2: Picker — file manager integration
- Phone screenshot 3: Processing — live progress ring with stats
- Phone screenshot 4: Result — before/after comparison

### Linux (.deb / AppImage)
- AppImage: include `.DirIcon` and `.desktop` file
- Debian package: proper control file, postinst script for desktop integration

### Windows (.exe)
- NSIS installer with custom Sensei wizard graphics
- Desktop shortcut with icon
- Start menu folder: "VideoSensei"

---

## 9. Sound Design (optional, future)

- Launch: soft brush stroke sound (180ms)
- Compression complete: gentle chime (singing bowl tone, 400ms)
- Error: muted wood-block tap (200ms)
- All sounds can be disabled in Settings

---

## 10. Brand Don'ts

- ❌ Never spell as "VideoSensi" — always **VideoSensei**
- ❌ Never use generic stock illustrations of "video cameras"
- ❌ Never use bright primary colors (red/yellow/green) as primary brand
- ❌ Never use Comic Sans, Papyrus, or system default fonts in marketing
- ❌ Never use stock photos of "Asian teacher" — culturally reductive
- ❌ Never use the rising-sun motif — politically sensitive in Asia

---

## 11. Open-Source Identity

- Repository: `github.com/JubairSenseiDev/VideoSensei`
- License: MIT
- Author: Jubair Sensei `<jubairsensei@gmail.com>`
- Author handles: `@JubairFF` (Telegram), `JubairSenseiDev` (GitHub)
- Contributor agreement: standard MIT, no CLA required for v1.x
