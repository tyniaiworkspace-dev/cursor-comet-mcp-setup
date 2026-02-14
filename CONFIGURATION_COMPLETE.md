# ✅ Perplexity MCP Server - Setup Complete!

## 🎉 Installation Successful

Your Perplexity MCP server is fully installed and tested successfully!

### What Was Done:
1. ✅ Installed **Bun runtime** (v1.3.9)
2. ✅ Cloned **perplexity-mcp-zerver** from GitHub
3. ✅ Installed all dependencies
4. ✅ Built the project successfully
5. ✅ Logged in to your **Perplexity Pro account**
6. ✅ Tested server startup - all tools initialized correctly

### Installation Paths:
- **MCP Server**: `c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver\build\main.js`
- **Browser Profile**: `C:\Users\admin\.perplexity-mcp`
- **Bun Runtime**: `C:\Users\admin\.bun\bin\bun.exe`

---

## 🔧 Final Step: Configure Cursor

### Option 1: Quick Copy-Paste Method (Recommended)

1. **Open Cursor Settings**:
   - Press `Ctrl + ,`
   - Click **Features** on the left
   - Find **Model Context Protocol (MCP)**
   - Click **Edit Config** button

2. **Copy and paste this configuration**:

```json
{
  "mcpServers": {
    "perplexity": {
      "command": "C:\\Users\\admin\\.bun\\bin\\bun.exe",
      "args": ["c:\\Users\\admin\\Perplexity mcp\\perplexity-mcp-zerver\\build\\main.js"],
      "env": {
        "PERPLEXITY_BROWSER_DATA_DIR": "C:\\Users\\admin\\.perplexity-mcp",
        "PERPLEXITY_PERSISTENT_PROFILE": "true"
      }
    }
  }
}
```

3. **Save and restart Cursor**:
   - Save the configuration file
   - Close Cursor completely
   - Reopen Cursor

### Option 2: Manual Configuration File

The configuration file is typically located at:
- Windows: `%APPDATA%\Cursor\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

Or you can access it through Cursor's settings UI.

---

## 🛠️ Available Tools

Once configured, you'll have access to these Perplexity-powered tools:

### 1. **search**
Perform research queries with web results
```
Example: "Search for the latest React 19 features"
```

### 2. **chat_perplexity**
Persistent conversations with context history
```
Example: "Start a conversation about quantum computing"
```

### 3. **get_documentation**
Retrieve technical documentation with examples
```
Example: "Get documentation for Python asyncio"
```

### 4. **find_apis**
Discover relevant APIs for development needs
```
Example: "Find APIs for weather data"
```

### 5. **check_deprecated_code**
Analyze code snippets for outdated patterns
```
Example: "Check if this React code uses deprecated patterns"
```

### 6. **extract_url_content**
Parse web content with automatic GitHub handling
```
Example: "Extract content from https://example.com/article"
```

---

## ✅ Verification

To verify the setup is working:

1. Restart Cursor
2. Open the MCP panel (if available in your Cursor version)
3. You should see "perplexity" listed as an available MCP server
4. Try asking Cursor to search for something using Perplexity

---

## 🔄 Maintenance

### Re-login to Perplexity (if session expires):
```powershell
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
bun run login
```

### Update the server:
```powershell
cd "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver"
git pull
bun install
bun run build
```

### Check if server is running:
Look for `bun.exe` processes in Task Manager when Cursor is open.

---

## 🐛 Troubleshooting

### Server Not Showing in Cursor
- Make sure you restarted Cursor completely
- Check the configuration file syntax (valid JSON)
- Verify the paths in the configuration are correct

### Login Session Expired
- Run `bun run login` again from the server directory
- Log in through the browser window that opens

### Browser Automation Issues
- Make sure no other automation is running
- Check that the profile directory has write permissions
- Try running in anonymous mode by setting `PERPLEXITY_PERSISTENT_PROFILE` to `false`

---

## 📚 Additional Resources

- **GitHub Repository**: https://github.com/wysh3/perplexity-mcp-zerver
- **MCP Documentation**: https://modelcontextprotocol.io
- **Perplexity**: https://www.perplexity.ai

---

## 🎊 You're All Set!

Your Perplexity MCP server is ready to use with your Pro account.
Just add the configuration to Cursor and restart!

**Note**: The server uses browser automation, so you'll see brief browser activity when making requests. This is normal and expected.
