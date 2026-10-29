#!/usr/bin/env python3
"""Check a tailored CV PDF for known-wrong claims and required structure.

Usage: check_cv.py <cv.pdf>
Exit:  0 no FAIL · 1 at least one FAIL · 2 usage/tool error

The known-wrong claims mirror profile/skills-inventory.md section 4 (user-confirmed
2026-10-28). When that section changes, update KNOWN_WRONG below.
"""
import re
import subprocess
import sys

# (pattern, why it is wrong) — matched case-insensitively on the PDF text.
KNOWN_WRONG = [
    (r"\bVNPay\b", "VNPay has no evidence; user asked to remove it"),
    (r"BUHINHYO", "FPT project name is BUHINH"),
    (r"dozens of real users", 'Chinese app: write "used by friends"'),
    (r"\b(565|541) pytest", "META-CXR test count is 1,012"),
    (r"\b14 Playwright", "RAG has 9 Playwright E2E tests"),
    (r"CIDEr\s*0\.007", "CIDEr 0.007 -> 0.168 has no source yet"),
    (r"18\s*%\s*to\s*68\s*%", "cue precision 18% -> 68% has no source yet"),
    (r"Mar 2026\s*[–-]\s*Sep 2026|May 2026\s*[–-]\s*Sep 2026|Aug 2026\s*[–-]\s*Oct 2026",
     "FPT internship is May 2026 – Oct 2026"),
    (r"Self-directed research", "META-CXR is the graduation thesis"),
    (r"May 2027", "graduation is Jun 2027"),
    (r"English:\s*Intermediate", 'English is "B2 (CEFR) equivalent"'),
    (r"Productivity Hub|Taskly|Todo App", "user chose not to put Hub/Todo on the CV"),
    (r"[–—]", 'use the plain keyboard hyphen "-", never – or — (LaTeX turns -- / --- into them)'),
]

REQUIRED_SECTIONS = {
    "Technical Skills": r"TECHNICAL SKILLS|KỸ NĂNG",
    "Education": r"EDUCATION|HỌC VẤN",
    "Awards And Certificates": r"AWARDS AND CERTIFICATES|GIẢI THƯỞNG",
    "Languages": r"LANGUAGES|NGOẠI NGỮ|NGÔN NGỮ",
}
FORBIDDEN_SECTIONS = r"^\s*(PROFESSIONAL SUMMARY|SUMMARY|OBJECTIVE|CAREER OBJECTIVE|MỤC TIÊU|TÓM TẮT)\s*$"


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[2], file=sys.stderr)
        return 2
    try:
        text = subprocess.run(
            ["pdftotext", "-layout", sys.argv[1], "-"],
            check=True, capture_output=True, text=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f"cannot read PDF: {exc}", file=sys.stderr)
        return 2

    fails = 0
    # Collapse whitespace so a phrase wrapped across PDF lines still matches.
    flat = re.sub(r"\s+", " ", text)
    for pattern, why in KNOWN_WRONG:
        for m in re.finditer(pattern, flat, re.IGNORECASE):
            context = flat[max(0, m.start() - 30): m.end() + 30].strip()
            print(f"FAIL known-wrong: {m.group(0)!r} — {why}\n     …{context}…")
            fails += 1

    for name, pattern in REQUIRED_SECTIONS.items():
        if not re.search(pattern, text):
            print(f"FAIL missing section: {name}")
            fails += 1

    for m in re.finditer(FORBIDDEN_SECTIONS, text, re.MULTILINE | re.IGNORECASE):
        print(f"FAIL forbidden section: {m.group(1)}")
        fails += 1

    for leftover in (r"\\[a-zA-Z]+\{", r"\?\?"):
        if re.search(leftover, text):
            print(f"WARN possible LaTeX artefact matching {leftover!r}")

    print("PASS" if fails == 0 else f"{fails} FAIL(s)")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
