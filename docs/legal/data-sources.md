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
- **Images:** 39 webp in the tree (screenshots, race poster, social cards), `favicon.ico`. Since T1334 (2026-10-24) only 9 webp are referenced by a page; the rest stay in the tree, unreferenced, for the developer to remove (each manifest row says so). T1455 (2026-10-25) removed the 23 Esri-derived stills and film posters (D490); no remaining webp is Esri-derived.
- **PDFs:** 21 collateral PDFs built from the collateral repo (T1455 removed the Globe technical brief, whose text names Esri World Imagery and CartoDB Voyager as built-in providers); since T1334 only the ForgeGIS technical brief and the Control Center datasheet are linked.
- **Videos:** six YouTube films, none self-hosted. Only the two race films (`p4qm5JPGmIY`, `KzotSSU933g`) are referenced; the other four (`KoMdibtuXGE`, `5oHm4z3gw5Q`, `4msA76n453A`, `y8wno9jVrh4`) are unlinked and marked "unlinked; the developer removes after the new site is live" in the manifest.

## Open items (status=open)

| Item | Why open |
|---|---|
| Esri World Imagery (the Globe and Suite release films `4msA76n453A`, `KoMdibtuXGE`, `5oHm4z3gw5Q`) | Esri terms text could not be read, so use is unverified. **T1455 (2026-10-25) removed every Esri-derived image and the Globe technical brief from the tree**; the site embeds, links or credits none of it. Left: the three YouTube films, which the developer removes after the new site is live. |
| SRTM DEM | Public-domain posture and the credit line "SRTM data courtesy of the U.S. Geological Survey" are recorded, but the NASA data-use page does not name SRTM. Confirm. |
| Copernicus GLO-30 DEM (race poster and race films) | Only the Sentinel "free, full and open" sentence was readable; DEM terms and commercial use not confirmed. |
| Mapzen Terrain Tiles (Globe terrain) | Upstream mix (SRTM, 3DEP, GEBCO for ocean) only partly covered by the attribution page here; seaglass-globe's `docs/legal/data-sources.md` ("Canonical rows") records all thirteen upstream licences, read first-hand on 2026-10-19, all commercial-OK. Shown again since T1348: it is the relief under `globe-2525.webp` (a US view, so USGS 3DEP, SRTM and GMTED2010, public domain), credited "Terrain: Mapzen Terrain Tiles (AWS Open Data); terrain data courtesy of the U.S. Geological Survey". |
| OpenStreetMap tile screenshots (Studio hero, vector-drop, three vector-at-scale maps) | STANDARD v2 says OSM-derived data is never shipped; a tile screenshot is a Produced Work. Developer decides. |
| CARTO | Standard forbids CARTO services; the Globe footer credits it and the screenshots cannot show where it is used. Not read. |
| `globe-2525.webp` and `globe-replay.webp` | The two film posters (Earth render) were removed in T1455. `globe-2525.webp` and `globe-replay.webp` are OpenStreetMap ('osm BASE default' in the pixels); `globe-2525.webp` also shows Mapzen Terrarium relief, the Globe's default elevation (T1348). |
| Denver hero clip and film (`denver-hero.mp4`, `denver-film.mp4`, two posters; T1456) | OpenFreeMap vector base (OpenMapTiles schema, OpenStreetMap data, ODbL) plus Mapzen Terrain Tiles; rendered by the Globe (seaglass-globe `out/_release/zoom-denver`), no Esri imagery. Credit burned into the frames and printed under each: "© OpenMapTiles, data © OpenStreetMap contributors (ODbL); terrain: Mapzen Terrain Tiles (AWS Open Data) / USGS and others". OpenFreeMap and OpenMapTiles terms were not read in this task; the rows stay open. Not yet placed in a page. |
| YouTube embedding | Embedded-player requirements read; terms for a commercial site not. |
| Films | The films were not watched by this task; imagery is inferred from posters and page credits. |

No row is `remove`. If T1146 rules against Esri imagery, the affected rows are listed above and in the manifest (grep `T1146`); replacement is the developer's call.
