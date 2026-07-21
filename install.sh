#!/bin/bash
# ============================================================================
# VideoSensei — Quick install (curl | bash one-liner)
# ============================================================================
# Smallest possible installer entry point. Just downloads and runs installer.sh
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/install.sh | bash
#
# Or with shorter URL (after redirect):
#   curl -fsSL https://jubairsensei.com/vs | bash
# ============================================================================

set -u

INSTALLER_URL="https://raw.githubusercontent.com/JubairSenseiDev/VideoSensei/main/installer/installer.sh"

# Download installer and execute
if ! command -v curl >/dev/null 2>&1; then
  echo "✗ curl is required. Please install it first." >&2
  exit 1
fi

# Fetch + run
curl -fsSL "$INSTALLER_URL" | bash
