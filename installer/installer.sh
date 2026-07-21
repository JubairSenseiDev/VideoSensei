#!/bin/bash
# ============================================================================
# VideoSensei — Cross-platform installer  (v1.0.1)
# ============================================================================
# Installs VideoSensei CLI on:
#   • Linux (Debian/Ubuntu/Fedora/Arch)
#   • macOS (Homebrew)
#   • Termux (Android)
#   • Windows (Git Bash / MSYS2 / WSL)
#
# v1.0.1 fixes:
#   - Use printf instead of echo (truecolor codes now work in ALL shells)
#   - Termux: handle mirror selection gracefully
#   - Termux: graceful fallback if pkg fails
#   - Better error messages with copy-paste fix instructions
#
# Usage:
#   bash installer.sh               # install
#   bash installer.sh --uninstall
#   bash installer.sh --version
#   bash installer.sh --help
#
# Author: Jubair Sensei <jubairsensei@gmail.com>
# Site:   https://jubairsensei.com
# Repo:   https://github.com/JubairSenseiDev/VideoSensei
# License: MIT
# ============================================================================

set -u  # fail on undefined vars; do NOT use -e (we handle errors manually)

# ============================================================================
# CONFIG
# ============================================================================
INSTALLER_VERSION="1.0.1"
REPO_RAW="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main"
CLI_URL="$REPO_RAW/cli/videosensei.js"
SENSEI_DIR="$HOME/.videosensei"
BIN_NAME="videosensei"

# Detect platform
detect_platform() {
  case "$(uname -s)" in
    Linux*)
      if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
        echo "termux"
      else
        echo "linux"
      fi
      ;;
    Darwin*) echo "macos" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

PLATFORM=$(detect_platform)

# ============================================================================
# COLORS — VideoSensei theme (neon green on near-black)
# ============================================================================
# Use printf %b for portability — works in bash, dash, sh, busybox, termux
if [ -t 1 ]; then
  C_ACCENT='\033[38;2;0;255;136m'      # #00FF88 neon green
  C_ACCENT_BOLD='\033[1;38;2;0;255;136m'
  C_INK='\033[38;2;255;255;255m'       # #FFFFFF
  C_MUTED='\033[38;2;161;161;170m'     # #A1A1AA
  C_WARN='\033[38;2;250;204;21m'       # #FACC15
  C_ERR='\033[38;2;248;113;113m'       # #F87171
  C_CYAN='\033[38;2;34;211;238m'
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
else
  C_ACCENT=''; C_ACCENT_BOLD=''; C_INK=''; C_MUTED=''; C_WARN=''; C_ERR=''; C_CYAN=''; C_RESET=''; C_BOLD=''
fi

# ============================================================================
# PRINT HELPERS (use printf — works everywhere)
# ============================================================================
# Note: %b interprets backslash escapes in the argument, %s does not.

