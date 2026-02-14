# MCP and Space Creation Isolation

**Do not run** these scripts unless the user explicitly requests to create a Perplexity Space and understands the risks:

- `space-registry/New-PerplexitySpace.ps1`
- `space-registry/create-space.ts`
- `space-registry/Configure-ProjectMCP.ps1`
- `install-context-with-space.ps1` (when it would trigger Space creation)

**Reason:** These spawn separate Puppeteer/browser processes or write project-local MCP config that can conflict with the global perplexity-server MCP. Cursor must use only the MCP server defined in `C:\Users\admin\.cursor\mcp.json`.

**If the user asks to create a Space:** Warn that it may conflict with MCP; suggest using the existing Space URL in mcp.json or creating manually on Perplexity.ai.
