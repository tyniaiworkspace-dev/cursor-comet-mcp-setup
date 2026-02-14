# poe2-mcp – Data / API / DB diagnostic and next steps

**Collaboration:** For size checks and next steps, ask Perplexity first to verify counts and recommend options, then implement.

**Supported way to fill Items:** The supported way to fill or refresh the **Items** table for poe2-mcp is the workspace script **`scripts/populate_items.py`**. It scrapes poe2db.tw (uniques + skill gems + support gems) and writes to the same DB the MCP uses. Everything beyond uniques+gems (e.g. full base-item tables from subcategory pages or datc64) is optional/advanced.

- **How to run:** From the workspace root: `python scripts\populate_items.py`  
  Default: all uniques + all skill gems + all support gems (~1,300–1,400 items). Optional: `UNIQUES_ONLY=1` for uniques only; `LIMIT=N` to cap unique count.

Run these checks to see what’s working and what needs fixing. Use Cursor with the poe2-optimizer MCP connected and ask the AI to run each check.

---

## 1. Diagnostic checklist (run these)

| # | Check | Tool / action | Working | Needs fixing |
|---|--------|----------------|---------|--------------|
| **1** | **poe.ninja API** | `health_check` with `verbose: true` | “Character Fetcher Diagnostic” shows **Fetch Result: SUCCESS** and a character (e.g. DoesFireWorkGoodNow) with class, level, stats | Fetch fails or “Character not found” |
| **2** | **Character fetch (real)** | `analyze_character` or `import_poe_ninja_url` with a known public character (e.g. account `cricrusic-5718`, character `feedbackerman`) | Full analysis (class, level, passives, build score) | “Character fetch failed” or “not found” |
| **3** | **Mods (JSON)** | `list_all_mods` with `generation_type: "PREFIX"`, `limit: 2` | Returns 2 mods (e.g. IncreasedLife1, IncreasedMana1) and total count | Error or 0 mods |
| **4** | **Passives (JSON)** | `list_all_keystones` with `limit: 2` | Returns 2 keystones (e.g. Ancestral Bond, Avatar of Fire) and total 30 | Error or 0 keystones |
| **5** | **Spells (JSON)** | `list_all_spells` with `limit: 2` | Returns 2 spells (e.g. Abiding Hex) and total 902 | Error or 0 spells |
| **6** | **Support gems (datc64 or JSON)** | `list_all_supports` with `limit: 2` | Returns at least 1 support gem | Returns “0 of 0” (no support data loaded) |
| **7** | **Base items (datc64)** | `list_all_base_items` with `limit: 2` | Returns at least 1 base item | “0 shown, 0 total” or “No base items found” |
| **8** | **Items search (datc64 DB)** | `search_items` with `query: "ring"` | List of items or “no results” | **SQL error**: `no such table: datc64.baseitemtypes` (or similar) |
| **9** | **Trade API (optional)** | `search_trade_items` with a simple query, or `health_check` | Trade results or clear “POESESSID not configured” / “auth required” | Timeout, crash, or unclear error |

---

## 2. How to interpret results

- **Checks 1–2:** poe.ninja **API** (character fetch). If both pass → API is working.
- **Checks 3–5:** **JSON data files** in `site-packages/data/` (mods, passives, spells). If pass → those files are present and readable.
- **Checks 6–8:** **datc64-derived data** (support gems, base items, item search). These need either:
  - **Extracted .datc64 files** under `data/extracted/data/` (e.g. `grantedeffects.datc64`, `baseitemtypes.datc64`), or
  - **SQLite DB** `poe2_datc64.db` (with tables like `datc64.baseitemtypes`, `datc64.itemclasses`) in the package data dir.
- **Check 9:** **Trade** is optional; “POESESSID not set” is expected unless you ran `setup_trade_auth`.

---

## 3. Current state (after running the checklist)

| Area | Status | Cause |
|------|--------|--------|
| **poe.ninja API** | ✅ Working | Character fetcher and health_check diagnostic succeed. |
| **JSON data (mods, passives, spells)** | ✅ Working | `poe2_mods_extracted.json`, `psg_passive_nodes.json`, `pob_complete_skills.json` exist in `site-packages/data/`. |
| **Support gems** | ✅ Working (after fix) | JSON fallback: server loads `poe2_support_gems_database.json` when FreshDataProvider is empty. Restart MCP to pick up. |
| **Base items** | ⚠️ Empty (0) | Same: FreshDataProvider expects `baseitemtypes.datc64` (or similar) under `data/extracted/data/`. |
| **Item search** | ❌ Fails | `search_items` attaches `poe2_datc64.db` and queries `datc64.baseitemtypes`. That DB is not shipped with pip → “no such table: datc64.baseitemtypes”. |
| **Trade** | ✅ Working (after POESESSID) | Set POESESSID in `.env`; health_check shows configured; `search_trade_items` responds. |

