# R. James Cotton — Website, Publications & Blog

Quarto website hosting technical/research posts (`posts/`), publications (`publications.qmd`), and the archived 2010–2017 *Build and Crash* posts (`archive/`) and **Media Gallery** (`gallery.qmd`).

## Structure

- `posts/` — Technical articles and research writeups (listed on the main **Blog** home page; defaults set in `posts/_metadata.yml`).
- `publications.qmd` + `publications/` — Academic publications list driven by `publications/publications.yml` and rendered via `publications/publications.ejs` with paper figures in `publications/figures/`.
- `archive/` — Migrated *Build and Crash* (2010–2017) posts with preserved images and videos (listed under **Build & Crash Archive**; shared defaults in `archive/_metadata.yml` add an archival notice banner).
- `gallery.qmd` + `gallery/` — **Media Gallery** of hardware builds, flight tests, short clips, and YouTube demos (`gallery/gallery.yml` + `gallery/gallery.ejs`).
- `video-map.yml` — Central mapping from archived video IDs to YouTube URLs. Adding a YouTube URL here automatically upgrades every post referencing that video on render.

## Local Preview

```bash
quarto preview
```

To build the static site into `_site/`:

```bash
quarto render
```

## Deploying to GitHub Pages

1. Push `main` to `peabody124/peabody124.github.io`.
2. In **Settings → Pages**, set **Source** to **GitHub Actions**. Every push to `main` builds and publishes automatically via `.github/workflows/publish.yml`.
