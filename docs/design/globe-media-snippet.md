# Globe media snippets (T1456)

Assets live in `products/seaglass-globe/`. Not placed in any page yet; the page tasks drop these in.
Paths below are root-relative. The caption is the credit text agreed in T1460 (the full joerd source block is on `/credits/#terrain`; do not add Mapbox or Maputnik names to promote anything).

Files:
- `video/denver-hero.mp4`: 22 s, 1600x900, H.264, no audio, faststart, ~5.9 MB.
- `video/denver-film.mp4`: 25 s, 1920x1080, H.264, no audio, faststart, ~10.7 MB (under 20 MB).
- `img/denver-hero-poster.webp` (hero frame at 11 s), `img/denver-film-poster.webp` (film frame at 12 s).

## Hero clip (home, Globe section)

```html
<figure class="globe-hero">
  <video class="globe-hero-video" muted autoplay loop playsinline preload="metadata"
         poster="/products/seaglass-globe/img/denver-hero-poster.webp"
         width="1600" height="900" aria-label="Seaglass Globe zooming from the Colorado Front Range down to Denver">
    <source src="/products/seaglass-globe/video/denver-hero.mp4" type="video/mp4">
  </video>
  <figcaption>Map: OpenFreeMap © <a href="https://openmaptiles.org/">OpenMapTiles</a> (openmaptiles.org; design CC BY 4.0), data © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ODbL — openstreetmap.org/copyright. Style: OSM Liberty. Terrain: Mapzen Terrain Tiles via AWS Open Data (registry.opendata.aws/terrain-tiles); sources: <a href="/credits/#terrain">terrain data credits</a></figcaption>
</figure>
<script>
/* Reduced motion: no autoplay, keep the poster. */
(function () {
  var v = document.querySelector('.globe-hero-video');
  if (v && window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    v.removeAttribute('autoplay');
    v.pause();
    v.removeAttribute('loop');
    v.preload = 'none';
  }
})();
</script>
```

Without JS the video still autoplays muted; the script is the reduced-motion switch.

## Film facade (Globe page)

Click-to-play: the poster is a button; the video element is created on click, so nothing but the poster loads first.

```html
<figure class="globe-film">
  <button type="button" class="globe-film-play" aria-label="Play the 25 second Denver film"
          data-src="/products/seaglass-globe/video/denver-film.mp4"
          data-poster="/products/seaglass-globe/img/denver-film-poster.webp">
    <img src="/products/seaglass-globe/img/denver-film-poster.webp" width="1920" height="1080" alt="Seaglass Globe map of the Colorado Front Range mid-descent toward Denver" loading="lazy">
  </button>
  <figcaption>Map: OpenFreeMap © <a href="https://openmaptiles.org/">OpenMapTiles</a> (openmaptiles.org; design CC BY 4.0), data © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ODbL — openstreetmap.org/copyright. Style: OSM Liberty. Terrain: Mapzen Terrain Tiles via AWS Open Data (registry.opendata.aws/terrain-tiles); sources: <a href="/credits/#terrain">terrain data credits</a></figcaption>
</figure>
<script>
document.querySelectorAll('.globe-film-play').forEach(function (b) {
  b.addEventListener('click', function () {
    var v = document.createElement('video');
    v.controls = true; v.autoplay = true; v.playsInline = true;
    v.poster = b.dataset.poster;
    v.src = b.dataset.src;
    v.style.width = '100%';
    b.replaceWith(v);
  });
});
/* TODO(YouTube): once the film is uploaded, replace this facade with
   https://www.youtube-nocookie.com/embed/<VIDEO_ID_GOES_HERE>?autoplay=1 created on click, and add the
   youtube:<id> row to docs/legal/data-manifest.tsv and the host to hosts-allowlist if needed. */
</script>
```
