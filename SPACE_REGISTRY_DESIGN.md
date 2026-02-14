# Fully Automated Perplexity Space Registry - Design Document

## 🎯 Goal

Automatically create and manage project-specific Perplexity Spaces so each project has its own organized knowledge base.

---

## 🏗️ Architecture

### Components

```
┌─────────────────────────────────────────────────┐
│         Project Template System                  │
│  (Install-CursorContext)                        │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│      Space Registry Manager                      │
│  - Detects new project                          │
│  - Checks if Space exists                       │
│  - Triggers Space creation if needed            │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│      Space Creator (Puppeteer)                   │
│  - Launches browser                              │
│  - Navigates to Perplexity                      │
│  - Creates new Space                            │
│  - Extracts Space URL                           │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│      Space Registry (SQLite DB)                  │
│  - Stores: project_path → space_url             │
│  - Timestamp, metadata                          │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│      MCP Auto-Configurator                       │
│  - Updates project .cursor/mcp-local.json       │
│  - Sets PERPLEXITY_SPACE_URL env var            │
└─────────────────────────────────────────────────┘
```

---

## 📊 Database Schema

### Table: space_registry

```sql
CREATE TABLE space_registry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_path TEXT UNIQUE NOT NULL,
    project_name TEXT NOT NULL,
    space_url TEXT NOT NULL,
    space_name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_used DATETIME,
    status TEXT DEFAULT 'active', -- active, archived, deleted
    metadata JSON
);

CREATE INDEX idx_project_path ON space_registry(project_path);
CREATE INDEX idx_space_url ON space_registry(space_url);
```

### Table: space_creation_log

```sql
CREATE TABLE space_creation_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_path TEXT NOT NULL,
    action TEXT NOT NULL, -- create, update, delete
    status TEXT NOT NULL, -- success, failure, pending
    error_message TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔧 Implementation Plan

### Phase 1: Database & Registry (Core)

**Files to create**:
1. `space-registry/db.ts` - SQLite database wrapper
2. `space-registry/registry.ts` - Registry manager
3. `space-registry/schema.sql` - Database schema

**Functions**:
- `initializeRegistry()` - Create database if not exists
- `registerSpace(projectPath, spaceUrl)` - Add entry
- `getSpace(projectPath)` - Retrieve Space URL
- `listSpaces()` - Get all registered projects
- `updateSpace(projectPath, spaceUrl)` - Update entry
- `deleteSpace(projectPath)` - Remove entry

---

### Phase 2: Space Creator (Browser Automation)

**Files to create**:
1. `space-registry/space-creator.ts` - Puppeteer automation
2. `space-registry/browser-utils.ts` - Browser helpers

**Functions**:
- `createPerplexitySpace(projectName)` - Main function
  - Launch browser (reuse existing profile)
  - Navigate to Perplexity
  - Click "New Space" button
  - Fill in Space name
  - Extract Space URL
  - Return URL

**Selectors** (will need to inspect Perplexity UI):
```typescript
const SELECTORS = {
  newSpaceButton: '[data-testid="new-space"]', // Placeholder
  spaceNameInput: 'input[name="space-name"]',  // Placeholder
  createButton: 'button[type="submit"]',       // Placeholder
  spaceUrl: 'meta[property="og:url"]'          // Placeholder
};
```

---

### Phase 3: Project Detection

**Files to create**:
1. `space-registry/project-detector.ts` - Detect new projects

**Logic**:
```typescript
function detectNewProject(projectPath: string): boolean {
  // Check if project has .cursor folder
  // Check if Space already registered
  // Return true if new project needs Space
}
```

---

### Phase 4: MCP Auto-Configuration

**Files to create**:
1. `space-registry/mcp-configurator.ts` - Configure MCP per project

**Logic**:
```typescript
function configureMCPForProject(projectPath: string, spaceUrl: string) {
  // Create/update .cursor/mcp-local.json in project
  // Set PERPLEXITY_SPACE_URL to project-specific Space
  // Merge with global mcp.json settings
}
```

**File structure**:
```
ProjectRoot/
└── .cursor/
    ├── mcp-local.json  ← Project-specific (Space URL)
    └── context/        ← Project context files
```

---

### Phase 5: PowerShell Interface

**Files to create**:
1. `space-registry/cli.ps1` - PowerShell commands

**Commands**:
```powershell
# Create Space and register
New-PerplexitySpace -ProjectPath "." -ProjectName "MyApp"

# List all Spaces
Get-PerplexitySpaces

# Get Space for current project
Get-ProjectSpace

# Update Space URL
Set-ProjectSpace -SpaceUrl "https://..."

# Remove project from registry
Remove-ProjectSpace -ProjectPath "."