---

## 3b. Post-restart verification (after fixes)

After applying the support-gems JSON fallback and setting POESESSID, **restart the MCP server** (or Cursor), then run:

| Check | Expected result |
|--------|------------------|
| **list_all_supports** (limit 5) | **PASS** – e.g. "5 of 21" support gems (JSON fallback working). |
| **health_check** (verbose) | **PASS** – 11 successes; "POESESSID configured (32 characters)"; only warning: items DB empty. |
| **list_all_keystones** (limit 2) | **PASS** – 2 of 30. |
| **search_trade_items** (simple query) | **PASS** – API responds (e.g. "No items found" or results; auth working). |

If all four pass, the collab next steps are complete: support-gems fallback is live, trade auth is live, and JSON-based tools are healthy. The only remaining gap is the items/datc64 database (see optional next step below).

---

## 4. Next steps (agreed with Perplexity)

**Order:** Do A (implement support-gems fallback), then B (document POESESSID), then C (document upstream). Treat trade (POESESSID) as optional and don’t block other work on it.

### A. Implemented: local JSON fallback for support gems

- **Done.** When FreshDataProvider returns no support gems (e.g. default pip install with no datc64), the server now loads from `data/poe2_support_gems_database.json` so `list_all_supports` returns data.
- **Base items:** No similar fallback added; the only base-item JSON in the package is `base_items_validation.json` (a validation report), not a full id→data list. Upstream could add a base-items JSON and a matching fallback later.

### B. POESESSID (trade) setup

- **Where:** Set `POESESSID` in the **.env** file the server loads. For a pip install that is usually:
  - `...\Python\Lib\site-packages\.env`
- **How:** Add one line: `POESESSID=your_session_id_here` (no quotes, no spaces around `=`). Get the value by logging into pathofexile.com and copying the session cookie, or use the `setup_trade_auth` tool.
- **Security:** Do not commit `.env` or share your POESESSID; it grants access to your account. If you added it to a repo by mistake, rotate the session (log out / log in again) and remove it from history.
- After setting it, restart the MCP server (or Cursor) so the new env is picked up. Then `search_trade_items` can work if the rest of the trade API is configured.

### C. Upstream recommendations (for repo maintainers)

1. **Confirm JSON data is present**  
   In your Python env, check that these exist (paths relative to `site-packages`):
   - `data/poe2_mods_extracted.json`
   - `data/psg_passive_nodes.json`
   - `data/pob_complete_skills.json`  
   If any are missing, reinstall or restore the package data.

2. **Optional: use trade only if needed**  
   If you need `search_trade_items`, run `setup_trade_auth` (and ensure POESESSID is set as the tool/docs describe). Otherwise, ignore trade warnings.

3. **Don’t rely on item search / base items / support gems from datc64**  
   Until datc64 data or DB is available, treat:
   - `list_all_supports` → 0 results  
   - `list_all_base_items` → 0 results  
   - `search_items` → SQL error  
   as **expected** for a default pip install.

### D. Optional (advanced): close the items/datc64 gap

*Only needed if you want full item/mod coverage (e.g. tools that rely on the main Items table). You can skip this and use the MCP as-is.*

- **Two different DBs:**
  - **Main app DB** (e.g. `poe2_optimizer.db`): has an **Items** table that health_check reports. It can be filled by scraping poe2db.tw (no game files needed). It does **not** create `poe2_datc64.db`.
  - **datc64 DB** (`poe2_datc64.db`): used by **search_items** and by FreshDataProvider for **list_all_base_items**. It expects tables like `datc64.baseitemtypes` and `datc64.itemclasses`, which are built from PoE2 game **.datc64** files (or an upstream-provided prebuilt DB). The pip package does not ship this DB or those files.

- **Scraper fix applied (pathway forward):**
  - poe2db.tw uses **Unique_item** (singular), not Unique_items. In `site-packages/src/utils/scraper.py` the URL was changed to `/us/Unique_item`.
  - The Unique_item page uses **link-based item cards**, not HTML tables. A **fallback parser** was added: when no `table.item`/`table.wikitable` is found, the scraper collects all links matching `/us/[A-Za-z0-9_%]+`, skips known non-item paths (Version_, Act_, Quest_, etc.), and builds one item per link (name = link text, base_type = "Unique"). This allows the Items table to be populated from the current site layout.

