# 📱 VideoSensei — Build on your phone via Termux

> **TL;DR**: You can build **every** VideoSensei artifact from your Android phone using Termux.
> CLI binary takes ~5 minutes, Flutter APK takes ~30 minutes. No PC required.

---

## 1. Install Termux

**Important**: Install Termux from **F-Droid**, NOT Google Play Store. The Play Store version is deprecated and broken.

- F-Droid: https://f-droid.org/en/packages/com.termux/
- Direct APK: https://github.com/termux/termux-app/releases

After install, open Termux and run:

```bash
termux-setup-storage    # grant storage permission (for /sdcard access)
pkg update -y && pkg upgrade -y
```

---

## 2. One-time setup (~15 min)

Paste this entire block into Termux:

```bash
# --- Core tooling ---
pkg install -y git nodejs python ffmpeg openjdk-17 cmake ninja clang \
                pkg-config libgtk3 libmpv jq zip tar wget unzip

# --- Flutter (manual — Termux doesn't ship Flutter) ---
git clone https://github.com/flutter/flutter.git ~/flutter --depth 1 -b stable
echo 'export PATH=$HOME/flutter/bin:$PATH' >> ~/.bashrc

# --- Android SDK (for APK builds) ---
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q commandlinetools-linux-*.zip
mv cmdline-tools latest
rm commandlinetools-linux-*.zip

yes | ~/android-sdk/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT=$HOME/android-sdk' >> ~/.bashrc

# --- Bun (CLI build, patched for Android by bd-loser/bun-termux) ---
curl -fsSL https://raw.githubusercontent.com/bd-loser/bun-termux/main/install.sh | bash
echo 'export PATH=$HOME/.bun/bin:$PATH' >> ~/.bashrc

# --- Reload env ---
source ~/.bashrc

# --- Verify ---
flutter --version
bun --version
node --version
ffmpeg -version | head -1
```

---

## 3. Clone the repo

```bash
cd ~
git clone https://github.com/JubairSenseiDev/VideoSensei.git
cd VideoSensei
```

---

## 4. Option A — Build CLI binary (~5 min, ~95 MB output)

This builds the `videosensei` command-line tool that runs **natively inside Termux**.

```bash
cd ~/VideoSensei/cli
bun install
bun run build:bun:linux-arm64

# Test it:
chmod +x dist/videosensei-linux-arm64
./dist/videosensei-linux-arm64 --version
./dist/videosensei-linux-arm64 --help

# Install to PATH:
cp dist/videosensei-linux-arm64 $PREFIX/bin/videosensei
videosensei --version

# Compress a video right from your phone:
videosensei /sdcard/Download/big-video.mp4 -p sensei -o /sdcard/Download/compressed/
```

---

## 5. Option B — Build Flutter APK (~30 min, ~80 MB output)

This builds the **native Android app** — installable like any other APK.

```bash
cd ~/VideoSensei/videosensei

# Generate platform scaffolds (one-time, since the repo doesn't ship them)
flutter create --platforms=android --project-name videosensei .

# Install deps + run Drift codegen
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n || true

# Build APK (arm64-v8a — works on all modern phones)
flutter build apk --release --target-platform android-arm64

# Output:
ls -la build/app/outputs/flutter-apk/app-release.apk
```

### Install the APK on your phone

```bash
# Option 1: Open via Android's installer
termux-open --chooser build/app/outputs/flutter-apk/app-release.apk

# Option 2: Copy to /sdcard/Download and install via Files app
cp build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/VideoSensei.apk
termux-open /sdcard/Download/VideoSensei.apk
```

> ⚠️ If installation is blocked, enable **Settings → Apps → Termux → Install unknown apps**.

---

## 6. Option C — Build everything (CLI + all APK variants)

```bash
cd ~/VideoSensei/cli
bun run build:bun:all    # builds linux-x64, linux-arm64, darwin-x64, darwin-arm64, windows-x64

cd ~/VideoSensei/videosensei

# All Android ABIs in one universal APK:
flutter build apk --release

# Or split per ABI (smaller APKs):
flutter build apk --release --split-per-abi --target-platform android-arm64,android-arm,android-x64

# Play Store App Bundle:
flutter build appbundle --release
```

---

## 7. Trigger GitHub Actions from your phone (alternative)

You don't have to build on the phone — you can trigger the workflow from the GitHub mobile web UI:

1. Open https://github.com/JubairSenseiDev/VideoSensei/actions
2. Tap **"Build Everything"** workflow
3. Tap **"Run workflow"** → pick `flavor: all` → confirm
4. Wait ~25 min. The Actions tab will list every artifact as downloadable.

The `termux-build.yml` workflow specifically produces **Termux-tuned artifacts** (linux-arm64 binary + arm64 APK), which you can grab directly from the **Actions → Artifacts** section.

---

## 8. Common Termux pitfalls

| Symptom | Fix |
| ------- | --- |
| `flutter: command not found` | `source ~/.bashrc` |
| `JAVA_HOME not set` | `export JAVA_HOME=$PREFIX/lib/jvm/openjdk-17` and add to `~/.bashrc` |
| `Android license not accepted` | `yes \| flutter doctor --android-licenses` |
| Build fails on `libmpv` / `media_kit` | Phase 3 hasn't wired media_kit yet — comment out `media_kit` in `pubspec.yaml` |
| `Out of memory` during Flutter build | Close other apps, restart Termux, retry. Phone needs ~3 GB free RAM. |
| `git clone` hangs | Use `--depth 1`: `git clone --depth 1 https://github.com/JubairSenseiDev/VideoSensei.git` |
| APK won't install | Enable Settings → Apps → Termux → "Install unknown apps" |
| Storage permission denied | Run `termux-setup-storage` again |

---

## 9. What you can do with each artifact

| Artifact | Where it runs | Use case |
| -------- | ------------- | -------- |
| `videosensei-linux-arm64` | **Inside Termux** | Quick CLI compression, batch scripts, automation |
| `app-release.apk` (arm64-v8a) | **Android phone** (install) | Native GUI app, file picker, history |
| `app-armeabi-v7a-release.apk` | Old 32-bit phones | Compatibility for older devices |
| `videosensei.js` | Any Node 18+ / Termux w/ Node | Fallback if Bun binary fails |
| `app-release.aab` | Upload to Play Store | Public release |
| `*.tar.gz` (Linux x64/arm64) | PC (Linux) | Desktop install |
| `*.zip` (Windows) | PC (Windows) | Desktop install |

---

## 10. Updates

To pull new changes and rebuild:

```bash
cd ~/VideoSensei
git pull
cd cli && bun install && bun run build:bun:linux-arm64
cd ../videosensei && flutter pub get && dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --target-platform android-arm64
```

That's it — you have a complete, production-grade video compression toolchain running entirely on your phone. 🥋

---

*Hack the size. Keep the clarity.*
