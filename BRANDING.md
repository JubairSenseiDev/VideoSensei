# 🥋 VideoSensei — Branding Guide

This document defines the **VideoSensei** brand identity.
All product decisions — UI, copy, marketing, packaging — should align with this.

> **Theme tokens live in [`THEME.md`](./THEME.md)** — extracted directly from [jubairsensei.com](https://jubairsensei.com).
> This document defines *what* the brand is; `THEME.md` defines *how* it looks in code.

---

## 1. Brand Name

> **VideoSensei** — one word, two capital letters, no spaces, no hyphens.

### Meaning
- **Video** — what we touch
- **Sensei** (先生) — Japanese for "master/teacher"; a person who has mastered their craft

### Tagline (primary)
> 🥇 **"Master your video. Sensei-grade clarity."**

### Tagline (alternative, brand-aligned with jubairsensei.com)
> 🥈 **"Compress like a master. Hack, learn, dominate."**

The second tagline inherits the **Jubair Sensei** brand voice (`"Hack, learn, dominate."`)
and is used on the splash screen, GitHub README header, and Telegram channel description.

### Voice
- **Confident, not arrogant** — like a calm master, not a loud marketer
- **Terminal-flavored** — short, sharp, monospace where it counts
- **Technical when needed, plain otherwise** — explain *why*, not just *what*
- **Respectful of the user's time** — show numbers, not adjectives

---

## 2. Logo Direction

### Concept
A fusion mark combining:
- The Japanese kanji **"技"** (waza = skill/technique) OR Latin **"S"** for Sensei
- A subtle play-arrow / video-frame silhouette
- A brush-stroke aesthetic (sumi-e calligraphy influence)
- **Set on the Jubair Sensei palette** — neon green `#00FF88` on near-black `#0A0A0B`

### Construction
```
   ╱━━━━━╲
  ╱  ┃█┃  ╲       ← Brushed "S" with play triangle negative space
  ╲  ┃█┃  ╱         Stroke: #00FF88 (neon green, dark mode)
   ╲━━━━━╱          Background: #0A0A0B (near-black)
   VIDEOSENSEI      Wordmark: Cabinet Grotesk Bold, all-caps
```

### Variants
- **Primary mark (dark)**: neon green `#00FF88` on near-black `#0A0A0B`
- **Primary mark (light)**: forest green `#008246` on warm cream `#F0F0EC`
- **App icon (Android)**: full-bleed `#0A0A0B` background, neon green mark
- **App icon (Linux/Windows)**: rounded square 12px radius, same as Android
- **Monochrome**: white mark for footer /合作伙伴 placements
- **Animated logo**: brush stroke draws in 1.2s on app launch (SVG path animation)

### Don't
- ❌ Don't spell as "VideoSensi" (the old misspelling)
- ❌ Don't use a literal sensei/teacher illustration (too literal, ages poorly)
- ❌ Don't use a video camera icon (too generic)
- ❌ Don't use red sun/rising sun motif (cultural sensitivity)
- ❌ Don't use indigo/blue (those aren't our colors — see `THEME.md`)
- ❌ Don't use pure white `#FFFFFF` or pure black `#000000` (always slightly warm/cool variants)

---

## 3. Color System

> 📌 **Full token reference: [`THEME.md`](./THEME.md)**

### Signature Palette (at a glance)

| Mode  | Background  | Accent (signature)   | Ink (text)  |
| ----- | ----------- | -------------------- | ----------- |
| Dark  | `#0A0A0B`   | `#00FF88` neon green | `#FFFFFF`   |
| Light | `#F0F0EC`   | `#008246` forest green | `#1E1914` |

**Dark mode is the default** — VideoSensei honors the terminal heritage of its predecessor.

### Why green?
- **Saved bytes = green** — the most intuitive color for "compression succeeded"
- **Mastery / growth** — green = sensei-level skill in many cultures
- **Terminal heritage** — classic green-on-black, hacker aesthetic
- **Brand alignment** — matches jubairsensei.com exactly

### Decorative accents (for tags, badges, charts)

| Color  | Hex (dark) | Hex (light) | Used for                |
| ------ | ---------- | ----------- | ----------------------- |
| green  | `#00FF88`  | `#008246`   | Primary (= accent)      |
| cyan   | `#22D3EE`  | `#0891B2`   | Balanced preset badge   |
| blue   | `#3B82F6`  | `#3B82F6`   | Crystal preset badge    |
| purple | `#C77DFF`  | `#9333EA`   | Custom preset badge     |
| orange | `#FB923C`  | `#EA580C`   | Lite preset badge       |
| yellow | `#FACC15`  | `#CA8A04`   | Warning                 |
| red    | `#F87171`  | `#DC2626`   | Error / destructive     |
| lime   | `#D4FF00`  | `#006633`   | Code blocks             |

---

## 4. Typography

