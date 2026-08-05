# Cat Problem Solver

Static affiliate/editorial site for practical cat problem fixes.

## Structure

- `src/pages/` - standalone page body HTML with metadata.
- `src/problems/` - full problem pages, grouped by category.
- `assets/` - shared CSS, JavaScript, brand images, and hero art.
- `promo/` - generated Pinterest/social promo packs and bulk upload CSV.
- `scripts/build-site.js` - tiny static generator.
- `docs/` - generated site output for GitHub Pages.
- `CONTENT_ROADMAP.md` - editorial roadmap and long-tail backlog.
- `ARTICLE_CREATION_GUIDE.md` - rules and workflow for creating problem pages.

## Build

Run:

```powershell
npm run build
```

Generate promo assets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-promo-assets.ps1
```

Upload `promo/pinterest-upload-now.csv` for immediate pins and `promo/pinterest-upload-scheduled.csv` for scheduled pins. `promo/PINTEREST_LEDGER.csv` tracks what has already been exported or uploaded.

Generate brand assets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-brand-assets.ps1
```

If Node is not installed locally, Codex can run the project using its bundled Node runtime.

## Publishing

Configure GitHub Pages to publish from the `main` branch and the `/docs` folder.

Do not edit files in `docs/` by hand. Edit `src/`, `assets/`, `scripts/`, `promo/`, or the markdown operating docs, then rebuild.
