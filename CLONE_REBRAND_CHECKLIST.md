# Clone Rebrand Checklist

Use this checklist when duplicating this project to create another focused affiliate site from the same static-site engine and article workflow. Promotion assets are archived/on-demand only, not part of routine article creation.

The goal is to preserve the parts that work:

- static source files in `src/`;
- generated output in `docs/`;
- roadmap-driven article creation;
- Amazon affiliate disclosure and product cards;
- Pinterest and Reddit promotion packs;
- simple GitHub Pages publishing.

And replace the parts that are brand- or niche-specific:

- site name, domain, analytics ID, and affiliate tag;
- homepage positioning;
- category structure;
- article formula;
- roadmap and long-tail targets;
- promo boards, pin copy, video hooks, and Reddit angles;
- visual assets and brand assets.

## Before Editing

Read these files first:

```text
README.md
CONTENT_ROADMAP.md
ARTICLE_CREATION_GUIDE.md
PROMOTION_WORKFLOW.md
src/PROBLEM_PAGE_TEMPLATE.txt
scripts/build-site.js
scripts/build-promo-assets.ps1
package.json
```

Also inspect at least two finished article pages under `src/problems/` and one finished promo folder under `promo/`.

Do not edit `docs/` by hand. Edit source files and rebuild.

## Decide The New Site Brief

Write this before changing code:

- Site name.
- Domain.
- One-sentence promise.
- Target reader.
- Main problem categories.
- Product categories that can be monetized with Amazon links.
- Trust angle.
- Topics to avoid.
- Disclosure style.

Good affiliate site positioning should answer:

```text
When a visitor lands on this site, what specific buying mistake are we helping them avoid?
```

## Replace Brand Settings

Update:

- `package.json` name.
- `scripts/build-site.js` site object:
  - `name`
  - `baseUrl`
  - `customDomain`
  - `analyticsId`
  - `affiliateTag`
  - `description`
- `docs/CNAME` indirectly by rebuilding after changing `customDomain`.
- Any visible brand text in `src/pages/`.
- Footer and disclosure wording if the new niche needs safer language.
- `assets/brand/` images and favicon files.
- Main hero image under `assets/images/`.

Search for old-brand terms after changes and remove anything that is no longer relevant.

## Rebuild The Content Model

Update `CONTENT_ROADMAP.md` completely.

The roadmap should include:

- new positioning;
- core promise;
- public categories;
- current published pages;
- priority pages;
- category clusters;
- guides/trust pages;
- content selection rules;
- promotion notes.

Each planned article should include:

- status;
- category;
- page title;
- suggested URL;
- 3-5 long-tail targets;
- rough product types to recommend.

Prefer articles that meet at least four criteria:

- solves a concrete problem;
- has clear buyer intent;
- naturally supports 4-8 Amazon product links;
- has a "what to skip" or "what to avoid" section;
- can be promoted on Reddit without sounding like a listicle ad;
- can become 3 Pinterest pins;
- can internally link to at least 2 related pages.

## Update The Article Guide

Rewrite `ARTICLE_CREATION_GUIDE.md` for the new niche.

Keep the useful mechanics:

- source/output rules;
- metadata requirements;
- product cards;
- no manual Amazon prices, ratings, review counts, Prime status, or availability;
- FAQ and JSON-LD;
- internal links;
- build and verification steps.

Replace niche-specific rules:

- page formula;
- scoring fields;
- safety warnings;
- product selection rules;
- SEO patterns;
- trust differentiators;
- recommended next pages.

For medical, safety, legal, financial, or technical niches, add conservative language rules.

## Update The Static Generator

Edit `scripts/build-site.js`.

Replace:

- `site` object;
- `categories`;
- `guidePlans`;
- nav labels if needed;
- category page copy;
- all index page copy that assumes the prior niche;
- CNAME/domain output.

Decide whether the URL structure should stay as `/problems/category/page/` or become something more natural for the new topic.

If changing the top-level path, update:

- source metadata paths;
- category generation;
- homepage links;
- internal links;
- sitemap expectations;
- article guide examples;
- promo URL generation.

## Update Source Pages

Rewrite:

- `src/pages/index.html`
- `src/pages/about.html`
- `src/pages/contact.html`
- `src/pages/affiliate-disclosure.html`
- `src/pages/privacy.html` if domain/contact details change

Then decide whether to:

- remove old article pages and start fresh;
- keep a few as structural examples but unpublished;
- rewrite existing articles into new-niche articles.

If removing categories, remove or rewrite their source folders.

## Update Templates

Rewrite `src/PROBLEM_PAGE_TEMPLATE.txt`.

The template should match the new site vocabulary.

Useful section patterns:

- "Problem"
- "Best first buy"
- "What to check first"
- "Product shortlist"
- "What to skip"
- "Mistakes to avoid"
- "When not to buy"
- "FAQ"
- "On this page"

## Update Promotion Workflow

Rewrite `PROMOTION_WORKFLOW.md`.

Keep:

- 3 Pinterest pins per strong article;
- unique UTM links per pin;
- `PINTEREST_LEDGER.csv`;
- status values;
- Reddit manual/non-spam guidance;
- no direct Amazon links from pins.

Replace:

- recommended Pinterest boards;
- example URLs;
- disclosure copy;
- Reddit advice style;
- video hooks;
- Fiverr creative direction.

## Update Promo Asset Generator

Edit `scripts/build-promo-assets.ps1`.

Replace:

- `$BaseUrl`;
- visible brand text in `Draw-Pin`;
- call-to-action text;
- logo initials;
- all entries in `$Articles`;
- Pinterest boards;
- keywords;
- video hooks;
- pin titles, subtitles, bullets, and descriptions;
- Fiverr brief style notes.

After the new site has fresh articles, update `$Articles` to match only published or soon-to-publish article slugs.

## Update Promo Files

For a clean new project, reset or regenerate:

```text
promo/PINTEREST_LEDGER.csv
promo/pinterest-upload-next.csv
promo/pinterest-upload-now.csv
promo/pinterest-upload-scheduled.csv
promo/pinterest-bulk-upload.csv
promo/<article-slug>/
```

Do not carry old Pinterest ledger rows into a new site unless intentionally preserving them for the same domain and articles.

## Update Assets And Visual Style

Replace:

- hero image;
- brand favicons;
- social profile image;
- any old-niche images.

Review `assets/style.css` for brand colors and old visual assumptions.

## Build And Verify

Run:

```powershell
npm run build
```

Verify:

```powershell
rg -n "old brand|old domain|previous-affiliate-tag|placeholder-affiliate-tag" .
rg -n "tag=" docs
Get-Content .\docs\sitemap.xml
Get-Content .\docs\robots.txt
```

Check:

- generated homepage exists at `docs/index.html`;
- generated category pages exist;
- sitemap contains the new domain;
- robots.txt points to the new sitemap;
- CNAME contains the new domain;
- Amazon links use the correct tag;
- old category names are gone;
- old promo URLs are gone;
- no links point to unpublished pages unless intentionally linking to hubs.

## Launch Order

Recommended launch sequence:

1. Rebrand site shell and generator.
2. Rewrite roadmap and article guide.
3. Publish 5-10 strong articles.
4. Generate promo packs only if the user explicitly asks for Pinterest/social promo assets.
5. Rebuild and verify.
6. Push to GitHub Pages.
7. Upload first small Pinterest batch.
8. Track uploaded pins in `promo/PINTEREST_LEDGER.csv`.
9. Continue publishing articles from the roadmap.
