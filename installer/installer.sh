#!/bin/bash
# ============================================================================
# VideoSensei — Modern installer (v1.2.0)
# ============================================================================
# Downloads the right pre-built single-binary for your platform.
# No Node.js, no Bun runtime needed at user's machine — the binary is self-contained.
#
# Fallback: if no pre-built binary available for your platform, downloads the
# Node.js-compatible bundle and ensures Node.js is installed.
#
# Supported platforms (pre-built binaries):
#   • Linux x86_64       (most desktops/servers)
#   • Linux arm64        (Raspberry Pi 4, Termux on arm64 Android, Apple Silicon Linux VMs)
#   • macOS x86_64       (Intel Macs)
#   • macOS arm64        (Apple Silicon Macs)
#   • Windows x86_64     (most Windows)
#
# Usage:
#   bash installer.sh                # install
#   bash installer.sh --uninstall
#   bash installer.sh --version
#   bash installer.sh --help
#
# Author: Jubair Sensei <jubairsensei@gmail.com>
# Site:   https://jubairsensei.com
# Repo:   https://github.com/JubairSenseiDev/VideoSensei
# License: MIT
# ============================================================================

set -u

# ============================================================================
# CONFIG
# ============================================================================
INSTALLER_VERSION="1.2.1"
REPO_RAW="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main"
REPO_RELEASES="https://github.com/JubairSenseiDev/VideoSensei/releases/latest/download"
SENSEI_DIR="$HOME/.videosensei"
BIN_NAME="videosensei"

# Detect platform + architecture
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

# ============================================================================
# COLORS — VideoSensei theme
# ============================================================================
if [ -t 1 ]; then
  C_ACCENT='\033[38;2;0;255;136m'
  C_ACCENT_BOLD='\033[1;38;2;0;255;136m'
  C_INK='\033[38;2;255;255;255m'
  C_MUTED='\033[38;2;161;161;170m'
  C_WARN='\033[38;2;250;204;21m'
  C_ERR='\033[38;2;248;113;113m'
  C_CYAN='\033[38;2;34;211;238m'
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
else
  C_ACCENT=''; C_ACCENT_BOLD=''; C_INK=''; C_MUTED=''; C_WARN=''; C_ERR=''; C_CYAN=''; C_RESET=''; C_BOLD=''
fi

