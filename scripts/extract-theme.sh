#!/usr/bin/env bash
# scripts/extract-theme.sh
#
# Re-extracts the VideoSensei theme tokens from jubairsensei.com
# Run this when jubairsensei.com theme changes; commit the diff.
#
# Usage: bash scripts/extract-theme.sh
# Output: scripts/_extracted/
#         - homepage.html (HTML)
#         - theme.css     (compiled CSS)
#         - tokens.txt    (extracted color tokens)
#         - logo.jpg      (brand logo)

set -euo pipefail

OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_extracted"
mkdir -p "$OUT_DIR"

SITE="https://jubairsensei.com"

echo "==> Fetching homepage HTML..."
curl -sL -A "Mozilla/5.0" "$SITE" -o "$OUT_DIR/homepage.html"

echo "==> Discovering CSS file..."
CSS_URL=$(grep -oE '/assets/index-[A-Za-z0-9]+\.css' "$OUT_DIR/homepage.html" | head -1)
if [ -z "$CSS_URL" ]; then
  echo "ERROR: Could not find CSS URL in homepage" >&2
  exit 1
fi
echo "    Found: $CSS_URL"

echo "==> Downloading CSS..."
curl -sL "$SITE$CSS_URL" -o "$OUT_DIR/theme.css"
echo "    Size: $(wc -c < "$OUT_DIR/theme.css") bytes"

echo "==> Extracting color tokens..."
{
  echo "# Dark theme tokens (data-theme=dark)"
  grep -oE '\[data-theme=dark\]\{[^}]+\}' "$OUT_DIR/theme.css" \
    | grep -oE -- '--[a-z-]+:[^;]+' \
    | sort -u
  echo ""
  echo "# Light theme tokens (data-theme=light)"
  grep -oE '\[data-theme=light\]\{[^}]+\}' "$OUT_DIR/theme.css" \
    | grep -oE -- '--[a-z-]+:[^;]+' \
    | sort -u
  echo ""
  echo "# All hex colors used"
  grep -oE '#[0-9a-fA-F]{3,8}' "$OUT_DIR/theme.css" | sort -u
  echo ""
  echo "# All rgb()/rgba() values"
  grep -oE 'rgba?\([^)]+\)' "$OUT_DIR/theme.css" | sort -u
  echo ""
  echo "# Font families"
  grep -oE 'font-family:[^;}]+' "$OUT_DIR/theme.css" | sort -u
  echo ""
  echo "# Keyframe animations"
  grep -oE '@keyframes [a-z-]+' "$OUT_DIR/theme.css" | sort -u
} > "$OUT_DIR/tokens.txt"

echo "==> Downloading logo..."
curl -sL "$SITE/logo.jpg" -o "$OUT_DIR/logo.jpg"
echo "    Size: $(wc -c < "$OUT_DIR/logo.jpg") bytes"

echo ""
echo "==> Done. Output in: $OUT_DIR"
echo "    Review tokens.txt and update THEME.md if anything changed."
