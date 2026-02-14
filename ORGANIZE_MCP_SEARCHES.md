# 🗂️ Organizing Cursor MCP Searches in Perplexity

## Research Summary

**Good News:** Perplexity has **Spaces** and **Collections** features to organize searches!

**Challenge:** The perplexity-mcp-zerver currently doesn't have built-in support for Spaces, but we can add it.

---

## Understanding Perplexity's Organization Features

### 🏢 **Spaces**
- Separate workspaces for different projects/topics
- Each Space has its own:
  - Custom AI instructions
  - Search settings
  - File storage
  - Thread history
- **Perfect for:** Keeping MCP searches separate from personal searches

### 📁 **Collections**
- Folders within Spaces to group related threads
- Organize by subtopics
- Search within specific Collections
- **Perfect for:** Further organizing searches by type (documentation, APIs, news, etc.)

---

## 🎯 Solution Options

### Option 1: Manual Space Creation (Easiest - No Code Changes)

**Setup Steps:**

1. **Create a Dedicated Space:**
   - Go to https://www.perplexity.ai
   - Click "Create Space" or "Spaces" in sidebar
   - Name it: "Cursor MCP Searches" (or whatever you prefer)
   - Add custom instructions (optional):
     ```
     This Space is used for automated searches from my development environment.
     Provide technical, detailed answers with code examples when relevant.
     ```

2. **Get the Space URL:**
   - Click the Share button on your Space
   - Copy the Space URL (e.g., `https://www.perplexity.ai/spaces/abc123xyz`)

3. **Configure MCP Server:**
   - The searches will still appear in your main history, but you can:
     - Manually move them to the Space after they're created
     - Or manually perform searches in the Space when needed

**Pros:**
- ✅ No code changes needed
- ✅ Works immediately
- ✅ Easy to set up

**Cons:**
- ❌ Searches still appear in main history first
- ❌ Manual organization required

---

### Option 2: Modify MCP Server to Use a Space (Recommended)

**This option modifies the server to automatically navigate to your Space before each search.**

**Implementation:**

1. **First, create your Space** (see Option 1, steps 1-2)

2. **Add Space URL configuration:**

```json
// Update: C:\Users\admin\.cursor\mcp.json
{
  "mcpServers": {
    "perplexity": {
      "command": "C:\\Users\\admin\\.bun\\bin\\bun.exe",
      "args": [
        "c:\\Users\\admin\\Perplexity mcp\\perplexity-mcp-zerver\\build\\main.js"
      ],
      "env": {
        "PERPLEXITY_BROWSER_DATA_DIR": "C:\\Users\\admin\\.perplexity-mcp",
        "PERPLEXITY_PERSISTENT_PROFILE": "true",
        "PERPLEXITY_SPACE_URL": "https://www.perplexity.ai/spaces/YOUR-SPACE-ID"
      }
    }
  }
}
```

3. **Modify the server code:**

I can create a modified version that:
- Reads the `PERPLEXITY_SPACE_URL` environment variable
- Navigates to that Space URL instead of the main page
- All searches will be created within that Space

**Pros:**
- ✅ Automatic - all searches go to your designated Space
- ✅ Clean separation from personal searches
- ✅ Persistent organization

**Cons:**
- ❌ Requires code modification
- ❌ Need to rebuild after changes
- ❌ Updates to the server might overwrite changes

---

### Option 3: Create a Separate Browser Profile (Alternative)

**This uses a completely separate browser profile just for MCP.**

**Implementation:**

```json
// Update: C:\Users\admin\.cursor\mcp.json
{
  "mcpServers": {
    "perplexity": {
      "command": "C:\\Users\\admin\\.bun\\bin\\bun.exe",
      "args": [
        "c:\\Users\\admin\\Perplexity mcp\\perplexity-mcp-zerver\\build\\main.js"
      ],
      "env": {
        "PERPLEXITY_BROWSER_DATA_DIR": "C:\\Users\\admin\\.perplexity-mcp-cursor-only",
        "PERPLEXITY_PERSISTENT_PROFILE": "true"
      }
    }
  }
}
```

