#!/usr/bin/env python3
"""Internal #anchor check for scripts/check_site.sh (lychee cannot resolve a fragment on a directory link
such as /#globe, so it reports false errors). Every internal href with a #fragment must point at an
existing id= or name= in the target html file. Exit 0 = pass, 1 = broken anchors listed.

  python scripts/check_fragments.py --root .
"""
import argparse, os, re, sys
from urllib.parse import unquote, urlsplit

SKIP_DIRS = {".git", ".tools", "node_modules"}
SKIP_TOP = {"docs", "scripts"}
HREF = re.compile(r"""\bhref\s*=\s*["']([^"']+)["']""", re.I)
ID = re.compile(r"""\b(?:id|name)\s*=\s*["']([^"']+)["']""", re.I)


def pages(root):
    for d, ds, fs in os.walk(root):
        rel = os.path.relpath(d, root)
        ds[:] = [x for x in ds if x not in SKIP_DIRS and not (rel == "." and x in SKIP_TOP)]
        for f in fs:
            if f.endswith(".html"):
                yield os.path.join(d, f)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    root = os.path.abspath(ap.parse_args().root)
    ids, bad, checked = {}, [], 0

    def ids_of(path):
        if path not in ids:
            ids[path] = set(ID.findall(open(path, encoding="utf-8", errors="replace").read()))
        return ids[path]

    for page in pages(root):
        for n, line in enumerate(open(page, encoding="utf-8", errors="replace"), 1):
            for href in HREF.findall(line):
                u = urlsplit(href)
                if u.scheme or u.netloc or not u.fragment or u.fragment == "top":
                    continue
                if not u.path:
                    target = page
                else:
                    p = unquote(u.path)
                    target = os.path.join(root, p.lstrip("/")) if p.startswith("/") else os.path.join(os.path.dirname(page), p)
                    if os.path.isdir(target):
                        target = os.path.join(target, "index.html")
                if not os.path.isfile(target) or not target.endswith(".html"):
                    continue  # missing files are lychee's job
                checked += 1
                if unquote(u.fragment) not in ids_of(target):
                    bad.append("%s:%d -> %s" % (os.path.relpath(page, root).replace(os.sep, "/"), n, href))
    for b in bad:
        print("  BROKEN-ANCHOR " + b)
    print("anchors checked=%d broken=%d" % (checked, len(bad)))
    sys.exit(1 if bad else 0)


main()
