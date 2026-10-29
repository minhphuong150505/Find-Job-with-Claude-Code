#!/usr/bin/env bash
# Khởi chạy overleaf-mcp-plus với credential lấy từ .env (gitignored) hoặc biến môi trường.
# Biến đã export trong shell được ưu tiên hơn giá trị trong .env.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$ROOT/.env" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ -z "${!key:-}" ]] && export "$key=$value"
  done < "$ROOT/.env"
fi

export OVERLEAF_TEMP_DIR="${OVERLEAF_TEMP_DIR:-$ROOT/.overleaf_cache}"
exec "$ROOT/.venv-overleaf/bin/overleaf-mcp" "$@"
