const menuButton = document.querySelector("[data-menu-button]");
const navLinks = document.querySelector("[data-nav-links]");

if (menuButton && navLinks) {
  menuButton.addEventListener("click", () => {
    const isOpen = navLinks.classList.toggle("open");
    menuButton.setAttribute("aria-expanded", String(isOpen));
  });
}

const choices = document.querySelectorAll("[data-choice]");
const resultTitle = document.querySelector("[data-result-title]");
const resultCopy = document.querySelector("[data-result-copy]");
const resultLink = document.querySelector("[data-result-link]");

const finderResults = {
  litter: {
    title: "Start with litter box problems.",
    copy: "Tracking, smell, dust, and box placement usually need a better daily setup before bigger purchases.",
    href: "problems/litter-box/"
  },
  scratching: {
    title: "Go to scratching and furniture.",
    copy: "Most couch and carpet scratching fixes need the right scratcher nearby, then protection for the target surface.",
    href: "problems/scratching/"
  },
  cleaning: {
    title: "Use hair and cleaning fixes.",
    copy: "Hair, odor, vomit, and laundry problems are easier when the cleanup routine is designed around the exact surface.",
    href: "problems/hair-cleaning/"
  },
  feeding: {
    title: "Open feeding and water mess.",
    copy: "Bowl spills, ants, messy wet food, and fast eating all need station design before random bowls.",
    href: "problems/feeding-water/"
  }
};

choices.forEach((choice) => {
  choice.addEventListener("click", () => {
    choices.forEach((item) => item.classList.remove("active"));
    choice.classList.add("active");
    const result = finderResults[choice.dataset.choice];
    if (!result) return;
    resultTitle.textContent = result.title;
    resultCopy.textContent = result.copy;
    resultLink.href = result.href;
  });
});

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

document.querySelectorAll("[data-static-form]").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const message = form.querySelector("[data-form-message]");
    if (message) message.hidden = false;
  });
});
