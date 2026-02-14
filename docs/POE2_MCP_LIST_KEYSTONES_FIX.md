# list_all_keystones (and list handlers) type error – fix summary

## Error

```
unsupported operand type(s) for +: 'int' and 'str'
```

When calling `list_all_keystones` (or other list tools) with `limit`/`offset`, the MCP client sometimes sends JSON with numeric parameters as **strings** (e.g. `"limit": "5"`). The code used them in slices and arithmetic (`offset:offset + limit`, `PaginationMeta(...)`), causing the above error.

## Root cause

- `limit = args.get("limit", 20)` and `offset = args.get("offset", 0)` were used without coercing to `int`.
- In `paginated = keystone_dicts[offset:offset + limit]`, if `limit` was the string `"5"`, Python raised `int + str`.
- `PaginationMeta(total=..., limit=limit, offset=offset, ...)` and later `meta.offset + meta.limit` in the response formatter had the same issue when values were strings.

## Fixes applied (in installed package)

### 1. `src/mcp_server.py` – coerce and cap in list handlers

In all list-style handlers that use `limit`/`offset` from `args`, values are coerced to `int` and (where applicable) capped:

- **list_all_keystones:** `limit = min(int(args.get("limit", 20)), 100)`, `offset = max(0, int(args.get("offset", 0)))`
- **list_all_supports:** same pattern (limit cap 100)
- **list_all_spells:** same pattern (limit cap 100)
- **list_all_notables:** `limit = min(int(args.get("limit", 100)), 200)`
- **list_all_base_items:** `limit = min(int(args.get("limit", 100)), 200)`
- **list_all_mods:** limit/offset coerced, limit cap 100
- **search_mods_by_stat:** `limit = min(int(args.get("limit", 50)), 100)`
- **get_available_mods:** `limit = min(int(args.get("limit", 100)), 200)`, `max_level = int(args.get("max_level", 100))`

### 2. `src/utils/response_formatter.py` – defensive handling

- **PaginationMeta:** added `__post_init__` to coerce `total`, `limit`, `offset`, and `showing` to `int` so string values from any caller are normalized.
- **format_pagination_header / format_list_response:** use `int(meta.offset) + int(meta.limit)` when formatting the “next offset” hint so display is safe even if meta was built with strings elsewhere.

## Applying the fix

These edits were made in the **installed** package under:

- `C:\Users\admin\Python\Lib\site-packages\src\mcp_server.py`
- `C:\Users\admin\Python\Lib\site-packages\src\utils\response_formatter.py`

After editing, **restart the poe2-mcp server** so it loads the new code:

- Restart Cursor, or  
- Disconnect and reconnect the **poe2-optimizer** MCP server in Cursor (e.g. Settings → MCP → disconnect/reconnect).

Then run again, e.g.:

- `list_all_keystones` with `limit=5`, `sort_by=name`.

## Upstream (poe2-mcp repo)

To propose this for the upstream [HivemindOverlord/poe2-mcp](https://github.com/HivemindOverlord/poe2-mcp) repo:

- **Title:** Fix list handlers and PaginationMeta when MCP sends limit/offset as strings  
- **Description (short):** MCP clients can send numeric parameters as JSON strings. Coerce `limit` and `offset` to `int` (with sensible caps) in all list handlers and in `PaginationMeta` so list tools (e.g. `list_all_keystones`) do not raise `unsupported operand type(s) for +: 'int' and 'str'`.
