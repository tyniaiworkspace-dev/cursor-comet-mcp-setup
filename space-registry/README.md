# Perplexity Space Registry

> **Fully Automated Space Management** - Each project gets its own organized Perplexity Space

---

## 🎯 What This Does

Automatically creates and manages **project-specific Perplexity Spaces** so each project has its own dedicated knowledge base, keeping research organized and separate.

### Before (Manual)
- All searches go to general history
- Research mixed across projects
- Hard to find project-specific info
- Manual Space management

### After (Automated)
- ✅ Each project → Dedicated Space
- ✅ Research auto-organized
- ✅ Easy to find project info
- ✅ Fully automated management

---

## 🚀 Quick Start

### Create New Project with Space

```powershell
# Navigate to project
cd "C:\MyNewProject"

# Install with auto Space creation
& "c:\Users\admin\Perplexity mcp\install-context-with-space.ps1" -Version Lean

# System automatically:
# 1. Installs context templates ✓
# 2. Creates Perplexity Space ✓
# 3. Registers in database ✓
# 4. Configures MCP ✓

# Done! All searches now go to project-specific Space
```

### Manage Spaces

```powershell
# View current project's Space
Get-ProjectSpace

# List all registered Spaces
Get-PerplexitySpaces

# Open Space in browser
Open-ProjectSpace

# Archive completed project
Set-ProjectSpace -Status archived

# Manual registration (if auto-creation fails)
Set-ProjectSpace -SpaceUrl "https://www.perplexity.ai/spaces/abc123..."
```

---

## 📊 How It Works

```
New Project Created
       │
       ▼
Template Installer
  (install-context-with-space.ps1)
       │
       ├─► Install Context Files
       │
       ├─► Check Registry
       │   (Does Space exist?)
       │   │
       │   ├─► Yes → Use existing
       │   └─► No  → Create new
       │            │
       │            ▼
       │         Launch Browser (Puppeteer)
       │         Create Space
       │         Extract URL
       │            │
       │            ▼
       │         Register in Database
       │         (registry.json)
       │            │
       │            ▼
       │         Configure Project MCP
       │         (.cursor/mcp-local.json)
       │
       └─► Done! ✓
```

---

## 📦 Components

### 1. **Registry Database** (registry.json)

Stores all project → Space mappings:

```json
{
  "version": "1.0",
  "projects": {
    "C:\\Projects\\MyApp": {
      "name": "MyApp",
      "spaceUrl": "https://www.perplexity.ai/spaces/myapp-abc123",
      "spaceName": "Project: MyApp",
      "createdAt": "2026-02-09T...",
      "status": "active"
    }
  }
}
```

**Location**: `c:\Users\admin\Perplexity mcp\space-registry\registry.json`

### 2. **Space Creator** (create-space.ts)

Puppeteer automation that:
- Launches browser with existing profile
- Navigates to Perplexity
- Clicks "New Space"
- Fills in name
- Extracts Space URL

### 3. **Registry Manager** (registry-manager.ps1)

PowerShell functions for:
- Registering Spaces
- Looking up Spaces
- Updating status
- Listing all Spaces

### 4. **MCP Configurator** (Configure-ProjectMCP.ps1)

Creates project-local MCP config:

```
ProjectRoot/
└── .cursor/
    ├── mcp-local.json          ← Project-specific (Space URL)
    ├── MCP_README.md            ← Documentation
    └── context/                 ← Context files
```

### 5. **CLI Commands** (Space-Commands.ps1)

User-friendly PowerShell commands:
- `Get-PerplexitySpaces`
- `Get-ProjectSpace`
- `Set-ProjectSpace`
- `Open-ProjectSpace`
- `Remove-ProjectSpace`

---

## 🔧 Installation

### Prerequisites

- ✅ Bun runtime (already installed)
- ✅ Perplexity MCP server (already set up)
- ✅ Perplexity Pro account (logged in)
- ✅ PowerShell 5.1+ (built into Windows)

### Setup

