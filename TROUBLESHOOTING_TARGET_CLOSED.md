# Troubleshooting: "Target closed" / Page not initialized

## If MCP stopped working after Space creation

If Cursor stopped using the Perplexity MCP after running space creation scripts:

1. **Remove project-local MCP override** (if it exists): Delete any `\.cursor\mcp-local.json` in your project. It can override the global config and break perplexity-server.
2. **Configure-ProjectMCP is disabled** in New-PerplexitySpace.ps1 — it no longer writes project-local config after creating a Space.
3. **Restart Cursor** and use only the global `C:\Users\admin\.cursor\mcp.json`.

---

When Cursor fails with:
```
Error: Page not initialized: Protocol error (Target.setDiscoverTargets): Target closed
```
follow these steps in order.

---

## 1. Kill conflicting processes

Before restarting Cursor, close all processes that may conflict:

**PowerShell (run as Administrator if needed):**
```powershell
Get-Process -Name "chrome","chromium","bun" -ErrorAction SilentlyContinue | Stop-Process -Force
```

**Or manually in Task Manager (Ctrl+Shift+Esc):**
- End `chrome.exe` / `chromium.exe`
- End `bun.exe`
- Ensure no `bun run start` or `bun run build` is running in a terminal

**Confirm:** Cursor should be the only process starting `bun` via MCP (mcp.json). No parallel bun processes.

---

## 2. Verify MCP config

**File:** `C:\Users\admin\.cursor\mcp.json`

- Server key: `perplexity-server`
- `command`: `bun`
- `args`: `["C:\\Users\\admin\\Perplexity mcp\\perplexity-mcp-zerver\\build\\main.js"]`
- `timeout`: `600`
- `env`: `PERPLEXITY_BROWSER_DATA_DIR`, `PERPLEXITY_PERSISTENT_PROFILE`, `LANG`, `LC_ALL`, `LOG_LEVEL`

Validate JSON: no trailing commas, balanced braces.

---

## 3. Where to find logs

With `LOG_LEVEL=debug` in mcp.json:

- **Cursor:** `View` → `Output` → select "MCP" or "Perplexity" channel
- **Stderr:** MCP server logs go to stderr; Cursor may surface them in Output
- **Manual run:**  
  ```powershell
  cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
  $env:PERPLEXITY_BROWSER_DATA_DIR="C:\Users\admin\.perplexity-mcp"
  $env:PERPLEXITY_PERSISTENT_PROFILE="true"
  $env:LOG_LEVEL="debug"
  bun build/main.js
  ```
  (Press Ctrl+C to stop)

**If the error repeats:** Copy the full error message, last 20–30 lines of stderr, and any Cursor Output lines. Paste that into Perplexity or the project issue tracker.

---

## 4. Fallback: Official Perplexity MCP (API-based)

If "Target closed" keeps happening, switch to the official Perplexity MCP server (API key required, no browser):

```json
{
  "mcpServers": {
    "perplexity-official": {
      "command": "npx",
      "args": ["-y", "@perplexity-ai/mcp-server"],
      "env": {
        "PPLX_API_KEY": "your_redacted_api_key_here",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8"
      },
      "timeout": 300
    }
  }
}
```

Get the key from [Perplexity API settings](https://www.perplexity.ai/settings/api). **Keep** `LANG` and `LC_ALL` to avoid garbled text between Cursor and Perplexity.
