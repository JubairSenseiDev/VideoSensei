# 🥋 VideoSensei CLI — Quick Start

> Master your video. Sensei-grade clarity.
> *Hack the size. Keep the clarity.*

The **VideoSensei CLI** is a terminal-based video compressor — the first shipping
component of the VideoSensei project. It works on Linux, macOS, Termux (Android),
and Windows (Git Bash/WSL).

The native Flutter GUI is coming later — but the CLI is fully functional today.

---

## 🚀 Install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

The installer will:
1. Check for Node.js (install if missing)
2. Check for FFmpeg (install if missing)
3. Download `videosensei.js` AND `filepicker.js` to `~/.videosensei/`
4. Create a `videosensei` command in your PATH
5. Verify the installation

**Manual install** (if you prefer):

```bash
git clone https://github.com/JubairSenseiDev/VideoSensei.git
cd VideoSensei/cli
chmod +x videosensei.js
sudo ln -sf "$PWD/videosensei.js" /usr/local/bin/videosensei
# (Also need filepicker.js in same directory as videosensei.js OR in ~/.videosensei/)
# (Then make sure /usr/local/bin is in your PATH)
```

---

## 📖 Usage

### Interactive mode (just run it)
```bash
videosensei
```
Shows a friendly menu:
```
  WHAT WOULD YOU LIKE TO DO?

  1. 🎬 Pick a video and compress  (file picker)
  2. 📂 Type path manually          (paste path)
  3. 📦 Batch compress              (multiple files)
  4. 📜 View history                (past compressions)
  5. ❓ Help                         (show all options)
  q. Quit
```

### File picker (NEW!)
```bash
videosensei --pick              # open picker, default preset (Balanced)
videosensei --pick -p sensei    # open picker, AV1 master
```

**Auto-detected pickers (in order):**
- **Termux**: `termux-file-picker` — install with `pkg install termux-api` (then install Termux:API app)
- **macOS**: `osascript` (built-in)
- **Linux**: `zenity` (GTK) or `kdialog` (KDE)
- **Windows**: PowerShell (.NET WinForms)
- **Any**: `fzf` (terminal fuzzy finder)
- **Fallback**: built-in arrow-key browser (no install needed)

The built-in fallback uses arrow keys to navigate directories:
```
  🥋 VideoSensei File Picker

  📁 /home/sensei/Videos
  Filter: mp4, mkv, mov, avi, webm  Hidden: off

  ❯   ↩ ..
        📁 old/
        🎬 vacation.mp4
        🎬 birthday.mp4

  ↑↓ navigate  →/Enter open  ←/⌫ up dir  h hidden  q done
```

### Quick compress (default: Balanced)
```bash
videosensei vacation.mp4
```

### Specific preset
```bash
videosensei video.mp4 -p lite         # 🪶 H.264, max compat
videosensei video.mp4 -p balanced     # ⚖️ H.265, daily default
videosensei video.mp4 -p crystal      # 💎 H.265, archive quality
videosensei video.mp4 -p sensei       # 🥋 AV1, smallest file
videosensei video.mp4 -p custom --codec h265 --crf 22  # 🎯 full control
```

### Batch compress
```bash
videosensei *.mp4 -p balanced
videosensei file1.mp4 file2.mp4 file3.mp4 -p sensei
# OR use the picker in multi-select mode:
videosensei   # → option 3 (Batch compress)
```

### Smart mode (auto-recommend)
```bash
videosensei video.mp4 --smart
```

### Skip prompts (for scripting)
```bash
videosensei video.mp4 -p lite -y
```

### Custom output directory
```bash
videosensei video.mp4 -o ~/Downloads
```

### History
```bash
videosensei --history          # show past 20 compressions
videosensei --clear-history    # wipe history
```

### Help & version
```bash
videosensei --help
videosensei --version
```

---

## 🎚️ The 5 Presets

