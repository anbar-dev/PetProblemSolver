# Cat Problem Solver

Static affiliate/editorial site for practical cat problem fixes.

## Structure

- `src/pages/` - standalone page body HTML with metadata.
- `src/problems/` - full problem pages, grouped by category.
- `assets/` - shared CSS, JavaScript, brand images, and hero art.
- `promo/` - archived/on-demand Pinterest/social promo packs. Do not regenerate these during normal article work.
- `scripts/build-site.js` - tiny static generator.
- `docs/` - generated site output for GitHub Pages.
- `CONTENT_ROADMAP.md` - editorial roadmap and long-tail backlog.
- `ARTICLE_CREATION_GUIDE.md` - rules and workflow for creating problem pages.

## Build

Run:

```powershell
npm run build
```

## Article Workflow

Default article work is article-only:

1. Create or update the source HTML page under `src/problems/`.
2. Update `CONTENT_ROADMAP.md`.
3. Run the site build.
4. Commit and push the article plus generated `docs/` output.

Do not generate Pinterest pins, promo CSV files, video briefs, Fiverr briefs, or Reddit-angle files when the user only asks for a new article. This keeps article production lean and avoids spending unnecessary credits/time.

## Promo Assets

Promo generation is archived and on-demand only. Existing files in `promo/` are kept as a reusable archive, but the normal article workflow must not touch them.

Generate promo assets only if the user explicitly asks for Pinterest/social promo materials:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-promo-assets.ps1 -GeneratePromo
```

Upload `promo/pinterest-upload-now.csv` for immediate pins and `promo/pinterest-upload-scheduled.csv` for scheduled pins. `promo/PINTEREST_LEDGER.csv` tracks what has already been exported or uploaded.

Generate brand assets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-brand-assets.ps1
```

If Node is not installed locally, Codex can run the project using its bundled Node runtime.

## Publishing

Configure GitHub Pages to publish from the `main` branch and the `/docs` folder.

Do not edit files in `docs/` by hand. Edit `src/`, `assets/`, `scripts/`, or the markdown operating docs, then rebuild. Edit `promo/` only during an explicit promo task.
