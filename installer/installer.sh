#!/bin/bash
# ============================================================================
# VideoSensei — Cross-platform installer
# ============================================================================
# Installs VideoSensei CLI on:
#   • Linux (Debian/Ubuntu/Fedora/Arch)
#   • macOS (Homebrew)
#   • Termux (Android)
#   • Windows (Git Bash / MSYS2 / WSL)
#
# What it does:
#   1. Checks for ffmpeg + ffprobe (installs if missing, where possible)
#   2. Checks for Node.js (installs if missing, where possible)
#   3. Downloads the latest videosensei.js CLI from GitHub
#   4. Installs it to /usr/local/bin (or $PREFIX/bin on Termux)
#   5. Creates config directory ~/.videosensei
#   6. Verifies installation
#
# Usage:
#   bash installer.sh           # install latest
#   bash installer.sh --uninstall
#   bash installer.sh --version
#
# Author: Jubair Sensei <jubairsensei@gmail.com>
# Site:   https://jubairsensei.com
# Repo:   https://github.com/JubairSenseiDev/VideoSensei
# License: MIT
# ============================================================================

set -e

# ============================================================================
# CONFIG
# ============================================================================
INSTALLER_VERSION="1.0.0"
REPO_URL="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/cli/videosensei.js"
PACKAGE_JSON_URL="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/cli/package.json"
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

# ============================================================================
# COLORS — VideoSensei theme (neon green on near-black)
# ============================================================================
if [ -t 1 ]; then
  ACCENT='\033[38;2;0;255;136m'   # #00FF88 neon green
  ACCENT_BOLD='\033[1;38;2;0;255;136m'
  INK='\033[38;2;255;255;255m'    # #FFFFFF
  MUTED='\033[38;2;161;161;170m'  # #A1A1AA
  WARN='\033[38;2;250;204;21m'    # #FACC15
  ERR='\033[38;2;248;113;113m'    # #F87171
  CYAN='\033[38;2;34;211;238m'
  RESET='\033[0m'
  BOLD='\033[1m'
else
  ACCENT=''; ACCENT_BOLD=''; INK=''; MUTED=''; WARN=''; ERR=''; CYAN=''; RESET=''; BOLD=''
fi

PLATFORM=$(detect_platform)

# ============================================================================
# LOGO
# ============================================================================
show_logo() {
  echo -e "${ACCENT}"
  echo "    ╱━━━━━━━╲"
  echo "   ╱  ┃█┃  ╲ ${RESET}${BOLD}VIDEOSENSEI${RESET} ${MUTED}installer v${INSTALLER_VERSION}${RESET}"
  echo "  ╱  ┃█┃  ╲  ${MUTED}Master your video. Sensei-grade clarity.${RESET}"
  echo "  ╲  ┃█┃  ╱  ${MUTED}by Jubair Sensei${RESET}"
  echo "   ╲━━━━━╱   ${MUTED}https://jubairsensei.com${RESET}"
  echo -e "${RESET}"
  echo -e "${MUTED}Platform:${RESET} ${ACCENT}${PLATFORM}${RESET}"
  echo -e "${MUTED}Sensei dir:${RESET} ${SENSEI_DIR}"
  echo ""
}

# ============================================================================
# HELPERS
# ============================================================================
log_info() {
  echo -e "  ${ACCENT}●${RESET} $1"
}

log_success() {
  echo -e "  ${ACCENT}✓${RESET} $1"
}

log_warn() {
  echo -e "  ${WARN}⚠${RESET} $1"
}

log_error() {
  echo -e "  ${ERR}✗${RESET} $1" >&2
}

die() {
  log_error "$1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================
check_node() {
  if command_exists node; then
    local version
    version=$(node --version 2>/dev/null | sed 's/v//')
    local major
    major=$(echo "$version" | cut -d. -f1)
    if [ "$major" -ge 16 ] 2>/dev/null; then
      log_success "Node.js v${version} found"
      return 0
    else
      log_warn "Node.js v${version} found (need >=16)"
      return 1
    fi
  else
    log_warn "Node.js not found"
    return 1
  fi
}

install_node() {
  log_info "Installing Node.js..."
  case "$PLATFORM" in
    termux)
      pkg install -y nodejs
      ;;
    linux)
      if command_exists apt; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y nodejs
      elif command_exists dnf; then
        sudo dnf install -y nodejs
      elif command_exists pacman; then
        sudo pacman -S --noconfirm nodejs
      else
        die "Could not detect package manager. Install Node.js manually: https://nodejs.org/"
      fi
      ;;
    macos)
      if ! command_exists brew; then
        die "Homebrew not found. Install from https://brew.sh or install Node.js manually."
      fi
      brew install node
      ;;
    windows)
      if command_exists choco; then
        choco install nodejs -y
      elif command_exists winget; then
        winget install OpenJS.NodeJS.LTS
      else
        die "Could not install Node.js. Download from https://nodejs.org/"
      fi
      ;;
    *)
      die "Unknown platform. Install Node.js manually: https://nodejs.org/"
      ;;
  esac
  log_success "Node.js installed"
}

check_ffmpeg() {
  if command_exists ffmpeg && command_exists ffprobe; then
    local version
    version=$(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}')
    log_success "FFmpeg ${version} found"
    return 0
  else
    log_warn "FFmpeg not found"
    return 1
  fi
}