# ============================================================================
# PRINT HELPERS
# ============================================================================
p_info()   { printf '  %b●%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_ok()     { printf '  %b✓%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_warn()   { printf '  %b⚠%b  %b\n' "$C_WARN" "$C_RESET" "$1"; }
p_err()    { printf '  %b✗%b  %b\n' "$C_ERR" "$C_RESET" "$1" >&2; }

die() { p_err "$1"; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ============================================================================
# LOGO
# ============================================================================
show_logo() {
  printf '%b\n' "${C_ACCENT}    ╱━━━━━━━╲${C_RESET}"
  printf '%b\n' "${C_ACCENT}   ╱  ┃█┃  ╲ ${C_RESET}${C_BOLD}VIDEOSENSEI${C_RESET} ${C_MUTED}installer v${INSTALLER_VERSION}${C_RESET}"
  printf '%b\n' "${C_ACCENT}  ╱  ┃█┃  ╲  ${C_RESET}${C_MUTED}Master your video. Sensei-grade clarity.${C_RESET}"
  printf '%b\n' "${C_ACCENT}  ╲  ┃█┃  ╱  ${C_RESET}${C_MUTED}by Jubair Sensei${C_RESET}"
  printf '%b\n' "${C_ACCENT}   ╲━━━━━╱   ${C_RESET}${C_MUTED}https://jubairsensei.com${C_RESET}"
  printf '\n'
  p_info "Platform: ${C_ACCENT}${PLATFORM}${C_RESET}"
  p_info "Sensei dir: ${C_MUTED}${SENSEI_DIR}${C_RESET}"
  printf '\n'
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================
# For single-binary install, we only need FFmpeg (not Node.js!)
check_ffmpeg() {
  if ! command_exists ffmpeg; then
    p_warn "FFmpeg not found"
    return 1
  fi
  if ! ffmpeg -version >/dev/null 2>&1; then
    p_warn "FFmpeg binary exists but fails to run (likely ABI mismatch)"
    return 2
  fi
  if ! command_exists ffprobe; then
    p_warn "FFprobe not found (usually ships with FFmpeg)"
    return 1
  fi
  if ! ffprobe -version >/dev/null 2>&1; then
    p_warn "FFprobe binary exists but fails to run"
    return 2
  fi
  local version
  version=$(ffmpeg -version 2>&1 | head -1 | awk '{print $3}')
  p_ok "FFmpeg ${version} found and working"
  return 0
}

# ============================================================================
# TERMUX HELPERS
# ============================================================================
termux_setup_mirror() {
  local sources_file="$PREFIX/etc/apt/sources.list"
  if [ ! -f "$sources_file" ] || ! grep -q "termux-main" "$sources_file" 2>/dev/null; then
    p_info "Setting Termux mirror (packages-cf.termux.dev)..."
    mkdir -p "$(dirname "$sources_file")"
    echo "deb https://packages-cf.termux.dev/apt/termux-main/ stable main" > "$sources_file"
    p_ok "Mirror set"
  fi
}

termux_install_pkg() {
  local pkg="$1"
  for attempt in 1 2 3; do
    p_info "Installing ${pkg} (attempt ${attempt}/3)..."
    if pkg install -y "$pkg" 2>&1 | tail -5; then
      if command_exists "$pkg" || { [ "$pkg" = "ffmpeg" ] && command_exists ffmpeg; }; then
        return 0
      fi
    fi
    p_warn "Attempt ${attempt} failed, trying a different mirror..."
    case "$attempt" in
      1) echo "deb https://mirrors.cbrx.io/apt/termux/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
      2) echo "deb https://mirror.rinarin.dev/termux/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
      3) echo "deb https://packages-cf.termux.dev/apt/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
    esac
    pkg update -y >/dev/null 2>&1 || true
  done
  return 1
}

termux_fix_abi_mismatch() {
  printf '\n'
  p_warn "Detected Termux ABI mismatch (partial upgrade issue)."
  p_info "Running ${C_ACCENT}pkg upgrade -y${C_RESET} to sync all packages..."
  printf '\n'
  if pkg upgrade -y 2>&1 | tail -20; then
    p_ok "Package upgrade complete"
  else
    p_warn "pkg upgrade had errors. Trying pkg update + reinstall..."
    pkg update -y >/dev/null 2>&1 || true
    pkg upgrade -y 2>&1 | tail -10 || true
  fi
}

termux_reinstall_pkg() {
  local pkg="$1"
  p_info "Force reinstalling ${pkg}..."
  pkg install -y --reinstall "$pkg" 2>&1 | tail -5 || true
}

install_ffmpeg() {
  p_info "Installing FFmpeg..."
  case "$PLATFORM" in
    termux-*)
      termux_setup_mirror
      if ! termux_install_pkg ffmpeg; then
        p_err "Failed to install FFmpeg via pkg."
        p_info "Manual fix: pkg install ffmpeg"
        return 1
      fi
      if ! ffmpeg -version >/dev/null 2>&1; then
        p_warn "FFmpeg installed but won't run — likely ABI mismatch."
        termux_fix_abi_mismatch
        termux_reinstall_pkg ffmpeg
        if ! ffmpeg -version >/dev/null 2>&1; then
          p_err "FFmpeg still won't run after upgrade + reinstall."
          p_info "Final manual fix:"
          printf '  %bpkg update && pkg upgrade -y%b\n' "$C_ACCENT" "$C_RESET"
          printf '  %bpkg install --reinstall ffmpeg%b\n' "$C_ACCENT" "$C_RESET"
          return 1
        fi
      fi
      ;;
    linux-*)
      if command_exists apt; then
        sudo apt-get install -y ffmpeg || return 1
      elif command_exists dnf; then
        sudo dnf install -y ffmpeg || return 1
      elif command_exists pacman; then
        sudo pacman -S --noconfirm ffmpeg || return 1
      else
        p_err "Could not detect package manager."
        return 1
      fi
      ;;
    darwin-*)
      if ! command_exists brew; then
        p_err "Homebrew not found."
        return 1
      fi
      brew install ffmpeg || return 1
      ;;
    windows-*)
      if command_exists winget; then
        winget install Gyan.FFmpeg || return 1
      elif command_exists choco; then
        choco install ffmpeg -y || return 1
      else
        p_err "Could not install FFmpeg automatically."
        return 1
      fi
      ;;
    *)
      p_err "Unknown platform."
      return 1
      ;;
  esac
  p_ok "FFmpeg installed"
}

