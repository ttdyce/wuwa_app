# WUWA.app

An unofficial **Wuthering Waves / 鳴潮** fan homepage and Traditional Chinese news
archive, built with Dart and Jaspr static rendering.

The design pairs full-bleed character artwork with charcoal, ivory, muted gold,
and editorial typography. The homepage includes version tracking, searchable
news, category filters, pinned posts, and a star-currency/draw calculator.

## Run locally

Install a stable Dart SDK compatible with the dependencies, then:

```sh
dart pub get
dart run lib/main.dart
python3 -m http.server 8080 --bind 127.0.0.1 --directory build
```

Open <http://127.0.0.1:8080>. The generator renders the homepage, every article,
and `/calc/`, then copies **all** static assets from `web/` into `build/`.
Re-run the generator and refresh the browser after changing Dart, CSS, or JS.
This is a static Jaspr site, not a Flutter application.

## News and version data

```sh
dart run tool/fetch_articles.dart
dart run lib/main.dart
```

News comes from Kuro Games' public Traditional Chinese article feed and is cached
in `data/articles.json`. Unchanged articles are reused. A failed update retains
the previous article **and its metadata** so it will be retried; a new article
with missing content fails the refresh without replacing the cache.

Version dates are extracted from announcements and interpreted in UTC+8,
independently of the build machine's timezone. Unannounced updates are not
assigned speculative dates.

Imported email links are normalized to `mailto:`. Unusable private-drive image
paths in the official source are omitted with a visible notice; valid artwork
and the cached source content are preserved.

The homepage initially shows ten posts, including pinned posts. Search and
category filters cover the entire archive; **載入更多情報** reveals subsequent
results. Without JavaScript, all articles remain available.

The calculator supports `+`, `-`, `*`, `/`, and parentheses without executing
input as JavaScript. Draw totals must be non-negative safe integers. Invalid
input clears the previous result and displays an accessible error. Listed
top-up prices are reference values, not live pricing.

## Checks

The JavaScript checks use Node.js 18+ and its built-in test runner; no npm install
is required.

```sh
dart analyze
dart run tool/check_site.dart
node --test test/site.test.cjs
```

These cover rendering, timezone/year rollover, failed-fetch recovery, pinned
search, combined filtering, pagination, and calculator validation.

## Deployment and artwork

The scheduled GitHub Actions workflow refreshes news twice daily, runs the
checks, regenerates the tracked `build/` output, and deploys it to GitHub Pages.
The same static output can be hosted by other providers.

The favicon matches the header waveform. Its raster variants are generated from
`web/favicon.svg` using Python 3 and Pillow:

```sh
python3 tool/gen_favicons.py
dart run lib/main.dart
```

Existing game artwork is credited to **KURO GAMES**. This is a fan project and is
not affiliated with or endorsed by Kuro Games.