p_line()   { printf '%b\n' "$1"; }
p_plain()  { printf '%s\n'  "$1"; }
p_info()   { printf '  %b●%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_ok()     { printf '  %b✓%b %b\n' "$C_ACCENT" "$C_RESET" "$1"; }
p_warn()   { printf '  %b⚠%b  %b\n' "$C_WARN" "$C_RESET" "$1"; }
p_err()    { printf '  %b✗%b  %b\n' "$C_ERR" "$C_RESET" "$1" >&2; }
p_prompt() { printf '  %b' "$1"; }

die() {
  p_err "$1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

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
  p_info "Platform: ${C_ACCENT}${PLATFORM}${C_RESET}${C_RESET}"
  p_info "Sensei dir: ${C_MUTED}${SENSEI_DIR}${C_RESET}"
  printf '\n'
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================
check_node() {
  if command_exists node; then
    local version major
    version=$(node --version 2>/dev/null | sed 's/v//')
    major=$(echo "$version" | cut -d. -f1)
    if [ "${major:-0}" -ge 16 ] 2>/dev/null; then
      p_ok "Node.js v${version} found"
      return 0
    else
      p_warn "Node.js v${version} found (need >=16)"
      return 1
    fi
  else
    p_warn "Node.js not found"
    return 1
  fi
}

check_ffmpeg() {
  if command_exists ffmpeg && command_exists ffprobe; then
    local version
    version=$(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')
    p_ok "FFmpeg ${version} found"
    return 0
  else
    p_warn "FFmpeg not found"
    return 1
  fi
}

# ============================================================================
# TERMUX-SPECIFIC HELPERS
# ============================================================================
termux_setup_mirror() {
  # If no mirror is selected, try to set a working one automatically.
  # This is a known Termux pain point — we just pick a reliable mirror.
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
  # Try up to 3 times — Termux mirrors can be flaky
  for attempt in 1 2 3; do
    p_info "Installing ${pkg} (attempt ${attempt}/3)..."
    if pkg install -y "$pkg" 2>&1 | tail -5; then
      if command_exists "$pkg" || [ "$pkg" = "nodejs" ] && command_exists node; then
        return 0
      fi
    fi
    p_warn "Attempt ${attempt} failed, trying a different mirror..."
    # Try a different mirror each retry
    case "$attempt" in
      1) echo "deb https://mirrors.cbrx.io/apt/termux/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
      2) echo "deb https://mirror.rinarin.dev/termux/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
      3) echo "deb https://packages-cf.termux.dev/apt/termux-main/ stable main" > "$PREFIX/etc/apt/sources.list" ;;
    esac
    pkg update -y >/dev/null 2>&1 || true
  done
  return 1
}

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================
install_node() {
  p_info "Installing Node.js..."
  case "$PLATFORM" in
    termux)
      termux_setup_mirror
      if ! termux_install_pkg nodejs; then
        printf '\n'
        p_err "Failed to install Node.js via pkg."
        p_info "Manual fix:"
        printf '  %btermux-change-repo%b  (pick a mirror manually)\n' "$C_ACCENT" "$C_RESET"
        printf '  %bpkg install nodejs%b\n' "$C_ACCENT" "$C_RESET"
        printf '  %b# Then re-run this installer%b\n' "$C_MUTED" "$C_RESET"
        return 1
      fi
      ;;
    linux)
      if command_exists apt; then
        if ! curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null; then
          p_warn "nodesource setup failed, trying apt-get install nodejs..."
          sudo apt-get install -y nodejs || return 1
        else
          sudo apt-get install -y nodejs || return 1
        fi
      elif command_exists dnf; then
        sudo dnf install -y nodejs || return 1
      elif command_exists pacman; then
        sudo pacman -S --noconfirm nodejs || return 1
      else
        p_err "Could not detect package manager."
        p_info "Install Node.js manually: https://nodejs.org/"
        return 1
      fi
      ;;
    macos)
      if ! command_exists brew; then
        p_err "Homebrew not found."
        p_info "Install from https://brew.sh or download Node.js from https://nodejs.org/"
        return 1
      fi
      brew install node || return 1
      ;;
    windows)
      if command_exists winget; then
        winget install OpenJS.NodeJS.LTS || return 1
      elif command_exists choco; then
        choco install nodejs -y || return 1
      else
        p_err "Could not install Node.js automatically."
        p_info "Download from https://nodejs.org/"
        return 1
      fi
      ;;
    *)
      p_err "Unknown platform. Install Node.js manually: https://nodejs.org/"
      return 1
      ;;
  esac
  p_ok "Node.js installed"
  return 0
}

install_ffmpeg() {
  p_info "Installing FFmpeg..."
  case "$PLATFORM" in
    termux)
      if ! termux_install_pkg ffmpeg; then
        printf '\n'
        p_err "Failed to install FFmpeg via pkg."
        p_info "Manual fix:"
        printf '  %bpkg install ffmpeg%b\n' "$C_ACCENT" "$C_RESET"
        return 1
      fi
      ;;
    linux)
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
    macos)
      brew install ffmpeg || return 1
      ;;
    windows)
      if command_exists winget; then
        winget install Gyan.FFmpeg || return 1
      elif command_exists choco; then
        choco install ffmpeg -y || return 1
      else
        p_err "Could not install FFmpeg automatically."
        p_info "Download from https://ffmpeg.org/download.html"
        return 1
      fi
      ;;
    *)
      p_err "Unknown platform."
      return 1
      ;;
  esac
  p_ok "FFmpeg installed"
  return 0
}

# ============================================================================
# INSTALL VIDOSENSEI
# ============================================================================
determine_bin_dir() {
  case "$PLATFORM" in
    termux)
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

