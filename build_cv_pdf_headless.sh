#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE_STR="$(date +%Y-%m-%d)"
OUT_FILE="${ROOT_DIR}/AntonioCosmaCV-${DATE_STR}.pdf"
HTML_FILE="${ROOT_DIR}/_site/index.html"

# Build the site (no server)
if command -v jekyll >/dev/null 2>&1; then
  jekyll build
else
  # fallback if jekyll not on PATH
  if command -v bundle >/dev/null 2>&1; then
    bundle exec jekyll build
  else
    echo "Error: jekyll is not installed or not on PATH." >&2
    exit 1
  fi
fi

if [[ ! -f "${HTML_FILE}" ]]; then
  echo "Error: ${HTML_FILE} not found after build." >&2
  exit 1
fi

# Prefer Puppeteer if Node is available.
NODE_BIN=""
if command -v node >/dev/null 2>&1; then
  NODE_BIN="node"
elif [[ -x "/opt/local/bin/node" ]]; then
  NODE_BIN="/opt/local/bin/node"
fi

if [[ -n "${NODE_BIN}" ]]; then
  "${NODE_BIN}" "${ROOT_DIR}/scripts/print_pdf.js" "${HTML_FILE}" "${OUT_FILE}"
  echo "PDF generated: ${OUT_FILE}"
  exit 0
fi

# Fallback to Chrome/Brave headless flags.
CHROME_BIN=""
if [[ "${BROWSER:-chrome}" == "brave" ]]; then
  if [[ -x "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ]]; then
    CHROME_BIN="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
  else
    echo "Error: Brave not found in /Applications." >&2
    exit 1
  fi
else
  if [[ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
    CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  else
    echo "Error: Google Chrome not found in /Applications." >&2
    exit 1
  fi
fi

"${CHROME_BIN}" \
  --headless=new \
  --disable-gpu \
  --print-to-pdf-no-header \
  --print-to-pdf="${OUT_FILE}" \
  "file://${HTML_FILE}"

echo "PDF generated: ${OUT_FILE}"
