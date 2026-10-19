#!/usr/bin/env python3
"""Data-provenance gate (STANDARD v2). Proves every data-like file and every
scanned http(s) host is ACCOUNTED FOR in the manifest; it does not prove licensing.
No network.

  python scripts/check_data_provenance.py --root . --manifest docs/legal/data-manifest.tsv
  (optional) --allowlist docs/legal/hosts-allowlist.tsv   default: next to the manifest
Exit 0 = pass, 1 = unlisted file/host (listed on stderr), 2 = bad input.
"""
import argparse, csv, fnmatch, os, re, subprocess, sys

EXT = set("""tif tiff hgt dem asc bil dt0 dt1 dt2 img jp2 png jpg jpeg gif webp svg ico shp shx dbf prj cpg gpkg
geojson kml kmz gml csv tsv parquet nc grd bag xyz las laz e57 ply pbf mvt mbtiles pmtiles osm ttf otf woff woff2
sqlite db gz zip tar 7z bin npy npz onnx pt safetensors wav mp3 mp4 mov webm pdf gtx gsb""".split())
SCAN_EXT = {".html", ".htm", ".js", ".mjs", ".css"}
BUILD = {"pom.xml", "package.json", "package-lock.json", "cargo.toml", "cargo.lock"}
HOST_RE = re.compile(r"https?://([A-Za-z0-9.-]+)")
CODE_JSON = {"package.json", "package-lock.json", "tsconfig.json", "composer.json"}


def tracked(root):
    if os.path.isdir(os.path.join(root, ".git")):
        out = subprocess.run(["git", "-C", root, "ls-files", "-z"], capture_output=True, check=True).stdout
        return [p for p in out.decode("utf-8").split("\0") if p]
    res = []
    for d, ds, fs in os.walk(root):
        ds[:] = [x for x in ds if not x.startswith(".")]
        for f in fs:
            res.append(os.path.relpath(os.path.join(d, f), root).replace(os.sep, "/"))
    return res


def is_data(root, rel):
    name = rel.rsplit("/", 1)[-1].lower()
    ext = name.rsplit(".", 1)[-1] if "." in name else ""
    if ext in EXT:
        return True
    if ext == "json":
        return name not in CODE_JSON and not name.startswith(("tsconfig", ".eslintrc"))
    p = os.path.join(root, rel)
    if os.path.getsize(p) > 100 * 1024:
        with open(p, "rb") as f:
            return b"\0" in f.read(8192)
    return False


def strip_comments(text, ext):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    if ext in (".html", ".htm"):
        text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    if ext in (".js", ".mjs"):
        text = re.sub(r"(?m)(^|\s)//.*$", "", text)
    return text


def hosts_in(root, rel):
    ext = os.path.splitext(rel)[1].lower()
    if ext not in SCAN_EXT or rel.startswith("docs/") or rel.lower().endswith(".md"):
        return set()
    if rel.rsplit("/", 1)[-1].lower() in BUILD:
        return set()
    with open(os.path.join(root, rel), encoding="utf-8", errors="replace") as f:
        text = strip_comments(f.read(), ext)
    text = re.sub(r"""xmlns(:\w+)?\s*=\s*["'][^"']*["']""", "", text)
    text = re.sub(r"""xsi:schemaLocation\s*=\s*["'][^"']*["']""", "", text)
    return {h.lower().rstrip(".") for h in HOST_RE.findall(text)}


def read_col(path, col):
    with open(path, encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE))
    if rows and col not in rows[0]:
        sys.exit(f"{path}: missing column {col}")
    return [r[col].strip() for r in rows if r[col].strip()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--allowlist")
    a = ap.parse_args()
    manifest = a.manifest
    allow = a.allowlist or os.path.join(os.path.dirname(os.path.abspath(manifest)), "hosts-allowlist.tsv")
    for p in (manifest, allow):
        if not os.path.isfile(p):
            print(f"missing {p}", file=sys.stderr); return 2
    pats = read_col(manifest, "path_or_host")
    hosts_ok = {p.lower() for p in pats} | {h.lower() for h in read_col(allow, "host")}
    missing_files, missing_hosts = [], {}
    for rel in tracked(a.root):
        if is_data(a.root, rel) and not any(fnmatch.fnmatchcase(rel, p) for p in pats):
            missing_files.append(rel)
        for h in hosts_in(a.root, rel):
            if h not in hosts_ok:
                missing_hosts.setdefault(h, []).append(rel)
    for f in missing_files:
        print(f"UNLISTED FILE: {f}", file=sys.stderr)
    for h, fs in sorted(missing_hosts.items()):
        print(f"UNLISTED HOST: {h} (in {', '.join(sorted(fs)[:3])})", file=sys.stderr)
    if missing_files or missing_hosts:
        return 1
    print(f"OK: every data-like file and scanned host is covered ({len(pats)} manifest rows)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
