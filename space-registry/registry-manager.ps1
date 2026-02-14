# Perplexity Space Registry Manager
# Manages project → Space URL mappings using SQLite

# Registry database path
$script:RegistryDB = Join-Path $PSScriptRoot "registry.db"

# Initialize database
function Initialize-SpaceRegistry {
    [CmdletBinding()]
    param()
    
    # Check if SQLite is available
    if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
        Write-Warning "SQLite not found. Installing..."
        # For now, use simple JSON file as fallback
        return Initialize-JsonRegistry
    }
    
    # Create database if it doesn't exist
    if (-not (Test-Path $script:RegistryDB)) {
        Write-Host "Initializing Space Registry database..." -ForegroundColor Yellow
        
        $schemaFile = Join-Path $PSScriptRoot "schema.sql"
        if (Test-Path $schemaFile) {
            sqlite3 $script:RegistryDB ".read '$schemaFile'"
            Write-Host "  Registry database created" -ForegroundColor Green
        } else {
            Write-Error "Schema file not found: $schemaFile"
            return $false
        }
    }
    
    return $true
}

# Fallback: JSON-based registry (if SQLite unavailable)
function Initialize-JsonRegistry {
    $jsonPath = Join-Path $PSScriptRoot "registry.json"
    
    if (-not (Test-Path $jsonPath)) {
        $registry = @{
            version = "1.0"
            projects = @{}
            created = (Get-Date -Format "o")
        }
        $registry | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8
        Write-Host "  JSON registry created" -ForegroundColor Green
    }
    
    return $true
}

# Register a new Space
function Register-PerplexitySpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectPath,
        
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,
        
        [Parameter(Mandatory=$true)]
        [string]$SpaceUrl,
        
        [Parameter(Mandatory=$false)]
        [string]$SpaceName = ""
    )
    
    # Normalize project path
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
    if (-not $ProjectPath) {
        Write-Error "Project path does not exist"
        return $false
    }
    
    # Use JSON registry for now (simpler, works everywhere)
    $jsonPath = Join-Path $PSScriptRoot "registry.json"
    
    if (-not (Test-Path $jsonPath)) {
        Initialize-JsonRegistry | Out-Null
    }
    
    $registry = Get-Content $jsonPath | ConvertFrom-Json
    
    # Add or update project
    $projectEntry = @{
        name = $ProjectName
        spaceUrl = $SpaceUrl
        spaceName = if ($SpaceName) { $SpaceName } else { "Project: $ProjectName" }
        createdAt = (Get-Date -Format "o")
        lastUsed = (Get-Date -Format "o")
        status = "active"
    }
    
    # Convert to hashtable if needed
    if ($registry.projects -isnot [hashtable]) {
        $registry.projects = @{}
    }
    
    $registry.projects[$ProjectPath] = $projectEntry
    
    # Save
    $registry | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8
    
    Write-Host "  Registered Space for '$ProjectName'" -ForegroundColor Green
    Write-Host "  URL: $SpaceUrl" -ForegroundColor Gray
    
    return $true
}

# Get Space for a project
function Get-ProjectSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ProjectPath = "."
    )
    
    # Normalize path
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
    if (-not $ProjectPath) {
        Write-Warning "Project path does not exist"
        return $null
    }
    
    $jsonPath = Join-Path $PSScriptRoot "registry.json"
    
    if (-not (Test-Path $jsonPath)) {
        return $null
    }
    
    $registry = Get-Content $jsonPath | ConvertFrom-Json
    
    # Check if project exists
    $project = $registry.projects.PSObject.Properties | Where-Object { $_.Name -eq $ProjectPath }
    
    if ($project) {
        return $project.Value
    }
    
    return $null
}

# List all registered Spaces
function Get-AllSpaces {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("active", "archived", "all")]
        [string]$Status = "active"
    )
    
    $jsonPath = Join-Path $PSScriptRoot "registry.json"
    
    if (-not (Test-Path $jsonPath)) {
        return @()
    }
    
    $registry = Get-Content $jsonPath | ConvertFrom-Json
    $spaces = @()
    
    foreach ($prop in $registry.projects.PSObject.Properties) {
        $space = [PSCustomObject]@{
            ProjectPath = $prop.Name
            ProjectName = $prop.Value.name
            SpaceUrl = $prop.Value.spaceUrl
            SpaceName = $prop.Value.spaceName
            CreatedAt = $prop.Value.createdAt
            LastUsed = $prop.Value.lastUsed
            Status = $prop.Value.status
        }
        
        if ($Status -eq "all" -or $space.Status -eq $Status) {
            $spaces += $space
        }
    }
    
    return $spaces
}

# Update Space status
function Update-SpaceStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectPath,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("active", "archived", "deleted")]
        [string]$Status
    )
    
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue).Path
    if (-not $ProjectPath) {
        Write-Error "Project path does not exist"
        return $false
    }
    
    $jsonPath = Join-Path $PSScriptRoot "registry.json"
    
    if (-not (Test-Path $jsonPath)) {
        Write-Error "Registry not found"
        return $false
    }
    
    $registry = Get-Content $jsonPath | ConvertFrom-Json
    
    $project = $registry.projects.PSObject.Properties | Where-Object { $_.Name -eq $ProjectPath }
    
    if ($project) {
        $project.Value.status = $Status
        $project.Value.lastUsed = (Get-Date -Format "o")
        
        $registry | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8
        
        Write-Host "  Updated status to '$Status'" -ForegroundColor Green
        return $true
    } else {
        Write-Error "Project not found in registry"
        return $false
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Initialize-SpaceRegistry',
    'Register-PerplexitySpace',
    'Get-ProjectSpace',
    'Get-AllSpaces',
    'Update-SpaceStatus'
)
