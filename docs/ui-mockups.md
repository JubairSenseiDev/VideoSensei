# 🎨 VideoSensei — UI Mockups (Wireframe Layouts)

This document describes the screen layouts and user flows for VideoSensei.
These are wireframe-level specs — final visual design happens in Phase 3.

---

## 1. Information Architecture

```
                          ┌──────────────┐
                          │   Splash     │
                          │   (1.2s)     │
                          └──────┬───────┘
                                 │
                          ┌──────▼───────┐
                          │  Onboarding  │  ← first launch only
                          │  (3 screens) │
                          └──────┬───────┘
                                 │
                          ┌──────▼───────┐
              ┌───────────│     Home     │───────────┐
              │           └──────────────┘           │
              │                │                     │
       ┌──────▼─────┐   ┌──────▼─────┐       ┌──────▼─────┐
       │  Picker    │   │  History   │       │  Settings  │
       └──────┬─────┘   └────────────┘       └────────────┘
              │
       ┌──────▼─────┐
       │ Configure  │  ← preset selection, size prediction
       └──────┬─────┘
              │
       ┌──────▼─────┐
       │ Processing │  ← live progress
       └──────┬─────┘
              │
       ┌──────▼─────┐
       │  Result    │  ← before/after, share, retry
       └────────────┘
```

---

## 2. Splash Screen

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│              ╱━━━━━╲                    │
│             ╱  ┃█┃  ╲                   │
│             ╲  ┃█┃  ╱                   │
│              ╲━━━━━╱                    │
│                                         │
│           VIDEOSENSEI                   │
│      Master your video.                 │
│      Sensei-grade clarity.              │
│                                         │
│                                         │
│                                         │
│         [brush stroke animation]        │
│                                         │
└─────────────────────────────────────────┘
```

- Dark indigo background `#1E1B4B`
- Logo draws in with brush-stroke animation (1.2s)
- Tagline fades in below
- Auto-advance to onboarding (first launch) or home (subsequent)

---

## 3. Onboarding (3 screens, first launch only)

### Screen 1 — "Welcome"
```
┌─────────────────────────────────────────┐
│   🥋                                    │
│                                         │
│   Welcome to VideoSensei                │
│                                         │
│   Shrink videos without losing          │
│   quality. Master-class compression     │
│   in your pocket.                       │
│                                         │
│                                         │
│                                         │
│            ● ○ ○                        │
│                                         │
│         [   Next   ]                    │
└─────────────────────────────────────────┘
```

### Screen 2 — "Smart presets"
```
┌─────────────────────────────────────────┐
│   🪶  ⚖️  💎  🥋                        │
│                                         │
│   Pick a preset, that's it.             │
│                                         │
│   From quick-share Lite to              │
│   future-proof Sensei (AV1),            │
│   we have the right master for          │
│   every video.                          │
│                                         │
│                                         │
│            ○ ● ○                        │
│                                         │
│         [   Next   ]                    │
└─────────────────────────────────────────┘
```

### Screen 3 — "Privacy"
```
┌─────────────────────────────────────────┐
│   🔒                                    │
│                                         │
│   Everything stays local.               │
│                                         │
│   No accounts, no cloud uploads,        │
│   no telemetry by default.              │
│   Your videos never leave your device.  │
│                                         │
│                                         │
│            ○ ○ ●                        │
│                                         │
│      [   Get started   ]                │
└─────────────────────────────────────────┘
```

---

## 4. Home Screen

