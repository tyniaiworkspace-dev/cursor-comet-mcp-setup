# Perplexity Standards for Best Results (Summary)

> **Researched via web + official Perplexity docs.** Use these whenever Cursor calls the Perplexity MCP so you get the best out of it.

---

## Where This Is Enforced

- **Project rule**: `.cursor/rules/perplexity-mcp-usage.md`  
  - Loaded when working in this Perplexity MCP project; Cursor should follow it when calling any Perplexity MCP tool here.

---

## Quick Reference (What Cursor Should Do)

### 1. Query design

- **Be specific**: Add 2–3 extra context words (e.g. "for urban planning", "in the past 6 months").
- **One topic per call**: No "and also tell me about X and Y."
- **Search-friendly wording**: Use terms that would appear on real pages (e.g. "energy efficiency ratings of heat pumps vs HVAC" not "which heating is better").
- **Explicit need**: Say exactly what you want (e.g. "latest developments in X announced in the past 6 months").

### 2. Output and format

- **Structure up front**: One sentence on how to search, one on output (e.g. "Search recent official sources. Return top 6 as a numbered brief with one-sentence takeaways.").
- **Never ask for "include links" in the prompt**: The model doesn’t see URLs; that causes hallucinated links. Use API/search metadata for real URLs if available.

### 3. Reliability

- **Boundaries**: Add "If you cannot find reliable sources, say so explicitly" (or similar).
- **Conditional language**: "If available, provide… Otherwise indicate what could not be found."
- **No few-shot in the query**: Examples trigger searches for the examples, not your real question.

### 4. When to search vs not

- **Use search**: News, pricing, research, docs, APIs, factual checks.
- **No search**: Add "Answer without searching the web" for pure reasoning/math/code when web data isn’t needed.

### 5. Tool choice (MCP)

- General research → `search` or `chat_perplexity`.
- Docs/APIs → `get_documentation`.
- Single URL → `extract_url_content`.
- Find APIs → `find_apis`.
- Deprecation/legacy → `check_deprecated_code`.

---

## Sources

- **Perplexity Prompt Guide** (docs.perplexity.ai): specificity, no URL requests in prompt, hallucination prevention, one topic, built-in parameters.
- **Perplexity Search Best Practices** (docs.perplexity.ai): retrieval + output structure, operators.
- **DataStudios / community**: search vs no-search, operators (site:, filetype:, time), structured outputs.

---

## Full Rule

See **`.cursor/rules/perplexity-mcp-usage.md`** in this project for the full, copy-paste-ready standards Cursor should follow when using the Perplexity MCP.
