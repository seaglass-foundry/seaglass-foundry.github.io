# seaglassfoundry.com: redesign brief

Study only, 2026-10-25. Site repo `C:\Development\eclipse-workspace\seaglass-foundry.github.io` at `fc3dd7b`. Every figure below is already on the site or in `forgegis-validation/docs/findings/bench-canonical-1.2.6-2026-10-04.md` sec. 7 (run `20261004-094534-191f1b44`).

## 1. Diagnosis

The home page has only three content sections (hero, Globe, Get the suite). The busyness is density and register, not section count.

- **The hero is a benchmark report**: eyebrow, headline, two figure cards, two bullets, an amber label, a video, a caption and a 110-word method note. 26 numerals in `index.html:316-355` before the first sentence about a product. The `<title>` is a stat: `index.html:6` "ForgeGIS vs GDAL: 1,191 Checks, 0 Failures".
- **ForgeGIS is never described.** The nav item is "Benchmark" (`index.html:302`); the product tagline is "GPU-Accelerated Geospatial Compute, Benchmarked Against GDAL" (`forgegis/index.html:753`). The flagship is a comparison, not a product.
- **Badges everywhere**: across four live pages 3 `flagship-badge`, 3 `flagship-tag`, 3 `feat-tag`, 2 eyebrows, a `demo-label`, 2 `dl-type`, a `publisher-badge`; four ™ superscripts in the home body alone.
- **Stat strips holding words**: Globe "Orbit → rooftop / f64 all the way down / WGS-84 ellipsoid" (`seaglass-globe/index.html:313-323`); Control Center "One installer / One window / Your model".
- **Equal weight**: footer and JSON-LD list six products flat; the installer page is the longest on the site (9 sections, a 7-row port table, 646 lines). `forgegis/index.html` carries ~400 lines of CSS for sections that no longer exist.

Worst "random / AI-sounding" lines:

| Where | Quote |
|---|---|
| `index.html:331` | "Parity: 1191 checks pass, 0 fail. 884 of them compare ForgeGIS's output with GDAL's or an independent oracle, within a tolerance stated per operation; the rest are consistency or smoke checks." |
| `index.html:347` | "Benchmark of record `20261004-094534-191f1b44`" |
| `index.html:335` | "Performance demonstration · not the benchmark" |
| `forgegis/index.html:824-825` | "pipelines 81× (n=14), resampling 30× (n=51), transforms 30× (n=13), vectorizing 26× (n=44)…" |
| `forgegis/index.html:816` | "294 are consistency checks that do not count as parity evidence, and 13 are smoke checks only" |
| `seaglass-globe/index.html:297` | "A WGS-84 ellipsoid, in double precision, all the way down" |
| `seaglass-globe/index.html:384-385` | "Evaluate the Forge suite — with the Earth in the room … Seaglass Foundry™ reads every email." |
| `control-center/index.html` Security | "Groundwork, not promises … named honestly rather than shipped as a promise" |

## 2. References (fetched 2026-10-25)

- **Linear**: hero is one sentence and one screenshot; the page's only number ("over 40,000 product teams") sits under the logo strip with context; sections follow the product's lifecycle, one visual each.
- **Vercel**: every number has a subject and a sentence ("Zapier serves over 100 million monthly website visits on Vercel"); none in bare tiles.
- **Fly.io**: the one stats block is a plain two-column table, four rows ("Machine boot time / <1 second"), no decoration.
- **Cesium**: leads with the platform, three equal pillars, one CTA at the bottom; restraint worth copying, though it under-explains.
- **Felt**: a GIS peer that puts the product in motion as section two and bounds its few numbers ("up to 10,000 addresses").
- **Mapbox** (counter-example): eight news cards, six equal tiles, nine customer stats; only the nav hierarchy (AI first, Navigation second) is worth noting.

## 3. Information architecture

```
/                           Home: ForgeGIS, proof line, Globe, suite, evaluate
/products/forgegis/         What it is, how it runs, benchmark table, method, race, brief
/products/seaglass-globe/   Film, what it is, spec, symbology, in the suite, credits
/suite/                     Control Center, Studio, ForgeMind, forgedata, forgerelay,
                            compute broker (FRM): one paragraph each + dashboard still
/credits/                   Data, imagery and licence attributions (footer + film credits)
/products/swingtopdf/, /products/worldwind-reforged/   unchanged
```

