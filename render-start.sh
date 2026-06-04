#!/usr/bin/env sh
set -eu

CONFIG_PATH="/MoneyPrinterTurbo/config.toml"
SECRET_CONFIG_PATH="/etc/secrets/config.toml"

if [ -f "$SECRET_CONFIG_PATH" ]; then
  cp "$SECRET_CONFIG_PATH" "$CONFIG_PATH"
elif [ ! -f "$CONFIG_PATH" ] && [ -f "/MoneyPrinterTurbo/config.example.toml" ]; then
  cp "/MoneyPrinterTurbo/config.example.toml" "$CONFIG_PATH"
fi

python - <<'PY'
import os
from pathlib import Path

import toml

config_path = Path("/MoneyPrinterTurbo/config.toml")
if config_path.exists():
    cfg = toml.load(config_path)
    app = cfg.setdefault("app", {})
    endpoint = os.getenv("AI_VIDEO_ENDPOINT", "").strip().rstrip("/")
    if endpoint:
        app["endpoint"] = endpoint
    with config_path.open("w", encoding="utf-8") as fp:
        toml.dump(cfg, fp)
PY

exec streamlit run ./webui/Main.py \
  --server.address=0.0.0.0 \
  --server.port="${PORT:-8501}" \
  --server.headless=true \
  --server.enableCORS=true \
  --browser.gatherUsageStats=false