# ============================================================================
# BINARY DOWNLOAD
# ============================================================================
# Map our platform to the binary filename
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

determine_bin_dir() {
  case "$PLATFORM" in
    termux-*)
      echo "$PREFIX/bin"
      ;;
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

# ============================================================================
# TERMUX-SPECIFIC: Install Bun runtime + run JS bundle (preferred path)
# ============================================================================
# On Termux, pre-built Linux-arm64 binary may fail due to SELinux/Bionic.
# Instead, install Bun for Termux (from bd-loser/bun-termux) and run the
# JS bundle directly with `bun run` — fast startup, full Android compatibility.

BUN_TERMUX_DEB_URL="https://github.com/bd-loser/bun-termux/releases/download/v1.3.14-patched/bun_1.3.14-patched_aarch64.deb"
BUN_TERMUX_DEB_URL_X64="https://github.com/bd-loser/bun-termux/releases/download/v1.3.14-patched/bun_1.3.14-patched_x86_64.deb"

check_bun() {
  if ! command_exists bun; then
    return 1
  fi
  if ! bun --version >/dev/null 2>&1; then
    p_warn "Bun binary exists but fails to run"
    return 2
  fi
  local version
  version=$(bun --version 2>/dev/null)
  p_ok "Bun ${version} found and working"
  return 0
}

install_bun_termux() {
  local arch="${PLATFORM##*-}"
  local deb_url
  local deb_name

  case "$arch" in
    arm64)
      deb_url="$BUN_TERMUX_DEB_URL"
      deb_name="bun_1.3.14-patched_aarch64.deb"
      ;;
    x64)
      # bd-loser/bun-termux may not have x86_64 build; fall back to Node.js path
      p_warn "Bun for Termux x86_64 not available — using Node.js path instead"
      return 1
      ;;
    *)
      p_warn "Unknown Termux arch: $arch — using Node.js path instead"
      return 1
      ;;
  esac

  p_info "Installing Bun for Termux (from bd-loser/bun-termux)..."
  p_info "URL: ${C_MUTED}${deb_url}${C_RESET}"

  local tmp_deb
  tmp_deb="${PREFIX:-/data/data/com.termux/files/usr}/tmp/${deb_name}"
  mkdir -p "$(dirname "$tmp_deb")"

  if ! curl -fsSL "$deb_url" -o "$tmp_deb"; then
    p_warn "Failed to download Bun .deb"
    return 1
  fi

  p_info "Installing .deb package..."
  if ! dpkg -i "$tmp_deb" 2>&1 | tail -5; then
    p_warn "dpkg install failed, trying with --force..."
    dpkg -i --force-all "$tmp_deb" 2>&1 | tail -5 || {
      rm -f "$tmp_deb"
      return 1
    }
  fi
  rm -f "$tmp_deb"

  # Verify
  if ! command_exists bun || ! bun --version >/dev/null 2>&1; then
    p_warn "Bun installed but doesn't run — likely Termux ABI mismatch"
    termux_fix_abi_mismatch
    if command_exists bun; then
      dpkg --configure -a 2>/dev/null || true
      pkg install -y --reinstall bun 2>&1 | tail -3 || true
    fi
    if ! bun --version >/dev/null 2>&1; then
      p_warn "Bun still won't run"
      return 1
    fi
  fi

  p_ok "Bun $(bun --version) installed"
  return 0
}

