#!/bin/bash
# ============================================================================
# VideoSensei — Quick install entry point (curl | bash one-liner)
# ----------------------------------------------------------------------------
# Downloads and runs installer.sh, attached to the user's TTY so interactive
# prompts (e.g. "Install FFmpeg now? [Y/n]") work even when piped via curl.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
# ============================================================================

set -u

INSTALLER_URL="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/installer/installer.sh"

if ! command -v curl >/dev/null 2>&1; then
  printf '✗ curl is required. Please install it first.\n' >&2
  exit 1
fi

# Pipe installer to bash, but connect stdin to the user's TTY so interactive
# prompts work even under `curl | bash`.
curl -fsSL "$INSTALLER_URL" | bash -s -- "$@" </dev/tty
