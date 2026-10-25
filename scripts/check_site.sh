#!/usr/bin/env bash
# Site checks (brief docs/design/redesign-2026-10.md section 10 item 8). Runs locally in Git Bash, foreground.
#
#   bash scripts/check_site.sh [--root DIR] [--tools DIR] [--only a,b,c,d,p]
#
#   a  no Esri/ArcGIS/CARTO/World Imagery in text, file names or PDFs (outside docs/legal, docs/design, scripts)
#   b  lychee: 0 broken internal links (offline) plus check_fragments.py for #anchors; external failures are listed, not fatal
#   c  headless Chrome at 375 px: document.documentElement.scrollWidth <= 375 on every live page
#   d  Lighthouse accessibility >= 95 and axe-core 0 serious/critical on /, /products/forgegis/,
#      /products/seaglass-globe/, /suite/ (skipped with a notice until /suite/ exists)
#   p  the data-provenance gate
#
# Tools live in the uncommitted .tools/ dir (lychee.exe in .tools/lychee, npm packages in .tools/node).
# Exit 0 = every selected check passed, 1 = at least one failed, 2 = setup problem.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$HERE")"
ROOT="$REPO"; TOOLS="$REPO/.tools"; ONLY="a,b,c,d,p"
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2;;
    --tools) TOOLS="$2"; shift 2;;
    --only) ONLY="$2"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
ROOT="$(cd "$ROOT" && pwd)"; TOOLS="$(cd "$TOOLS" && pwd)"
CHROME="${CHROME:-}"
for c in "$CHROME" "/c/Program Files/Google/Chrome/Application/chrome.exe" "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"; do
  [ -n "$c" ] && [ -f "$c" ] && CHROME="$c" && break
done
PAT='esri|arcgis|\bcarto\b|cartodb|cartocdn|world imagery'
TM='trademark|marks of their respective|registered mark'
declare -A RESULT
want() { case ",$ONLY," in *",$1,"*) return 0;; esac; return 1; }
need() { [ -e "$1" ] || { echo "setup problem: missing $1 (see .tools/ in scripts/check_site.sh header)" >&2; exit 2; }; }
section() { echo; echo "=== ($1) $2"; }

# Tracked-or-not file list, as paths relative to ROOT, minus the excluded trees.
files() { (cd "$ROOT" && find . \( -name .git -o -name .tools -o -name node_modules \) -prune -o -type f -print \
  | sed 's|^\./||' | grep -vE '^(docs/legal|docs/design|scripts)/'); }

if want a; then
  section a "Esri / ArcGIS / CARTO / World Imagery (case-insensitive)"
  hits=0
  echo "-- file names"
  while IFS= read -r f; do echo "  NAME  $f"; hits=$((hits+1)); done < <(files | grep -iE "$PAT")
  echo "-- text content"
  while IFS= read -r f; do
    while IFS= read -r line; do echo "  TEXT  $f:$line"; hits=$((hits+1)); done < <(cd "$ROOT" && grep -aniIE "$PAT" -- "$f" | cut -c1-160)
  done < <(files | grep -viE '\.pdf$' | while IFS= read -r f; do (cd "$ROOT" && grep -qaiIE "$PAT" -- "$f") && echo "$f"; done)
  echo "-- PDFs (pdftotext; pure trademark lines are listed, not counted)"
  tmhits=0
  while IFS= read -r f; do
    while IFS= read -r line; do
      n="${line%%:*}"; txt="${line#*:}"
      if echo "$txt" | grep -qiE "$TM"; then echo "  PDF-TM (ignored) $f:$n"; tmhits=$((tmhits+1))
      else echo "  PDF   $f:$n: $(echo "$txt" | grep -aoiE ".{0,60}($PAT).{0,60}" | head -1)"; hits=$((hits+1)); fi
    done < <(cd "$ROOT" && pdftotext "$f" - 2>/dev/null | grep -aniE "$PAT")
  done < <(files | grep -i '\.pdf$')
  echo "(a) hits=$hits (ignored trademark lines=$tmhits)"
  [ "$hits" -eq 0 ] && RESULT[a]=PASS || RESULT[a]="FAIL ($hits hits)"
fi

if want b; then
  section b "lychee link check"
  LY="$TOOLS/lychee/lychee.exe"; need "$LY"
  # --root-dir resolves /root-relative links; directory links resolve to index.html. Anchors are checked
  # separately (check_fragments.py) because lychee cannot resolve a #fragment on a directory link.
  RD="$(cygpath -m "$ROOT")"
  mapfile -t pages < <(cd "$ROOT" && find . \( -name .git -o -name .tools -o -name node_modules \) -prune -o -name '*.html' -print | sed 's|^\./||' | grep -vE '^(docs/legal|docs/design|scripts)/')
  inputs=(); for p in "${pages[@]}"; do inputs+=("$RD/$p"); done
  echo "-- internal (offline, ${#pages[@]} html files)"
  "$LY" --offline --root-dir "$RD" --no-progress --format compact "${inputs[@]}" > "$TOOLS/lychee-internal.txt" 2>&1; rc=$?
  grep -vE '^\s*$' "$TOOLS/lychee-internal.txt" | tail -40
  python -I "$HERE/check_fragments.py" --root "$ROOT"; frc=$?
  [ "$frc" -ne 0 ] && rc=1
  echo "-- external (listed, not fatal)"
  timeout 600 "$LY" --scheme https --scheme http --root-dir "$RD" --no-progress --format compact --max-retries 1 --timeout 20 "${inputs[@]}" > "$TOOLS/lychee-external.txt" 2>&1
  grep -E '\[(ERR|[45][0-9][0-9]|TIMEOUT)' "$TOOLS/lychee-external.txt" | sort -u | head -40 | sed 's/^/  EXT  /'
  grep -E 'Errors|Excluded|Total' "$TOOLS/lychee-external.txt" | sed 's/^/  /'
  [ "$rc" -eq 0 ] && RESULT[b]=PASS || RESULT[b]="FAIL (broken internal links or anchors, see above)"
fi

if want c || want d; then
  need "$TOOLS/node/node_modules/puppeteer-core"; need "$CHROME"
fi
if want c; then
  section c "375 px horizontal overflow"
  node "$HERE/check_site_browser.mjs" --root "$(cygpath -m "$ROOT")" --tools "$(cygpath -m "$TOOLS")" --chrome "$(cygpath -m "$CHROME")" --mode overflow; rc=$?
  [ "$rc" -eq 0 ] && RESULT[c]=PASS || RESULT[c]="FAIL (exit $rc)"
fi
if want d; then
  section d "Lighthouse accessibility >= 95 and axe-core 0 serious/critical"
  node "$HERE/check_site_browser.mjs" --root "$(cygpath -m "$ROOT")" --tools "$(cygpath -m "$TOOLS")" --chrome "$(cygpath -m "$CHROME")" --mode a11y; rc=$?
  [ "$rc" -eq 0 ] && RESULT[d]=PASS || RESULT[d]="FAIL (exit $rc)"
fi

if want p; then
  section p "data-provenance gate"
  python "$HERE/check_data_provenance.py" --root "$ROOT" --manifest "$ROOT/docs/legal/data-manifest.tsv"; rc=$?
  [ "$rc" -eq 0 ] && RESULT[p]=PASS || RESULT[p]="FAIL (exit $rc)"
fi

echo; echo "=== summary"
overall=0
for k in a b c d p; do
  want "$k" || continue
  echo "  $k: ${RESULT[$k]}"
  [ "${RESULT[$k]}" = PASS ] || overall=1
done
exit $overall