| Preset        | Icon | Codec | CRF | Audio       | Use case                            |
| ------------- | ---- | ----- | --- | ----------- | ----------------------------------- |
| `lite`        | 🪶   | H.264 | 30  | AAC 128k    | WhatsApp/Telegram share, max compat |
| `balanced`    | ⚖️   | H.265 | 26  | AAC 128k    | Daily default, 50% smaller          |
| `crystal`     | 💎   | H.265 | 22  | AAC 192k    | Archive, near-lossless              |
| `sensei`      | 🥋   | AV1   | 32  | Opus 96k    | Future-proof, smallest file         |
| `custom`      | 🎯   | any   | any | any         | Full manual control                 |

---

## 🛠️ Requirements

- **Node.js** ≥ 16 (installer handles this)
- **FFmpeg** with libx264, libx265, libsvtav1 (installer handles this)
- Any modern terminal with truecolor support

### Codec availability check
```bash
ffmpeg -codecs | grep -E 'libx264|libx265|libsvtav1'
```

If `libsvtav1` is missing, the `sensei` preset won't work — install a newer FFmpeg
or use `balanced` / `crystal` instead.

---

## 🎨 Theme

The CLI uses the same theme tokens as the upcoming native app — extracted from
[jubairsensei.com](https://jubairsensei.com):

- **Background**: near-black `#0A0A0B`
- **Accent**: neon green `#00FF88`
- **Text**: white `#FFFFFF` / muted `#A1A1AA`
- **Progress bar**: animated neon green with glow

Truecolor (24-bit) terminal required for full effect. Most modern terminals
support this: iTerm2, Alacritty, Kitty, WezTerm, Windows Terminal, GNOME Terminal,
Konsole, Termux.

---

## 📂 File Locations

| Path                                | Purpose                          |
| ----------------------------------- | -------------------------------- |
| `~/.videosensei/videosensei.js`     | The CLI script itself            |
| `~/.videosensei/history.json`       | Compression history (last 100)   |
| `~/.videosensei/videosensi.log`     | Debug log                        |
| `/usr/local/bin/videosensei`        | Launcher (or `~/.local/bin/...`) |

---

## 🧪 Try It Out

```bash
# Compress your phone recording
videosensei ~/Downloads/IMG_1234.mp4 -p balanced

# See the difference
ls -lh ~/Downloads/IMG_1234*
# IMG_1234.mp4         187 MB
# IMG_1234_sensei.mp4   42 MB  ← 78% smaller

# Check history
videosensei --history
```

---

## 🗑️ Uninstall

```bash
bash installer.sh --uninstall
# (or)
rm -f /usr/local/bin/videosensei
rm -rf ~/.videosensei
```

---

## ❓ Troubleshooting

### "FFmpeg not found"
Install FFmpeg:
- Ubuntu/Debian: `sudo apt install ffmpeg`
- macOS: `brew install ffmpeg`
- Termux: `pkg install ffmpeg`
- Windows: `choco install ffmpeg` or download from ffmpeg.org

### "libsvtav1 not found" (Sensei preset fails)
Your FFmpeg is too old or built without AV1. Either:
- Upgrade FFmpeg to 5.0+
- Build from source with `--enable-libsvtav1`
- Use `balanced` or `crystal` preset instead

### "Output larger than source"
The source video was already well-compressed. VideoSensei automatically
detects this and skips (deletes the larger output). Try a different preset
or just keep the original.

### Colors look weird
Your terminal may not support truecolor. Set `TERM=xterm-256color` or use
a modern terminal (see Theme section above).

---

## 📝 License

MIT — see [LICENSE](../LICENSE) in the repo root.

## 👤 Author

**Jubair Sensei** — *Hack, learn, dominate.*
- 🌐 [jubairsensei.com](https://jubairsensei.com)
- 📧 jubairsensei@gmail.com
- 🐙 [github.com/JubairSenseiDev](https://github.com/JubairSenseiDev)
- 💬 Telegram: [@JubairSensei](https://t.me/JubairSensei)
