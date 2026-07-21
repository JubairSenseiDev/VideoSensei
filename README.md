# 🥋 VideoSensei

```
██╗   ██╗███████╗███████╗██████╗ ███████╗██████╗  ██████╗ ███╗   ███╗██████╗ ███████╗██████╗
██║   ██║██╔════╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗████╗ ████║██╔══██╗██╔════╝██╔══██╗
██║   ██║█████╗  █████╗  ██████╔╝█████╗  ██████╔╝██║   ██║██╔████╔██║██║  ██║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══╝  ██╔══╝  ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║██║  ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ███████╗███████╗██║  ██║███████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║
  ╚═══╝  ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                              Master your video. Sensei-grade clarity.
```

> **Master your video. Sensei-grade clarity.**
> *Hack the size. Keep the clarity.*

---

## 📦 Install

**Termux (Android — primary target)**

```bash
pkg update -y && pkg install -y curl ffmpeg
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

That's it. Run `videosensei` and you're compressing.

**Linux / macOS / Windows / Git Bash**

```bash
curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
```

The installer auto-detects your platform and picks the right binary — no Node.js, no Bun runtime needed on your machine (except on Termux, where Bun is used for full Android compatibility via [bd-loser/bun-termux](https://github.com/bd-loser/bun-termux)).

---

## 🚀 Usage

```bash
videosensei                          # picker + smart + compress (zero prompts)
videosensei video.mp4                # smart preset, auto-compress
videosensei video.mp4 -p sensei      # AV1 master
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

---

## 🎨 Theme

| Token     | Dark mode | Light mode |
| --------- | --------- | ---------- |
| Accent    | `#00FF88` | `#008246`  |
| Background| `#0A0A0B` | `#F0F0EC`  |
| Body      | Satoshi   | Satoshi    |
| Headlines | Cabinet Grotesk | Cabinet Grotesk |

Full tokens in [`THEME.md`](./THEME.md). Brand voice in [`BRANDING.md`](./BRANDING.md).

---

## 📚 Docs

| File | Purpose |
| ---- | ------- |
| [`TERMUX.md`](./TERMUX.md) | 📱 Build VideoSensei on your phone with Termux |
| [`cli/README.md`](./cli/README.md) | Full CLI reference + flags |
| [`COMPRESSION.md`](./COMPRESSION.md) | Codec strategy + CRF logic |
| [`ROADMAP.md`](./ROADMAP.md) | What's done, what's next |
| [`BRANDING.md`](./BRANDING.md) | Name, logo, voice |
| [`THEME.md`](./THEME.md) | Design tokens |

---

## 🛣️ Roadmap

- ✅ **v1.0** — Original Bash CLI (Termux-only, 2019–2024)
- ✅ **v1.2** — TypeScript rewrite + auto-everything + Bun single binaries
- ✅ **v1.2.1** — Termux support via bd-loser/bun-termux
- 🚧 **v2.0** — Flutter GUI app (in `flutter-app` branch — see below)

---

## 🌿 Branches

| Branch | Contents |
| ------ | -------- |
| `main` | **CLI + installer** — what most users need. Stable. |
| `flutter-app` | Flutter GUI app source + multi-platform CI (Android/Linux/Windows/macOS/Web). Work in progress. |

To try the GUI build:
```bash
git clone -b flutter-app https://github.com/JubairSenseiDev/VideoSensei.git
cd VideoSensei
open TERMUX.md
```

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
