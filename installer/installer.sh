#!/bin/bash
# ============================================================================
#  VideoSensei — installer
# ----------------------------------------------------------------------------
#  Termux-first install. Falls back to pre-built binary on desktop.
#
#  Usage:
#    bash installer.sh               # install
#    bash installer.sh --uninstall   # remove
#    bash installer.sh --version
#    bash installer.sh --help
#
#  Repo:    https://github.com/JubairSenseiDev/VideoSensei
#  Author:  Jubair Sensei <jubairsensei@gmail.com>
#  License: MIT
# ============================================================================

set -u

# ── Config ──────────────────────────────────────────────────────────────────
INSTALLER_VERSION="1.3.0"
REPO_RAW="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main"
REPO_RELEASES="https://github.com/JubairSenseiDev/VideoSensei/releases/latest/download"
SENSEI_DIR="$HOME/.videosensei"
BIN_NAME="videosensei"

# bd-loser/bun-termux — patched Bun runtime for Android
BUN_TERMUX_DEB_URL_ARM64="https://github.com/bd-loser/bun-termux/releases/download/v1.3.14-patched/bun_1.3.14-patched_aarch64.deb"
BUN_TERMUX_VERSION="1.3.14"

# ── Colors ──────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  C_ACCENT='\033[1;38;2;0;255;136m'   # neon green (signature)
  C_DIM='\033[38;2;0;255;136m'        # dim green
  C_INK='\033[1;38;2;255;255;255m'    # bold white
  C_MUTED='\033[38;2;161;161;170m'    # slate
  C_WARN='\033[38;2;250;204;21m'      # amber
  C_ERR='\033[38;2;248;113;113m'      # red
  C_RESET='\033[0m'
else
  C_ACCENT=''; C_DIM=''; C_INK=''; C_MUTED=''; C_WARN=''; C_ERR=''; C_RESET=''
fi

# ── Print helpers ───────────────────────────────────────────────────────────
p_info() { printf '  %b●%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_ok()   { printf '  %b✓%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_warn() { printf '  %b⚠%b  %b\n' "$C_WARN" "$C_RESET" "$1"; }
p_err()  { printf '  %b✗%b  %b\n' "$C_ERR" "$C_RESET" "$1" >&2; }
die()    { p_err "$1"; exit 1; }
have()   { command -v "$1" >/dev/null 2>&1; }

# ── Platform detection ─────────────────────────────────────────────────────
detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux*)  os="linux" ;;
    Darwin*) os="darwin" ;;
    MINGW*|MSYS*|CYGWIN*) os="windows" ;;
    *) os="unknown" ;;
  esac

  case "$arch" in
    x86_64|amd64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) arch="unknown" ;;
  esac

  # Termux detection (Android)
  if [ "$os" = "linux" ] && { [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; }; then
    echo "termux-$arch"
    return
  fi

  echo "${os}-${arch}"
}

PLATFORM=$(detect_platform)

# ── Big banner ──────────────────────────────────────────────────────────────
# Generated with pyfiglet (font: 'doom'). VIDEOSENSEI spelled correctly on one line.
show_banner() {
  printf '\n'
  printf '  %b _   _ ___________ _____ _____ _____ _____ _   _  _____ _____ _____ %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b| | | |_   _|  _  \\  ___|  _  /  ___|  ___| \\ | |/  ___|  ___|_   _|%b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b| | | | | | | | | | |__ | | | \\ `--.| |__ |  \\| |\\ `--.| |__   | |  %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b| | | | | | | | | |  __|| | | |`--. \\  __|| . ` | `--. \\  __|  | |  %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b\\ \\_/ /_| |_| |/ /| |___\\ \\_/ /\\__/ / |___| |\\  |/\\__/ / |___ _| |_ %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b \\___/ \\___/|___/ \\____/ \\___/\\____/\\____/\\_| \\_/\\____/\\____/ \\___/ %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b                                                                     %b\n' "$C_ACCENT" "$C_RESET"
  printf '  %b            Master your video. Sensei-grade clarity.%b\n' "$C_MUTED" "$C_RESET"
  printf '\n'
  printf '  %b installer%s v%s   %bplatform:%b %s   %bby Jubair Sensei%b\n' \
    "$C_INK" "$C_RESET" "$INSTALLER_VERSION" \
    "$C_MUTED" "$C_RESET" "$PLATFORM" \
    "$C_MUTED" "$C_RESET"
  printf '  %b https://jubairsensei.com  ·  https://github.com/JubairSenseiDev/VideoSensei%b\n' \
    "$C_MUTED" "$C_RESET"
  printf '\n'
}

