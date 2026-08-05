const fs = require("fs");
const path = require("path");

const rootDir = path.resolve(__dirname, "..");
const outDir = path.join(rootDir, "docs");
const sourceDirs = [path.join(rootDir, "src", "pages"), path.join(rootDir, "src", "problems")];
const assetSource = path.join(rootDir, "assets");
const promoSource = path.join(rootDir, "promo");

const site = {
  name: "Cat Problem Solver",
  baseUrl: "https://catproblemsolver.com",
  customDomain: "catproblemsolver.com",
  googleAnalyticsId: "G-8FY92MXS8B",
  affiliateTag: "catprobs-20",
  description: "Practical fixes for annoying cat problems, with what to buy first and what to skip."
};

const categories = [
  {
    slug: "litter-box",
    title: "Cat Litter Problems",
    eyebrow: "Litter box",
    description: "Tracking, smell, dust, scattered litter, box placement, liners, mats, scoops, and small-home litter routines.",
    planned: [
      "Litter box dust control",
      "Litter box in a bedroom",
      "Covered vs open litter boxes",
      "Best setup for multiple cats sharing boxes",
      "Litter stuck in cat paws"
    ]
  },
  {
    slug: "scratching",
    title: "Scratching And Furniture",
    eyebrow: "Scratching",
    description: "Couch scratching, carpet scratching, door-frame scratching, nail care, scratcher placement, and furniture protection.",
    planned: [
      "Cat scratching carpet corners",
      "Cat scratching door frame",
      "Cat ignores scratching post",
      "Cat nail trimming setup",
      "Couch corner protection"
    ]
  },
  {
    slug: "hair-cleaning",
    title: "Cat Hair And Cleaning",
    eyebrow: "Hair and cleaning",
    description: "Cat hair on clothes, furniture, bedding, car seats, laundry, vacuum routines, odor cleanup, and washable surfaces.",
    planned: [
      "Cat hair on black clothes",
      "Cat hair in bed",
      "Cat hair in car seats",
      "Washable rug setup for cat homes",
      "Enzyme cleaner starter guide"
    ]
  },
  {
    slug: "feeding-water",
    title: "Feeding And Water Mess",
    eyebrow: "Food and water",
    description: "Water bowl spills, ants in cat food, messy wet food, fast eating, bowl placement, mats, fountains, and feeding stations.",
    planned: [
      "Wet cat food mess on floors",
      "Cat pushes water bowl around",
      "Cat food ants setup",
      "Slow feeder for cats",
      "Cat fountain cleaning setup"
    ]
  },
  {
    slug: "travel-carriers",
    title: "Travel And Carriers",
    eyebrow: "Travel",
    description: "Carrier avoidance, vet trips, car seat mess, calming travel setup, cleanup supplies, and safe carrier staging.",
    planned: [
      "Cat carrier for cats that hate carriers",
      "Vet trip checklist for anxious cats",
      "Cat pee in carrier cleanup",
      "Car seat cover for cat trips",
      "Carrier training starter setup"
    ]
  },
  {
    slug: "small-home",
    title: "Small Home Cat Setup",
    eyebrow: "Small home",
    description: "Cat trees, window perches, hidden litter zones, vertical territory, washable rugs, toy storage, and tight-room layouts.",
    planned: [
      "Small bedroom cat setup",
      "Cat tree for a narrow room",
      "Hide litter box without trapping smell",
      "Window perch setup",
      "Toy storage for small cat homes"
    ]
  },
  {
    slug: "behavior-support",
    title: "Behavior-Support Gear",
    eyebrow: "Behavior support",
    description: "Problem-solving gear for common cat habits: night waking, boredom, counter surfing, food stealing, hiding, and stress cues.",
    planned: [
      "Cat wakes me up at night",
      "Cat bored while owner works",
      "Cat jumps on counters",
      "Cat eats too fast then vomits",
      "New cat hiding setup"
    ]
  }
];

const guidePlans = [
  "What to buy first for a new cat",
  "When gear will not fix a cat problem",
  "How to pick a litter mat",
  "Cat product mistakes to skip",
  "Small-home cat setup priorities"
];

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function walkFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) return walkFiles(fullPath);
    return entry.isFile() && entry.name.endsWith(".html") ? [fullPath] : [];
  });
}

function parseSource(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  const match = raw.match(/^<!--\s*([\s\S]*?)\s*-->\s*/);
  const meta = {};
  let body = raw;

  if (match) {
    body = raw.slice(match[0].length);
    match[1].split(/\r?\n/).forEach((line) => {
      const pair = line.match(/^\s*([A-Za-z0-9_-]+):\s*(.*?)\s*$/);
      if (pair) meta[pair[1]] = pair[2];
    });
  }

  if (!meta.path || !meta.title || !meta.description) {
    throw new Error(`Missing required metadata in ${filePath}`);
  }

  return { filePath, meta, body };
}

function rootPrefix(urlPath) {
  const clean = urlPath.replace(/^\/|\/$/g, "");
  if (!clean) return "";
  return "../".repeat(clean.split("/").length);
}

