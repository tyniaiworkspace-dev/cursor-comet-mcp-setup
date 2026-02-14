# Configure Project-Local MCP Settings
# WARNING: Project-local MCP config can override global mcp.json and break perplexity-server.
# Prefer setting PERPLEXITY_SPACE_URL in global C:\Users\admin\.cursor\mcp.json instead.
# Only run this if you understand the risks and need project-specific Space URLs.

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [Parameter(Mandatory=$true)]
    [string]$SpaceUrl
)

# Resolve project path
$ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
if (-not $ProjectPath) {
    Write-Error "Project path does not exist"
    exit 1
}

# Create .cursor directory if needed
$cursorDir = Join-Path $ProjectPath ".cursor"
if (-not (Test-Path $cursorDir)) {
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
}

# Create project-local MCP configuration
$mcpLocalPath = Join-Path $cursorDir "mcp-local.json"

# Read global MCP config as base
$globalMcpPath = "$env:USERPROFILE\.cursor\mcp.json"
$mcpConfig = @{
    mcpServers = @{
        perplexity-server = @{
            command = "C:\Users\admin\.bun\bin\bun.exe"
            args = @(
                "c:\Users\admin\Perplexity mcp\perplexity-mcp-zerver\build\main.js"
            )
            timeout = 600
            env = @{
                PERPLEXITY_BROWSER_DATA_DIR = "C:\Users\admin\.perplexity-mcp"
                PERPLEXITY_PERSISTENT_PROFILE = "true"
                PERPLEXITY_SPACE_URL = $SpaceUrl  # Project-specific!
                LANG = "en_US.UTF-8"
                LC_ALL = "en_US.UTF-8"
                LOG_LEVEL = "debug"
            }
        }
    }
}

# Save project-local config
$mcpConfig | ConvertTo-Json -Depth 10 | Set-Content $mcpLocalPath -Encoding UTF8

Write-Host "  ✓ MCP configured for project" -ForegroundColor Green
Write-Host "  Config: $mcpLocalPath" -ForegroundColor Gray

# Create README about MCP config
$readmePath = Join-Path $cursorDir "MCP_README.md"
$readmeContent = @"
# Project-Specific Perplexity Configuration

This project has a dedicated Perplexity Space for organizing research:

**Space URL**: $SpaceUrl

All Perplexity MCP searches from this project will automatically go to this Space.

## How It Works

- The ``.cursor/mcp-local.json`` file overrides the global MCP configuration
- The ``PERPLEXITY_SPACE_URL`` environment variable points to this project's Space
- Cursor loads project-local config when working in this project

## Commands

View this project's Space:
``````powershell
Get-ProjectSpace
``````

Open Space in browser:
``````powershell
Open-ProjectSpace
``````

Update Space URL:
``````powershell
Set-ProjectSpace -SpaceUrl "https://..."
``````

## Registry

This project is registered in the global Space Registry:
``C:\Users\admin\Perplexity mcp\space-registry\registry.json``

The registry tracks all project → Space mappings across your system.
"@

$readmeContent | Set-Content $readmePath -Encoding UTF8

Write-Host "  ✓ Created MCP_README.md" -ForegroundColor Green
