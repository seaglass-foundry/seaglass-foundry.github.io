#!/usr/bin/env bash
# Proves each check in scripts/check_site.sh catches a planted fault. Faults are planted ONLY in scratch
# copies of the committed tree (git archive HEAD), never in the repo.
#
#   bash scripts/check_site_selftest.sh SCRATCH_DIR
#
# SCRATCH_DIR must be outside the repo; a fresh run-<timestamp> directory is created inside it.
# Exit 0 = every plant was caught (and every must-be-ignored plant was ignored).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$HERE")"
BASE="$(cd "${1:?usage: check_site_selftest.sh SCRATCH_DIR}" && pwd)"
case "$BASE/" in "$REPO"/*) echo "SCRATCH_DIR must be outside the repo" >&2; exit 2;; esac
RUN="$BASE/run-$(date +%Y%m%d-%H%M%S)"; mkdir "$RUN" "$RUN/clean"
(cd "$REPO" && git archive HEAD) | tar -x -C "$RUN/clean"
echo "scratch copy: $RUN/clean (from HEAD $(git -C "$REPO" rev-parse --short HEAD))"
fails=0

mkpdf() { # mkpdf FILE TEXT  (single-page uncompressed PDF)
  python -I - "$1" "$2" <<'PY'
import sys
out, text = sys.argv[1], sys.argv[2]
stream = "BT /F1 12 Tf 20 100 Td (%s) Tj ET" % text.replace("(", chr(92) + "(").replace(")", chr(92) + ")")
objs = ["<< /Type /Catalog /Pages 2 0 R >>", "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
  "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 600 200] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>",
  "<< /Length %d >>\nstream\n%s\nendstream" % (len(stream), stream), "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"]
b = b"%PDF-1.4\n"; offs = []
for i, o in enumerate(objs, 1):
    offs.append(len(b)); b += ("%d 0 obj\n%s\nendobj\n" % (i, o)).encode()
x = len(b); b += ("xref\n0 %d\n0000000000 65535 f \n" % (len(objs) + 1)).encode()
for o in offs: b += ("%010d 00000 n \n" % o).encode()
b += ("trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % (len(objs) + 1, x)).encode()
open(out, "wb").write(b)
PY
}

# run NAME CHECK PLANT_FUNCTION EXPECT_REGEX [NOT_EXPECT_REGEX]
run() {
  local name="$1" chk="$2" plant="$3" expect="$4" notexpect="${5:-}"
  cp -r "$RUN/clean" "$RUN/$name"
  "$plant" "$RUN/$name"
  local out; out="$(bash "$HERE/check_site.sh" --root "$RUN/$name" --only "$chk" 2>&1)"; local rc=$?
  local ok=1
  [ "$rc" -ne 0 ] || ok=0
  echo "$out" | grep -qE "$expect" || ok=0
  if [ -n "$notexpect" ] && echo "$out" | grep -qE "$notexpect"; then ok=0; fi
  echo "[$([ $ok = 1 ] && echo CAUGHT || echo MISSED)] $name (check $chk, exit $rc): expect /$expect/${notexpect:+, must not match /$notexpect/}"
  echo "$out" | grep -E "$expect" | head -4 | sed 's/^/        /'
  [ $ok = 1 ] || { fails=$((fails+1)); echo "$out" | tail -20; }
}

plant_a_text()  { echo '<!-- selftest-plant: basemap (c) Esri, World Imagery -->' >> "$1/index.html"; }
plant_a_name()  { : > "$1/assets/selftest-plant-cartocdn.webp"; }
plant_a_pdf()   { mkpdf "$1/products/selftest-plant-real.pdf" "Selftest-plant: basemap tiles by CARTO."; }
plant_a_pdf_tm(){ mkpdf "$1/products/selftest-plant-tm.pdf" "Esri is a trademark of its owner; reference does not imply endorsement."; }
plant_a_excl()  { echo 'selftest-plant Esri ArcGIS' > "$1/docs/legal/selftest-plant.md"; echo 'selftest-plant Esri' > "$1/scripts/selftest-plant.txt"; }
plant_b_link()  { sed -i 's#</body>#<a href="/products/selftest-plant-missing/">x</a></body>#' "$1/index.html"; }
plant_b_anchor(){ sed -i 's#</body>#<a href="/\#selftest-plant-anchor">x</a></body>#' "$1/index.html"; }
plant_c()       { sed -i 's#</body>#<div id="selftest-plant" style="width:900px;height:4px;background:red"></div></body>#' "$1/index.html"; }
plant_d()       { sed -i 's#</body>#<img src="/favicon.ico"><button></button><a href="\#"></a></body>#' "$1/index.html"; }
plant_d_suite() { mkdir "$1/suite"; printf '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Suite</title></head><body><main><h1>Suite</h1><img src="/favicon.ico"></main></body></html>\n' > "$1/suite/index.html"; }
plant_p()       { printf 'x' > "$1/products/forgegis/img/selftest-plant.png"; }

run a-text       a plant_a_text    'TEXT  index\.html'
run a-filename   a plant_a_name    'NAME  assets/selftest-plant-cartocdn\.webp'
run a-pdf        a plant_a_pdf     'PDF   products/selftest-plant-real\.pdf'
# must-be-ignored plants: a pure trademark PDF line is listed but not counted; docs/legal and scripts are excluded.
cp -r "$RUN/clean" "$RUN/a-tm-and-excluded"; plant_a_pdf_tm "$RUN/a-tm-and-excluded"; plant_a_excl "$RUN/a-tm-and-excluded"
base_out="$(bash "$HERE/check_site.sh" --root "$RUN/clean" --only a 2>&1)"
tm_out="$(bash "$HERE/check_site.sh" --root "$RUN/a-tm-and-excluded" --only a 2>&1)"
if echo "$tm_out" | grep -q 'PDF-TM (ignored) products/selftest-plant-tm\.pdf' && ! echo "$tm_out" | grep -q 'selftest-plant\.\(md\|txt\)' \
   && [ "$(echo "$base_out" | grep -o 'hits=[0-9]*')" = "$(echo "$tm_out" | grep -o 'hits=[0-9]*')" ]; then
  echo "[OK] a-tm-and-excluded: trademark-only PDF line listed but not counted; docs/legal and scripts plants ignored ($(echo "$tm_out" | grep -o 'hits=[0-9]*'))"
else echo "[WRONG] a-tm-and-excluded"; fails=$((fails+1)); echo "$tm_out" | tail; fi
run b-link       b plant_b_link    'selftest-plant-missing'
run b-anchor     b plant_b_anchor  'BROKEN-ANCHOR index\.html.*selftest-plant-anchor'
run c-overflow   c plant_c         'FAIL / scrollWidth=900'
run d-a11y       d plant_d         'FAIL / lighthouse-accessibility=[0-9]+.*|axe critical (image-alt|button-name)'
run d-suite      d plant_d_suite   'FAIL /suite/ '
run p-provenance p plant_p         'selftest-plant'

echo; echo "selftest: $([ $fails = 0 ] && echo 'all plants caught' || echo "$fails problem(s)")"
exit $([ $fails = 0 ] && echo 0 || echo 1)