# ── FFmpeg ──────────────────────────────────────────────────────────────────
check_ffmpeg() {
  if ! have ffmpeg; then
    p_warn "FFmpeg not found"
    return 1
  fi
  if ! ffmpeg -version >/dev/null 2>&1; then
    p_warn "FFmpeg binary exists but fails to run (likely ABI mismatch)"
    return 2
  fi
  if ! have ffprobe; then
    p_warn "FFprobe not found (usually ships with FFmpeg)"
    return 1
  fi
  local version
  version=$(ffmpeg -version 2>&1 | head -1 | awk '{print $3}')
  p_ok "FFmpeg ${version} ready"
  return 0
}

install_ffmpeg() {
  p_info "Installing FFmpeg..."
  case "$PLATFORM" in
    termux-*)
      pkg install -y ffmpeg 2>&1 | tail -3 || return 1
      ;;
    linux-*)
      if have apt; then
        sudo apt-get install -y ffmpeg || return 1
      elif have dnf; then
        sudo dnf install -y ffmpeg || return 1
      elif have pacman; then
        sudo pacman -S --noconfirm ffmpeg || return 1
      else
        p_err "No package manager detected."
        return 1
      fi
      ;;
    darwin-*)
      have brew || { p_err "Homebrew not found"; return 1; }
      brew install ffmpeg || return 1
      ;;
    windows-*)
      if have winget; then
        winget install Gyan.FFmpeg || return 1
      elif have choco; then
        choco install ffmpeg -y || return 1
      else
        p_err "Could not install FFmpeg automatically."
        return 1
      fi
      ;;
    *)
      p_err "Unknown platform: $PLATFORM"
      return 1
      ;;
  esac
  p_ok "FFmpeg installed"
}

# ── Bin dir ─────────────────────────────────────────────────────────────────
determine_bin_dir() {
  case "$PLATFORM" in
    termux-*) echo "$PREFIX/bin" ;;
    *)
      if [ -w "/usr/local/bin" ] 2>/dev/null; then
        echo "/usr/local/bin"
      elif [ -w "/usr/bin" ] 2>/dev/null; then
        echo "/usr/bin"
      else
        echo "$HOME/.local/bin"
      fi
      ;;
  esac
}

# ── Termux: install Bun runtime (from bd-loser/bun-termux) ──────────────────
# On Android, Bun's pre-compiled linux-arm64 binary fails due to SELinux + Bionic.
# bd-loser/bun-termux patches all that. We use Bun to run the JS bundle directly.
install_bun_termux() {
  local arch="${PLATFORM##*-}"
  local deb_url deb_name

  case "$arch" in
    arm64)
      deb_url="$BUN_TERMUX_DEB_URL_ARM64"
      deb_name="bun_${BUN_TERMUX_VERSION}-patched_aarch64.deb"
      ;;
    *)
      p_warn "Bun for Termux ${arch} not available — will fall back to Node.js"
      return 1
      ;;
  esac

  if have bun && bun --version >/dev/null 2>&1; then
    p_ok "Bun $(bun --version) ready"
    return 0
  fi

  p_info "Installing Bun for Termux (bd-loser/bun-termux)..."
  p_info "URL: ${C_MUTED}${deb_url}${C_RESET}"

  local tmp_deb="${PREFIX:-/data/data/com.termux/files/usr}/tmp/${deb_name}"
  mkdir -p "$(dirname "$tmp_deb")"

  if ! curl -fsSL "$deb_url" -o "$tmp_deb"; then
    p_warn "Failed to download Bun .deb"
    return 1
  fi

  p_info "Installing .deb..."
  if ! dpkg -i "$tmp_deb" 2>&1 | tail -5; then
    p_warn "dpkg install failed, retrying with --force..."
    dpkg -i --force-all "$tmp_deb" 2>&1 | tail -5 || {
      rm -f "$tmp_deb"
      return 1
    }
  fi
  rm -f "$tmp_deb"

  if ! have bun || ! bun --version >/dev/null 2>&1; then
    p_warn "Bun installed but won't run — likely Termux ABI mismatch"
    p_info "Running pkg upgrade to sync packages..."
    pkg upgrade -y 2>&1 | tail -5 || true
    dpkg --configure -a 2>/dev/null || true
  fi

  if have bun && bun --version >/dev/null 2>&1; then
    p_ok "Bun $(bun --version) installed"
    return 0
  fi
  return 1
}