**Then re-login:**
```powershell
$env:PERPLEXITY_BROWSER_DATA_DIR="C:\Users\admin\.perplexity-mcp-cursor-only"
$env:PERPLEXITY_PERSISTENT_PROFILE="true"
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
bun run login
```

**Pros:**
- ✅ Complete isolation - different account or session
- ✅ No code changes needed
- ✅ Can use a separate Perplexity account if you have one

**Cons:**
- ❌ Searches still mixed in that profile's history
- ❌ Need to maintain separate login
- ❌ Can't share Pro features across profiles easily

---

## 🚀 Recommended Approach

**Best Solution: Option 2 (Modified Server with Space Support)**

This gives you:
- ✅ Automatic organization
- ✅ Clean separation
- ✅ All MCP searches in one dedicated Space
- ✅ Easy to review MCP search history
- ✅ Can create Collections within the Space for different search types

---

## 📝 Implementation Plan for Option 2

### Step 1: Create Your Space

1. Go to https://www.perplexity.ai
2. Create a new Space called "Cursor MCP"
3. Copy the Space URL from the Share button
4. (Optional) Create Collections like:
   - "Documentation Searches"
   - "API Discovery"
   - "Code Analysis"
   - "News & Updates"

### Step 2: Modify the Server

I can create the code modifications for you:

**Files to modify:**
1. `src/server/config.ts` - Add Space URL config
2. `src/server/modules/BrowserManager.ts` - Modify navigation logic
3. Rebuild the server

**Changes needed:**

```typescript
// config.ts - Add this
export const CONFIG = {
  // ... existing config ...
  SPACE_URL: process.env["PERPLEXITY_SPACE_URL"] || null,
} as const;
```

```typescript
// BrowserManager.ts - Modify navigateToPerplexity()
async navigateToPerplexity(): Promise<void> {
  const url = CONFIG.SPACE_URL || "https://www.perplexity.ai";
  logInfo(`Navigating to: ${url}`);
  await page.goto(url, {
    waitUntil: "domcontentloaded",
    timeout: CONFIG.TIMEOUT_PROFILES.navigation,
  });
}
```

### Step 3: Update Configuration

Add the Space URL to your MCP config (shown above in Option 2)

### Step 4: Rebuild and Restart

```powershell
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
bun run build
```

Then restart Cursor.

---

## 🎯 What You'll Get

After implementation:

✅ **In Perplexity Web:**
- Go to your "Cursor MCP" Space
- All automated searches appear there
- Organized in Collections if you set them up
- Clean main history without automated searches

✅ **In Cursor:**
- Everything works exactly the same
- No visible changes to your workflow
- Searches happen automatically in your Space

---

## 🤔 Which Option Should You Choose?

| Scenario | Best Option |
|----------|-------------|
| Quick fix, don't want to modify code | Option 1 (Manual) |
| Want automatic organization, willing to modify | Option 2 (Modified Server) ⭐ |
| Want complete isolation | Option 3 (Separate Profile) |
| Don't mind manual organization | Option 1 (Manual) |
| Heavy MCP usage | Option 2 (Modified Server) ⭐ |

---

## 📊 Current Status

- ✅ Perplexity supports Spaces and Collections
- ✅ Your Pro account is logged in
- ✅ MCP server is working perfectly
- ⚠️ Current setup: All searches go to main Perplexity history
- 🎯 Next step: Choose your preferred option

---

## 🛠️ Want Me to Implement Option 2?

I can:
1. ✅ Modify the server code to support Space URLs
2. ✅ Rebuild the server
3. ✅ Update your configuration
4. ✅ Test it works with your Space

**Just say: "Implement Option 2" and provide your Space URL!**

Or if you prefer Option 1 or 3, let me know and I'll guide you through those instead.

---

**Created**: February 9, 2026
**Status**: Research complete, ready to implement
**Recommendation**: Option 2 for best automatic organization
