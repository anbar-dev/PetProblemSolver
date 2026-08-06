# Promo Archive

This folder contains archived/on-demand Pinterest and social promo assets.

Do not update or regenerate this folder during normal article creation. When the user asks for a new article, create only the article source HTML, update the roadmap, rebuild `docs/`, commit, and push.

Generate promo assets only when the user explicitly asks for Pinterest/social promo materials:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build-promo-assets.ps1 -GeneratePromo
```

Running the script without `-GeneratePromo` is intentionally a no-op.