# Install videosensei via Bun runtime (preferred on Termux)
install_via_bun() {
  local bin_dir target js_target
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  target="$bin_dir/$BIN_NAME"
  js_target="$SENSEI_DIR/videosensei.js"

  p_info "Downloading JS bundle..."
  if ! curl -fsSL "${REPO_RAW}/cli/dist/videosensei.js" -o "$js_target"; then
    p_err "Failed to download bundle."
    return 1
  fi
  chmod +x "$js_target"
  p_ok "Bundle saved to ${C_MUTED}${js_target}${C_RESET}"

  # Launcher script — exec bun on the JS bundle
  local launcher="/tmp/videosensei_launcher_$$"
  cat > "$launcher" << EOF
#!/data/data/com.termux/files/usr/bin/bash
# VideoSensei launcher (Bun runtime) — auto-generated by installer v${INSTALLER_VERSION}
exec bun "$js_target" "\$@"
EOF
  chmod +x "$launcher"
  mv "$launcher" "$target" 2>/dev/null || cp "$launcher" "$target"
  chmod +x "$target"
  rm -f "$launcher"

  p_ok "Installed to ${C_MUTED}${target}${C_RESET} (runs via Bun)"
  return 0
}

# ── Pre-built binary (desktop) ──────────────────────────────────────────────
get_binary_url() {
  local os arch
  os="${PLATFORM%%-*}"
  arch="${PLATFORM##*-}"

  local filename
  case "$os-$arch" in
    linux-x64)    filename="videosensei-linux-x64" ;;
    linux-arm64)  filename="videosensei-linux-arm64" ;;
    darwin-x64)   filename="videosensei-darwin-x64" ;;
    darwin-arm64) filename="videosensei-darwin-arm64" ;;
    windows-x64)  filename="videosensei-windows-x64.exe" ;;
    *) return 1 ;;
  esac

  echo "${REPO_RELEASES}/${filename}"
}

install_binary() {
  local bin_dir target tmp_bin url size
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  local sudo=""
  if { [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; } && [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
  fi

  target="$bin_dir/$BIN_NAME"
  tmp_bin="/tmp/videosensei_bin_$$"

  url=$(get_binary_url) || {
    p_warn "No pre-built binary for ${PLATFORM}. Will use Node.js bundle."
    return 1
  }

  p_info "Downloading ${C_MUTED}${PLATFORM}${C_RESET} binary..."
  p_info "URL: ${C_MUTED}${url}${C_RESET}"
  if ! curl -fSL "$url" -o "$tmp_bin"; then
    p_warn "Download failed."
    rm -f "$tmp_bin"
    return 1
  fi

  size=$(wc -c < "$tmp_bin")
  p_ok "Downloaded ($(numfmt --to=iec "$size" 2>/dev/null || echo "${size} bytes"))"
  chmod +x "$tmp_bin"

  if ! "$tmp_bin" --version >/dev/null 2>&1; then
    p_warn "Binary failed to run on this platform. Falling back to Node.js bundle."
    rm -f "$tmp_bin"
    return 1
  fi
  p_ok "Binary verified"

  p_info "Installing to ${C_MUTED}${target}${C_RESET}..."
  if [ -n "$sudo" ]; then
    $sudo mv "$tmp_bin" "$target"
  else
    mv "$tmp_bin" "$target" 2>/dev/null || cp "$tmp_bin" "$target"
  fi
  chmod +x "$target"

  # PATH hint
  case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *)
      p_warn "${bin_dir} is not in your PATH"
      p_info "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
      printf '  %bexport PATH="%s:$PATH"%b\n' "$C_ACCENT" "$bin_dir" "$C_RESET"
      ;;
  esac

  p_ok "Installed to $target"
  return 0
}

# ── Node.js fallback ────────────────────────────────────────────────────────
check_node() {
  if ! have node; then
    p_warn "Node.js not found"
    return 1
  fi
  if ! node --version >/dev/null 2>&1; then
    p_warn "Node.js binary exists but fails to run"
    return 2
  fi
  local version major
  version=$(node --version 2>/dev/null | sed 's/v//')
  major=$(echo "$version" | cut -d. -f1)
  if [ "${major:-0}" -ge 18 ] 2>/dev/null; then
    p_ok "Node.js v${version} ready"
    return 0
  fi
  p_warn "Node.js v${version} found (need >=18)"
  return 1
}

install_node() {
  p_info "Installing Node.js..."
  case "$PLATFORM" in
    termux-*)
      pkg install -y nodejs 2>&1 | tail -3 || return 1
      ;;
    linux-*)
      if have apt; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y nodejs || return 1
      elif have dnf; then
        sudo dnf install -y nodejs || return 1
      elif have pacman; then
        sudo pacman -S --noconfirm nodejs || return 1
      else
        return 1
      fi
      ;;
    darwin-*)
      have brew || return 1
      brew install node || return 1
      ;;
    windows-*)
      if have winget; then
        winget install OpenJS.NodeJS.LTS || return 1
      elif have choco; then
        choco install nodejs -y || return 1
      else
        return 1
      fi
      ;;
    *)
      return 1
      ;;
  esac
  p_ok "Node.js installed"
}