function destinationFor(urlPath) {
  const clean = urlPath.replace(/^\/|\/$/g, "");
  return clean ? path.join(outDir, clean, "index.html") : path.join(outDir, "index.html");
}

function canonicalUrl(urlPath) {
  const clean = urlPath === "/" ? "/" : `/${urlPath.replace(/^\/|\/$/g, "")}/`;
  return `${site.baseUrl}${clean === "/" ? "/" : clean}`;
}

function renderHeader(root) {
  return `
  <header class="site-header">
    <nav class="nav" aria-label="Main navigation">
      <a class="brand" href="${root}"><img class="brand-logo" src="${root}assets/brand/favicon-192.png" alt="" width="34" height="34"><span>${site.name}</span></a>
      <button class="menu-button" data-menu-button aria-expanded="false" aria-label="Open menu">=</button>
      <div class="nav-links" data-nav-links>
        <a href="${root}problems/">Problems</a>
        <a href="${root}about/">About</a>
        <a href="${root}contact/">Contact</a>
        <a href="${root}affiliate-disclosure/">Disclosure</a>
      </div>
    </nav>
  </header>`;
}

function renderFooter(root) {
  return `
  <footer class="footer">
    <div class="footer-inner">
      <span>${site.name}</span>
      <span>As an Amazon Associate, this site earns from qualifying purchases.</span>
      <span><a href="${root}contact/">Contact</a> | <a href="${root}privacy/">Privacy</a> | <a href="${root}affiliate-disclosure/">Affiliate disclosure</a></span>
    </div>
  </footer>`;
}

function renderPage({ title, description, urlPath, body }) {
  const root = rootPrefix(urlPath);
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <meta name="description" content="${escapeHtml(description)}">
  <link rel="canonical" href="${canonicalUrl(urlPath)}">
  <link rel="icon" type="image/png" sizes="32x32" href="${root}assets/brand/favicon-32.png">
  <link rel="icon" type="image/png" sizes="192x192" href="${root}assets/brand/favicon-192.png">
  <link rel="apple-touch-icon" sizes="512x512" href="${root}assets/brand/favicon-512.png">
  <link rel="stylesheet" href="${root}assets/style.css">
  <script async src="https://www.googletagmanager.com/gtag/js?id=${site.googleAnalyticsId}"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', '${site.googleAnalyticsId}');
  </script>
</head>
<body>
${renderHeader(root)}
  <main>
${body.trim()}
  </main>
${renderFooter(root)}
  <script src="${root}assets/script.js"></script>
</body>
</html>
`;
}

function categoryCard(category) {
  return `<article class="directory-item">
  <span class="pill">${escapeHtml(category.eyebrow)}</span>
  <div>
    <h3>${escapeHtml(category.title)}</h3>
    <p>${escapeHtml(category.description)}</p>
  </div>
  <a class="link" href="${category.slug}/">Open category</a>
</article>`;
}

function plannedList(items) {
  return items.map((item) => `<li>${escapeHtml(item)}</li>`).join("");
}

function pageDisplayTitle(page) {
  return page.meta.title.replace(` | ${site.name}`, "");
}

function renderProblemCards(pages, currentPath) {
  if (!pages.length) {
    return `<div class="empty-state card">
  <h2>Problem pages coming soon.</h2>
  <p>This category is being shaped around common cat-owner searches. Start with the planned topics below, or browse another category with finished fixes.</p>
</div>`;
  }

  return `<div class="directory-list">
${pages.map((page) => {
    const href = relativeHref(currentPath, page.meta.path);
    return `<article class="directory-item">
  <span class="pill">${escapeHtml(page.meta.category || "Problem")}</span>
  <div>
    <h3>${escapeHtml(pageDisplayTitle(page))}</h3>
    <p>${escapeHtml(page.meta.summary || page.meta.description)}</p>
  </div>
  <a class="link" href="${href}">Open fix</a>
</article>`;
  }).join("\n")}
</div>`;
}

function relativeHref(fromPath, toPath) {
  const fromDir = path.posix.dirname(`/${fromPath.replace(/^\/|\/$/g, "")}/index.html`);
  const toDir = `/${toPath.replace(/^\/|\/$/g, "")}/`;
  let rel = path.posix.relative(fromDir, toDir);
  if (!rel) rel = ".";
  return rel.endsWith("/") ? rel : `${rel}/`;
}

function renderCategoryPage(category, pages) {
  const urlPath = `/problems/${category.slug}/`;
  const published = pages.filter((page) => page.meta.category === category.slug && page.meta.type === "problem");
  const body = `
    <section class="page-hero">
      <div class="page-title">
        <p class="eyebrow">${escapeHtml(category.eyebrow)}</p>
        <h1>${escapeHtml(category.title)}.</h1>
        <p>${escapeHtml(category.description)}</p>
      </div>
    </section>
    <section class="section">
      <div class="split-heading">
        <p class="eyebrow">Available fixes</p>
        <div>
          <h2>Start with the specific cat problem.</h2>
          <p>Each page keeps the buying list focused, explains what to try first, and calls out gear that is easy to overbuy.</p>
        </div>
      </div>
      ${renderProblemCards(published, urlPath)}
    </section>
    <section class="band">
      <div class="section">
        <div class="section-title">
          <div>
            <p class="eyebrow">Coming next</p>
            <h2>More cat problems in this category.</h2>
            <p>These are common search and forum topics that can support practical product recommendations without turning into generic shopping lists.</p>
          </div>
        </div>
        <div class="card roadmap-list"><ul>${plannedList(category.planned)}</ul></div>
      </div>
    </section>`;

  return {
    urlPath,
    html: renderPage({
      title: `${category.title} | ${site.name}`,
      description: category.description,
      urlPath,
      body
    })
  };
}

function renderProblemsIndex() {
  const body = `
    <section class="page-hero">
      <div class="page-title">
        <p class="eyebrow">Content map</p>
        <h1>Cat problem categories.</h1>
        <p>The site is organized around annoying, searchable cat problems: litter tracking, box smell, scratching, hair cleanup, food and water mess, carrier trouble, small-home setup, and behavior-support gear.</p>
      </div>
    </section>
    <section class="section">
      <div class="directory-list">
        ${categories.map(categoryCard).join("\n")}
      </div>
    </section>`;

  return {
    urlPath: "/problems/",
    html: renderPage({
      title: `Cat Problem Categories | ${site.name}`,
      description: "Browse practical cat problem categories for litter box mess, scratching, hair cleanup, feeding stations, carriers, small homes, and behavior-support gear.",
      urlPath: "/problems/",
      body
    })
  };
}

function renderGuidesIndex(pages) {
  const published = pages.filter((page) => page.meta.type === "guide");
  const body = `
    <section class="page-hero">
      <div class="page-title">
        <p class="eyebrow">Guides</p>
        <h1>Buying strategy for cat problems.</h1>
        <p>Comparison pages and buying guides about what to try first, when gear is enough, and when the problem needs a vet or behavior professional.</p>
      </div>
    </section>
    <section class="section">
      ${renderProblemCards(published, "/guides/")}
    </section>
    <section class="band">
      <div class="section">
        <div class="section-title">
          <div>
            <p class="eyebrow">Coming next</p>
            <h2>More buying guides.</h2>
          </div>
        </div>
        <div class="card roadmap-list"><ul>${plannedList(guidePlans)}</ul></div>
      </div>
    </section>`;

  return {
    urlPath: "/guides/",
    html: renderPage({
      title: `Cat Buying Guides | ${site.name}`,
      description: "Cat buying guides about what to buy first, what to skip, and when gear will not fix the problem.",
      urlPath: "/guides/",
      body
    })
  };
}

function renderSitemap(paths) {
  const urls = paths
    .sort()
    .map((urlPath) => `  <url><loc>${canonicalUrl(urlPath)}</loc></url>`)
    .join("\n");

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>
`;
}