- **Verify before running:** Run `python scripts/verify_populate_before_run.py` from this workspace. It checks DATA_DIR, scraper (one unique item), and DB write. After the above fix, verification **passes** (scraper returns items, DB write OK).

- **Populate the Items table:** Use the workspace script **`scripts/populate_items.py`** (no repo clone needed):
  - From workspace: `python scripts\populate_items.py`
  - Default: scrapes **all uniques + all skill gems + all support gems** and replaces the Items table (~1,300–1,400 rows). Optional env: `UNIQUES_ONLY=1` for uniques only; `LIMIT=N` to cap unique count.
  - **Size:** Uniques ~403; with gems, total ~1,300–1,400 rows. **Expected DB file size** after populate: **~1–5 MB** (poe2_optimizer.db). Use this as a quick sanity check after a run.
  - After running, **restart the MCP** (or Cursor) and run **health_check** to confirm “Items table populated: N items”.
- **Verified with Perplexity (Feb 2025):** poe2db.tw page totals confirmed: Unique_item 73+207+123=403; Skill_Gems ~355; Support_Gems 527; base types on ~15–20 subcategory pages. Populate script extended to include skill + support gems; default run inserts uniques + gems (~1,300–1,400 rows depending on parser). Use `UNIQUES_ONLY=1` to skip gems.

- **Was the MCP meant to run all items (not just uniques)?** Yes. The scraper in the package is designed to fill from multiple sources:
  - **Uniques:** `/us/Unique_item` → **~403** (we fixed; `populate_items.py` uses this).
  - **Skill gems:** `/us/Skill_Gems` → **~355** (table layout; 1 request).
  - **Support gems:** `/us/Support_Gems` → **~527** (table layout; 1 request).
  - **Base items:** Scraper calls `/us/Weapons`, `/us/Armours`, `/us/Accessories` — those pages are category stubs and do **not** list base types. Base types live on subcategory pages (e.g. `/us/Claws` has 13, `/us/Daggers`, `/us/Body_Armours`, etc.). So with the current code, base-item scrape returns **0**. To get all base items you’d need to scrape ~35–50 subcategory pages (Claws, Daggers, Wands, … Helmets, Amulets, Rings, Belts, etc.), roughly **~500–1,000** base types.
  - **Total “all items” (if uniques + skill gems + support gems + base items were all scraped and written to the Items table):** **~1,300** (uniques + gems only) or **~2,000–2,300** (with base items from subcategory pages). DB size: still **on the order of 1–3 MB** (low thousands of rows, small columns).
  - The script **`populate_items.py`** now populates uniques + skill gems + support gems; base items would require scraper changes to hit subcategory URLs and parse those pages (optional/advanced).

- **search_items / list_all_base_items:** Still require the datc64 DB (see above). Either obtain .datc64 files and the repo build script, or wait for upstream to ship a prebuilt `poe2_datc64.db`.

### E. What the repo/package could do (upstream)

1. **Ship datc64-derived data with pip**  
   - Either ship a pre-built `poe2_datc64.db` (with `baseitemtypes`, `itemclasses`, etc.) in the package data dir, or  
   - Ship the required `data/extracted/data/*.datc64` files and document that they must be present for support gems and base items.

2. **Or document “extended” setup**  
   - Document that `populate_database.py` (or an equivalent script) must be run from a game/data path to create `poe2_datc64.db` or the extracted .datc64 files, and that without it, item search and list_all_base_items (and possibly list_all_supports) will not work.

3. **Clearer errors for datc64-dependent tools**  
   For tools that depend on datc64 (e.g. `search_items`, `list_all_base_items`, `list_all_supports`), return a clear message such as:  
   *“Item/support database not initialized. Run populate_database.py from the repo or ensure poe2_datc64.db (or extracted .datc64 files) are available.”*  
   instead of raw SQLite or filesystem errors.

---

## 5. One-line summary

- **API:** Working if health_check and one character fetch succeed.  
- **DB/Data:** Mods, passives, and spells work from JSON; support gems, base items, and item search depend on datc64 data or `poe2_datc64.db`, which are not provided by the default pip install—run the diagnostic checklist above to confirm, then use “Next steps” to decide whether to fix locally support gems now have a JSON fallback (implemented); base items/item search still need datc64 or upstream.