# Open project's Space in browser
Open-ProjectSpace
```

---

### Phase 6: Integration with Template System

**Modify**: `install-context-fixed.ps1`

**Add**:
```powershell
# After installing context files
if ($AutoCreateSpace) {
    $projectName = Split-Path -Leaf (Get-Location)
    Write-Host "Creating Perplexity Space for project..."
    
    $spaceUrl = & "$PSScriptRoot\..\space-registry\create-space.ps1" -ProjectName $projectName
    
    if ($spaceUrl) {
        # Configure MCP
        & "$PSScriptRoot\..\space-registry\configure-mcp.ps1" -SpaceUrl $spaceUrl
        Write-Host "Space created: $spaceUrl"
    }
}
```

---

## 🔐 Security & Privacy

### Considerations

1. **Browser Profile**:
   - Reuse existing Perplexity MCP browser profile
   - Already authenticated
   - No credential storage needed

2. **Database Location**:
   - Store in `C:\Users\admin\.cursor\space-registry\registry.db`
   - User-only access
   - Backup to GitHub (optional)

3. **Space URLs**:
   - Private by default in Perplexity
   - Only accessible to your account
   - URLs are long/random (not guessable)

---

## 🚨 Error Handling

### Scenarios

1. **Space Creation Fails**:
   - Retry with exponential backoff
   - Log error
   - Fall back to manual creation prompt
   - Continue project setup

2. **Browser Not Authenticated**:
   - Detect login state
   - Prompt user to login
   - Wait for authentication
   - Retry Space creation

3. **Database Locked**:
   - Wait and retry
   - Use SQLite timeout settings
   - Log warning

4. **Perplexity UI Changed**:
   - Selectors fail
   - Log detailed error
   - Provide manual creation instructions
   - Continue project setup

---

## 📊 Workflow Example

### Scenario: Creating New Project

```powershell
# User navigates to new project
cd "C:\Projects\MyNewApp"

# User runs template installation
Install-CursorContext -Version Lean -AutoCreateSpace

# System automatically:
# 1. Detects new project ✓
# 2. Checks registry (not found) ✓
# 3. Launches browser ✓
# 4. Creates Space "Project: MyNewApp" ✓
# 5. Extracts Space URL ✓
# 6. Registers in database ✓
# 7. Configures local MCP ✓
# 8. Installs context templates ✓

# User starts working
# All Perplexity searches go to project-specific Space automatically
```

---

## 🔄 Space Lifecycle

### States

1. **Created**: Space created and registered
2. **Active**: Currently in use
3. **Archived**: Project completed, Space kept for reference
4. **Deleted**: Space and registry entry removed

### Management

```powershell
# Archive project Space
Set-ProjectSpace -Status Archived

# Reactivate archived Space
Set-ProjectSpace -Status Active

# Delete Space (removes from registry, keeps Perplexity Space)
Remove-ProjectSpace

# Clean up old Spaces (interactive)
Clear-ArchivedSpaces -OlderThan 90days
```

---

## 📦 File Structure

```
c:\Users\admin\Perplexity mcp\
├── space-registry\
│   ├── db.ts                    # SQLite wrapper
│   ├── registry.ts              # Registry manager
│   ├── space-creator.ts         # Puppeteer automation
│   ├── browser-utils.ts         # Browser helpers
│   ├── project-detector.ts      # Project detection
│   ├── mcp-configurator.ts      # MCP auto-config
│   ├── cli.ps1                  # PowerShell interface
│   ├── create-space.ps1         # Create Space script
│   ├── configure-mcp.ps1        # Configure MCP script
│   ├── schema.sql               # Database schema
│   └── registry.db              # SQLite database (created)
│
├── perplexity-mcp-zerver\      # Existing MCP server
└── install-context-fixed.ps1    # Modified template installer
```

---

## 🧪 Testing Strategy

### Test Cases

1. **New Project**:
   - Create Space automatically ✓
   - Register correctly ✓
   - Configure MCP ✓

2. **Existing Project**:
   - Detect existing Space ✓
   - Don't create duplicate ✓
   - Use existing Space URL ✓

3. **Manual Override**:
   - User provides Space URL ✓
   - Skip automation ✓
   - Register custom Space ✓

4. **Error Recovery**:
   - Browser fails → prompt manual creation ✓
   - Auth fails → guide user ✓
   - Database fails → log error, continue ✓

5. **Multiple Projects**:
   - Each gets unique Space ✓
   - No conflicts ✓
   - Correct Space per project ✓

---

## 🚀 Rollout Plan

### Phase 1: Core (Week 1)
- ✅ Database schema
- ✅ Registry manager
- ✅ Basic CLI

### Phase 2: Automation (Week 2)
- ✅ Puppeteer Space creation
- ✅ Error handling
- ✅ Testing

### Phase 3: Integration (Week 3)
- ✅ Template system integration
- ✅ MCP auto-configuration
- ✅ End-to-end testing

### Phase 4: Polish (Week 4)
- ✅ Documentation
- ✅ Error messages
- ✅ User guide

---

## 💰 Cost Analysis

### Storage

- **Database**: ~100KB per 1000 projects
- **Logs**: ~1MB per year
- **Total**: Negligible

### Performance

- **Space Creation**: ~5-10 seconds per project
- **Registry Lookup**: <1ms
- **MCP Configuration**: <100ms
- **Total Overhead**: ~10 seconds one-time per project

### Maintenance

- **Browser Selectors**: Update if Perplexity UI changes
- **Database**: Occasional cleanup of old entries
- **Logs**: Rotate monthly

---

## 📚 Next Steps

1. **Build Core Registry** (database + manager)
2. **Test Space Creation** (manual Puppeteer script)
3. **Integrate with Templates** (modify installer)
4. **Test End-to-End** (create multiple test projects)
5. **Document** (user guide + troubleshooting)
6. **Deploy** (add to GitHub repo)

---

**Status**: Design Complete ✅  
**Ready to Build**: Yes  
**Estimated Time**: 2-3 hours for MVP  
**Complexity**: High but manageable
