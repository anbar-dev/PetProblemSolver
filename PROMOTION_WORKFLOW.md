# Promotion Workflow

This file describes the low-effort distribution flow for Cat Problem Solver.

## Current Strategy

For every strong article, create a small promo pack:

- 3 Pinterest-ready vertical PNGs.
- Pinterest bulk upload CSV rows.
- Pinterest title and description copy.
- 20-30 second short video script.
- Fiverr brief for cheap batch editing.
- Reddit angle for manual, non-spam replies.

Pins should link to the article page, not directly to Amazon. The article page contains the Amazon affiliate links and disclosure.

## Folder Structure

```text
promo/
  PINTEREST_LEDGER.csv
  pinterest-upload-next.csv
  pinterest-upload-now.csv
  pinterest-upload-scheduled.csv
  pinterest-bulk-upload.csv
  article-slug/
    pins/
      pin-01.png
      pin-02.png
      pin-03.png
    pinterest-upload-next.csv
    pinterest-bulk-upload.csv
    pinterest-copy.md
    short-video-script.md
    fiverr-brief.md
    reddit-angle.md
```

The static site build copies `promo/` into `docs/promo/`, so images become public after GitHub Pages publishes.

Example:

```text
https://catproblemsolver.com/promo/litter-tracking-everywhere/pins/pin-01.png
```

## Pinterest Bulk Upload

Use a Pinterest business account. It is free unless ads are used.

For controlled uploads, use these files:

```text
promo/pinterest-upload-now.csv
promo/pinterest-upload-scheduled.csv
```

`pinterest-upload-now.csv` contains the first 9 pending pins with an empty `Publish date`, so Pinterest should publish them immediately.

`pinterest-upload-scheduled.csv` contains the next 9 pending pins with dates after the already scheduled batch.

`pinterest-upload-next.csv` is the combined view of both files. Use it only when uploading the full pending batch at once is intentional.

`promo/pinterest-bulk-upload.csv` is the full generated archive. Do not upload it repeatedly, because it includes pins that may already be on Pinterest.

The CSV points to public image URLs on the site. Push the site before uploading the CSV, otherwise Pinterest cannot fetch the media.

Each Pin row needs a unique destination URL. When publishing multiple variants for the same article, use UTM parameters so Pinterest does not reject rows with `Duplicate Pin link`:

```text
?utm_source=pinterest&utm_medium=social&utm_campaign=bulk_promo&utm_content=article-slug-pin-01
```

## Pinterest Ledger

`promo/PINTEREST_LEDGER.csv` is the memory file for Pinterest.

Status values:

- `ready`: generated but not exported yet.
- `exported`: included in `pinterest-upload-next.csv`; waiting for manual upload confirmation.
- `uploaded`: Pinterest accepted the pin.
- `published`: pin is live and no longer only scheduled.
- `error`: Pinterest rejected the row and it needs fixing.
- `hold`: intentionally paused.

When Pinterest accepts an upload, update the corresponding rows from `exported` to `uploaded`. If Pinterest returns errors, keep those rows as `error` or paste the error into chat so Codex can update the ledger.

The generator excludes `uploaded`, `published`, and `hold` rows from `pinterest-upload-next.csv`. It keeps `ready`, `exported`, and `error` rows in the next upload file until they are confirmed or paused.

Recommended boards:

- `Cat Litter Box Fixes`
- `Cat Cleaning Tips`
- `Cat Scratching Solutions`
- `Cat Feeding Stations`
- `Cat Carrier And Vet Tips`
- `Small Home Cat Ideas`
- `Cat Behavior Support`

## Reddit Use

Use manually only where the advice fits the discussion. Do not drop a link first.

Good Reddit angle:

1. Answer the exact problem in plain text.
2. Share a 3-step setup or what-to-skip warning.
3. Mention the article only if links are allowed or the person asks.
4. Disclose that the page contains affiliate links if linking.

## Disclosure

Pinterest descriptions should include a clear disclosure such as `#ad` when the linked page contains affiliate links. The Pin links to the article, and the article includes the Amazon Associate disclosure.

## Build Commands

Generate promo assets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-promo-assets.ps1
```

Rebuild site:

```powershell
npm run build
```

If normal Node is unavailable, Codex can use its bundled Node runtime.
