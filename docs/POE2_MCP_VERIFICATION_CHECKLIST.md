# poe2-mcp – Full verification checklist

Use these checks to confirm the whole MCP is working. Run in Cursor (with poe2-optimizer MCP connected) by asking the AI to call each tool.

---

## 1. Health & utility

| Tool | Example / params | Expected |
|------|------------------|----------|
| **health_check** | `verbose: true` | Operational; may show warnings (items DB empty, POESESSID not set). After running `python scripts\populate_items.py` and restarting MCP, expect “Items table populated: 1,XXX items” (e.g. 1,400+). |
| **clear_cache** | (no args) | "Successfully cleared" message; no crash. |
| **get_formula** | (no args) | Lists all formula types (dps, ehp, armor, etc.). |
| **get_formula** | `formula_type: "ehp"` | Returns EHP formula and explanation. |

---

## 2. Character & poe.ninja

| Tool | Example / params | Expected |
|------|------------------|----------|
| **analyze_character** | `account: "cricrusic-5718"`, `character: "feedbackerman"`, `league: "Standard"` | Full analysis (class, level, build score, passives). |
| **import_poe_ninja_url** | `url: "https://poe.ninja/poe2/builds/character/cricrusic-5718/feedbackerman"` | Same as above. |
| **compare_to_top_players** | Same account/character, `top_player_limit: 3` | Either comparison data or "Could not find similar top players" (API-dependent). |
| **get_pob_code** | Same account/character | PoB code or message that character/PoB data not available. |

---

## 3. Validation

| Tool | Example / params | Expected |
|------|------------------|----------|
| **validate_support_combination** | `support_gems: ["Faster Projectiles", "Slower Projectiles"]` | "Invalid combination" with conflict reason. |
| **validate_item_mods** | `mod_ids: ["Strength1", "FireResist3"]`, `item_level: 83` | Valid/Invalid and prefix/suffix counts. |
| **validate_build_constraints** | (needs `character_data` from analyze) | Validation result or error if no data. |

---

## 4. Passive tree

| Tool | Example / params | Expected |
|------|------------------|----------|
| **list_all_keystones** | `limit: 5`, `sort_by: "name"` | 5 keystones; pagination "Use offset=5 for more". |
| **list_all_keystones** | `limit: 5`, `offset: 5` | Next 5 keystones; "Offset: 5". |
| **list_all_notables** | `limit: 10`, `sort_by: "name"` | 10 notables; "X shown, 968 total" (or similar). |
| **inspect_keystone** | `keystone_name: "Chaos Inoculation"` | Keystone stats (e.g. "Maximum Life is 1"). |
| **inspect_passive_node** | `node_name: "Chaos Inoculation"` | Node details including ID and position. |
| **analyze_passive_tree** | `node_ids: [56349, 12345]`, `find_recommendations: true` | Summary, allocated nodes, nearest notables. |

---

## 5. Mods

| Tool | Example / params | Expected |
|------|------------------|----------|
| **list_all_mods** | `generation_type: "PREFIX"`, `limit: 5` | List of mods; pagination. |
| **get_mod_tiers** | `mod_base: "IncreasedLife"` | Tier progression T1–T13 (or similar). |
| **get_available_mods** | `generation_type: "PREFIX"`, `limit: 5` | Mod families; "Showing X of Y families". |
| **search_mods_by_stat** | `stat_keyword: "life"`, `limit: 5` | Mods matching "life" or "No mods found". |
| **inspect_mod** | `mod_id: "IncreasedLife5"` | Full mod details. |

---

## 6. Spells & supports

| Tool | Example / params | Expected |
|------|------------------|----------|
| **list_all_spells** | `limit: 5`, `sort_by: "name"` | Spell list; pagination. |
| **list_all_supports** | `limit: 5` | Support list (may be 0 if data source differs). |
| **inspect_spell_gem** | `spell_name: "Fireball"` | Full spell data (levels, stats, source). |
| **inspect_support_gem** | `support_name: "<name from list_all_supports>"` | Full support data or "not found". |

---

## 7. Base items & items search

| Tool | Example / params | Expected |
|------|------------------|----------|
| **list_all_base_items** | `limit: 10` or with `filter_type: "Ring"` | Base items or "No base items found" (if DB empty). |
| **inspect_base_item** | `item_name: "<name from list>"` | Base item details. |
| **search_items** | `query: "ring"` | Search results or SQL/DB error if items DB not populated (known limitation). |

---

## 8. Knowledge & mechanics

| Tool | Example / params | Expected |
|------|------------------|----------|
| **explain_mechanic** | `mechanic_name: "armor"` | Full explanation and formula. |
| **explain_mechanic** | `mechanic_name: "critical strike"` | Explanation. |

---

## 9. Path of Building

| Tool | Example / params | Expected |
|------|------------------|----------|
| **import_pob** | `pob_code: "<base64 PoB export>"` | Parsed build data or error. |
| **export_pob** | (needs `character_data`) | PoB export string. |
| **get_pob_code** | `account`, `character` | PoB code or "Could not fetch" (API/data dependent). |

---

## 10. Trade (optional; requires auth)

| Tool | Example / params | Expected |
|------|------------------|----------|
| **setup_trade_auth** | (browser login) | Session saved or instructions. |
| **search_trade_items** | `league`, `character_needs`, `max_price_chaos` | Trade results or clear "auth/config required" message. |

---

## Quick “smoke test” (minimal set)

If you only run a few checks, use these:

1. **health_check** (verbose)
2. **list_all_keystones** (limit=5)
3. **validate_support_combination** (Faster + Slower Projectiles)
4. **explain_mechanic** (armor)
5. **get_formula** (ehp)
6. **inspect_keystone** (Chaos Inoculation)
7. **import_poe_ninja_url** (known character URL)
8. **clear_cache**

All of the above should complete without crashes. List tools should return pagination; character tools may depend on poe.ninja/API availability.

---

## Known limitations (not failures)

- **list_all_supports** / **list_all_base_items**: May return 0 if data comes from a different DB or filter.
- **search_items**: Fails with "no such table: datc64.baseitemtypes" if the datc64 DB is missing (separate from the main Items table). To fill the **Items** table used by health_check, run **`python scripts\populate_items.py`** from the workspace (see docs/POE2_MCP_DATA_API_DB_DIAGNOSTIC.md).
- **compare_to_top_players** / **get_pob_code**: May return "not found" or "could not fetch" depending on poe.ninja/PoB API and character.
- **search_trade_items**: Requires **setup_trade_auth** first; otherwise expect "auth required" or similar.

These are data/configuration limits, not MCP server bugs.