```powershell
# Navigate to workspace
cd "c:\Users\admin\Perplexity mcp\space-registry"

# Initialize registry
. .\registry-manager.ps1
Initialize-SpaceRegistry

# Import commands (optional - for manual use)
. .\Space-Commands.ps1
```

That's it! The system is ready to use.

---

## 💡 Usage Examples

### Example 1: New Project Auto-Setup

```powershell
cd "C:\Projects\NewApp"

& "c:\Users\admin\Perplexity mcp\install-context-with-space.ps1"

# Output:
# 🚀 Installing Cursor Context with Space Registry
# ✓ Context templates installed
# 📦 Creating Perplexity Space...
# ✓ Space created: https://www.perplexity.ai/spaces/newapp-xyz
# ✓ MCP configured
# ✅ Setup Complete!
```

### Example 2: Manual Space Registration

```powershell
# If auto-creation fails, manually create Space on Perplexity.ai
# Then register it:

Set-ProjectSpace -SpaceUrl "https://www.perplexity.ai/spaces/manual-abc123"

# Output:
# ✓ Space registered
# ✓ MCP configured
```

### Example 3: View All Projects

```powershell
Get-PerplexitySpaces

# Output:
# 📚 Registered Perplexity Spaces (3)
# 
# MyApp
#   Path: C:\Projects\MyApp
#   Space: https://www.perplexity.ai/spaces/myapp-abc
#   Status: active
# 
# OldProject
#   Path: C:\Projects\OldProject
#   Space: https://www.perplexity.ai/spaces/old-xyz
#   Status: archived
```

### Example 4: Archive Completed Project

```powershell
cd "C:\Projects\CompletedApp"
Set-ProjectSpace -Status archived

# Space stays registered but marked as archived
# Can reactivate later if needed
```

---

## 🔄 Workflow

### Daily Usage

```powershell
# 1. Work on project
cd "C:\MyProject"

# 2. Use Perplexity normally in Cursor
#    All searches automatically go to project's Space

# 3. View Space anytime
Get-ProjectSpace
Open-ProjectSpace
```

### Managing Multiple Projects

```powershell
# List all projects
Get-PerplexitySpaces

# Switch between projects
cd "C:\ProjectA"
Get-ProjectSpace  # Shows ProjectA's Space

cd "C:\ProjectB"
Get-ProjectSpace  # Shows ProjectB's Space
```

### Cleanup

```powershell
# Archive old projects
Set-ProjectSpace -ProjectPath "C:\OldProject" -Status archived

# Remove from registry (keeps Space on Perplexity)
Remove-ProjectSpace -ProjectPath "C:\OldProject"

# Delete local config too
Remove-ProjectSpace -ProjectPath "C:\OldProject" -DeleteLocal
```

---

## 🐛 Troubleshooting

### Space Creation Fails

**Problem**: Browser automation can't create Space

**Solutions**:
1. Make sure you're logged in to Perplexity.ai
2. Try creating Space manually
3. Use `Set-ProjectSpace` to register manual Space
4. Check if Perplexity UI changed (may need script update)

**Manual creation**:
```powershell
# 1. Go to Perplexity.ai
# 2. Create new Space
# 3. Copy Space URL
# 4. Register:
Set-ProjectSpace -SpaceUrl "https://www.perplexity.ai/spaces/your-space"
```

### Wrong Space Being Used

**Problem**: Searches go to wrong Space

**Solutions**:
```powershell
# Check current project Space
Get-ProjectSpace

# Check local MCP config
Get-Content ".cursor\mcp-local.json"

# Reconfigure if needed
$space = Get-ProjectSpace
& "$PSScriptRoot\space-registry\Configure-ProjectMCP.ps1" `
    -ProjectPath "." -SpaceUrl $space.spaceUrl
```

### Registry Corrupted

**Problem**: Registry database/JSON is corrupted

**Solution**:
```powershell
# Backup old registry
Copy-Item "registry.json" "registry.backup.json"

# Reinitialize
Initialize-SpaceRegistry

