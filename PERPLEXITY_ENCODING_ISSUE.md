# 🐛 Perplexity MCP Encoding Issue - CRITICAL

## Problem Identified

**Your query**:
```
"PowerShell scripting best practices guide 2026 heredoc formatting rules style guide Microsoft official"
```

**What Perplexity received**:
```
"rPgoawneirzSahteiloln slcarziyp tlionagd ibnegs td opcruamcetnitcaetsi ognu itdrei g2g0e2r6..."
```

**Result**: Completely scrambled/garbled text causing Perplexity to think it's a cipher puzzle!

---

## Root Cause (from Perplexity Research)

### Most Likely Issues:

1. **Mixed Encodings**
   - Cursor sends UTF-8
   - MCP server interprets as Windows-1252 (or vice versa)
   - Characters get corrupted during transmission

2. **Double Encoding/Decoding**
   - Text decoded as UTF-8, then re-decoded
   - Causes character scrambling

3. **Missing Charset Declaration**
   - HTTP responses lack `charset=utf-8`
   - Client guesses wrong encoding

4. **Bun Runtime Issues**
   - Default encoding might not be UTF-8
   - Buffer handling problems

---

## Impact

❌ **All Perplexity searches are broken**  
❌ **Wasted API calls** (returning garbage)  
❌ **No useful research results**  
❌ **System appears to work but returns nonsense**

---

## Diagnosis Steps

### Test 1: Simple Query

Try this in Cursor:
```
"test simple query"
```

If scrambled, issue is in MCP server or transmission layer.

### Test 2: Check MCP Server Logs

```powershell
# Check if Bun process is running
Get-Process -Name bun -ErrorAction SilentlyContinue

# Check MCP server output
# (Logs should be in C:\Users\admin\.perplexity-mcp or terminal output)
```

### Test 3: Restart MCP Server

```powershell
# Kill existing process
Stop-Process -Name bun -Force -ErrorAction SilentlyContinue

# Cursor will restart it automatically when you use it next
```

---

## Potential Fixes

### Fix 1: Ensure UTF-8 in MCP Server

**In `perplexity-mcp-zerver` source**:

Add to main server file:
```typescript
// Force UTF-8 encoding
process.env.NODE_OPTIONS = '--input-type=module --experimental-modules';
process.stdout.setDefaultEncoding('utf-8');
process.stdin.setEncoding('utf-8');
```

### Fix 2: Update Bun Configuration

**In mcp.json**:
```json
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
        "PERPLEXITY_SPACE_URL": "https://www.perplexity.ai/spaces/cursor-97IktFHMQnKgUtdVm2ofyw",
        "NODE_OPTIONS": "--input-type=module",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8"
      }
    }
  }
}
```

### Fix 3: Rebuild MCP Server with Encoding Fix

```powershell
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
bun install
bun run build
```

### Fix 4: Check Cursor Settings

**In Cursor settings**, ensure:
- File encoding: UTF-8
- No BOM (Byte Order Mark)
- Consistent line endings

---

## Immediate Workaround

While debugging, you can:

1. **Use Perplexity directly** in browser for research
2. **Document findings** manually
3. **Skip MCP** for now until fixed

---

## Testing After Fix

### Test Query:
```
"Simple test query 2026"
```

**Expected**: Perplexity returns relevant results about "test query 2026"  
**If working**: Query is transmitted correctly  
**If scrambled**: Issue persists, needs deeper investigation

### Complex Test:
```
"PowerShell heredoc formatting rules Microsoft official documentation"
```

**Expected**: Relevant PowerShell docs  
**If working**: Full encoding chain is correct

---

## Known Working vs Broken

### Working:
- ✅ Cursor IDE text display
- ✅ File editing
- ✅ Git operations
- ✅ Terminal commands

### Broken:
- ❌ Perplexity MCP queries
- ❌ Text transmission to MCP server
- ❌ Possibly other MCP integrations?

---

## Next Steps

### Immediate:
1. ✅ Document issue (this file)
2. ⏳ Test simple query to confirm
3. ⏳ Try Fix 2 (update mcp.json)
4. ⏳ Restart Cursor
5. ⏳ Test again

### If Fix 2 Works:
1. ✅ Update GitHub repo
2. ✅ Document in README
3. ✅ Add to troubleshooting guide

### If Fix 2 Doesn't Work:
1. ⏳ Try Fix 1 (modify server code)
2. ⏳ Rebuild server
3. ⏳ Contact MCP server maintainer
4. ⏳ File GitHub issue

---

## References

**Perplexity Research**:
- Encoding issues in MCP servers
- UTF-8 vs Windows-1252 conflicts
- Double encoding/decoding problems

**Related Links**:
- [Perplexity MCP Server](https://github.com/wysh3/perplexity-mcp-zerver)
- [Bun Encoding Docs](https://bun.sh/)
- [MCP Protocol Spec](https://modelcontextprotocol.io)

---

## Status

**Issue**: CONFIRMED ❌  
**Severity**: HIGH (blocks all Perplexity functionality)  
**Priority**: Fix immediately  
**Workaround**: Use Perplexity web directly

---

## Update Log

**2026-02-09 01:55 UTC**:
- Issue discovered by user
- Confirmed scrambled queries
- Researched root causes
- Documented fixes
- Status: Awaiting testing

---

**This is a critical issue that needs immediate attention!** 🔴

The good news: Perplexity identified the likely causes and we have multiple potential fixes to try.

**Next**: Test Fix 2 (simplest) first.
