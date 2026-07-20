# 🎨 VideoSensei — Theme Tokens

> **Single source of truth** for VideoSensei's design tokens.
> Extracted directly from [jubairsensei.com](https://jubairsensei.com) (the official Jubair Sensei brand site) on 2026-07-21.
> All Flutter code, CSS, and marketing assets must reference these exact values.

---

## 0. Brand Personality

> *"Hack, learn, dominate."*

VideoSensei inherits the **Jubair Sensei** aesthetic — a **terminal-inspired, dark-first** identity with **neon green** as the signature accent. It honors the tool's bash-CLI heritage (VideoSensi 2019–2024) while bringing it into a modern native-app shell.

**Keywords**: hacker · minimal · sharp · neon · terminal · mastery · green

**Vibe references**:
- GitHub dark theme
- Vercel / Linear / Raycast aesthetic
- Classic terminal emulators (xterm, iTerm2)
- Mr. Robot UI (minimal, monospace, green-on-black)

---

## 1. Color Tokens

All colors stored as space-separated RGB triplets (CSS variable convention from jubairsensei.com) so they can be reused with `/opacity` modifiers. Flutter equivalents provided.

### 1.1 Dark Theme (DEFAULT)

```css
[data-theme="dark"] {
  --c-bg:           10 10 11;        /* #0A0A0B — near-black, slightly cool */
  --c-bg-elevated:  17 17 20;        /* #111114 — elevated surfaces */
  --c-surface:      255 255 255;     /* #FFFFFF — used with low opacity */
  --c-surface-hover: 255 255 255;    /* #FFFFFF — used at slightly higher opacity */
  --c-accent:       0 255 136;       /* #00FF88 — NEON GREEN, the signature */
  --c-ink:          255 255 255;     /* #FFFFFF — primary text */
  --c-ink-secondary: 161 161 170;    /* #A1A1AA — secondary text */
  --c-ink-muted:    82 82 91;        /* #52525B — muted text */
  --c-line:         255 255 255;     /* #FFFFFF — borders, with opacity */
  --c-line-strong:  255 255 255;     /* #FFFFFF — stronger borders */
}
```

| Token              | Hex        | Flutter `Color`           | Usage                                  |
| ------------------ | ---------- | ------------------------- | -------------------------------------- |
| `bg`               | `#0A0A0B`  | `Color(0xFF0A0A0B)`       | App background                         |
| `bg-elevated`      | `#111114`  | `Color(0xFF111114)`       | Cards, dialogs, elevated surfaces      |
| `surface`          | `#FFFFFF`  | `Color(0xFFFFFFFF)`       | Used at 4–8% opacity for hover states  |
| `surface-hover`    | `#FFFFFF`  | `Color(0xFFFFFFFF)`       | Used at 10% opacity for active states  |
| **`accent`**       | **`#00FF88`** | **`Color(0xFF00FF88)`** | **Primary accent — neon green** 🟢    |
| `ink`              | `#FFFFFF`  | `Color(0xFFFFFFFF)`       | Primary text, headings                 |
| `ink-secondary`    | `#A1A1AA`  | `Color(0xFFA1A1AA)`       | Secondary text, captions               |
| `ink-muted`        | `#52525B`  | `Color(0xFF52525B)`       | Tertiary text, placeholders            |
| `line`             | `#FFFFFF` @ 8–12% | `Color(0x14FFFFFF)` | Hairline borders, dividers             |
| `line-strong`      | `#FFFFFF` @ 20%   | `Color(0x33FFFFFF)` | Emphasized borders                     |

### 1.2 Light Theme

```css
[data-theme="light"] {
  --c-bg:           240 240 236;     /* #F0F0EC — warm cream */
  --c-bg-elevated:  250 249 245;     /* #FAF9F5 — softer cream */
  --c-surface:      30 25 20;        /* #1E1914 — warm dark, used with opacity */
  --c-surface-hover: 30 25 20;       /* #1E1914 */
  --c-accent:       0 130 70;        /* #008246 — forest green */
  --c-ink:          30 25 20;        /* #1E1914 — warm near-black */
  --c-ink-secondary: 80 72 60;       /* #50483C */
  --c-ink-muted:    120 110 95;      /* #786E5F */
  --c-line:         30 25 20;        /* with opacity */
  --c-line-strong:  30 25 20;        /* with opacity */
}
```

| Token              | Hex        | Flutter `Color`           | Usage                                  |
| ------------------ | ---------- | ------------------------- | -------------------------------------- |
| `bg`               | `#F0F0EC`  | `Color(0xFFF0F0EC)`       | App background (warm cream)            |
| `bg-elevated`      | `#FAF9F5`  | `Color(0xFFFAF9F5)`       | Cards, dialogs                         |
| `surface`          | `#1E1914`  | `Color(0xFF1E1914)`       | Used at 4–8% opacity for hover states  |
| `surface-hover`    | `#1E1914`  | `Color(0xFF1E1914)`       | Used at 10% opacity                    |
| **`accent`**       | **`#008246`** | **`Color(0xFF008246)`** | **Primary accent — forest green** 🌲  |
| `ink`              | `#1E1914`  | `Color(0xFF1E1914)`       | Primary text                           |
| `ink-secondary`    | `#50483C`  | `Color(0xFF50483C)`       | Secondary text                         |
| `ink-muted`        | `#786E5F`  | `Color(0xFF786E5F)`       | Muted text                             |
| `line`             | `#1E1914` @ 10%  | `Color(0x1A1E1914)`  | Hairline borders                       |
| `line-strong`      | `#1E1914` @ 20%  | `Color(0x331E1914)`  | Emphasized borders                     |

### 1.3 Semantic Colors (mode-specific)

| Purpose        | Dark hex    | Light hex   | Usage                              |
| -------------- | ----------- | ----------- | ---------------------------------- |
| success        | `#00FF88`   | `#008246`   | Compression done (= accent)        |
| warning        | `#EAB308`   | `#CA8A04`   | Slow preset / large file warning   |
| error          | `#EF4444`   | `#DC2626`   | FFmpeg failure                     |
| info           | `#0891B2`   | `#0891B2`   | Tips, hints (cyan)                 |

### 1.4 Decorative Accent Palette (mode-aware)

From jubairsensei.com's color utility classes. Use sparingly — for category tags, charts, badges.

| Color  | Dark hex    | Light hex   | Usage idea                  |
| ------ | ----------- | ----------- | --------------------------- |
| green  | `#00FF88`   | `#009952`   | Success / primary (= accent)|
| cyan   | `#22D3EE`   | `#0891B2`   | Info / links alt            |
| blue   | `#3B82F6`   | `#3B82F6`   | External links              |
| purple | `#C77DFF`   | `#9333EA`   | "Custom" preset badge       |
| pink   | `#F472B6`   | `#DB2777`   | Decorative                  |
| orange | `#FB923C`   | `#EA580C`   | "Lite" preset badge         |
| red    | `#F87171`   | `#DC2626`   | Error / destructive         |
| yellow | `#FACC15`   | `#CA8A04`   | Warning                     |
| teal   | `#4ECDC4`   | `#4ECDC4`   | Decorative                  |
| lime   | `#D4FF00`   | `#006633`   | Code blocks                 |

### 1.5 Preset Brand Colors

Each preset gets its own decorative color for cards and chips:

| Preset    | Color        | Hex (dark) | Hex (light) |
| --------- | ------------ | ---------- | ----------- |
| 🪶 Lite   | orange       | `#FB923C`  | `#EA580C`   |
| ⚖️ Balanced | cyan       | `#22D3EE`  | `#0891B2`   |
| 💎 Crystal | blue        | `#3B82F6`  | `#3B82F6`   |
| 🥋 Sensei | accent green | `#00FF88`  | `#008246`   |
| 🎯 Custom | purple       | `#C77DFF`  | `#9333EA`   |

---

## 2. Typography

### 2.1 Font Families

```html
<!-- From jubairsensei.com index.html -->
<link href="https://api.fontshare.com/v2/css?f[]=cabinet-grotesk@400,500,700,800,900&f[]=satoshi@400,500,700,900&display=swap" rel="stylesheet" />
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet" />
```

| Role                | Font                    | Weights       | Source           |
| ------------------- | ----------------------- | ------------- | ---------------- |
| Headlines / Display | **Cabinet Grotesk**     | 400, 500, 700, 800, 900 | Fontshare  |
| Body / UI           | **Satoshi**             | 400, 500, 700, 900     | Fontshare  |
| Numbers / Code      | **JetBrains Mono**      | 400, 500      | Google Fonts     |
| Bengali             | **Noto Sans Bengali**   | 400, 500, 700 | Google Fonts     |

### 2.2 Flutter Setup

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: CabinetGrotesk
      fonts:
        - asset: assets/fonts/CabinetGrotesk-Regular.otf
        - asset: assets/fonts/CabinetGrotesk-Medium.otf
          weight: 500
        - asset: assets/fonts/CabinetGrotesk-Bold.otf
          weight: 700
        - asset: assets/fonts/CabinetGrotesk-Extrabold.otf
          weight: 800
        - asset: assets/fonts/CabinetGrotesk-Black.otf
          weight: 900
    - family: Satoshi
      fonts:
        - asset: assets/fonts/Satoshi-Regular.otf
        - asset: assets/fonts/Satoshi-Medium.otf
          weight: 500
        - asset: assets/fonts/Satoshi-Bold.otf
          weight: 700
        - asset: assets/fonts/Satoshi-Black.otf
          weight: 900
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
    - family: NotoSansBengali
      fonts:
        - asset: assets/fonts/NotoSansBengali-Regular.ttf
        - asset: assets/fonts/NotoSansBengali-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoSansBengali-Bold.ttf
          weight: 700
```

### 2.3 Type Scale

| Token            | Size / Line   | Weight | Font           | Letter-spacing |
| ---------------- | ------------- | ------ | -------------- | -------------- |
| displayXL        | 64 / 72       | 900    | Cabinet Grotesk | -0.03em       |
| displayL         | 48 / 56       | 800    | Cabinet Grotesk | -0.02em       |
| displayM         | 36 / 44       | 700    | Cabinet Grotesk | -0.02em       |
| headlineL        | 28 / 36       | 700    | Cabinet Grotesk | -0.01em       |
| headlineM        | 22 / 28       | 700    | Cabinet Grotesk | -0.01em       |
| headlineS        | 18 / 24       | 500    | Cabinet Grotesk | 0             |
| bodyL            | 16 / 24       | 400    | Satoshi         | 0             |
| bodyM            | 14 / 20       | 400    | Satoshi         | 0             |
| bodyS            | 13 / 18       | 500    | Satoshi         | 0             |
| labelL           | 14 / 20       | 500    | Satoshi         | 0.02em        |
| labelM           | 12 / 16       | 700    | Satoshi         | 0.04em        |
| monoL            | 16 / 24       | 500    | JetBrains Mono  | 0             |
| monoM            | 14 / 20       | 500    | JetBrains Mono  | 0             |
| monoS            | 12 / 16       | 400    | JetBrains Mono  | 0             |

**Rules**:
- Stats / file sizes / percentages → **JetBrains Mono with tabular figures** (`tnum`)
- Bengali text uses Noto Sans Bengali for body, Cabinet Grotesk for headlines (Bengali glyphs fall back to Noto)
- All headlines use **negative letter-spacing** (Cabinet Grotesk looks better tight)
- Labels use **positive letter-spacing** (uppercase tracking)

---

## 3. Spacing & Layout

### 3.1 Spacing Scale (4px base)

| Token | Value | Usage                          |
| ----- | ----- | ------------------------------ |
| `xs`  | 4px   | Tight inline spacing           |
| `sm`  | 8px   | Default inline                 |
| `md`  | 12px  | Card internal padding          |
| `lg`  | 16px  | Default block spacing          |
| `xl`  | 24px  | Section spacing                |
| `2xl` | 32px  | Major section spacing          |
| `3xl` | 48px  | Page-level rhythm              |
| `4xl` | 64px  | Hero spacing                   |

### 3.2 Border Radius

From jubairsensei.com CSS — favor small radii, no heavy rounding:

| Token    | Value  | Usage                            |
| -------- | ------ | -------------------------------- |
| `none`   | 0      | Code blocks, terminal output     |
| `xs`     | 4px    | Small chips, tags                |
| `sm`     | 6px    | Inputs, small buttons            |
| `md`     | 8px    | Default buttons                  |
| `lg`     | 12px   | Cards, dialogs                   |
| `xl`     | 16px   | Large cards, hero elements       |
| `2xl`    | 24px   | Modals (max practical)           |
| `full`   | 9999px | Pills, progress rings            |

**Style rule**: Never exceed 24px radius. VideoSensei is sharp, not bubbly.

### 3.3 Layout Max-Widths

| Container         | Max-width | Usage                            |
| ----------------- | --------- | -------------------------------- |
| `content-narrow`  | 640px     | Settings, result screens         |
| `content-default` | 896px     | Most screens                     |
| `content-wide`    | 1200px    | Batch queue, history list        |
| `full-bleed`      | 100%      | Hero sections, image banners     |

---

## 4. Effects

### 4.1 Shadows & Glows

Dark mode favors **glow over shadow** (terminal aesthetic):

| Token            | Value (dark)                              | Value (light)                              |
| ----------------- | ----------------------------------------- | ------------------------------------------ |
| `glow-accent-sm`  | `0 0 12px rgba(0,255,136,0.3)`            | `0 0 8px rgba(0,130,70,0.2)`               |
| `glow-accent-md`  | `0 0 24px rgba(0,255,136,0.4)`            | `0 0 16px rgba(0,130,70,0.25)`             |
| `glow-accent-lg`  | `0 0 40px rgba(0,255,136,0.5)`            | `0 0 24px rgba(0,130,70,0.3)`              |
| `shadow-card`     | `0 4px 6px -1px rgba(0,0,0,0.4), 0 2px 4px -2px rgba(0,0,0,0.3)` | `0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.06)` |
| `shadow-dialog`   | `0 25px 50px -12px rgba(0,0,0,0.6)`       | `0 25px 50px -12px rgba(0,0,0,0.25)`       |

### 4.2 Glassmorphism (use sparingly)

From jubairsensei.com — minimal backdrop-blur usage:

```css
.glass {
  background: rgb(255 255 255 / 0.04);          /* dark mode */
  backdrop-filter: blur(12px);
  border: 1px solid rgb(255 255 255 / 0.08);
}
.glass-light {
  background: rgb(30 25 20 / 0.04);             /* light mode */
  backdrop-filter: blur(12px);
  border: 1px solid rgb(30 25 20 / 0.08);
}
```

**Rule**: Use glass only for floating elements (sticky app bar, FAB, modals over content).
Don't use for primary cards — solid `bg-elevated` reads better.

### 4.3 Animations

Three keyframes defined in jubairsensei.com CSS:

```css
@keyframes fade { /* fade-in on mount */ }
@keyframes pulse { /* subtle 2s opacity pulse for accents */ }
@keyframes spin { /* loading spinner */ }
```

**VideoSensei additions** (Phase 3):
- `brush-draw` — 1.2s splash logo animation (SVG path drawing)
- `progress-ring` — smooth animated arc with `Curves.easeInOutCubic`
- `shimmer` — 1.5s skeleton loader
- `confetti-burst` — 1.5s success celebration (60 particles)
- `slide-up-fade` — 200ms screen transition

**Rules**:
- Default duration: 200ms (transitions), 400ms (screen transitions)
- Default curve: `Curves.easeOutCubic`
- Respect `MediaQuery.disableAnimations`
- Never use linear easing for organic motion
- Never exceed 600ms for any UI animation

---

## 5. Component Style Cheatsheet

### Buttons

| Variant   | Background                    | Text         | Border                      |
| --------- | ----------------------------- | ------------ | --------------------------- |
| primary   | `accent` (#00FF88)            | `bg` (#0A0A0B)| none                        |
| secondary | transparent                   | `ink` (#FFF) | `line` 1px                  |
| ghost     | transparent                   | `ink-secondary` | none                     |
| destructive | `error` (#EF4444)           | `#FFF`       | none                        |