install_ffmpeg() {
  log_info "Installing FFmpeg..."
  case "$PLATFORM" in
    termux)
      pkg install -y ffmpeg
      ;;
    linux)
      if command_exists apt; then
        sudo apt-get install -y ffmpeg
      elif command_exists dnf; then
        sudo dnf install -y ffmpeg
      elif command_exists pacman; then
        sudo pacman -S --noconfirm ffmpeg
      else
        die "Could not detect package manager. Install FFmpeg manually."
      fi
      ;;
    macos)
      brew install ffmpeg
      ;;
    windows)
      if command_exists choco; then
        choco install ffmpeg -y
      elif command_exists winget; then
        winget install Gyan.FFmpeg
      else
        die "Could not install FFmpeg. Download from https://ffmpeg.org/"
      fi
      ;;
    *)
      die "Unknown platform. Install FFmpeg manually."
      ;;
  esac
  log_success "FFmpeg installed"
}

# ============================================================================
# INSTALL
# ============================================================================
determine_bin_dir() {
  case "$PLATFORM" in
    termux)
      echo "$PREFIX/bin"
      ;;
    *)
      # Try /usr/local/bin if writable, else $HOME/.local/bin
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

  # If /usr/local/bin not writable and we're not root, use sudo
  local sudo=""
  if [ "$bin_dir" = "/usr/local/bin" ] || [ "$bin_dir" = "/usr/bin" ]; then
    if [ ! -w "$bin_dir" ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
      sudo="sudo"
    fi
  fi

  local target="$bin_dir/$BIN_NAME"

  log_info "Downloading VideoSensei CLI..."
  if ! curl -fsSL "$REPO_URL" -o "/tmp/videosensei_install.js"; then
    die "Failed to download from $REPO_URL"
  fi

  log_info "Installing to ${target}..."
  # Write a wrapper script that runs node on the actual JS file
  local js_target="$SENSEI_DIR/videosensei.js"
  cp "/tmp/videosensei_install.js" "$js_target"
  chmod +x "$js_target"

  # Write launcher
  cat > "/tmp/videosensei_launcher" << EOF
#!/bin/bash
# VideoSensei launcher — auto-generated by installer v${INSTALLER_VERSION}
exec node "$js_target" "\$@"
EOF
  chmod +x "/tmp/videosensei_launcher"
  $sudo mv "/tmp/videosensei_launcher" "$target" 2>/dev/null || cp "/tmp/videosensei_launcher" "$target"
  chmod +x "$target"

  rm -f "/tmp/videosensei_install.js"

  # Ensure bin_dir is in PATH
  case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *)
      log_warn "$bin_dir is not in your PATH"
      echo -e "  ${MUTED}Add this to your shell profile (~/.bashrc or ~/.zshrc):${RESET}"
      echo -e "  ${ACCENT}export PATH=\"$bin_dir:\$PATH\"${RESET}"
      ;;
  esac

  log_success "Installed to $target"
}

verify_installation() {
  if command_exists videosensei; then
    local version
    version=$(videosensei --version 2>/dev/null | head -1)
    log_success "VideoSensei is ready: $version"
    echo ""
    echo -e "  ${BOLD}Quick start:${RESET}"
    echo -e "  ${ACCENT}videosensei${RESET}                          ${MUTED}# interactive mode${RESET}"
    echo -e "  ${ACCENT}videosensei${RESET} video.mp4                 ${MUTED}# compress with Balanced preset${RESET}"
    echo -e "  ${ACCENT}videosensei${RESET} video.mp4 -p sensei       ${MUTED}# AV1 master${RESET}"
    echo -e "  ${ACCENT}videosensei${RESET} --help                    ${MUTED}# full options${RESET}"
    echo ""
    echo -e "  ${MUTED}Hack the size. Keep the clarity.${RESET}"
    echo -e "  ${MUTED}https://jubairsensei.com${RESET}"
  else
    die "Installation verification failed. Try running 'videosensei --version' manually."
  fi
}

# ============================================================================
# UNINSTALL
# ============================================================================
uninstall_videosensei() {
  local bin_dir
  bin_dir=$(determine_bin_dir)
  local target="$bin_dir/$BIN_NAME"

  log_info "Removing VideoSensei..."
  if [ -f "$target" ]; then
    if [ -w "$bin_dir" ] 2>/dev/null; then
      rm -f "$target"
    else
      sudo rm -f "$target"
    fi
    log_success "Removed $target"
  else
    log_warn "$target not found"
  fi

  if [ -d "$SENSEI_DIR" ]; then
    read -p "  Also remove config + history at $SENSEI_DIR? [y/N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$SENSEI_DIR"
      log_success "Removed $SENSEI_DIR"
    else
      log_info "Kept $SENSEI_DIR"
    fi
  fi

  echo ""
  log_success "VideoSensei uninstalled"
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
      echo "VideoSensei installer v${INSTALLER_VERSION}"
      exit 0
      ;;
    --help|-h)
      echo "Usage: bash installer.sh [--uninstall|--version|--help]"
      exit 0
      ;;
  esac

  # Step 1: Node.js
  if ! check_node; then
    read -p "  Install Node.js now? [Y/n] " -r
    if [[ ! $REPLY || $REPLY =~ ^[Yy]$ ]]; then
      install_node
    else
      die "Node.js is required. Install manually from https://nodejs.org/"
    fi
  fi

  # Step 2: FFmpeg
  if ! check_ffmpeg; then
    read -p "  Install FFmpeg now? [Y/n] " -r
    if [[ ! $REPLY || $REPLY =~ ^[Yy]$ ]]; then
      install_ffmpeg
    else
      die "FFmpeg is required. Install manually."
    fi
  fi

  # Step 3: Download + install
  install_videosensei

  # Step 4: Verify
  echo ""
  verify_installation
}

main "$@"
