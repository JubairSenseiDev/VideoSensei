# 🥋 VideoSensei

```
 _   _ ___________ _____ _____ _____ _____ _   _  _____ _____ _____
| | | |_   _|  _  \  ___|  _  /  ___|  ___| \ | |/  ___|  ___|_   _|
| | | | | | | | | | |__ | | | \ `--.| |__ |  \| |\ `--.| |__   | |
| | | | | | | | | |  __|| | | |`--. \  __|| . ` | `--. \  __|  | |
\ \_/ /_| |_| |/ /| |___\ \_/ /\__/ / |___| |\  |/\__/ / |___ _| |_
 \___/ \___/|___/ \____/ \___/\____/\____/\_| \_/\____/\____/ \___/

                  Master your video. Sensei-grade clarity.
```

> *Hack the size. Keep the clarity.*

---

## 📦 Install

### Termux (Android)

```bash
pkg update -y && pkg install -y curl ffmpeg
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

### Linux / macOS / Windows / Git Bash

```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

The installer auto-detects your platform and picks the right binary. **No Node.js or Bun runtime needed** on your machine.

📱 **Phone build guide**: [`TERMUX.md`](./TERMUX.md)

---

## 🚀 Usage

```bash
videosensei                          # picker + smart + compress (auto)
videosensei video.mp4                # smart preset, auto-compress
videosensei video.mp4 -p sensei      # AV1 master (smallest file)
videosensei video.mp4 -p lite        # quick H.264 share
videosensei video.mp4 -p custom --codec h265 --crf 22
videosensei -i                       # interactive menu
videosensei --help                   # see all options
```

### Presets

| Preset     | Codec | Use case                       |
| ---------- | ----- | ------------------------------ |
| `lite`     | H.264 | Quick share, small files       |
| `balanced` | H.265 | Best size-quality balance      |
| `crystal`  | H.264 | Max H.264 quality              |
| `sensei`   | AV1   | Smallest file, future-proof    |
| `custom`   | any   | You pick codec + CRF           |

### Examples

Compress one file:
```bash
videosensei /sdcard/Download/big-video.mp4 -o /sdcard/Download/compressed/
```

Batch compress a folder:
```bash
videosensei *.mp4 -p balanced -o ./output/
```

### Commands

```bash
videosensei --help         # full help
videosensei --version       # show version
videosensei --history       # see past compressions
videosensei --uninstall     # remove VideoSensei
```

---

## 🆘 Help

| Need | Where |
| ---- | ----- |
| Phone install | [`TERMUX.md`](./TERMUX.md) |
| Version history | [`CHANGELOG.md`](./CHANGELOG.md) |
| Report a bug / request feature | [GitHub Issues](https://github.com/JubairSenseiDev/VideoSensei/issues) |
| Source code, dev docs | [`dev` branch](https://github.com/JubairSenseiDev/VideoSensei/tree/dev) |
| Flutter GUI app (WIP) | [`flutter-app` branch](https://github.com/JubairSenseiDev/VideoSensei/tree/flutter-app) |

---

## 👤 Author

**Jubair Sensei** — *Hack, learn, dominate.*
- 🌐 [jubairsensei.com](https://jubairsensei.com)
- 🐙 [github.com/JubairSenseiDev](https://github.com/JubairSenseiDev)
- 💬 Telegram: [@JubairSensei](https://t.me/JubairSensei)
- ▶️ YouTube: [@JubairSensei](https://youtube.com/@JubairSensei)

## 📜 License

MIT — see [`LICENSE`](./LICENSE).

---

*Hack the size. Keep the clarity.* 🥋
