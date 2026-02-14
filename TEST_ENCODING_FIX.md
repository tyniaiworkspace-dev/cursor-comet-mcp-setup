# Test Encoding Fix

## What Was Changed

Updated `C:\Users\admin\.cursor\mcp.json` with UTF-8 encoding environment variables:

```json
"env": {
  ...existing vars...,
  "LANG": "en_US.UTF-8",
  "LC_ALL": "en_US.UTF-8",
  "NODE_OPTIONS": "--input-type=module"
}
```

## Testing Instructions

### Test 1: Simple Query

**In Cursor, ask**:
```
Use Perplexity to search: "test simple query 2026"
```

**Expected**: Perplexity returns results about "test simple query 2026"  
**If scrambled**: Fix didn't work, try Fix #1

### Test 2: Complex Query

**In Cursor, ask**:
```
Use Perplexity to search: "PowerShell heredoc formatting best practices Microsoft"
```

**Expected**: Relevant PowerShell documentation  
**If scrambled**: Fix didn't work

### Test 3: Special Characters

**In Cursor, ask**:
```
Use Perplexity to search: "UTF-8 encoding issues 2026"
```

**Expected**: Results about UTF-8 encoding  
**If scrambled or special chars broken**: Encoding still problematic

## If Tests Fail

Try Fix #1 (modify server code):

1. Edit `c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver\src\main.ts`
2. Add at top of file:
```typescript
// Force UTF-8 encoding
process.stdout.setDefaultEncoding('utf-8');
if (process.stdin.setEncoding) {
  process.stdin.setEncoding('utf-8');
}
```
3. Rebuild:
```powershell
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
bun run build
```
4. Restart Cursor
5. Test again

## If Still Broken

File issue with MCP server maintainer:
- GitHub: https://github.com/wysh3/perplexity-mcp-zerver/issues
- Include: Scrambled query examples, your OS, Bun version

## Status

- [x] Fix applied to mcp.json
- [x] Bun process killed (will restart)
- [ ] Test 1: Simple query
- [ ] Test 2: Complex query  
- [ ] Test 3: Special characters
- [ ] Confirmed working OR needs Fix #1

---

**Next**: Restart Cursor and test!
