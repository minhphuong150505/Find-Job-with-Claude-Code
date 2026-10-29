#!/usr/bin/env bash
# Build a tailored CV with XeLaTeX, verify it is exactly 1 A4 page, then copy it
# to its final location and clean build artefacts from the source folder.
#
# Usage: build_cv.sh <source_dir> <main.tex> <final_pdf_path>
# Exit:  0 ok · 1 usage/missing tool · 2 compile failed · 3 not exactly 1 A4 page
set -uo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <source_dir> <main.tex> <final_pdf_path>" >&2
  exit 1
fi
SRC="$1"; MAIN="$2"; DEST="$3"
for tool in xelatex pdfinfo pdftotext; do
  command -v "$tool" >/dev/null || { echo "missing tool: $tool" >&2; exit 1; }
done
[[ -f "$SRC/$MAIN" ]] || { echo "not found: $SRC/$MAIN" >&2; exit 1; }

cd "$SRC" || exit 1
JOB="${MAIN%.tex}"
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT

# Two passes so hyperref/refs settle; build into a temp dir to keep the source clean.
for pass in 1 2; do
  if ! xelatex -interaction=nonstopmode -halt-on-error -output-directory="$BUILD" "$MAIN" >/dev/null 2>&1; then
    echo "COMPILE FAILED (pass $pass). First errors:" >&2
    grep -A3 '^!' "$BUILD/$JOB.log" | head -20 >&2
    exit 2
  fi
done

PDF="$BUILD/$JOB.pdf"
PAGES=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
SIZE=$(pdfinfo "$PDF" | awk -F': *' '/^Page size:/{print $2}')
OVERFULL=$(grep -c 'Overfull \\hbox' "$BUILD/$JOB.log" || true)
MISSING=$(grep -c 'Missing character' "$BUILD/$JOB.log" || true)

echo "pages=$PAGES size=\"$SIZE\" overfull_hbox=$OVERFULL missing_chars=$MISSING"

if [[ "$SIZE" != *"(A4)"* ]]; then
  echo "NOT A4 — keep \\documentclass[...,a4paper]" >&2
  exit 3
fi
if [[ "$PAGES" != "1" ]]; then
  echo "NOT 1 PAGE ($PAGES pages) — nothing copied" >&2
  pdftotext -layout -f 2 "$PDF" - | head -15 | sed 's/^/  overflow> /' >&2
  exit 3
fi

mkdir -p "$(dirname "$DEST")"
cp "$PDF" "$DEST"
pdftotext -layout "$DEST" "$BUILD/text.txt"
echo "OK -> $DEST"
echo "---- extracted text ----"
cat "$BUILD/text.txt"

# Leave only sources behind: no PDFs or LaTeX artefacts in the source folder.
rm -f ./*.aux ./*.log ./*.out ./*.fls ./*.fdb_latexmk ./*.xdv ./*.synctex.gz ./*.pdf
exit 0
