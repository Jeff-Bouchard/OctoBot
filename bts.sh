#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure deps (skip if already done)
uv pip install -r requirements.txt >/dev/null
uv pip install -r dev_requirements.txt >/dev/null || true

# 2) Pick a safe, free port (avoid 8000,8080,3000,4000,6660-6669,6006)
for PORT in 5001 5051 5010 5511 5522 5533; do
  if ! ss -lnt "( sport = :$PORT )" | grep -q ":$PORT"; then
    CHOSEN_PORT="$PORT"
    break
  fi
done
if [ -z "${CHOSEN_PORT:-}" ]; then
  echo "No free port found in candidate list." >&2
  exit 1
fi
echo "Using port: $CHOSEN_PORT"

# 3) Start OctoBot (web interface served on the chosen port)
uv run python start.py start --port "$CHOSEN_PORT"

# Access URL
echo "Open: http://localhost:$CHOSEN_PORT"