function renderRobots() {
  return `User-agent: *
Allow: /

Sitemap: ${site.baseUrl}/sitemap.xml
`;
}

function copyDir(src, dest) {
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else if (entry.isFile()) {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function writeOutput(urlPath, html) {
  const dest = destinationFor(urlPath);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, html, "utf8");
}

function build() {
  const resolvedOut = path.resolve(outDir);
  if (!resolvedOut.startsWith(rootDir + path.sep)) {
    throw new Error(`Refusing to write outside project: ${resolvedOut}`);
  }

  fs.rmSync(outDir, { recursive: true, force: true });
  fs.mkdirSync(outDir, { recursive: true });

  const pages = sourceDirs.flatMap(walkFiles).map(parseSource);
  const outputs = [];

  for (const page of pages) {
    outputs.push({
      urlPath: page.meta.path,
      html: renderPage({
        title: page.meta.title,
        description: page.meta.description,
        urlPath: page.meta.path,
        body: page.body
      })
    });
  }

  outputs.push(renderProblemsIndex());
  if (pages.some((page) => page.meta.type === "guide")) {
    outputs.push(renderGuidesIndex(pages));
  }
  for (const category of categories) outputs.push(renderCategoryPage(category, pages));

  const paths = new Set();
  for (const output of outputs) {
    writeOutput(output.urlPath, output.html);
    paths.add(output.urlPath);
  }

  copyDir(assetSource, path.join(outDir, "assets"));
  copyDir(promoSource, path.join(outDir, "promo"));
  fs.writeFileSync(path.join(outDir, "sitemap.xml"), renderSitemap([...paths]), "utf8");
  fs.writeFileSync(path.join(outDir, "robots.txt"), renderRobots(), "utf8");
  fs.writeFileSync(path.join(outDir, "CNAME"), `${site.customDomain}\n`, "utf8");
  fs.writeFileSync(path.join(outDir, ".nojekyll"), "", "utf8");

  console.log(`Built ${paths.size} pages into ${path.relative(rootDir, outDir)}`);
}

build();
