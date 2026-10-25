# Data sources and provenance (T1162, STANDARD v2)

Machine record: `data-manifest.tsv` (one row per tracked data file or glob, per external source, per embedded video and per runtime host). Hosts that are only links or JSON-LD identifiers are in `hosts-allowlist.tsv`. Terms were read first-hand on 2026-10-19; each row carries the URL and an exact quote.

## Gate

```
python scripts/check_data_provenance.py --root . --manifest docs/legal/data-manifest.tsv
```

No network. It passes when a manifest row covers every data-like file (the fixed STANDARD v2 extension list, `.json` data, binary files over 100 KB) and every http(s) host in `.html`/`.js`/`.css` (comments, xmlns and `docs/` skipped). It proves accounting, not licensing. Failure was shown on a copy of the tree in the session scratchpad (an injected `.png` and an injected `cdn.example-unlisted.net` script tag); the real tree was never touched.

## What the site contains

- **Fonts:** none. System font stacks only; no Google Fonts, no `@font-face`, no external scripts or CSS.
- **Runtime host:** `www.youtube-nocookie.com` (the click-to-play race excerpt on the homepage, one lazy iframe on the ForgeGIS page).
- **Images:** 62 webp in the tree (screenshots, film posters, social cards), `favicon.ico`. Since T1334 (2026-10-24) only 9 webp are referenced by a page; the rest stay in the tree, unreferenced, for the developer to remove (each manifest row says so).
- **PDFs:** 22 collateral PDFs built from the collateral repo; since T1334 only the ForgeGIS technical brief and the Control Center datasheet are linked.
- **Videos:** six YouTube films, none self-hosted. Since T1334 only the two race films (`p4qm5JPGmIY`, `KzotSSU933g`) are referenced; the three Esri films and the broker film are unlinked.

## Open items (status=open)

| Item | Why open |
|---|---|
| Esri World Imagery (hoover-dam, plume, digital-twin screenshots; 9 Globe screenshots; Globe and release films, their posters) | Esri terms text could not be read (index page only), so use is unverified. **Since T1334 (2026-10-24) nothing on the site embeds, links or credits any of it**: the pages are redirect stubs or were cut, and the files stay in the tree unreferenced until the developer removes them. |
| SRTM DEM | Public-domain posture and the credit line "SRTM data courtesy of the U.S. Geological Survey" are recorded, but the NASA data-use page does not name SRTM. Confirm. |
| Copernicus GLO-30 DEM (race poster and race films) | Only the Sentinel "free, full and open" sentence was readable; DEM terms and commercial use not confirmed. |
| Mapzen Terrain Tiles (Globe terrain) | Upstream mix (SRTM, 3DEP, GEBCO for ocean) only partly covered by the attribution page here; seaglass-globe's `docs/legal/data-sources.md` ("Canonical rows") records all thirteen upstream licences, read first-hand on 2026-10-19, all commercial-OK. Shown again since T1348: it is the relief under `globe-2525.webp` (a US view, so USGS 3DEP, SRTM and GMTED2010, public domain), credited "Terrain: Mapzen Terrain Tiles (AWS Open Data); terrain data courtesy of the U.S. Geological Survey". |
| OpenStreetMap tile screenshots (Studio hero, vector-drop, three vector-at-scale maps) | STANDARD v2 says OSM-derived data is never shipped; a tile screenshot is a Produced Work. Developer decides. |
| CARTO | Standard forbids CARTO services; the Globe footer credits it and the screenshots cannot show where it is used. Not read. |
| Globe screenshots with unidentifiable base maps; Earth render in the two film posters | Origin not recorded; all unreferenced since T1334. `globe-2525.webp` and `globe-replay.webp` are OpenStreetMap ('osm BASE default' in the pixels); `globe-2525.webp` also shows Mapzen Terrarium relief, the Globe's default elevation (T1348). |
| YouTube embedding | Embedded-player requirements read; terms for a commercial site not. |
| Films | The films were not watched by this task; imagery is inferred from posters and page credits. |

No row is `remove`. If T1146 rules against Esri imagery, the affected rows are listed above and in the manifest (grep `T1146`); replacement is the developer's call.
