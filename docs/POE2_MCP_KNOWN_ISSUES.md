# PoE2 MCP – known issues and fixes

This repo only **configures** Cursor to run `poe2-mcp` (the `poe2-optimizer` entry in `mcp.json.template`). It does **not** include the poe2-mcp package or any patches to it.

When you `pip install poe2-mcp`, you get the upstream package. As of our testing, that package had two issues that we patched **only on this machine** (in the installed site-packages). On a **fresh install or another machine**, you may see the same errors until you re-apply these fixes or until upstream includes them.

---

## 1. "coroutine 'main' was never awaited"

**Symptom:** MCP server fails to start; log shows `RuntimeWarning: coroutine 'main' was never awaited`.

**Cause:** The package’s console script calls `main()` but `main` is an async function, so it’s never awaited.

**Fix (in installed package):** In `...\site-packages\src\mcp_server.py`:

- Rename the current async entry point to `_main_async()`.
- Add a sync `main()` that does: `asyncio.run(_main_async())`.
- Ensure the `if __name__ == "__main__":` block also uses `asyncio.run(_main_async())`.

Then restart Cursor so it uses the patched code.

---

## 2. "unsupported operand type(s) for +: 'int' and 'str'" (e.g. list_all_keystones with limit)

**Symptom:** Calling list tools (e.g. `list_all_keystones`) with `limit` or `offset` returns a server error about int + str.

**Cause:** The MCP client sometimes sends numeric arguments as JSON strings (`"limit": "5"`). The code uses them in arithmetic and in `PaginationMeta` without coercing to int.

**Fix (in installed package):**

- **In list handlers** (e.g. in `mcp_server.py`): coerce and cap:
  - `limit = min(int(args.get("limit", 20)), 100)`
  - `offset = max(0, int(args.get("offset", 0)))`
  Apply the same pattern in any other list handler that uses `args.get("limit")` / `args.get("offset")`.
- **In `utils/response_formatter.py`:** In `PaginationMeta`, add a `__post_init__` that coerces `total`, `limit`, `offset`, and `showing` to `int`. Also ensure any use of `meta.offset + meta.limit` (e.g. in the “use offset=… for more” text) uses `int(meta.offset) + int(meta.limit)` so string values never reach arithmetic.

Then restart the MCP server (or Cursor).

---

## Upstream

- **Repo:** [HivemindOverlord/poe2-mcp](https://github.com/HivemindOverlord/poe2-mcp)
- These fixes can be proposed upstream so future `pip install poe2-mcp` may include them and you won’t need to patch locally.
