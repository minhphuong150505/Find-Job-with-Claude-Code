#!/usr/bin/env bash
# In ra mọi link tin tuyển dụng đã có trong các báo cáo trước (job-reports/*/report.md và JD.md),
# đã chuẩn hoá (bỏ query string, fragment, dấu / cuối, chữ thường) để so trùng khi lập báo cáo ngày mới.
# Dùng: bash scripts/seen_job_links.sh [YYYY-MM-DD]   (bỏ qua thư mục của ngày truyền vào, mặc định: hôm nay)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="${1:-$(date +%F)}"

find "$ROOT/job-reports" -mindepth 2 \( -name report.md -o -name JD.md \) -not -path "*/job-reports/$TODAY/*" -print0 \
  | xargs -0 -r grep -ohE 'https?://[^][ )|<>"`]+' \
  | sed -E 's/[?#].*$//; s#/+$##; s/[.,;:]+$//' \
  | tr '[:upper:]' '[:lower:]' \
  | sort -u
