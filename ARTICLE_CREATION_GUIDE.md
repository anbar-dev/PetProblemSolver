# Article Creation Guide

This is the operating manual for creating new Cat Problem Solver pages.

If the chat history is unavailable, use this guide together with:

- `CONTENT_ROADMAP.md` - what pages to create.
- `src/PROBLEM_PAGE_TEMPLATE.txt` - starter HTML structure.
- `scripts/build-site.js` - site generator.
- `README.md` - project/build overview.

## Project Positioning

Brand:

> Cat Problem Solver

Core promise:

> Solve the cat problem in front of you before buying a pile of random pet products.

Working description:

> Practical fixes for annoying cat problems, with what to buy first and what to skip.

Every page should feel like a practical decision tool for a real cat-owner problem, not a generic pet product roundup.

## Affiliate Settings

Amazon Associates tag:

```text
catprobs-20
```

Use this tag in every Amazon product link. Search links are acceptable for product-type recommendations when a specific ASIN has not been verified:

```html
https://www.amazon.com/s?k=cat+litter+mat&tag=catprobs-20
```

For exact product pages, use a verified current Amazon product URL and direct image URL from the product page. Do not invent ASINs or image URLs.

Do not manually state Amazon prices, ratings, review counts, Prime status, shipping claims, or availability.

## Source And Output

Do not edit `docs/` by hand.

Edit source files:

```text
src/pages/
src/problems/
assets/
scripts/
promo/
CONTENT_ROADMAP.md
ARTICLE_CREATION_GUIDE.md
PROMOTION_WORKFLOW.md
```

Then rebuild:

```powershell
npm run build
```

Generated output goes to:

```text
docs/
```

GitHub Pages publishes:

```text
main branch /docs folder
```

## Page Metadata

Every problem page source must start with metadata:

```html
<!--
title: Page Title | Cat Problem Solver
description: Short SEO description.
path: /problems/category-slug/page-slug/
type: problem
category: category-slug
summary: One-sentence category card summary.
-->
```

Allowed category slugs:

```text
litter-box
scratching
hair-cleaning
feeding-water
travel-carriers
small-home
behavior-support
```

Guides use:

```text
type: guide
path: /guides/page-slug/
```

The builder automatically:

- wraps the body with shared head/header/footer;
- links CSS and JS;
- places the page in the correct category;
- updates category pages;
- updates `sitemap.xml`;
- copies assets and promo files into `docs/`.

## Page Structure

Use this structure for most problem pages:

1. Page hero
2. Scoreboard
3. Disclosure box
4. Quick verdict
5. What to try first
6. Product shortlist
7. Scenario or choosing table
8. What to skip / what to avoid
9. Safety, vet, or behavior notes
10. Internal links
11. FAQ
12. JSON-LD FAQPage
13. Sidebar with "On this page"

The sidebar "On this page" is currently written manually inside each page. It is not generated automatically.

## Scores To Include

Use 4 scoreboard items. Choose the most relevant:

- `Buy priority`: First / Soon / Optional / Wait
- `Mess level`: Low / Medium / High
- `Training effort`: None / Light / Daily / Multi-week
- `Cat tolerance`: Easy / Mixed / Sensitive / Stress-prone
- `Cleanup frequency`: Daily / Weekly / As-needed
- `Best first buy`: short product type

Use the scores to help cat owners decide, not as decoration.

## Product Selection Rules

Prefer products that are:

- useful for a concrete cat problem;
- broadly available on Amazon US;
- easy to explain without relying on prices or review counts;
- simple enough for normal homes;
- compatible with cat welfare and stress reduction;
- not a substitute for veterinary care when symptoms suggest a health issue.

Each product card should include:

- exact product type or verified product title;
- "for..." phrase in the heading;
- why it belongs in the setup;
- when to skip it;
- Amazon button with `tag=catprobs-20`.

Example with a product-type search link:

```html
<div class="product">
  <a class="product-media placeholder" href="https://www.amazon.com/s?k=cat+litter+mat&tag=catprobs-20" rel="sponsored nofollow noopener" target="_blank">
    <span>Litter mat</span>
  </a>
  <div>
    <h3>Large litter mat <span>for tracking at the box exit</span></h3>
    <p>Use it where the cat actually steps out. Skip oversized mats if they block the path and make your cat jump over them.</p>
    <a class="button amazon" href="https://www.amazon.com/s?k=cat+litter+mat&tag=catprobs-20">View on Amazon</a>
  </div>
</div>
```

Use 4-8 products for most problem pages. Fewer is better if the page is narrow.

## SEO Rules

Each page should target 3-5 long-tail phrases from `CONTENT_ROADMAP.md`.

Include them naturally in:

- `title`;
- `description`;
- H1 or intro;
- Quick verdict paragraph;
- FAQ questions;
- internal anchor text where relevant.