Merge `products/control-center/` into `/suite/` (leave a 301 stub); its port table, security and shared-workstation cards already live in the datasheet PDF. Existing redirect stubs stay, pointed at `/suite/`. Nav: **ForgeGIS · Seaglass Globe · The suite · Evaluate**; GitHub and Contact move to the footer.

## 4. Home page wireframe

1. **Hero: ForgeGIS.** H1 "GPU geospatial compute for Java." Sub: "ForgeGIS runs terrain, hydrology, visibility, spectral and vector operations on the GPU, from Java or from an AI agent over MCP. Checked against GDAL, and faster." Button "Request an evaluation"; link "How it compares →". Visual: a 20–30 s muted screen capture of a Studio pipeline over Copernicus data, or the cleared `race-excerpt-poster.webp` until it exists. No figure cards.
2. **Proof line** (one band, `--grey-bg`): "15× faster than GDAL, geometric mean across 242 benchmark operations, with 1,191 parity checks and no failures. ForgeGIS 1.2.6 benchmark; method and limits →"
3. **Seaglass Globe.** H2 "From orbit to the rooftops." Sub: "A WGS-84 virtual globe in double precision, with terrain, 3D buildings, geodesy that names its method and MIL-STD-2525C scenarios on a timeline. The suite's optional 3D view." Visual: the 22 s Denver clip, muted autoplay, credit beneath. Link "More about the Globe →".
4. **The suite.** H2 "One installer. One window." Sub: "The Seaglass Control Center installs ForgeGIS, the Globe, ForgeGIS Studio and the ForgeMind agent on one Windows workstation and runs them from the same window." Visual: `cc-05-dashboard.webp`. Link "The Forge suite →".
5. **Evaluate.** H2 "Evaluate the suite." Sub: "Release 1.2.7, Windows x64. Evaluations are by request and run for 90 days from first install." One button (mailto).
6. **Footer**: links, one-line credits → `/credits/`, marks, copyright. Drop the italic slogan.

## 5. Product pages

**ForgeGIS.** (1) Hero: "ForgeGIS" / "GPU geospatial compute for Java, with a native MCP server." One paragraph: the operations catalog in plain words, data stays on the GPU between stages, CPU fallback for every operation, Maven artifacts, no GDAL at run time, no native binaries of its own. CTA + brief link. (2) How it runs: from Java; from an agent over MCP with typed refusals; as `run_dag` pipelines. Visual `03-pipeline-graph.webp`. (3) The benchmark: a four-row table (15× geomean / 6× kernel / 1,191 checks, 0 failures / 239 of 242 faster) and one sentence: "3 of 242 operations were slower, all small rasters." (4) Method: five bullets, run id as a `<code>` link to the brief, rig line; by-category table inside `<details>`. (5) The race: `KzotSSU933g` facade, caption "Not the benchmark: 61 operations run once each, side by side, real time." (6) Brief download; footer.

**Seaglass Globe.** (1) Hero: the 25 s Denver film as a facade; "Seaglass Globe" / "From orbit to the rooftops on one WGS-84 globe." Paragraph: Rust and wgpu, f64 held relative to the camera, terrain and 3D buildings from vector tiles, Karney geodesy named beside each measurement. (2) Spec: two columns (Datum, Geodesy, View, GPU, Data formats) in body type. (3) Symbology and scenarios: `globe-2525.webp`, one paragraph. (4) In the suite: the agent draws answers on the globe; the workflow editor runs ForgeGIS under the map; Windows x64, a real GPU, opt-in, not sold separately. (5) Credits → `/credits/`; CTA; footer.

## 6. Numbers policy and rewrite table

One figure per claim, in a sentence, with scope and source; rounded as the record rounds (15×, 6×); "geometric mean", never "average"; "3 slower" within one screen of the headline; identifiers (run id, GDAL version, GPU) on the ForgeGIS page only; no counts without a validation record; the version once per page.

