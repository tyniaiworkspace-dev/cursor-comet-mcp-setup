# Perplexity Space Registry - Complete CLI
# All commands for managing project Spaces

# Import registry manager
. "$PSScriptRoot\registry-manager.ps1"

# List all registered Spaces
function Get-PerplexitySpaces {
    <#
    .SYNOPSIS
    List all registered Perplexity Spaces
    
    .PARAMETER Status
    Filter by status: active, archived, or all
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("active", "archived", "all")]
        [string]$Status = "active"
    )
    
    Initialize-SpaceRegistry | Out-Null
    
    $spaces = Get-AllSpaces -Status $Status
    
    if ($spaces.Count -eq 0) {
        Write-Host "`nNo Spaces found." -ForegroundColor Yellow
        Write-Host "Create one with: New-PerplexitySpace" -ForegroundColor Gray
        return
    }
    
    Write-Host "`n📚 Registered Perplexity Spaces ($($spaces.Count))" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Gray
    
    foreach ($space in $spaces) {
        $statusColor = switch ($space.Status) {
            "active" { "Green" }
            "archived" { "Yellow" }
            default { "Gray" }
        }
        
        Write-Host "`n$($space.ProjectName)" -ForegroundColor White
        Write-Host "  Path: $($space.ProjectPath)" -ForegroundColor Gray
        Write-Host "  Space: $($space.SpaceUrl)" -ForegroundColor Gray
        Write-Host "  Status: $($space.Status)" -ForegroundColor $statusColor
        Write-Host "  Created: $($space.CreatedAt)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
}

# Get Space for current or specified project
function Get-ProjectSpace {
    <#
    .SYNOPSIS
    Get Perplexity Space for a project
    
    .PARAMETER ProjectPath
    Path to project (defaults to current directory)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectPath = "."
    )
    
    Initialize-SpaceRegistry | Out-Null
    
    $space = Get-ProjectSpace -ProjectPath $ProjectPath
    
    if ($space) {
        Write-Host "`n✓ Space found for this project" -ForegroundColor Green
        Write-Host "  Name: $($space.name)" -ForegroundColor Gray
        Write-Host "  URL: $($space.spaceUrl)" -ForegroundColor Gray
        Write-Host "  Status: $($space.status)" -ForegroundColor Gray
        return $space
    } else {
        Write-Host "`nNo Space registered for this project." -ForegroundColor Yellow
        Write-Host "Create one with: New-PerplexitySpace" -ForegroundColor Gray
        return $null
    }
}

# Set/Update Space for a project
function Set-ProjectSpace {
    <#
    .SYNOPSIS
    Set or update Perplexity Space for a project
    
    .PARAMETER ProjectPath
    Path to project
    
    .PARAMETER SpaceUrl
    Perplexity Space URL
    
    .PARAMETER Status
    Update status (active, archived)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectPath = ".",
        
        [Parameter(Mandatory=$false)]
        [string]$SpaceUrl = "",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("active", "archived")]
        [string]$Status = ""
    )
    
    Initialize-SpaceRegistry | Out-Null
    
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
    if (-not $ProjectPath) {
        Write-Error "Project path does not exist"
        return
    }
    
    if ($SpaceUrl) {
        # Register/update Space URL
        $projectName = Split-Path -Leaf $ProjectPath
        Register-PerplexitySpace -ProjectPath $ProjectPath `
                                -ProjectName $projectName `
                                -SpaceUrl $SpaceUrl
        
        # Configure MCP
        & "$PSScriptRoot\Configure-ProjectMCP.ps1" -ProjectPath $ProjectPath -SpaceUrl $SpaceUrl
        
        Write-Host "`n✓ Space updated successfully" -ForegroundColor Green
    }
    
    if ($Status) {
        # Update status
        Update-SpaceStatus -ProjectPath $ProjectPath -Status $Status
    }
}

# Open project's Space in browser
function Open-ProjectSpace {
    <#
    .SYNOPSIS
    Open project's Perplexity Space in browser
    
    .PARAMETER ProjectPath
    Path to project (defaults to current directory)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectPath = "."
    )
    
    Initialize-SpaceRegistry | Out-Null
    
    $space = Get-ProjectSpace -ProjectPath $ProjectPath
    
    if ($space) {
        Write-Host "Opening Space in browser..." -ForegroundColor Yellow
        Start-Process $space.spaceUrl
    } else {
        Write-Host "`nNo Space registered for this project." -ForegroundColor Yellow
    }
}

# Remove project from registry
function Remove-ProjectSpace {
    <#
    .SYNOPSIS
    Remove project from Space registry
    
    .PARAMETER ProjectPath
    Path to project
    
    .PARAMETER DeleteLocal
    Also delete project-local MCP configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectPath = ".",
        
        [Parameter(Mandatory=$false)]
        [switch]$DeleteLocal = $false
    )
    
    Initialize-SpaceRegistry | Out-Null
    
    $confirmed = Read-Host "Remove Space registration for this project? (yes/no)"
    if ($confirmed -ne "yes") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }
    
    Update-SpaceStatus -ProjectPath $ProjectPath -Status "deleted"
    
    if ($DeleteLocal) {
        $mcpLocalPath = Join-Path $ProjectPath ".cursor\mcp-local.json"
        if (Test-Path $mcpLocalPath) {
            Remove-Item $mcpLocalPath -Force
            Write-Host "  ✓ Removed local MCP config" -ForegroundColor Green
        }
    }
    
    Write-Host "`n✓ Project removed from registry" -ForegroundColor Green
}

# Export all commands
Export-ModuleMember -Function @(
    'Get-PerplexitySpaces',
    'Get-ProjectSpace',
    'Set-ProjectSpace',
    'Open-ProjectSpace',
    'Remove-ProjectSpace'
)