# Install videosensei using Bun runtime (preferred on Termux)
install_with_bun_runtime() {
  local bin_dir
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  local target="$bin_dir/$BIN_NAME"
  local tmp_js="/tmp/videosensei_bundle_$$.js"
  local tmp_launcher="/tmp/videosensei_launcher_$$"

  p_info "Downloading Node.js bundle (will run with Bun on Termux)..."
  if ! curl -fsSL "${REPO_RAW}/cli/dist/videosensei.js" -o "$tmp_js"; then
    p_err "Failed to download bundle."
    return 1
  fi
  p_ok "Downloaded bundle"

  local js_target="$SENSEI_DIR/videosensei.js"
  cp "$tmp_js" "$js_target"
  chmod +x "$js_target"
  rm -f "$tmp_js"

  # Use Bun to run (much faster startup than Node.js, ~4x)
  cat > "$tmp_launcher" << EOF
#!/data/data/com.termux/files/usr/bin/bash
# VideoSensei launcher — auto-generated by installer v${INSTALLER_VERSION}
# Uses Bun runtime (from bd-loser/bun-termux) for fast startup + Android compat
exec bun "$js_target" "\$@"
EOF
  chmod +x "$tmp_launcher"

  mv "$tmp_launcher" "$target" 2>/dev/null || cp "$tmp_launcher" "$target"
  chmod +x "$target"
  rm -f "$tmp_launcher"

  p_ok "Installed to $target (running via Bun runtime)"
  return 0
}

install_binary() {
  local bin_dir
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  local sudo=""
  if { [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; } && [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
  fi

  local target="$bin_dir/$BIN_NAME"
  local tmp_bin="/tmp/videosensei_bin_$$"

  # On Termux: try Bun runtime path FIRST (more reliable than Linux-arm64 binary)
  if [ "${PLATFORM%%-*}" = "termux" ]; then
    p_info "Detected Termux — trying Bun runtime path (recommended for Android)..."
    printf '\n'

    # Step A: ensure Bun is installed
    if ! check_bun; then
      if ! install_bun_termux; then
        p_warn "Bun install failed — will try pre-built binary or Node.js fallback"
      fi
    fi

    # Step B: install launcher that runs JS bundle via Bun
    if command_exists bun && bun --version >/dev/null 2>&1; then
      if install_with_bun_runtime; then
        return 0
      fi
    fi

    p_warn "Bun runtime path failed — trying pre-built Linux-arm64 binary..."
    printf '\n'
  fi

  local url
  url=$(get_binary_url)
  if [ -z "$url" ]; then
    p_warn "No pre-built binary for ${PLATFORM}. Falling back to Node.js bundle..."
    return 1
  fi

  p_info "Downloading pre-built binary for ${C_MUTED}${PLATFORM}${C_RESET}..."
  p_info "URL: ${C_MUTED}${url}${C_RESET}"
  if ! curl -fSL "$url" -o "$tmp_bin"; then
    p_warn "Failed to download pre-built binary."
    p_info "Falling back to Node.js bundle install..."
    rm -f "$tmp_bin"
    return 1
  fi

  local size
  size=$(wc -c < "$tmp_bin")
  p_ok "Downloaded ($(numfmt --to=iec "$size" 2>/dev/null || echo "${size} bytes"))"

  chmod +x "$tmp_bin"

  # Quick sanity check — does the binary actually run?
  if ! "$tmp_bin" --version >/dev/null 2>&1; then
    p_warn "Downloaded binary failed to run on this platform."
    if [ "${PLATFORM%%-*}" = "termux" ]; then
      p_info "This is common on Termux (Android SELinux/Bionic restrictions)."
      p_info "Falling back to Node.js bundle..."
    else
      p_info "Falling back to Node.js bundle install..."
    fi
    rm -f "$tmp_bin"
    return 1
  fi
  p_ok "Binary runs correctly"

  p_info "Installing to ${C_MUTED}${target}${C_RESET}..."
  if [ -n "$sudo" ]; then
    $sudo mv "$tmp_bin" "$target"
  else
    mv "$tmp_bin" "$target" 2>/dev/null || cp "$tmp_bin" "$target"
  fi
  chmod +x "$target"

  # Ensure bin_dir is in PATH
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

# ============================================================================
# FALLBACK: Node.js bundle install (if no pre-built binary)
# ============================================================================
check_node() {
  if ! command_exists node; then
    p_warn "Node.js not found"
    return 1
  fi
  if ! node --version >/dev/null 2>&1; then
    p_warn "Node.js binary exists but fails to run (likely ABI mismatch)"
    return 2
  fi
  local version major
  version=$(node --version 2>/dev/null | sed 's/v//')
  major=$(echo "$version" | cut -d. -f1)
  if [ "${major:-0}" -ge 18 ] 2>/dev/null; then
    p_ok "Node.js v${version} found and working"
    return 0
  else
    p_warn "Node.js v${version} found (need >=18)"
    return 1
  fi
}

install_node() {
  p_info "Installing Node.js..."
  case "$PLATFORM" in
    termux-*)
      termux_setup_mirror
      if ! termux_install_pkg nodejs; then
        return 1
      fi
      if ! node --version >/dev/null 2>&1; then
        p_warn "Node.js installed but won't run — likely ABI mismatch."
        termux_fix_abi_mismatch
        termux_reinstall_pkg nodejs
        node --version >/dev/null 2>&1 || return 1
      fi
      ;;
    linux-*)
      if command_exists apt; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y nodejs || return 1
      elif command_exists dnf; then
        sudo dnf install -y nodejs || return 1
      elif command_exists pacman; then
        sudo pacman -S --noconfirm nodejs || return 1
      else
        return 1
      fi
      ;;
    darwin-*)
      command_exists brew || return 1
      brew install node || return 1
      ;;
    windows-*)
      if command_exists winget; then
        winget install OpenJS.NodeJS.LTS || return 1
      elif command_exists choco; then
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