install_via_node() {
  local bin_dir target js_target launcher
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  target="$bin_dir/$BIN_NAME"
  js_target="$SENSEI_DIR/videosensei.js"

  p_info "Downloading JS bundle..."
  if ! curl -fsSL "${REPO_RAW}/cli/dist/videosensei.js" -o "$js_target"; then
    p_err "Failed to download bundle."
    return 1
  fi
  chmod +x "$js_target"
  p_ok "Bundle saved"

  launcher="/tmp/videosensei_launcher_$$"
  cat > "$launcher" << EOF
#!/bin/bash
# VideoSensei launcher (Node.js) — auto-generated by installer v${INSTALLER_VERSION}
exec node "$js_target" "\$@"
EOF
  chmod +x "$launcher"

  local sudo=""
  if { [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; } && [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
  fi
  if [ -n "$sudo" ]; then
    $sudo mv "$launcher" "$target"
  else
    mv "$launcher" "$target" 2>/dev/null || cp "$launcher" "$target"
  fi
  chmod +x "$target"
  rm -f "$launcher"

  p_ok "Installed to ${C_MUTED}${target}${C_RESET} (Node.js bundle)"
  return 0
}

# ── Verify ──────────────────────────────────────────────────────────────────
verify_installation() {
  if have videosensei; then
    local version
    version=$(videosensei --version 2>/dev/null | head -1)
    printf '\n'
    p_ok "VideoSensei ready: ${C_ACCENT}${version}${C_RESET}"
    printf '\n'
    printf '  %bQuick start:%b\n' "$C_INK" "$C_RESET"
    printf '  %bvideosensei%b                          %b# picker + smart + compress%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b video.mp4                %b# smart preset, auto-compress%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b video.mp4 -p sensei      %b# AV1 master%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b -i                       %b# interactive menu%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '\n'
    printf '  %bHack the size. Keep the clarity.%b\n' "$C_MUTED" "$C_RESET"
    printf '  %bhttps://jubairsensei.com%b\n' "$C_MUTED" "$C_RESET"
  else
    p_err "Installation verification failed."
    p_info "Try running 'videosensei --version' manually."
    return 1
  fi
}

# ── Uninstall ───────────────────────────────────────────────────────────────
uninstall_videosensei() {
  local bin_dir target
  bin_dir=$(determine_bin_dir)
  target="$bin_dir/$BIN_NAME"

  p_info "Removing VideoSensei..."
  if [ -f "$target" ]; then
    if [ -w "$bin_dir" ] 2>/dev/null; then
      rm -f "$target"
    else
      sudo rm -f "$target" 2>/dev/null || rm -f "$target" 2>/dev/null || true
    fi
    p_ok "Removed ${C_MUTED}${target}${C_RESET}"
  else
    p_warn "$target not found"
  fi

  if [ -d "$SENSEI_DIR" ]; then
    printf '  %bRemove config + history at %s? [y/N] %b' "$C_INK" "$SENSEI_DIR" "$C_RESET"
    read -r reply
    if [ "${reply:-}" = "y" ] || [ "${reply:-}" = "Y" ]; then
      rm -rf "$SENSEI_DIR"
      p_ok "Removed ${C_MUTED}${SENSEI_DIR}${C_RESET}"
    fi
  fi

  printf '\n'
  p_ok "VideoSensei uninstalled"
}

# ── Main ────────────────────────────────────────────────────────────────────
main() {
  show_banner

  case "${1:-}" in
    --uninstall|-u)
      uninstall_videosensei
      exit 0
      ;;
    --version|-v)
      printf 'VideoSensei installer v%s\n' "$INSTALLER_VERSION"
      exit 0
      ;;
    --help|-h)
      cat <<EOF
