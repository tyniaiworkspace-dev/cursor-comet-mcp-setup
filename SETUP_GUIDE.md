# Perplexity MCP Server Setup Guide ✅ COMPLETED

## Overview
This MCP server uses **browser automation** (Puppeteer) to access Perplexity AI without API keys.
You're using it with your **Perplexity Pro account** for access to better models!

## ✅ Installation Complete

### What Was Installed:
1. ✅ **Bun Runtime** - JavaScript/TypeScript runtime
2. ✅ **perplexity-mcp-zerver** - Cloned from GitHub
3. ✅ **Dependencies** - All packages installed
4. ✅ **Build** - Project compiled successfully
5. ✅ **Login Session** - Your Perplexity Pro account authenticated

### Installation Location:
- **MCP Server**: `c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver`
- **Browser Profile**: `C:\Users\admin\.perplexity-mcp`

## 🔧 Cursor Configuration

To use this MCP server in Cursor:

### Step 1: Open Cursor Settings
1. Press `Ctrl + ,` to open Settings
2. Go to **Features** → **Model Context Protocol (MCP)**
3. Click **Edit Config** or manually add the configuration

### Step 2: Add This Configuration

```json
{
  "mcpServers": {
    "perplexity": {
      "command": "bun",
      "args": ["c:\\Users\\admin\\Perplexity mcp\\perplexity-mcp-zerver\\build\\main.js"],
      "env": {
        "PERPLEXITY_BROWSER_DATA_DIR": "C:\\Users\\admin\\.perplexity-mcp",
        "PERPLEXITY_PERSISTENT_PROFILE": "true"
      }
    }
  }
}
```

### Step 3: Restart Cursor
Close and reopen Cursor completely for the MCP server to load.

## Available Tools

Once configured, you'll have access to three Perplexity tools:

### 1. `perplexity_search`
Quick web search using Perplexity's turbo model.

**Best for:** Quick questions, everyday searches, conversational queries

**Parameters:**
- `query` (required): The search query or question
- `sources` (optional): Array of sources - `"web"`, `"scholar"`, `"social"`. Default: `["web"]`
- `language` (optional): Language code, e.g., `"en-US"`. Default: `"en-US"`

### 2. `perplexity_research`
Deep, comprehensive research using Perplexity's sonar-deep-research model.

**Best for:** Complex topics requiring detailed investigation, comprehensive reports, in-depth analysis with citations

**Parameters:** Same as `perplexity_search`

### 3. `perplexity_reason`
Advanced reasoning and problem-solving using Perplexity's sonar-reasoning-pro model.

**Best for:** Logical problems, complex analysis, decision-making, step-by-step reasoning

**Parameters:** Same as `perplexity_search`

## Response Format

All tools return JSON with:
```json
{
  "answer": "The generated answer text...",
  "chunks": [
    // Citation/source chunks from Perplexity
  ],
  "follow_up": {
    "backend_uuid": "uuid-for-follow-up-queries",
    "attachments": []
  }
}
```

## Testing the Setup

You can test the MCP server manually before using it in Cursor:

```bash
# Windows PowerShell
$env:SESSION_TOKEN="your-session-token"
$env:CSRF_TOKEN="your-csrf-token"
perlexity-web-mcp
```

Or use the MCP Inspector:
```bash
npx @modelcontextprotocol/inspector
```

## Troubleshooting

### Tokens Not Working
- Make sure you're logged into Perplexity.ai
- Tokens may expire - re-extract them from the browser if needed
- Check that there are no extra spaces when copying the token values

### Server Not Found
- Verify the installation: `npm list -g perlexity-web-mcp`
- Try reinstalling: `npm uninstall -g perlexity-web-mcp && npm install -g perlexity-web-mcp`

### Cursor Not Recognizing the Server
- Check the configuration file syntax (valid JSON)
- Restart Cursor completely
- Check Cursor logs for any error messages

## Security Notes

⚠️ **Important:** 
- Keep your SESSION_TOKEN and CSRF_TOKEN private
- Don't commit these tokens to version control
- These tokens provide access to your Perplexity account
- Consider using environment variables instead of hardcoding in config files

## License
MIT

## More Information
- GitHub: https://github.com/mishamyrt/perplexity-web-api-mcp
- LobeHub Page: https://lobehub.com/nl/mcp/mishamyrt-perplexity-web-api-mcp