```
┌─────────────────────────────────────────┐
│ ☰  VideoSensei              🥋  ⚙️       │  ← app bar
├─────────────────────────────────────────┤
│                                         │
│   Hello, Sensei. 🥋                     │  ← greeting
│                                         │
│   ┌─────────────────────────────────┐   │
│   │                                 │   │
│   │       📁  Pick a video          │   │  ← primary CTA card
│   │                                 │   │     (glassmorphism, glowing)
│   │   From file manager or drag     │   │
│   │   and drop here                 │   │
│   │                                 │   │
│   └─────────────────────────────────┘   │
│                                         │
│   Recent                                │  ← recent files section
│   ┌─────────────────────────────────┐   │
│   │ 🎬 vacation.mp4                 │   │
│   │ 1080p · 187 MB → 42 MB · 78% ↓  │   │
│   │ 2 hours ago · Balanced          │   │
│   └─────────────────────────────────┘   │
│   ┌─────────────────────────────────┐   │
│   │ 🎬 meeting-recording.mp4        │   │
│   │ 720p · 340 MB → 89 MB · 74% ↓   │   │
│   │ Yesterday · Lite                │   │
│   └─────────────────────────────────┘   │
│                                         │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │  📊 View all history            │   │
│   └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

**Behaviors**:
- Tap "Pick a video" → opens native file picker
- Tap a recent file → opens result detail (with option to re-compress)
- Drag-and-drop on desktop supported anywhere on home

---

## 5. Configure Screen

```
┌─────────────────────────────────────────┐
│ ←  Configure                             │
├─────────────────────────────────────────┤
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ 🎬 vacation.mp4                 │   │  ← file info card
│   │ 1080p · 60fps · 187 MB · 2:34   │   │
│   │ H.264 / AAC 320k                │   │
│   │ [ change file ]                 │   │
│   └─────────────────────────────────┘   │
│                                         │
│   Choose your preset                    │
│                                         │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│   │ 🪶 Lite │ │⚖️Balance│ │💎Crystal│  │
│   │ ~65 MB  │ │ ~42 MB  │ │ ~75 MB  │  │
│   │ H.264   │ │ H.265   │ │ H.265   │  │
│   │  ~12s   │ │  ~55s   │ │ ~4m10s  │  │
│   └─────────┘ └─────────┘ └─────────┘  │
│   ┌─────────┐ ┌─────────┐              │
│   │🥋Sensei │ │🎯Custom │              │
│   │ ~28 MB  │ │  You    │              │
│   │  AV1    │ │ decide  │              │
│   │ ~8m30s  │ │         │              │
│   └─────────┘ └─────────┘              │
│                                         │
│   ┌─────────────────────────────────┐   │  ← Sensei recommends
│   │ 🥋 Sensei recommends: Balanced  │   │
│   │ "Halves the file size without   │   │
│   │  visible quality loss."         │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ▸ Advanced options                    │
│                                         │
│   Output to:  ⚪ Original folder         │
│               ⚪ Custom folder           │
│               ⚪ Downloads (Android)     │
│               ⚪ Gallery (Android)       │
│                                         │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │       🥋 Compress video         │   │  ← primary CTA
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Behaviors**:
- Tap preset card → selects (highlight with cyan glow)
- Size estimate updates live as you switch presets
- "Sensei recommends" appears if Smart Mode is on
- Advanced options expand with smooth animation
- Bottom CTA shows "Compress with {selected preset}"

---

## 6. Processing Screen

```
┌─────────────────────────────────────────┐
│ ←  Processing...                  Cancel │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│            ╱─────────╲                  │
│           │           │                 │
│           │   67 %    │                 │  ← animated progress ring
│           │           │                 │     (cyan glow, 60fps)
│            ╲─────────╱                  │
│                                         │
│         Compressing with ⚖️ Balanced    │
│                                         │
│   ┌─────────────────────────────────┐   │  ← live stats card
│   │  Elapsed:    0:42               │   │
│   │  ETA:        0:21               │   │
│   │  Speed:      2.8×               │   │
│   │  Frame:      4521 / 6720        │   │
│   │  Bitrate:    1.2 Mbps           │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌─────────────────────────────────┐   │  ← before/after live
│   │  Source:  187 MB                │   │
│   │  Output:  ~42 MB (predicted)    │   │
│   │  Saving:  ~145 MB (78% ↓)       │   │
│   └─────────────────────────────────┘   │
│                                         │
│                                         │
│   Tip: You can leave the app — we'll    │
│   notify you when it's done. 📱         │
│                                         │
└─────────────────────────────────────────┘
```

