# 🔍 How to Verify Perplexity MCP is Actually Being Used

## Quick Verification Methods

### Method 1: Check if MCP Server Process is Running ⭐ EASIEST

After restarting Cursor, run this PowerShell script:
```powershell
cd "c:\Users\admin\Perplexity mcp"
.\check-mcp-running.ps1
```

Or manually check in Task Manager:
1. Open Task Manager (Ctrl + Shift + Esc)
2. Go to "Details" tab
3. Look for `bun.exe` process
4. If it's running → MCP server is active ✅

### Method 2: Watch for Browser Automation Activity

The Perplexity MCP uses **Puppeteer** (browser automation), so when it's working you should see:
- Brief Chromium browser activity in the background
- A `chrome.exe` or `chromium.exe` process may appear momentarily
- This happens when you make a query

**This is the BIGGEST indicator** - Cursor's built-in AI won't launch any browsers!

### Method 3: Check Cursor's MCP Panel

In Cursor:
1. Open Command Palette (`Ctrl + Shift + P`)
2. Type: "MCP"
3. Look for MCP-related commands or panels
4. You should see "perplexity" listed as an available server

### Method 4: Look at Chat History Database

When Perplexity MCP is used, it creates a SQLite database:
```
c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver\build\chat_history.db
```

Check if this file exists and grows in size when you use the chat_perplexity tool.

### Method 5: Explicit Tool Usage Request

Try asking specifically:
```
"Use the Perplexity MCP search tool to find the latest Python 3.13 features"
```

or

```
"Call the perplexity search tool to look up information about quantum computing"
```

If the MCP is working, you should see tool usage indicators in Cursor.

### Method 6: Check for Real-Time Web Data

Ask questions that require **real-time information** that only web search would know:

**Test Query Examples:**
```
"Use Perplexity to find what's the current price of Bitcoin"
"Search Perplexity for today's top tech news"
"Use the search tool to find the latest version of React released this week"
```

Cursor's built-in AI has a knowledge cutoff and won't have real-time data, but Perplexity will!

### Method 7: Look for Perplexity-Specific Response Format

Perplexity responses often include:
- Citations and sources
- Recent/current information
- "According to [source]..." type phrasing
- Real-time data that post-dates Cursor's training cutoff

### Method 8: Check Cursor Output/Debug Logs

In Cursor:
1. Go to: **View** → **Output**
2. Look for MCP-related logs
3. You should see connection messages, tool calls, etc.

---

## 🧪 Definitive Test After Restart

Once you've restarted Cursor, try this test:

1. **First, run the process check:**
   ```powershell
   .\check-mcp-running.ps1
   ```

2. **Then ask me explicitly:**
   ```
   "Use the Perplexity search tool to find information about today's date and current events"
   ```

3. **Watch for:**
   - ✅ Bun process running (from script)
   - ✅ Brief browser/chromium activity
   - ✅ Real-time information in response
   - ✅ Tool usage indicator in Cursor

---

## 🚨 Signs MCP is NOT Working

If you see these, the MCP isn't active:
- ❌ No `bun.exe` process in Task Manager
- ❌ No browser activity when you ask questions
- ❌ Responses don't have real-time/current information
- ❌ No tool usage indicators in Cursor
- ❌ I respond with "I don't have access to..." for web searches

---

## 🔧 If MCP Isn't Working

1. **Verify configuration:**
   ```powershell
   Get-Content "C:\Users\admin\AppData\Roaming\Cursor\User\settings.json"
   ```

2. **Make sure you restarted Cursor COMPLETELY**
   - Close all windows
   - Check Task Manager that Cursor.exe isn't running
   - Reopen Cursor

3. **Check for errors:**
   - View → Output → Look for MCP errors
   - Check if paths in settings.json are correct

4. **Manual test the server:**
   ```powershell
   cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
   $env:PERPLEXITY_BROWSER_DATA_DIR="C:\Users\admin\.perplexity-mcp"
   $env:PERPLEXITY_PERSISTENT_PROFILE="true"
   bun build/main.js
   ```
   (Press Ctrl+C to stop)

---

## 📊 Quick Visual Checklist

Before asking questions:
- [ ] Cursor has been restarted after configuration
- [ ] Run `.\check-mcp-running.ps1` → Shows bun.exe running
- [ ] Task Manager shows `bun.exe` process

When asking questions:
- [ ] Explicitly mention "Use Perplexity" or "search tool"
- [ ] Watch for brief browser activity
- [ ] Check if response has real-time information
- [ ] Look for tool usage indicators in Cursor

---

## 🎯 Best Test Query

The ultimate test query after restart:
```
"Please use the Perplexity search tool to find the current date, 
time, and today's top trending topic on the internet."
```

This requires:
1. Real-time web access ✅
2. Current information ✅
3. Explicit tool usage ✅

If you get accurate real-time info → **Perplexity MCP is working!** 🎉

If I say "I can't access the internet" → **MCP isn't active yet** ❌

---

**Created**: 2026-02-09
**Purpose**: Verification guide for Perplexity MCP integration
