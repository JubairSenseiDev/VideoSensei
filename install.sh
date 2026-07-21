#!/bin/bash
# ============================================================================
# VideoSensei — Quick install entry point (curl | bash one-liner)
# ----------------------------------------------------------------------------
# Downloads and runs installer.sh from the repo. If --yes is passed, the
# installer will auto-confirm any prompts (used by CI + unattended installs).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash -s -- --yes
#   bash install.sh --yes      # local, no network
# ============================================================================

set -u

REPO_RAW="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main"
INSTALLER_URL="${REPO_RAW}/installer/installer.sh"
LOCAL_INSTALLER="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/installer/installer.sh"

if ! command -v curl >/dev/null 2>&1; then
  printf '✗ curl is required. Please install it first.\n' >&2
  exit 1
fi

# Use local installer.sh if available (faster + works offline), else download.
if [ -f "$LOCAL_INSTALLER" ]; then
  # Local installer — only redirect /dev/tty if we're interactive AND /dev/tty exists
  if [ -t 0 ] && [ -e /dev/tty ]; then
    bash "$LOCAL_INSTALLER" "$@" </dev/tty
  else
    bash "$LOCAL_INSTALLER" --yes "$@"
  fi
else
  # Download installer + run. Same TTY logic as above.
  if [ -t 0 ] && [ -e /dev/tty ]; then
    curl -fsSL "$INSTALLER_URL" | bash -s -- "$@" </dev/tty
  else
    curl -fsSL "$INSTALLER_URL" | bash -s -- --yes "$@"
  fi
fi