| Current (where) | Decision |
|---|---|
| 15× geomean, 242 ops, 16×16–8192×8192, RTX 5070 (home 320-322; forgegis 770-801) | **Keep.** Home: "15× faster than GDAL, geometric mean across 242 benchmark operations (ForgeGIS 1.2.6, warm timings)". ForgeGIS adds size range and GPU. |
| 6× kernel, ≥1 ms, 256²–4096² (home 326-327; forgegis 805-810) | **Move** to the ForgeGIS table: "6× on operations of 1 ms or more, GDAL in process". |
| 1191 / 0 / 884 / 294 / 13 (home 331; forgegis 815-817) | **Keep** "1,191 parity checks, 0 failures"; 884 → Method bullet; 294 and 13 **cut** (brief only). |
| 3 of 242 slower, 256² and 1024² cases (home 332; forgegis 800-801) | **Keep** as one sentence on ForgeGIS; home link text says "239 of 242 faster". |
| Run id (home 347; forgegis 790); GDAL 3.12.1/3.11.5, protocol v4, CPU, Java 26 (home 347-348; forgegis 839-847) | **Cut** from home. ForgeGIS Method keeps run id as a code link, GDAL 3.12.1, RTX 5070 Laptop, Windows 11; "protocol v4" becomes "warm runs, median of each block". |
| By category 81×…3.0× with n (forgegis 824-825) | **Keep** only in a collapsed `<details>` table, n shown; else cut. |
| 178× workflow (forgegis 829-832) | **Cut** from pages; brief only. |
| Ops 1–9 of 61, 1:26 (home 338-344) | **Cut** the excerpt; the full race keeps "61 operations". |
| 90-day evaluation (home 389) | **Keep**: "90 days from first install". |
| v1.2.7 badges ×3 | **Keep once**, Evaluate section: "Release 1.2.7, Windows x64". |
| Globe and CC stat strips | **Cut**; the facts move into sentences. 2525C, WGS-84, Karney stay in prose; ports → datasheet. |

## 7. Voice guide

1. Say what it does before how it was measured.
2. One figure per claim, in a sentence, with its scope; the link carries the rest.
3. No internal vocabulary: "benchmark of record", "parity evidence", "protocol v4", "categorical claim", "flagship".
4. No slogans as sentences and no self-praise of honesty ("named honestly", "we read every email").
5. Limits stated plainly after the figure, never in the headline.

| Before | After |
|---|---|
| "Checked against GDAL. And faster." + two figure cards (`index.html:317-329`) | "GPU geospatial compute for Java. 15× faster than GDAL across 242 benchmark operations, with 1,191 parity checks and no failures." |
| "A WGS-84 ellipsoid, in double precision, all the way down" (`globe:297`) | "A WGS-84 globe in double precision, from orbit to the rooftops." |
| "Evaluate the Forge suite — with the Earth in the room … Seaglass Foundry™ reads every email." (`globe:384-385`) | "Evaluate the suite. Release 1.2.7, Windows x64, 90 days from first install." |

## 8. Video and image plan

| Slot | Content |
|---|---|
| Home, Globe section | **22 s Denver clip**, self-hosted MP4 (H.264, 720p–1080p, ≤ 8 MB), `muted autoplay loop playsinline`, `poster`, reduced-motion shows the poster. Credit under it, copied from the film's own strip: "© OpenMapTiles, data © OpenStreetMap contributors (ODbL); terrain Mapzen Terrain Tiles / USGS". |
| Globe page hero | **25 s Denver film** as a click-to-play facade (YouTube nocookie once uploaded, else the MP4 with controls); poster = a mid-descent frame. |
| Home, ForgeGIS hero | **New** 20–30 s muted Studio screen capture over Copernicus data (hillshade, slope, contour), no basemap; until then the cleared `race-excerpt-poster.webp`. |
| ForgeGIS page | Keep the uncut race `KzotSSU933g` (Copernicus credit) and `03-pipeline-graph.webp`. |
| Globe page / Suite page | Keep `globe-2525.webp`; keep `cc-01-welcome`, `cc-05-dashboard`, `cc-06-data-gallery`. |

Drop: every manifest row derived from `source:esri-world-imagery` (`forgegis/img/dt-01/02/03/11–15`, `pl-01/08/09/11`; the nine `seaglass-globe/img/*-b.webp`; `seaglass-globe/img/film-poster.webp`; `control-center/img/film-poster.webp`), the excerpt `p4qm5JPGmIY`, the unlinked films `KoMdibtuXGE`, `5oHm4z3gw5Q`, `4msA76n453A`, `y8wno9jVrh4`, and the orphan `vs-*`, `pl-*`, `dt-*srtm*` stills. Update `docs/legal/data-manifest.tsv`, `data-sources.md`, `sitemap.xml`.

## 9. Visual system: evolve, don't replace