# Re-register projects manually
Set-ProjectSpace -SpaceUrl "https://..."
```

---

## 📁 File Structure

```
space-registry/
├── README.md                    # This file
├── SPACE_REGISTRY_DESIGN.md     # Technical design doc
│
├── schema.sql                   # SQLite schema (if using SQL)
├── registry.json                # JSON registry (default)
│
├── registry-manager.ps1         # Core registry functions
├── Space-Commands.ps1           # User CLI commands
│
├── create-space.ts              # Puppeteer automation
├── New-PerplexitySpace.ps1      # PowerShell wrapper
├── Configure-ProjectMCP.ps1     # MCP configurator
│
└── install-context-with-space.ps1  # Integrated installer
```

---

## ⚙️ Configuration

### Settings

Located in `registry.json`:

```json
{
  "settings": {
    "autoCreateSpaces": true,
    "defaultSpacePrefix": "Project: ",
    "browserTimeout": 30000,
    "maxRetryAttempts": 3
  }
}
```

### Customization

**Change Space name format**:
Edit `New-PerplexitySpace.ps1`, modify `$spaceName` variable

**Change browser behavior**:
Edit `create-space.ts`, modify `CONFIG` object

**Change registry location**:
Edit `registry-manager.ps1`, modify `$script:RegistryDB` variable

---

## 🔐 Security & Privacy

### Data Storage

- **Registry**: Local JSON file, user-only access
- **Spaces**: Private by default on Perplexity
- **Browser**: Uses existing profile, no new credentials

### What's Stored

- Project paths (local)
- Space URLs (public-ish, but random/long)
- Project names (you control)
- Timestamps (metadata)

### What's NOT Stored

- Perplexity credentials
- Search history
- API keys
- Personal data

---

## 📊 Limitations

### Current Limitations

1. **No Official API**: Uses browser automation (may break if UI changes)
2. **Windows Only**: PowerShell scripts (Mac/Linux coming)
3. **Requires Pro**: Spaces are Perplexity Pro feature
4. **Browser Required**: Must have browser profile with login

### Future Enhancements

When Perplexity adds official API:
- ✅ Direct API calls (no browser)
- ✅ Faster Space creation
- ✅ More reliable
- ✅ Bulk operations

---

## 🎯 Best Practices

### Do's

✅ Create Space per project  
✅ Archive completed projects  
✅ Use descriptive project names  
✅ Keep registry backed up  
✅ Review Spaces periodically

### Don'ts

❌ Don't share Space URLs publicly  
❌ Don't delete Spaces manually (use commands)  
❌ Don't edit registry JSON directly  
❌ Don't forget to archive old projects

---

## 📚 Related Systems

### Integration

- **Project Context Templates**: Provides project memory files
- **Perplexity MCP**: Enables search from Cursor
- **GitHub Sync**: Templates backed up to GitHub

### Workflow

```
1. Create project
2. Install context (install-context-with-space.ps1)
3. Auto-creates Space ✓
4. Fill context files
5. Use Perplexity → goes to project Space ✓
6. Complete project
7. Archive Space ✓
```

---

## 🆘 Support

### Issues

File issues at: https://github.com/tyniaiworkspace-dev/cursor-templates/issues

### Common Problems

See [Troubleshooting](#troubleshooting) section above

### Updates

Check for updates:
```powershell
cd "$env:USERPROFILE\.cursor\templates"
git pull
```

---

## 📈 Statistics

Track your usage:

```powershell
# Total Spaces
(Get-PerplexitySpaces -Status all).Count

# Active projects
(Get-PerplexitySpaces -Status active).Count

# Archived
(Get-PerplexitySpaces -Status archived).Count
```

---

## 🎉 Summary

### What You Get

✅ **Automatic Space creation** per project  
✅ **Organized research** (no more mixed searches)  
✅ **Easy management** (PowerShell commands)  
✅ **Project-local config** (MCP per project)  
✅ **Registry tracking** (all projects in one place)  
✅ **GitHub-synced** (templates backed up)

### Result

**Each project has its own dedicated, auto-managed Perplexity Space!** 🚀

---

**Status**: ✅ Production Ready  
**Version**: 1.0  
**Date**: 2026-02-09  
**Author**: Automated Space Registry System
