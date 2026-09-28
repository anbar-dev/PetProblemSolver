const menuButton = document.querySelector("[data-menu-button]");
const navLinks = document.querySelector("[data-nav-links]");

if (menuButton && navLinks) {
  menuButton.addEventListener("click", () => {
    const isOpen = navLinks.classList.toggle("open");
    menuButton.setAttribute("aria-expanded", String(isOpen));
    menuButton.setAttribute("aria-label", isOpen ? "Close menu" : "Open menu");
    menuButton.textContent = isOpen ? "×" : "☰";
  });
}

const problemSearch = document.querySelector("[data-problem-search]");
const searchIndex = document.querySelector("#problem-search-index");

if (problemSearch && searchIndex) {
  const input = problemSearch.querySelector("input[type=search]");
  const results = problemSearch.querySelector("[data-problem-search-results]");
  const pages = JSON.parse(searchIndex.textContent);
  const normalize = (value) => value.toLowerCase().normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
  const stopWords = new Set(["a", "and", "cat", "cats", "does", "i", "is", "keeps", "my", "of", "on", "the", "to", "with", "il", "la", "le", "l", "sui", "sul", "un", "una"]);

  const findMatches = (query) => {
    const words = normalize(query).split(" ").filter((word) => word && !stopWords.has(word));
    if (!words.length) return [];
    return pages.map((page) => {
      const title = normalize(page.title);
      const haystack = normalize(`${page.title} ${page.summary} ${page.description} ${page.aliases.join(" ")}`);
      if (!words.every((word) => haystack.includes(word))) return null;
      const score = words.reduce((total, word) => total + (title.includes(word) ? 3 : 1), 0);
      return { page, score };
    }).filter(Boolean).sort((a, b) => b.score - a.score || a.page.title.localeCompare(b.page.title)).slice(0, 6);
  };

  const renderMatches = () => {
    results.replaceChildren();
    const query = input.value.trim();
    if (!query) {
      results.hidden = true;
      return [];
    }
    const matches = findMatches(query);
    if (!matches.length) {
      const message = document.createElement("p");
      message.className = "problem-search-empty";
      message.textContent = "No matching fix yet. Try a shorter phrase or browse the categories below.";
      results.append(message);
    } else {
      matches.forEach(({ page }) => {
        const link = document.createElement("a");
        link.href = page.path.replace(/^\//, "");
        const title = document.createElement("strong");
        title.textContent = page.title;
        const category = document.createElement("small");
        category.textContent = page.category;
        link.append(title, category);
        results.append(link);
      });
    }
    results.hidden = false;
    return matches;
  };

  input.addEventListener("input", renderMatches);
  input.addEventListener("keydown", (event) => {
    if (event.key === "Escape") results.hidden = true;
  });
  problemSearch.addEventListener("submit", (event) => {
    event.preventDefault();
    const matches = findMatches(input.value);
    if (matches.length) window.location.href = matches[0].page.path.replace(/^\//, "");
    else renderMatches();
  });
  document.addEventListener("click", (event) => {
    if (!problemSearch.contains(event.target)) results.hidden = true;
  });
}

document.querySelectorAll('a[href*="amazon.com"]').forEach((link) => {
  link.rel = "sponsored nofollow noopener";
  link.target = "_blank";
});

document.querySelectorAll(".product-media img").forEach((image) => {
  const showFallback = () => {
    if (image.naturalWidth > 2 && image.naturalHeight > 2) return;
    image.classList.add("is-missing");
    const media = image.closest(".product-media");
    if (!media || media.querySelector(".image-fallback")) return;
    const fallback = document.createElement("span");
    fallback.className = "image-fallback";
    fallback.textContent = "Image unavailable";
    media.appendChild(fallback);
  };

  if (image.complete) showFallback();
  image.addEventListener("load", showFallback);
  image.addEventListener("error", showFallback);
});

document.querySelectorAll("[data-topic-form]").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const problem = form.elements.problem?.value.trim();
    const category = form.elements.category?.value.trim();
    const details = form.elements.details?.value.trim();
    const output = form.querySelector("[data-request-output]");
    const message = form.querySelector("[data-form-message]");
    const copyButton = form.querySelector("[data-copy-request]");
    if (!output || !message) return;
    output.value = `Topic: ${problem || "Cat problem"}\nCategory: ${category || "Not specified"}\n\nDetails:\n${details || "No details added yet."}`;
    output.hidden = false;
    message.hidden = false;
    if (copyButton) copyButton.disabled = false;
    output.focus();
  });
});

document.querySelectorAll("[data-copy-request]").forEach((button) => {
  button.addEventListener("click", async () => {
    const form = button.closest("form");
    const output = form?.querySelector("[data-request-output]");
    const message = form?.querySelector("[data-copy-message]");
    if (!output || !message) return;
    try {
      await navigator.clipboard.writeText(output.value);
      message.textContent = "Request copied. Paste it into your email or notes.";
    } catch {
      output.focus();
      output.select();
      message.textContent = "Select the text above and copy it manually.";
    }
    message.hidden = false;
  });
});