install_videosensei() {
  local bin_dir
  bin_dir=$(determine_bin_dir)
  mkdir -p "$bin_dir" 2>/dev/null || true
  mkdir -p "$SENSEI_DIR"

  local sudo=""
  if { [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; } && [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
  fi

  local target="$bin_dir/$BIN_NAME"
  local tmp_js="/tmp/videosensei_install_$$.js"
  local tmp_launcher="/tmp/videosensei_launcher_$$"

  p_info "Downloading VideoSensei CLI..."
  if ! curl -fsSL "$CLI_URL" -o "$tmp_js"; then
    p_err "Failed to download from $CLI_URL"
    p_info "Check your internet connection and try again."
    return 1
  fi
  p_ok "Downloaded"

  p_info "Installing to ${C_MUTED}${target}${C_RESET}..."
  local js_target="$SENSEI_DIR/videosensei.js"
  cp "$tmp_js" "$js_target"
  chmod +x "$js_target"

  # Write launcher script
  cat > "$tmp_launcher" << EOF
#!/data/data/com.termux/files/usr/bin/bash
# VideoSensei launcher — auto-generated by installer v${INSTALLER_VERSION}
exec node "$js_target" "\$@"
EOF
  # Fix shebang for non-termux
  if [ "$PLATFORM" != "termux" ]; then
    cat > "$tmp_launcher" << EOF
#!/bin/bash
# VideoSensei launcher — auto-generated by installer v${INSTALLER_VERSION}
exec node "$js_target" "\$@"
EOF
  fi
  chmod +x "$tmp_launcher"

  if [ -n "$sudo" ]; then
    $sudo mv "$tmp_launcher" "$target"
  else
    mv "$tmp_launcher" "$target" 2>/dev/null || cp "$tmp_launcher" "$target"
  fi
  chmod +x "$target"

  rm -f "$tmp_js"

  # Ensure bin_dir is in PATH
  case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *)
      p_warn "${bin_dir} is not in your PATH"
      p_info "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
      printf '  %bexport PATH="%s:$PATH"%b\n' "$C_ACCENT" "$bin_dir" "$C_RESET"
      printf '  %b# Then: source ~/.bashrc%b\n' "$C_MUTED" "$C_RESET"
      ;;
  esac

  p_ok "Installed to $target"
  return 0
}

verify_installation() {
  if command_exists videosensei; then
    local version
    version=$(videosensei --version 2>/dev/null | head -1)
    p_ok "VideoSensei is ready: ${C_ACCENT}${version}${C_RESET}"
    printf '\n'
    printf '  %bQuick start:%b\n' "$C_BOLD" "$C_RESET"
    printf '  %bvideosensei%b                          %b# interactive mode%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b video.mp4                 %b# compress with Balanced preset%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b video.mp4 -p sensei       %b# AV1 master%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '  %bvideosensei%b --help                    %b# full options%b\n' "$C_ACCENT" "$C_RESET" "$C_MUTED" "$C_RESET"
    printf '\n'
    printf '  %bHack the size. Keep the clarity.%b\n' "$C_MUTED" "$C_RESET"
    printf '  %bhttps://jubairsensei.com%b\n' "$C_MUTED" "$C_RESET"
  else
    p_err "Installation verification failed."
    p_info "Try running 'videosensei --version' manually."
    p_info "If not found, your PATH may need updating (see warning above)."
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
    else
      p_info "Kept $SENSEI_DIR"
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
    --uninstall|-u)
      uninstall_videosensei
      exit 0
      ;;
    --version|-v)
      printf 'VideoSensei installer v%s\n' "$INSTALLER_VERSION"
      exit 0
      ;;
    --help|-h)
      printf 'Usage: bash installer.sh [--uninstall|--version|--help]\n'
      exit 0
      ;;
  esac

  # Step 1: Node.js
  if ! check_node; then
    printf '  %bInstall Node.js now? [Y/n] %b' "$C_BOLD" "$C_RESET"
    read -r reply
    if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
      if ! install_node; then
        die "Node.js installation failed."
      fi
    else
      die "Node.js is required. Install manually from https://nodejs.org/"
    fi
  fi

  # Step 2: FFmpeg
  if ! check_ffmpeg; then
    printf '  %bInstall FFmpeg now? [Y/n] %b' "$C_BOLD" "$C_RESET"
    read -r reply
    if [ -z "${reply:-}" ] || [ "${reply}" = "y" ] || [ "${reply}" = "Y" ]; then
      if ! install_ffmpeg; then
        die "FFmpeg installation failed."
      fi
    else
      die "FFmpeg is required. Install manually."
    fi
  fi

  # Step 3: Download + install
  if ! install_videosensei; then
    die "Failed to install VideoSensei."
  fi

  # Step 4: Verify
  printf '\n'
  verify_installation
}

main "$@"