> 📌 **Full type scale: [`THEME.md`](./THEME.md#2-typography)**

| Role            | Font                    | Weights              |
| --------------- | ----------------------- | -------------------- |
| Headlines       | **Cabinet Grotesk**     | 400, 500, 700, 800, 900 |
| Body / UI       | **Satoshi**             | 400, 500, 700, 900   |
| Numbers / Code  | **JetBrains Mono**      | 400, 500             |
| Bengali support | **Noto Sans Bengali**   | 400, 500, 700        |

### Why these fonts?
- **Cabinet Grotesk** — modern geometric sans, distinctive enough to feel branded
- **Satoshi** — excellent legibility, used as default body across jubairsensei.com
- **JetBrains Mono** — perfect for stats, percentages, file sizes (tabular figures)
- All three are **free for commercial use** (Fontshare OFL / Google Fonts OFL)

### Rules
- Numbers in stats / file sizes → **JetBrains Mono with tabular figures**
- Headlines use **Cabinet Grotesk 700** with `-0.02em` letter-spacing
- Bengali text: Cabinet Grotesk for headlines (with Noto fallback), Satoshi for body (with Noto fallback)

---

## 5. Iconography

- **System**: Material Symbols (Rounded variant) — consistent with Material 3
- **Style**: Rounded, 2px stroke equivalent
- **Sizes**: 20 / 24 / 32 / 48 px
- **Custom icons** (for unique features): hand-drawn brush style, matching logo

Required custom icons (preset badges):
- 🥋 Sensei badge → **neon green** `#00FF88` (dark) / `#008246` (light)
- 🪶 Feather → orange (Lite preset)
- ⚖️ Scale → cyan (Balanced preset)
- 💎 Diamond → blue (Crystal preset)
- 🎯 Target → purple (Custom preset)

---

## 6. Tone of Voice — Microcopy

### Do
- ✅ "Sensei recommends **Balanced** — halves file size, keeps quality sharp."
- ✅ "Done in 1m 23s. Saved 187 MB (74% smaller)."
- ✅ "Pick a video to begin"
- ✅ "Hack the size. Keep the clarity." (brand-aligned CTA)

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
- Adaptive icon: foreground = Sensei mark (neon green), background = `#0A0A0B`
- Round icon: same, masked to circle
- Legacy icon: full-bleed `#0A0A0B` with neon green mark
- Size: 512×512 master, scaled to 48/72/96/144/192

### Linux
- 512×512 PNG + SVG
- Follows [freedesktop.org icon spec](https://specifications.freedesktop.org/icon-theme-spec/)
- Place in `hicolor/512x512/apps/videosensei.png`

### Windows
- ICO with multiple sizes (16/24/32/48/64/128/256)
- Dark background by default (`#0A0A0B`)

---

## 8. Packaging Aesthetics

### Android (Play Store listing)
- Feature graphic: 1024×500, `#0A0A0B` background, large neon green Sensei mark, tagline
- Phone screenshot 1: Home screen — shows recent + quick action
- Phone screenshot 2: Picker — file manager integration
- Phone screenshot 3: Processing — live progress ring with neon green glow
- Phone screenshot 4: Result — before/after comparison + "74% smaller" badge in green

### Linux (.deb / AppImage)
- AppImage: include `.DirIcon` and `.desktop` file
- Debian package: proper control file, postinst script for desktop integration

### Windows (.exe)
- NSIS installer with custom Sensei wizard graphics (dark background, neon green accents)
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
- ❌ Never use indigo, blue, or purple as primary brand color (green is the signature)
- ❌ Never use Comic Sans, Papyrus, Roboto, or system default fonts in marketing
- ❌ Never use pure black `#000000` (use `#0A0A0B` — slightly cooler than pure black)
- ❌ Never use pure white `#FFFFFF` for surfaces in dark mode (use at low opacity)
- ❌ Never use stock photos of "Asian teacher" — culturally reductive
- ❌ Never use the rising-sun motif — politically sensitive in Asia
- ❌ Never use rounded corners > 24px (sharp terminal aesthetic)

---

## 11. Open-Source Identity

- Repository: `github.com/JubairSenseiDev/VideoSensei`
- License: MIT
- Author: Jubair Sensei `<jubairsensei@gmail.com>`
- Author site: [jubairsensei.com](https://jubairsensei.com)
- Author handles: `@JubairSensei` (Telegram, YouTube), `JubairSenseiDev` (GitHub)
- Contributor agreement: standard MIT, no CLA required for v1.x

---

## 12. Relationship to Jubair Sensei (parent brand)

VideoSensei is the **first product** under the **Jubair Sensei** brand umbrella.

| Element        | Jubair Sensei (parent)  | VideoSensei (product)            |
| -------------- | ----------------------- | -------------------------------- |
| Site           | jubairsensei.com        | (subdomain or path, future)      |
| Tagline        | "Hack, learn, dominate" | "Master your video. Sensei-grade clarity." |
| Primary color  | Neon green `#00FF88`    | Same — inherited                  |
| Background     | Near-black `#0A0A0B`    | Same — inherited                  |
| Headlines font | Cabinet Grotesk         | Same — inherited                  |
| Body font      | Satoshi                 | Same — inherited                  |
| Voice          | Terminal, hacker        | Same — inherited                  |

When VideoSensei references its parent brand (About screen, splash, footer):
- Link to `https://jubairsensei.com`
- Use the Jubair Sensei logo from `https://jubairsensei.com/logo.jpg`
- Cite the brand tagline "Hack, learn, dominate."

---

## 13. Theme Provenance

The visual identity (colors, fonts, motion) was extracted directly from
`jubairsensei.com` on 2026-07-21. Full extraction details in [`THEME.md`](./THEME.md).

If jubairsensei.com theme changes, re-extract and update `THEME.md` first,
then propagate changes here and to Flutter code.