- Padding: `12px 20px` (default), `10px 16px` (compact), `16px 24px` (large)
- Radius: `8px` (default), `6px` (compact), `12px` (large)
- Primary button has `glow-accent-sm` by default, `glow-accent-md` on hover

### Cards

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,  // bg-elevated
    borderRadius: BorderRadius.circular(12),       // lg
    border: Border.all(
      color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
    ),
  ),
)
```

### Inputs

- Height: 44px (touch-friendly)
- Padding: `12px 16px`
- Radius: `8px`
- Background: `surface` at 4% opacity
- Border: `line` 1px, becomes `accent` at 40% opacity on focus

### Progress Ring

- Stroke width: 6px
- Radius: 80px (default), 120px (hero)
- Track color: `line` at 8% opacity
- Active color: `accent` with `glow-accent-md`
- Center text: `displayM` Cabinet Grotesk Bold + `monoS` JetBrains Mono "67%"

---

## 6. Flutter ThemeData Reference

```dart
// lib/core/theme/video_sensei_theme.dart

import 'package:flutter/material.dart';

class VideoSenseiTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00FF88),
      brightness: Brightness.dark,
      surface: const Color(0xFF111114),
      onSurface: const Color(0xFFFFFFFF),
    ).copyWith(
      background: const Color(0xFF0A0A0B),
      onBackground: const Color(0xFFFFFFFF),
      primary: const Color(0xFF00FF88),
      onPrimary: const Color(0xFF0A0A0B),
      secondary: const Color(0xFFA1A1AA),
      onSecondary: const Color(0xFF0A0A0B),
      error: const Color(0xFFEF4444),
      onError: const Color(0xFFFFFFFF),
      outline: const Color(0xFFFFFFFF).withOpacity(0.08),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: 'Satoshi',
      textTheme: _buildTextTheme(isDark: true),
      scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      // ... full theme in ARCHITECTURE.md
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF008246),
      brightness: Brightness.light,
      surface: const Color(0xFFFAF9F5),
      onSurface: const Color(0xFF1E1914),
    ).copyWith(
      background: const Color(0xFFF0F0EC),
      onBackground: const Color(0xFF1E1914),
      primary: const Color(0xFF008246),
      onPrimary: const Color(0xFFFFFFFF),
      // ...
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: 'Satoshi',
      textTheme: _buildTextTheme(isDark: false),
      scaffoldBackgroundColor: const Color(0xFFF0F0EC),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    // ... see type scale above
  }
}
```

---

## 7. Asset Acquisition

### Fonts (download to `assets/fonts/`)

```bash
# Cabinet Grotesk + Satoshi (Fontshare, free for commercial use)
curl -L "https://api.fontshare.com/v2/fonts/download/cabinet-grotesk" -o cabinet-grotesk.zip
curl -L "https://api.fontshare.com/v2/fonts/download/satoshi" -o satoshi.zip