**Inventory.** Palette, identical on every page: `--navy #1a3a5c`, `--navy-dark #0f2640`, `--teal #4a9e8e`, `--teal-dark #3b8273`, `--teal-light #e8f5f1`, `--amber #d8973c`, `--amber-light #fef3e6`, `--amber-dark #9a5c1e`, `--grey-bg #f4f7f9`, `--text #2c3e50`, `--text-light #5a6a7a`, `--border #dce3ea`, `--code-bg #1e293b`; on-navy greys `#c8d6e0 / #a8c4d8 / #8eaec6 / #7790a8` as literals. Type: system sans, SFMono/Consolas mono; ~38 distinct `font-size` values against the design system's 20 `--fs-*` tokens. Radii 4/6/8/10/12/14/20 px and 50%; four shadows; sections 70–80 px, hero 80/90 px, container 1100 px, breakpoints 768/900. Components: nav, subnav with crumb and tag, gradient hero with badge, stats strip, three-up cards, spec table, download card, film facade, lightbox, amber left-border callout, contact strip, footer. Motifs: one teal accent word per heading, uppercase letter-spaced eyebrows, amber for labels and limits, ™ superscripts.

**Keep as is**: palette and hero gradient; nav; film facade and lightbox; container and breakpoints; footer structure; the teal accent word.

**Refine.** *Contrast*: white on `--teal` buttons is 3.2:1, below AA at 15 px; fill buttons with `--teal-dark` (4.5:1), keep `--teal` for large accents and hover; teal text on white only at heading sizes; on-navy greys pass (4.6–6.6:1) and should become tokens (`--on-navy`, `--on-navy-muted`) as the design system has. *Hierarchy*: adopt the design-system type scale (`--fs-display` 3rem … `--fs-micro` .8rem), retire the ad-hoc sizes; three radii (6, 10, 20), two shadows. *Consistency*: one `/assets/site.css` built from `seaglass-foundry-design-system/dist/seaglass.css` tokens; pages keep only page-specific rules. *Dark mode*: a `prefers-color-scheme: dark` variant swapping white/grey/text to the navy family, teal and amber unchanged, so the Globe film sits on dark without a white frame; cheap once tokens are shared.

**Drop as clutter**: stat strips for non-numbers; `flagship-badge`, `flagship-tag`, `feat-tag`, `publisher-badge`, `demo-label`; the subnav bar (a crumb in the hero eyebrow suffices); terminal-prompt styling on the Globe spec; the italic slogan; ™ except first mention per page and the marks line; amber callouts except licence notes.

## 10. Build plan (ordered tasks, site repo)

1. **Shared stylesheet.** `/assets/site.css` from design-system tokens; buttons on `--teal-dark`. Accept: all live pages link it; no inline `<style>` over 60 lines; 390/1280 px diffs sent to the developer.
2. **Asset takedown** per sec. 8; manifest, sources and sitemap updated. Accept: `python scripts/check_data_provenance.py --root . --manifest docs/legal/data-manifest.tsv` passes; `grep -ri "esri\|arcgis\|carto"` over `*.html *.xml *.tsv` returns nothing outside `docs/legal/` history notes.
3. **Globe media.** Hero MP4 ≤ 8 MB + poster; 25 s facade; credits in captions and `/credits/`. Accept: `/` transfers under 3 MB before video; reduced-motion shows the poster; first, last and one frame per second checked for Esri text.
4. **Home page** to secs. 4, 6, 7; `<title>` "Seaglass Foundry: GPU geospatial software". Accept: ≤ 5 sections before the footer; numeric claims limited to 15×, 1,191/0, 1.2.7, 90 days; one button.
5. **ForgeGIS page** to sec. 5; dead CSS removed. Accept: run id once as a code link; "3 of 242 slower" inside the benchmark section; by-category only in `<details>`.
6. **Globe page** to sec. 5. Accept: no stats strip; film credits present; no figure except the version.
7. **Suite and credits pages**; 301 stubs. Accept: every footer links `/credits/`; the datasheet download remains.
8. **Automated checks** in a new `scripts/check_site.sh`: (a) Esri/CARTO grep over text and filenames = 0 outside `docs/legal/`; (b) `lychee` (or `linkchecker`) over the tree, 0 broken internal links, external failures listed; (c) headless Chrome/Playwright at 375 px: `document.documentElement.scrollWidth <= 375` on every page; (d) Lighthouse accessibility ≥ 95 and axe-core 0 serious/critical on `/`, `/products/forgegis/`, `/products/seaglass-globe/`, `/suite/`. Accept: all four green in the run report, commands quoted.
9. **Developer visual review**: before/after of the four pages at 390 and 1280 px plus the hero video playing, one message. Accept: approval recorded before publish.
