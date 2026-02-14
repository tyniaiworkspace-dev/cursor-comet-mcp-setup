# Pre-push checklist (project manager)

Before pushing to GitHub, verify:

1. **No secrets or absolute Windows paths** in any tracked file (only `{{CURSOR_DIR}}` in template).
2. **.gitignore** excludes `node_modules/`, `.env`, `space-mapping.json`, and other local/sensitive files.
3. **README** has first-time push and restore instructions.
4. **setup.ps1** is idempotent (safe to run twice).
5. **Required files** present: `mcp.json.template`, `comet-auto-space.js`, `package.json`, `setup.ps1`, `README.md`, `.gitignore` (optional: `.env.example`).
6. **(Optional)** `.env.example` documents optional env vars only; no real secrets.
7. **Smoke test:** Run `.\setup.ps1` once; restart Cursor and confirm MCP servers are listed and respond.
8. **Before push:** Remote is set to your GitHub repo (public); `git status` shows only intended tracked files.

Then: install GitHub MCP (see README), log in with PAT, and push.
