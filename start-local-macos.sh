#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

choose_python() {
  for candidate in \
    "$ROOT_DIR/.venv/bin/python" \
    python3.12 \
    python3.11 \
    /opt/homebrew/bin/python3.12 \
    /opt/homebrew/bin/python3.11 \
    /usr/local/bin/python3.12 \
    /usr/local/bin/python3.11; do
    if command -v "$candidate" >/dev/null 2>&1; then
      "$candidate" - <<'PY' >/dev/null 2>&1 && {
import sys
raise SystemExit(0 if (3, 11) <= sys.version_info[:2] <= (3, 12) else 1)
PY
        command -v "$candidate"
        return 0
      }
    fi
  done
  return 1
}

PYTHON_BIN="$(choose_python || true)"

if [[ -z "${PYTHON_BIN}" ]]; then
  if command -v brew >/dev/null 2>&1; then
    echo "Python 3.11/3.12 not found. Installing python@3.12 with Homebrew..."
    brew install python@3.12
    PYTHON_BIN="$(choose_python || true)"
  fi
fi

if [[ -z "${PYTHON_BIN}" ]]; then
  echo "Python 3.11/3.12 is required. Install one of them, then rerun this script." >&2
  exit 1
fi

if [[ ! -d .venv ]]; then
  "$PYTHON_BIN" -m venv .venv
fi

source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

if ! command -v magick >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "ImageMagick not found. Installing imagemagick with Homebrew..."
    brew install imagemagick
  else
    echo "ImageMagick not found. Subtitle rendering may fail until it is installed." >&2
  fi
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "ffmpeg not found. Installing ffmpeg with Homebrew..."
    brew install ffmpeg
  else
    echo "ffmpeg is required but was not found." >&2
    exit 1
  fi
fi

echo "Starting MoneyPrinterTurbo WebUI at http://127.0.0.1:8501"
streamlit run ./webui/Main.py --browser.serverAddress=127.0.0.1 --server.enableCORS=True --browser.gatherUsageStats=False
