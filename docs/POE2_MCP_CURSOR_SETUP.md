# poe2-mcp in Cursor – Setup & Checklist

Instructions to get [poe2-mcp](https://github.com/HivemindOverlord/poe2-mcp) working in Cursor on Windows. Aligned with the [official README](https://github.com/HivemindOverlord/poe2-mcp) and Perplexity research.

---

## 1. Install

**Option A: Pip (recommended for Cursor)**

```powershell
pip install poe2-mcp
```

**Option B: From source** (if you want to run `launch.py` and have a local clone)

```powershell
git clone https://github.com/HivemindOverlord/poe2-mcp.git
cd poe2-mcp
pip install -e .
```

---

## 2. Fix async entry point (pip install only)

The PyPI console script calls `main()` from `src.mcp_server`, but `main` is async, so the process exits with “coroutine 'main' was never awaited”.

**Applied fix:** The installed package was patched so there is a **sync** `main()` that runs `asyncio.run(_main_async())`.

- **File:** `C:\Users\admin\Python\Lib\site-packages\src\mcp_server.py`
- **Effect:** Running `poe2-mcp` now correctly starts the MCP server.
- **If you reinstall** (e.g. `pip install --force-reinstall poe2-mcp`), re-apply this patch or use the launch.py method below.

---

## 3. Cursor MCP config

Cursor uses **`mcpServers`** in `mcp.json` (not `mcp.servers`).

**Config file:** `C:\Users\admin\.cursor\mcp.json`

**Current config (pip + patched entry point):**

```json
{
  "mcpServers": {
    "comet": {
      "command": "node",
      "args": ["C:\\Users\\admin\\.cursor\\comet-auto-space.js"]
    },
    "poe2-optimizer": {
      "command": "poe2-mcp",
      "args": []
    }
  }
}
```

**Alternative (from source, using `launch.py`):**  
Use this if you prefer the repo’s launcher (pre-flight checks, dirs, DB init) or if you did not patch the pip install:

```json
"poe2-optimizer": {
  "command": "python",
  "args": ["C:\\Users\\admin\\poe2-mcp\\launch.py"]
}
```

If you use `launch.py`, run it from the **repo root** (so `data/`, `config.yaml`, `.env` are found). Cursor does not support `cwd` in `mcp.json`; using the full path to `launch.py` usually still works because paths inside the repo are relative to the process start (often your project or home). If you get missing-file errors, use a wrapper script that `cd`s to the repo root and then runs `python launch.py`.

---

## 4. Data and .env (pip install)

- **Data dir:** Resolved from package location: `...\site-packages\data\` (e.g. `poe2_mods_extracted.json`, `poe2_support_gems_database.json`). No need to set `cwd` for data.
- **.env:** The package expects `.env` in the same directory as the package (e.g. `...\site-packages\.env`) for `SECRET_KEY` and `ENCRYPTION_KEY`. If you see errors about missing secrets, add a `.env` there with:
  - `SECRET_KEY` and `ENCRYPTION_KEY` (e.g. generate with `python -c "import secrets; print(secrets.token_hex(32))"`).

---

## 5. Optional: Trade API

For the **search_trade_items** tool:

```powershell
pip install playwright
playwright install chromium
python scripts/setup_trade_auth.py
```

Run `setup_trade_auth.py` from the repo root if you use a clone; the script opens a browser to log in and saves the session.

---

## 6. Verify

1. Restart Cursor (or disconnect/reconnect the poe2-optimizer MCP server).
2. In Cursor, open MCP tools and confirm **poe2-optimizer** is connected.
3. Try a tool, e.g. “Run poe2 health_check” or “List all keystones”.

---

## 7. Test build (for manual verification)

Use this public character to confirm character fetch and analysis work:

| Field        | Value |
|-------------|--------|
| **URL**     | https://poe.ninja/poe2/builds/character/cricrusic-5718/feedbackerman |
| **Account** | `cricrusic-5718` |
| **Character** | `feedbackerman` |
| **League**  | Standard |

- In Cursor, ask the AI to run **analyze_character** with account `cricrusic-5718`, character `feedbackerman`, league `Standard`.
- Or use **import_poe_ninja_url** with the URL above.

---

## Summary

| Step                    | Status / note                                      |
|-------------------------|----------------------------------------------------|
| Install (pip)           | Done                                               |
| Async main() patch      | Applied in site-packages `mcp_server.py`            |
| Cursor mcp.json         | Uses `poe2-mcp` under `mcpServers`                 |
| Data / .env (pip)       | Uses site-packages paths; .env present if needed   |
| Trade auth              | Optional; run from repo root if using a clone       |

If the server fails after a **pip upgrade/reinstall**, re-apply the sync `main()` wrapper in `mcp_server.py` or switch to the `python` + `launch.py` config and run from repo root.
