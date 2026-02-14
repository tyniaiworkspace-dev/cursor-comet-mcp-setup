# Create New Perplexity Space for Project
# PowerShell wrapper for create-space.ts

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

# Import registry manager
. "$PSScriptRoot\registry-manager.ps1"

# Resolve project path
$ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
if (-not $ProjectPath) {
    Write-Error "Project path does not exist"
    exit 1
}

# Determine project name
if (-not $ProjectName) {
    $ProjectName = Split-Path -Leaf $ProjectPath
}

Write-Host "`n🚀 Creating Perplexity Space for: $ProjectName" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

# Initialize registry
Initialize-SpaceRegistry | Out-Null

# Check if Space already exists
$existingSpace = Get-ProjectSpace -ProjectPath $ProjectPath

if ($existingSpace -and -not $Force) {
    Write-Host "`n✓ Space already exists for this project!" -ForegroundColor Green
    Write-Host "  Name: $($existingSpace.spaceName)" -ForegroundColor Gray
    Write-Host "  URL: $($existingSpace.spaceUrl)" -ForegroundColor Gray
    Write-Host "`nUse -Force to create a new Space anyway." -ForegroundColor Yellow
    exit 0
}

# Create Space using Bun script
Write-Host "`n📦 Launching browser automation..." -ForegroundColor Yellow
Write-Host "  This may take 10-30 seconds..." -ForegroundColor Gray
Write-Host "  Browser will open briefly (this is normal)" -ForegroundColor Gray

$createScriptPath = Join-Path $PSScriptRoot "create-space.ts"
$bunPath = "C:\Users\admin\.bun\bin\bun.exe"

if (-not (Test-Path $bunPath)) {
    $bunPath = "bun"
}

# Run Space creation
try {
    $output = & $bunPath $createScriptPath $ProjectName 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        # Parse output
        $lines = $output | Where-Object { $_ -is [string] }
        $successLine = $lines | Where-Object { $_ -eq "SUCCESS" }
        
        if ($successLine) {
            # Get Space URL (next line after SUCCESS)
            $successIndex = [array]::IndexOf($lines, "SUCCESS")
            if ($successIndex -ge 0 -and $successIndex + 1 -lt $lines.Count) {
                $spaceUrl = $lines[$successIndex + 1]
                
                Write-Host "`n✅ Space created successfully!" -ForegroundColor Green
                Write-Host "  URL: $spaceUrl" -ForegroundColor Gray
                
                # Register in registry
                $spaceName = "Project: $ProjectName"
                Register-PerplexitySpace -ProjectPath $ProjectPath `
                                        -ProjectName $ProjectName `
                                        -SpaceUrl $spaceUrl `
                                        -SpaceName $spaceName
                
                # DISABLED: Configure-ProjectMCP overwrites MCP config and can break perplexity-server.
                # Use global mcp.json PERPLEXITY_SPACE_URL instead. See TROUBLESHOOTING_TARGET_CLOSED.md
                # & "$PSScriptRoot\Configure-ProjectMCP.ps1" -ProjectPath $ProjectPath -SpaceUrl $spaceUrl

                Write-Host "`n🎉 Done! Add this Space URL to mcp.json PERPLEXITY_SPACE_URL if needed." -ForegroundColor Green
                
                return $spaceUrl
            }
        }
    }
    
    # If we got here, something went wrong
    Write-Host "`n❌ Space creation failed" -ForegroundColor Red
    Write-Host "`nOutput:" -ForegroundColor Yellow
    $output | ForEach-Object { Write-Host "  $_" }
    
    Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Make sure you're logged in to Perplexity.ai in browser" -ForegroundColor Gray
    Write-Host "  2. Try creating Space manually and use Set-ProjectSpace instead" -ForegroundColor Gray
    Write-Host "  3. Check if Perplexity UI has changed (may need update)" -ForegroundColor Gray
    
    exit 1
    
} catch {
    Write-Error "Error running Space creation: $_"
    exit 1
}