# JetBrains Mono (Google Fonts, OFL)
curl -L "https://fonts.google.com/download?family=JetBrains+Mono" -o jetbrains-mono.zip

# Noto Sans Bengali (Google Fonts, OFL)
curl -L "https://fonts.google.com/download?family=Noto+Sans+Bengali" -o noto-bengali.zip
```

### Logo Reference

The Jubair Sensei logo is at `https://jubairsensei.com/logo.jpg` (320×320 JPEG, 21 KB).
For VideoSensei, a custom variant will be designed in Phase 4 — same green-on-black palette,
different mark (brush-stroke "S" + play triangle, per `BRANDING.md` §2).

---

## 8. Brand Don'ts (theme-specific)

- ❌ Never use indigo, purple, or blue as primary — green is the signature
- ❌ Never use Material default colors — always use the tokens above
- ❌ Never use rounded corners > 24px (sharp terminal aesthetic)
- ❌ Never use drop shadows on text — only glow effects
- ❌ Never use Comic Sans, Papyrus, Roboto, or system default fonts
- ❌ Never invert the dark/light defaults (dark is default, period)
- ❌ Never use the light theme accent (`#008246`) in dark mode or vice versa
- ❌ Never use solid black `#000000` for backgrounds — always `#0A0A0B` (warmer)
- ❌ Never use pure white `#FFFFFF` for surfaces in dark mode — use it only at low opacity

---

## 9. Verification Checklist

Before any screen ships to main:

- [ ] All colors come from `VideoSenseiTheme` tokens (no hardcoded `Color(0xFF...)`)
- [ ] All text uses Cabinet Grotesk / Satoshi / JetBrains Mono (no system fonts)
- [ ] Dark mode is the default; light mode is opt-in
- [ ] No drop shadows on text in dark mode (use glow only)
- [ ] All border radii are ≤ 24px
- [ ] Primary accent is `#00FF88` (dark) / `#008246` (light) — not indigo, not blue
- [ ] Stats and numbers use JetBrains Mono with tabular figures
- [ ] Animations respect `MediaQuery.disableAnimations`

---

## 10. Source Provenance

This theme was extracted on **2026-07-21** from:
- `https://jubairsensei.com/` (HTML)
- `https://jubairsensei.com/assets/index-DBiZdQdI.css` (CSS, 51 KB)
- `https://jubairsensei.com/logo.jpg` (logo, 320×320)

Re-extraction script: `scripts/extract-theme.sh` (to be added in Phase 2).
If jubairsensei.com theme changes, re-run the script and update this file.