install_bundle_fallback() {
  p_info "Installing Node.js bundle as fallback..."
  local bin_dir
  bin_dir=$(determine_bin_dir)
  local sudo=""
  if { [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; } && [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
  fi

  local target="$bin_dir/$BIN_NAME"
  local tmp_js="/tmp/videosensei_bundle_$$.js"
  local tmp_launcher="/tmp/videosensei_launcher_$$"

  p_info "Downloading Node.js bundle..."
  if ! curl -fsSL "${REPO_RAW}/cli/dist/videosensei.js" -o "$tmp_js"; then
    p_err "Failed to download bundle."
    return 1
  fi
  p_ok "Downloaded bundle"

  local js_target="$SENSEI_DIR/videosensei.js"
  cp "$tmp_js" "$js_target"
  chmod +x "$js_target"
  rm -f "$tmp_js"

  cat > "$tmp_launcher" << EOF
#!/bin/bash
# VideoSensei launcher — auto-generated by installer v${INSTALLER_VERSION}
exec node "$js_target" "\$@"
EOF
  chmod +x "$tmp_launcher"

  if [ -n "$sudo" ]; then
    $sudo mv "$tmp_launcher" "$target"
  else
    mv "$tmp_launcher" "$target" 2>/dev/null || cp "$tmp_launcher" "$target"
  fi
  chmod +x "$target"
  rm -f "$tmp_launcher"

  p_ok "Installed to $target (Node.js bundle)"
}

# ============================================================================
# VERIFY
# ============================================================================
verify_installation() {
  if command_exists videosensei; then
    local version
    version=$(videosensei --version 2>/dev/null | head -1)
    p_ok "VideoSensei is ready: ${C_ACCENT}${version}${C_RESET}"
    printf '\n'
    printf '  %bQuick start (auto-mode, zero prompts):%b\n' "$C_BOLD" "$C_RESET"
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

# ============================================================================
# UNINSTALL
# ============================================================================
uninstall_videosensei() {
  local bin_dir
  bin_dir=$(determine_bin_dir)
  local target="$bin_dir/$BIN_NAME"

  p_info "Removing VideoSensei..."
  if [ -f "$target" ]; then
    if [ -w "$bin_dir" ] 2>/dev/null; then
      rm -f "$target"
    else
      sudo rm -f "$target" 2>/dev/null || rm -f "$target" 2>/dev/null || true
    fi
    p_ok "Removed $target"
  else
    p_warn "$target not found"
  fi

  if [ -d "$SENSEI_DIR" ]; then
    printf '  %bRemove config + history at %s? [y/N] %b' "$C_BOLD" "$SENSEI_DIR" "$C_RESET"
    read -r reply
    if [ "${reply:-}" = "y" ] || [ "${reply:-}" = "Y" ]; then
      rm -rf "$SENSEI_DIR"
      p_ok "Removed $SENSEI_DIR"
    fi
  fi

  printf '\n'
  p_ok "VideoSensei uninstalled"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  show_logo

  case "${1:-}" in
    --uninstall|-u)  uninstall_videosensei; exit 0 ;;
    --version|-v)    printf 'VideoSensei installer v%s\n' "$INSTALLER_VERSION"; exit 0 ;;
    --help|-h)       printf 'Usage: bash installer.sh [--uninstall|--version|--help]\n'; exit 0 ;;
  esac

  # Step 1: FFmpeg (required for any install path)
  check_ffmpeg
  ffmpeg_status=$?
  if [ "$ffmpeg_status" -ne 0 ]; then
    if [ "$ffmpeg_status" -eq 2 ]; then
      if [ "${PLATFORM%%-*}" = "termux" ]; then
        termux_fix_abi_mismatch
        termux_reinstall_pkg ffmpeg
        check_ffmpeg || die "FFmpeg still broken. Run: pkg update && pkg upgrade -y && pkg install --reinstall ffmpeg"
      else
        printf '  %bReinstall FFmpeg now? [Y/n] %b' "$C_BOLD" "$C_RESET"
        read -r reply
        if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
          install_ffmpeg || die "FFmpeg installation failed."
        else
          die "FFmpeg is broken. Please reinstall manually."
        fi
      fi
    else
      printf '  %bInstall FFmpeg now? [Y/n] %b' "$C_BOLD" "$C_RESET"
      read -r reply
      if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
        install_ffmpeg || die "FFmpeg installation failed."
      else
        die "FFmpeg is required. Install manually."
      fi
    fi
  fi

  # Step 2: Try pre-built binary first (no Node.js needed!)
  if install_binary; then
    printf '\n'
    verify_installation
    exit 0
  fi

  # Step 3: Fallback to Node.js bundle
  p_info "Pre-built binary unavailable for ${PLATFORM}. Using Node.js bundle."
  printf '\n'

  check_node
  node_status=$?
  if [ "$node_status" -ne 0 ]; then
    if [ "$node_status" -eq 2 ]; then
      if [ "${PLATFORM%%-*}" = "termux" ]; then
        termux_fix_abi_mismatch
        termux_reinstall_pkg nodejs
        check_node || die "Node.js still broken. Run: pkg update && pkg upgrade -y && pkg install --reinstall nodejs"
      else
        printf '  %bReinstall Node.js now? [Y/n] %b' "$C_BOLD" "$C_RESET"
        read -r reply
        if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
          install_node || die "Node.js installation failed."
        else
          die "Node.js is broken. Please reinstall from https://nodejs.org/"
        fi
      fi
    else
      printf '  %bInstall Node.js now? [Y/n] %b' "$C_BOLD" "$C_RESET"
      read -r reply
      if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
        install_node || die "Node.js installation failed."
      else
        die "Node.js is required for fallback bundle. Install from https://nodejs.org/"
      fi
    fi
  fi

  install_bundle_fallback || die "Failed to install Node.js bundle."

  printf '\n'
  verify_installation
}

main "$@"