**Behaviors**:
- Progress ring smoothly animates between values (don't jump)
- Stats update every 500ms (debounced to avoid flicker)
- "Cancel" → confirmation dialog → kills FFmpeg process
- App backgroundable; foreground service (Android) keeps it alive
- Notification posted with progress on mobile

---

## 7. Result Screen

```
┌─────────────────────────────────────────┐
│ ←  Result                          ⋮    │
├─────────────────────────────────────────┤
│                                         │
│         ✅ Compression complete!        │
│                                         │
│   ┌─────────────────────────────────┐   │  ← hero stat card
│   │                                 │   │
│   │      78% smaller                │   │
│   │                                 │   │
│   │   187 MB  →  42 MB              │   │
│   │   saved 145 MB                  │   │
│   │                                 │   │
│   └─────────────────────────────────┘   │
│                                         │
│   Preset used: ⚖️ Balanced             │
│   Time taken:  1m 3s                    │
│   Codec:       H.265 (CRF 26)           │
│   Quality:     SSIM 0.97 (excellent)    │
│                                         │
│   ┌─────────────────────────────────┐   │  ← preview card
│   │  ▶  Original       ▶  Compressed│   │
│   │  ┌─────────┐       ┌─────────┐  │   │
│   │  │ [thumb] │       │ [thumb] │  │   │
│   │  └─────────┘       └─────────┘  │   │
│   │  187 MB            42 MB       │   │
│   │  ━━━━━━━━━━━━ scrub ━━━━━━━━━  │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌──────────┐  ┌──────────┐           │
│   │ 📤 Share │  │ 📁 Open  │           │
│   └──────────┘  └──────────┘           │
│                                         │
│   ┌──────────┐  ┌──────────┐           │
│   │ 🔄 Again │  │ 🏠 Home  │           │
│   └──────────┘  └──────────┘           │
│                                         │
└─────────────────────────────────────────┘
```

**Behaviors**:
- Confetti animation on first compression of the day
- Before/after scrubbers are synced (drag one, both move)
- "Share" → native share sheet
- "Open" → opens file in default video player
- "Again" → back to configure with same file
- "Home" → back to home

---

## 8. Batch Screen

```
┌─────────────────────────────────────────┐
│ ←  Batch Queue                    Clear │
├─────────────────────────────────────────┤
│                                         │
│   3 videos queued                       │
│                                         │
│   Apply preset to all:                  │
│   [ 🪶 Lite ] [⚖️Balanced] [💎Crystal]  │
│   [🥋Sensei] [🎯Custom]                 │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ 1. 🎬 vacation.mp4              │   │
│   │    1080p · 187 MB · ⚖️ Balanced │   │
│   │    ⏳ Waiting                    │   │
│   ├─────────────────────────────────┤   │
│   │ 2. 🎬 meeting.mp4               │   │
│   │    720p · 340 MB · ⚖️ Balanced  │   │
│   │    ▶ Processing 67%             │   │  ← currently encoding
│   │    ━━━━━━━━━━━━━━━━━━━━━━━━     │   │
│   ├─────────────────────────────────┤   │
│   │ 3. 🎬 kids-bday.mp4             │   │
│   │    4K · 1.2 GB · 🥋 Sensei      │   │
│   │    ⏳ Waiting                    │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌──────────┐  ┌──────────┐           │
│   │ + Add    │  │ ▶ Start  │           │
│   └──────────┘  └──────────┘           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 9. History Screen

```
┌─────────────────────────────────────────┐
│ ←  History                               │
├─────────────────────────────────────────┤
│                                         │
│   🔍 Search by filename...              │
│                                         │
│   Filter:  All  | Lite | Balanced | ... │
│   Date:    Today | Week | Month | All   │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ 🎬 vacation.mp4                 │   │
│   │ ⚖️ Balanced · 2h ago            │   │
│   │ 187 MB → 42 MB · 78% ↓          │   │
│   │ [ open ]  [ re-compress ]       │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ 🎬 meeting-recording.mp4        │   │
│   │ 🪶 Lite · Yesterday              │   │
│   │ 340 MB → 89 MB · 74% ↓          │   │
│   │ [ open ]  [ re-compress ]       │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ...                                   │
│                                         │
└─────────────────────────────────────────┘
```

---

## 10. Settings Screen

```
┌─────────────────────────────────────────┐
│ ←  Settings                              │
├─────────────────────────────────────────┤
│                                         │
│   APPEARANCE                            │
│   ┌─────────────────────────────────┐   │
│   │ Theme        [ Dark ▾ ]         │   │
│   │ Language     [ English ▾ ]      │   │
│   │ Dynamic color  ⚪ On / Off       │   │
│   └─────────────────────────────────┘   │
│                                         │
│   DEFAULTS                              │
│   ┌─────────────────────────────────┐   │
│   │ Default preset  [ Balanced ▾ ]  │   │
│   │ Output folder   [ Downloads ▾ ] │   │
│   │ Output naming   [ Original ▾ ]  │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ENCODING                              │
│   ┌─────────────────────────────────┐   │
│   │ Hardware accel   [ Auto ▾ ]     │   │
│   │ Delete original after ⚪ Off     │   │
│   │ Notification on done  ⚪ On      │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ABOUT                                 │
│   ┌─────────────────────────────────┐   │
│   │ Version 1.0.0                   │   │
│   │ Open source (MIT)               │   │
│   │ [ View on GitHub ]              │   │
│   │ [ Report a bug ]                │   │
│   │ [ By Jubair Sensei ]            │   │
│   └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

---

## 11. Responsive Behavior

### Mobile (Android, < 600dp)
- Single-column layouts throughout
- Bottom navigation OR hamburger drawer (decide in Phase 3)
- Cards full-width
- Presets wrap to 2×3 grid

### Tablet / Desktop (≥ 600dp)
- Two-column layouts where appropriate
- Side navigation rail
- Cards in grid (2-3 per row)
- Presets in single row of 5

### Desktop (Linux/Windows)
- Window min size: 800×600
- Default size: 1100×750
- Drag-and-drop zones highlighted
- Keyboard shortcuts: Ctrl+O (open), Ctrl+B (batch), Ctrl+, (settings)

---

## 12. Motion Design Principles

- **Hero transitions** between file selection → configure → result
- **Staggered fade-in** for list items (50ms per item)
- **Spring physics** for cards (not linear)
- **Progress ring** animates with curve `Curves.easeInOutCubic`
- **Confetti** on result screen (60 particles, 1.5s, gravity 0.4)
- **Shimmer loaders** for any async data > 200ms wait
- **Never** use linear easing for organic motion
- **Always** respect `MediaQuery.disableAnimations` (accessibility)

---

## 13. Dark vs Light

**Dark mode (default)**:
- Background: `#0F0F14` (ink.900)
- Cards: glassmorphism over `#1A1A22` (ink.800)
- Text: `#FAFAF9` (cream.50)
- Accent glow: `#06B6D4` (cyan.500)

**Light mode**:
- Background: `#FAFAF9` (cream.50)
- Cards: `#F5F5F4` (cream.100) with subtle indigo tint
- Text: `#1E1B4B` (indigo.900)
- Accent: `#4F46E5` (indigo.600) — cyan reads too harsh on white

**Auto mode**: follows system setting (Android 10+, iOS 13+, Linux/Windows via Flutter platform channel).
