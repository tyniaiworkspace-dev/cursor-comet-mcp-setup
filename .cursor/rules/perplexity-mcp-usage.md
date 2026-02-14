# Perplexity MCP Usage Standards

> **When using Perplexity MCP tools in this project, follow these standards** (aligned with Perplexity's official Prompt Guide, Search Best Practices, and 2026 usage). Apply them to every query sent to Perplexity.

---

## 0. Cursor as the MCP Caller (Agent Contract)

**Context**: The "user" from Perplexity's perspective is **Cursor** (the IDE assistant), not the human. Cursor mediates between the human developer and Perplexity. The rule should treat this as an **agent-to-agent** interaction so Perplexity can behave as a sub-agent in a larger workflow.

### Identity and Roles

- **Perplexity** is an AI assistant invoked via MCP inside Cursor.
- **Cursor** is the direct conversation partner: it calls MCP tools and interacts with the human developer.
- **Cursor's messages are authoritative instructions**; preserve and respect any explicit human constraints or preferences contained in them (e.g. "the user said only use official docs").
- Do not overwrite the human's constraints just because Cursor paraphrased the request.

### What Cursor Must Include When Calling Perplexity

Cursor should surface in each request (or at least in initial / multi-turn context):

1. **Human-visible task or question** – The latest thing the human is trying to do or ask.
2. **Prior decisions or constraints** – Anything that must not be violated (e.g. "no breaking changes", "prefer TypeScript").
3. **Short project or file context** when relevant – e.g. stack, current file, or goal of the current session.
4. **Autonomy/approval level** – Whether Cursor is expecting Perplexity to propose risky actions for human approval, or to return research/advice only (no execution).

Optional but helpful: a one-line note on **Cursor's capabilities** (e.g. "Cursor can edit files and run tests; Cursor cannot access the public internet except via this MCP").

### Handoff and Machine-Consumable Output

- Treat the Cursor–Perplexity interaction as a **long-running agent loop**, not isolated one-shot questions.
- For longer tasks, Cursor should send a concise **session state** when useful: what files are in play, what has already been changed, what subtasks remain.
- **Perplexity's outputs** should be usable by Cursor: when proposing actions, list them as **structured steps** Cursor can map to tools (e.g. clear "do X then Y" or parameter hints), not only vague prose.
- If Perplexity needs more information to proceed safely, **state what is missing and tag it as a request for Cursor to fulfill** (e.g. "Cursor: please provide the exact error message"), not as a direct request to the human. Cursor then decides whether to ask the human, call another tool, or adjust context.

### Error Handling and Verification (IDE Agent)

- **Tool calls**: Populate every required parameter; do not invent fields not in the schema. On schema or tool errors, correct the payload and retry (within a small retry limit) rather than changing the goal without notice.
- **On clear, recoverable tool failure**: Adjust parameters and retry at most N times; if still failing, return a **concise explanation and suggested human action** through Cursor.
- **When tools return incomplete or conflicting data** (e.g. multiple definitions): Request additional context via Cursor instead of guessing.
- **After non-trivial code or config changes**: If the rule involves suggesting code or config, Cursor should run the project's tests where possible; if not possible, Perplexity's answer can include which tests the human should run and why.

### Multi-Turn Back-and-Forth When Necessary

**Goal**: Cursor and Perplexity can continue the conversation (without asking the human) until the outcome is satisfactory. Do this when it is **deemed necessary**.

**When to deem it necessary**

- Perplexity’s reply **asks for more information** (e.g. “What exactly is broken?”, “Please provide the error message”, “I need more context”).
- The reply is **generic or non-actionable** (e.g. only high-level steps, no concrete fix for this project).
- Cursor **knows it sent too little context** (e.g. vague first message) and has more in scope (open file, error text, stack, env).

**What Cursor must do**

1. **Use `chat_perplexity` with a stable `chat_id`**  
   - First call: omit `chat_id` (or generate one); the tool returns `chat_id` in the JSON response.  
   - **Store that `chat_id`** for the rest of the “session” (this Perplexity sub-task).

2. **After each Perplexity response, decide**  
   - **Satisfactory?** (concrete, actionable, answers the human’s goal) → Stop; use the answer and present to the human.  
   - **Needs more info?** (Perplexity asked for clarification, or answer is too generic) → Continue to step 3.  
   - **Can’t satisfy** (no more context to add, or already at max turns) → Stop; surface what we have and, if useful, “Perplexity asked for X; add that and try again.”

3. **If continuing**  
   - **Gather context** from the conversation and the environment: open file, error message, stack, OS, tool versions, relevant snippet.  
   - **Build one follow-up message** that supplies what Perplexity asked for (or what would make the answer concrete).  
   - Call **`chat_perplexity` again with the same `chat_id`** and this message.  
   - **Parse the new response** and repeat from step 2.

4. **Limits**  
   - **Max turns**: Cap at **3–4** Perplexity calls per “task” (e.g. one human question). After that, stop and present the best answer or clearly say what’s still missing.  
   - **No loop on same message**: If Cursor would send the same or nearly identical message again, stop and surface to the human instead.

**Stopping and surfacing**

- When the answer is **satisfactory**: Return it to the user as the result of “asking Perplexity.”  
- When **max turns** or **no progress**: Summarise what was asked, what Perplexity said, and what’s still needed (e.g. “Perplexity needs the exact error text; paste it and I’ll ask again”).

**Example flow**

1. Human: “How do I fix this?”  
2. Cursor calls `chat_perplexity`: “What is the best way to fix this? I need clear steps.” → Gets `chat_id` + reply asking for details.  
3. Cursor sees “need more info”, gathers error text + file from context.  
4. Cursor calls `chat_perplexity` with **same `chat_id`**: “Context: [error message], [file/stack]. Please give concrete steps to fix.”  
5. Perplexity returns a concrete fix. Cursor deems it satisfactory and shows it to the human.

---

## 1. Query Design (What to Send)

### Be Specific and Contextual

- **Do**: Add 2–3 extra words of context; it sharply improves retrieval.
- **Do**: Prefer **natural, conversational questions**, not keyword salad.
- **Do**: Include **intent** (e.g. "compare", "design a plan", "step-by-step") so the model can pick the right search and reasoning pattern.
- **Good**: "Explain recent advances in climate prediction models for urban planning"
- **Bad**: "Tell me about climate models"

### One Goal Per Call (Allow Related Sub-Questions)

- **Do**: Focus each call on a **single clear outcome** (answer, design, plan).
- **Do**: You **may** include closely related sub-questions if they serve the same goal (e.g. "Summarise this RFC and propose a migration plan").
- **Avoid**: Multiple unrelated topics in one call ("Explain X, and also Y, and give me Z").

### Think Like a Web Search

- Use **search-friendly terms** that would appear on relevant pages.
- **Prefer descriptive, natural-language queries** over raw Boolean (AND/OR) operator strings.
- **Good**: "Compare energy efficiency ratings of heat pumps vs traditional HVAC for residential use"
- **Bad**: "Tell me which home heating is better"

### Be Explicit About What You Need

- **Avoid**: "Tell me about the latest developments."
- **Good**: "What are the latest developments in offshore wind technology announced in the past 6 months?"

### When to Use Search vs No-Search

- **Search (default)**: News, pricing, research, factual checks, docs, APIs. Perplexity is **web-native**; use retrieval unless you have a clear reason not to.
- **No-search**: Add "Answer without searching the web" only when you truly want **pure model-only reasoning** (e.g. math, coding logic, style).

### Source and Scope (When Relevant)

- Specify **source constraints** when it matters (e.g. "use only official docs", "prefer academic sources").
- For MCP + Cursor: clarify when the answer should come from **existing context / project files** vs **web** vs both.

---

## 2. Output and Format (How to Ask for Answers)

### Request Structure Up Front

- Start with **one sentence on retrieval** (or scope), then **one on output format**.
- **Example**: "Search recent primary sources (past 90 days, official pages first). Then give the top 6 findings as a numbered brief with one-sentence takeaways."
- **Example**: "Return: 1) brief answer, 2) risks, 3) implementation steps as a checklist."

### Ask for Structure When Useful

- Request **tables** (e.g. "2-column: claim | citation"), **numbered lists**, **checklists**, or **Summary → Evidence → Analysis**.

### URLs and Citations

- **Do not** paste huge raw URL dumps or ask the model to "click links". Use **MCP tools** (e.g. extract_url_content) when you need to analyse specific pages.
- **Do** encourage **citations and verifiability**: e.g. "Show which sources you relied on" or "Provide citations for non-trivial factual claims and keep them visible in the output."
- The generative model does not see URLs; real source URLs come from API/search metadata or MCP tool results—not from asking "include a link" in the prompt.

### Recency and Scope in Natural Language

- Use **natural-language** hints: "past 90 days", "since 2024", "latest updates", "for US regulations", "official documentation only"—rather than assuming classic search operators only.

---

## 3. Reliability and Hallucination Prevention

### Set Clear Boundaries

- **Do**: "If you cannot find reliable sources, say so explicitly."
- **Do**: "Only provide information you can verify from search results; state if details are not available."
- **Do**: Explicitly **allow the model to decline or ask for clarification** when inputs are ambiguous or unsafe.

### Prefer Public, Indexable Sources

- **Prefer**: News, official docs, public reports.
- **Avoid** relying on: LinkedIn, private docs, paywalled or non-indexed content for factual claims.

### Use Conditional Language

- **Do**: "If available, provide… Otherwise, indicate what could not be found."

### Few-Shot in Queries

- **Avoid** long, noisy or mixed-pattern few-shot blocks—they confuse retrieval and waste context.
- **Lightweight** examples for **style or schema** (e.g. one or two JSON examples) are acceptable when they don’t trigger irrelevant searches.

### Data and Action Safety (MCP / Enterprise)

- For MCP tools that **perform actions** (file edits, tickets, deployments): require **natural-language confirmation** ("show the plan, then wait for my approval before executing").
- Make clear what the agent **may not do** (e.g. "never modify production data without explicit confirmation").
- **Internal files and connectors**: in-scope for answering, but must not be used for unrelated questions or exfiltrated to other tools. Respect data boundaries (e.g. some data stays in local MCP only).

---

## 4. Search Operators (When Plain Text Is Sent)

If the MCP passes the query as a single text string, you can embed:

- **site:** e.g. `site:docs.python.org`
- **filetype:** e.g. `filetype:pdf`
- **intitle:** / **inurl:** for FAQs or methodology pages
- **Time / scope in natural language**: "past 90 days", "since 2024", "latest", "for EU"

**Do not** over-optimise for classic search syntax; Perplexity is tuned for **natural language** first.

---

## 5. Tool Choice (Perplexity MCP Capabilities)

Describe **capabilities** rather than hard-coding tool IDs (which may change):

| Capability | When to use |
|------------|-------------|
| **Web search** | Open-ended, up-to-date questions; comparisons; "how to"; news. |
| **Documentation lookup** | Known stack, SDK, or framework; official docs. |
| **URL / file content** | Specific artifact is source of truth (spec, RFC, PRD, code file). Use MCP extract/content tools. |
| **API discovery** | Finding services, endpoints, or libraries. |
| **Deprecation / legacy check** | Checking if code or dependency is deprecated. |
| **Internal knowledge / file connectors** | When in Enterprise or project context; use as first-class sources when available. |

**Decision flow**: Prefer **documentation** when inside a known stack; prefer **web search** for broad or current questions; use **URL/content** tools when a specific page or file is the source of truth.

---

## 6. Role and Context for This Project

When queries affect **this project** (Perplexity MCP, Cursor integration, Space registry, encoding, scripts):

- **Include role** when it helps**: e.g. "You are advising as a senior engineer on a Cursor + Perplexity MCP integration. [specific question]."
- **Include stack/context**: e.g. "We use Bun, Puppeteer, PowerShell, and a browser-based MCP (no API key)."
- **Project-level objectives**: e.g. "This space is for refactoring the MCP server safely."
- **Allowed tools and risk**: Clarify read-only vs write/side-effects; require confirmation for destructive or production actions.
- **Data boundaries**: What internal data is okay to use; what must never be sent to external APIs.
- **Encourage the agent** to surface uncertainty and ask follow-ups for complex research or agent workflows.

Consider a short **system-style block** for Perplexity MCP sessions: project description, stack, main services, environments, and tool-safety rules.

---

## 7. Citations, Deep Research, and Spaces

### Citations and Transparency

- Ask the model to **provide citations for non-trivial factual claims** and keep them visible in the output.

### Deep Research vs Quick Answers

- For **complex, multi-step research** or large design docs: use a "deep research" style (one focused, multi-part goal per call).
- For **quick, interactive** help: keep prompts short and allow follow-ups.

### Spaces / Project Memory

- For ongoing Cursor + MCP work that mirrors **Perplexity Spaces**: prefer reusing the **same Space/thread** so context accumulates, instead of re-explaining every time.

---

## 8. API and Safety (When Using Perplexity Programmatically)

- **Credits / quota**: Do not assume infinite API quota; batch or summarise when appropriate.
- **Security and privacy**: Align with Perplexity’s security posture; avoid leaking internal content to arbitrary external APIs; respect organisation connectors and permission boundaries.

---

## 9. Checklist Before Calling Perplexity MCP

- [ ] Query is **specific** and **conversational** (intent clear).
- [ ] **One goal** per call (related sub-questions OK).
- [ ] **No** "include links/URLs" in the prompt; use MCP tools for URL content; ask for **citations** instead.
- [ ] **Explicit** instruction to say "no reliable sources" when appropriate.
- [ ] **Right capability** chosen (web search vs docs vs URL extract vs deprecation vs internal).
- [ ] **Knowledge sources in scope** specified when relevant (project files, internal, web).
- [ ] **Answerable from existing context?** If yes, avoid redundant web search.
- [ ] **Side effects?** If the tool can change state, is there an explicit confirmation step?
- [ ] **Confidential data**: Verify the question does not require data that must not leave a given boundary.
- [ ] For this repo: **role/context** and **data boundaries** included when relevant.
- [ ] For **dangerous actions**: Am I asking for a **draft plan first** before running them?
- [ ] **Multi-turn**: If I might send a vague or minimal first query, am I prepared to **reuse `chat_id`** and send a follow-up with more context when Perplexity asks for it (up to 3–4 turns)?

---

**Sources**: Perplexity Prompt Guide, Search Best Practices (docs.perplexity.ai); Perplexity Hub (Spaces, Deep Research, MCP, Enterprise); 2026 usage patterns; MCP client concepts (modelcontextprotocol.io); agentic IDE practices.

**Apply**: Every time you invoke a Perplexity MCP tool in this project.

---

### Maintenance (Rewrite vs Iterate)

- **Prefer iterating** on this rule unless it becomes long, inconsistent, or the architecture changes (e.g. from human-first chat to strict agent-only orchestration). Existing project-specific constraints (stack, tool quirks, workflows) are easy to lose in a full rewrite.
- If the document grows unwieldy, do a **skeleton refactor**: define a short structure (identity, goals, tool policy, reliability, formatting), then migrate only the rules that still matter and drop the rest.
- **From-scratch rewrite** is worth it only if the doc is an inconsistent dump or the interaction model has fundamentally changed.