VideoSensei installer v${INSTALLER_VERSION}

Usage:
  bash installer.sh                Install VideoSensei
  bash installer.sh --uninstall     Remove VideoSensei
  bash installer.sh --version       Show installer version
  bash installer.sh --help          Show this help

Platform detected: ${PLATFORM}

Repo:  https://github.com/JubairSenseiDev/VideoSensei
Site:  https://jubairsensei.com
EOF
      exit 0
      ;;
  esac

  # ── Step 1: FFmpeg (required for any path) ────────────────────────────────
  printf '  %b[1/3]%b Checking FFmpeg...\n' "$C_INK" "$C_RESET"
  check_ffmpeg
  ffmpeg_status=$?
  if [ "$ffmpeg_status" -ne 0 ]; then
    if [ "$ffmpeg_status" -eq 2 ] && [ "${PLATFORM%%-*}" = "termux" ]; then
      p_info "Running pkg upgrade to fix ABI mismatch..."
      pkg upgrade -y 2>&1 | tail -5 || true
      pkg install -y --reinstall ffmpeg 2>&1 | tail -3 || true
      check_ffmpeg || die "FFmpeg still broken. Manual fix: pkg update && pkg upgrade -y && pkg install --reinstall ffmpeg"
    else
      printf '  %bInstall FFmpeg now? [Y/n] %b' "$C_INK" "$C_RESET"
      read -r reply
      if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
        install_ffmpeg || die "FFmpeg installation failed."
      else
        die "FFmpeg is required."
      fi
    fi
  fi

  # ── Step 2: Install videosensei ───────────────────────────────────────────
  printf '\n  %b[2/3]%b Installing VideoSensei...\n' "$C_INK" "$C_RESET"

  # Termux: Bun runtime path (preferred for Android)
  if [ "${PLATFORM%%-*}" = "termux" ]; then
    p_info "Termux detected — using Bun runtime (recommended for Android)"
    printf '\n'
    if install_bun_termux && install_via_bun; then
      printf '\n'
      verify_installation
      exit 0
    fi
    p_warn "Bun path failed — trying Node.js bundle as fallback"
    printf '\n'
  fi

  # Desktop: pre-built single binary (no runtime needed)
  if install_binary; then
    printf '\n'
    verify_installation
    exit 0
  fi

  # Universal fallback: Node.js + JS bundle
  p_info "Falling back to Node.js bundle..."
  printf '\n'
  check_node
  node_status=$?
  if [ "$node_status" -ne 0 ]; then
    if [ "$node_status" -eq 2 ] && [ "${PLATFORM%%-*}" = "termux" ]; then
      pkg upgrade -y 2>&1 | tail -5 || true
      pkg install -y --reinstall nodejs 2>&1 | tail -3 || true
      check_node || die "Node.js still broken."
    else
      printf '  %bInstall Node.js now? [Y/n] %b' "$C_INK" "$C_RESET"
      read -r reply
      if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
        install_node || die "Node.js installation failed."
      else
        die "Node.js is required for fallback bundle."
      fi
    fi
  fi

  install_via_node || die "Failed to install Node.js bundle."

  printf '\n'
  verify_installation
}

main "$@"
