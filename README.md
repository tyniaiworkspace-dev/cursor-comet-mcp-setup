# Cursor MCP Setup (Comet + poe2-optimizer)

Backup repo for Cursor IDE MCP configuration. After a fresh install, clone this repo and run the setup script to restore your Comet (Perplexity) and poe2-optimizer MCP servers.

## First-time: push to GitHub

1. Create a **public** repo on GitHub (e.g. `cursor-comet-mcp-setup`).
2. Push this folder (include `mcp.json.template`, `setup.ps1`, `comet-auto-space.js`, `package.json`, `README.md`, `.gitignore`, `docs/POE2_MCP_KNOWN_ISSUES.md`; do not push `node_modules` or `.env`).
3. On any new machine: clone → run `.\setup.ps1` → restart Cursor.

## What this restores

- **Comet** – Launched via `comet-auto-space.js` (auto Space creation + `npx comet-mcp`).
- **poe2-optimizer** – Launched via `poe2-mcp` (must be installed separately).

## Prerequisites

- **Node.js** (with `npm` and `npx` on PATH).
- **Optional:** `pip install poe2-mcp` if you use the PoE2 Build Optimizer server.

### PoE2 MCP: known issues (future installs)

After `pip install poe2-mcp`, you may see startup or list-tool errors. This repo includes a guide so you can fix them on any future install:

- **[docs/POE2_MCP_KNOWN_ISSUES.md](docs/POE2_MCP_KNOWN_ISSUES.md)** – Describes the async `main` fix and the limit/offset (int+str) fix, and where to apply them in the installed package. Check this when you install the PoE2 MCP on a new machine.

## Restore (fresh install)

1. **Clone this repo** (e.g. to `~\cursor-comet-mcp-setup` or anywhere you like):
   ```powershell
   git clone https://github.com/YOUR_USERNAME/cursor-comet-mcp-setup.git
   cd cursor-comet-mcp-setup
   ```

2. **Run the setup script** (run from the repo root):
   ```powershell
   .\setup.ps1
   ```
   If you get an execution policy error:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   .\setup.ps1
   ```

3. **Restart Cursor** (or Reload Window) so it loads the new `mcp.json` from `%USERPROFILE%\.cursor\`.

That’s it. Comet will run via the wrapper; poe2-optimizer will work if `poe2-mcp` is on your PATH.

## What the setup does

- Creates `%USERPROFILE%\.cursor` if missing.
- Copies `comet-auto-space.js` and `package.json` there and runs `npm install` (for `chrome-remote-interface`).
- Writes `%USERPROFILE%\.cursor\mcp.json` from `mcp.json.template`, using your actual home path.

## Secrets

- No API keys or tokens are stored in this repo.
- Comet uses the browser (and optional Space URL) only; poe2-optimizer may use its own env/config (e.g. trade auth) – configure those separately after restore.

## Pushing updates

After changing your live config (e.g. editing `mcp.json` or `comet-auto-space.js` in `%USERPROFILE%\.cursor`), copy the changes back into this repo and push:

- Update `mcp.json.template` if you add/remove MCP servers (keep `{{CURSOR_DIR}}` for the comet script path).
- Update `comet-auto-space.js` and/or `package.json` to match.

Then commit and push so the GitHub repo stays in sync with your desired setup.

---

## Using GitHub MCP to create repo and push (optional)

If you want to use the GitHub MCP server to create the repo (and later manage issues/PRs from Cursor): the MCP can create the repo via the GitHub API; the first-time push (git init, add, commit, remote add, push) is still done in a terminal.

### 1. Install GitHub MCP in Cursor

Add the GitHub MCP server to your Cursor config. Edit `%USERPROFILE%\.cursor\mcp.json` and add a `"github"` entry (merge with existing `mcpServers`):

```json
{
  "mcpServers": {
    "comet": { ... },
    "poe2-optimizer": { ... },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE"
      }
    }
  }
}
```

Replace `YOUR_GITHUB_PAT_HERE` with a [GitHub Personal Access Token](https://github.com/settings/tokens) that has at least **repo** scope (so you can create the repo and push).

Restart Cursor (or Reload Window) so the GitHub MCP loads.

### 2. Create the repo on GitHub

- In Cursor, you can ask the AI to use the GitHub MCP to create a new repository named `cursor-comet-mcp-setup` (or use GitHub in the browser: New repository → Public → Create).
- Do **not** add a README, .gitignore, or license on GitHub (this repo already has them).

### 3. Push from the repo folder

**Order of operations (ready to push):** (A) Create GitHub PAT (repo scope) → (C) Add `github` to mcp.json with PAT → (D) Restart Cursor → (B) Create public repo on GitHub (empty) → (E) Terminal: git init, add, commit, remote add, push.

In a terminal, from the `cursor-comet-mcp-setup` folder:

```powershell
cd "c:\Users\admin\Perplexity mcp\cursor-comet-mcp-setup"
git init
git add mcp.json.template comet-auto-space.js package.json setup.ps1 README.md .gitignore .env.example PRE_PUSH_CHECKLIST.md docs/POE2_MCP_KNOWN_ISSUES.md
git status
git commit -m "Cursor MCP setup: Comet + poe2-optimizer"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cursor-comet-mcp-setup.git
git push -u origin main
```

Or, if the GitHub MCP exposes push/create-repo tools, you can ask the AI to create the repo and push this folder after the MCP is configured and you’re in the project.