Good patterns:

- "cat [problem] everywhere"
- "how to stop cat [behavior]"
- "cat [mess] cleanup setup"
- "cat [product] for cats that hate..."
- "best setup for cat [specific problem]"
- "what to buy first for cat [problem]"

Avoid keyword stuffing. The page should read like useful advice from someone trying to solve the problem, not like a shopping feed.

## Trust Differentiators

Every page should include at least one trust-building section:

- `What to try first`
- `What to skip`
- `When gear is not enough`
- `Vet or behavior notes`
- `Buy this only if...`
- `Skip this if...`

This is central to the site. Do not create pages that only list products.

## Safety And Welfare

Do not make veterinary, medical, behavioral, or safety guarantees. Use careful language:

- "ask your vet";
- "call your vet promptly";
- "do not use punishment";
- "introduce gear gradually";
- "avoid blocking escape routes";
- "stop if your cat panics";
- "not a substitute for veterinary care or a qualified behavior professional."

For sudden litter box avoidance, straining, blood, repeated vomiting, major appetite changes, severe aggression, or distress, the page should say gear is not the first fix.

## FAQ And Structured Data

Most full problem pages should include:

- visible FAQ section;
- matching `FAQPage` JSON-LD.

Keep FAQ answers short, practical, and consistent with page copy.

## Internal Links

Each page should include 2-4 internal links to related categories or pages.

If a related page is not published yet, link to the category.

Example:

```html
<div class="internal-links">
  <a href="../">Litter box category</a>
  <a href="../../hair-cleaning/">Hair and cleaning category</a>
  <a href="../../feeding-water/cat-water-bowl-mess/">Cat water bowl mess fix</a>
</div>
```

## Images

Hero/category imagery:

- Use generated or original images when needed.
- Store project images in `assets/images/`.

Product images:

- Use direct Amazon product images only after verifying them from a current product page.
- Do not download Amazon product images into the repository.
- If exact images are not verified, use text-based product cards with the `.product-media.placeholder` style.

## Research Workflow

Before writing a page:

1. Pick a `next` page from `CONTENT_ROADMAP.md`, or follow the user's requested topic.
2. Search current products only if choosing exact products or ASINs.
3. Prefer product types over fake specificity.
4. Do not rely on stale prices, ratings, review counts, Prime status, or availability.
5. Choose products that fit the cat problem and welfare constraints.

## Build Workflow

After creating a page:

1. Save source file under the right folder, for example:

   ```text
   src/problems/litter-box/litter-tracking-everywhere.html
   ```

2. Update `CONTENT_ROADMAP.md` status from `next` or `planned` to `published`.
3. Rebuild:

   ```powershell
   npm run build
   ```

4. Verify:

   - generated page exists under `docs/`;
   - category page links to it;
   - `docs/sitemap.xml` includes it;
   - Amazon links include `tag=catprobs-20`;
   - no placeholder tag remains;
   - no links point to unpublished pages unless intentionally linking to category hubs.

Useful checks:

```powershell
rg -n "placeholder-affiliate-tag|tag=previous-affiliate-tag" .
rg -n "tag=catprobs-20" docs
Get-Content .\docs\sitemap.xml
```

## Current Published Problem Pages

- `/problems/litter-box/litter-tracking-everywhere/`
- `/problems/litter-box/litter-box-smell-small-home/`
- `/problems/scratching/cat-scratching-couch/`
- `/problems/hair-cleaning/cat-hair-everywhere/`
- `/problems/feeding-water/cat-water-bowl-mess/`
- `/problems/feeding-water/ants-in-cat-food/`
- `/problems/travel-carriers/cat-carrier-hates-carrier/`
- `/problems/behavior-support/cat-wakes-me-up-at-night/`

## Recommended Next Pages

- `/problems/scratching/cat-scratching-carpet-corners/`
- `/problems/hair-cleaning/cat-hair-black-clothes/`
- `/problems/small-home/hide-litter-box-without-smell/`
- `/problems/behavior-support/cat-jumps-on-counters/`

## Promotion Workflow

After publishing a strong page, generate a promo pack:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-promo-assets.ps1
```

Promo packs live in `promo/` and are copied into `docs/promo/` by the static site build.

Pins should link to the article page, not directly to Amazon.

Use unique UTM-tagged article URLs for multiple Pin variants of the same page, otherwise Pinterest may reject extra rows with `Duplicate Pin link`.

Use `promo/PINTEREST_LEDGER.csv` as the durable memory for Pinterest status. After generating promotion assets, prefer `promo/pinterest-upload-now.csv` and `promo/pinterest-upload-scheduled.csv`; use `promo/pinterest-upload-next.csv` only as the combined pending batch.

Live URL pattern:

```text
https://catproblemsolver.com/
```
