# Project Memory Setup Script (Token-Optimized Lean Version)
# Copies the optimized context management system to a project

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Minimal", "Lean", "Full")]
    [string]$Version = "Lean",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

Write-Host "`n⚡ Token-Optimized Project Memory Setup" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

# Version info
$versionInfo = @{
    "Minimal" = @{
        Tokens = "800-1,500"
        Files = "1 file (CONTEXT.md)"
        Cost = "0.2x"
        BestFor = "Small projects, quick prototypes"
    }
    "Lean" = @{
        Tokens = "2,000-3,000"
        Files = "6 optimized files"
        Cost = "0.4x"
        BestFor = "Most projects (recommended)"
    }
    "Full" = @{
        Tokens = "5,000-8,000"
        Files = "6 comprehensive files"
        Cost = "1.0x"
        BestFor = "Large/complex projects"
    }
}

Write-Host "`n📊 Selected Version: $Version" -ForegroundColor Yellow
Write-Host "   Tokens: $($versionInfo[$Version].Tokens)"
Write-Host "   Files: $($versionInfo[$Version].Files)"
Write-Host "   Cost Factor: $($versionInfo[$Version].Cost)"
Write-Host "   Best For: $($versionInfo[$Version].BestFor)"

# Resolve full path
$ProjectPath = Resolve-Path $ProjectPath -ErrorAction SilentlyContinue
if (-not $ProjectPath) {
    Write-Host "`n❌ Project path does not exist!" -ForegroundColor Red
    exit 1
}

Write-Host "`n📁 Target Project: $ProjectPath" -ForegroundColor Yellow

# Check if .cursor directory exists
$cursorDir = Join-Path $ProjectPath ".cursor"
if (-not (Test-Path $cursorDir)) {
    Write-Host "`n📂 Creating .cursor directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
}

# Check if context files already exist
$contextDir = Join-Path $cursorDir "context"
if ((Test-Path $contextDir) -and -not $Force) {
    Write-Host "`n⚠️  Context files already exist!" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (yes/no)"
    if ($response -ne "yes") {
        Write-Host "`n❌ Setup cancelled." -ForegroundColor Red
        exit 0
    }
}

# Create directories
Write-Host "`n📁 Creating structure..." -ForegroundColor Yellow
$dirs = @(
    (Join-Path $cursorDir "context"),
    (Join-Path $cursorDir "skills\project-memory"),
    (Join-Path $cursorDir "rules")
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "   ✓ $($dir -replace [regex]::Escape($ProjectPath), '.')" -ForegroundColor Green
    }
}

# Copy files based on version
Write-Host "`n📄 Installing $Version version..." -ForegroundColor Yellow

$templateDir = Split-Path -Parent $PSCommandPath
$templateCursorDir = Join-Path $templateDir ".cursor"

if ($Version -eq "Minimal") {
    # Copy just CONTEXT.md
    $source = Join-Path $templateCursorDir "context\CONTEXT.md"
    $dest = Join-Path $contextDir "CONTEXT.md"
    Copy-Item -Path $source -Destination $dest -Force
    Write-Host "   ✓ CONTEXT.md (single-file)" -ForegroundColor Green
    
} elseif ($Version -eq "Lean") {
    # Copy 6 lean files
    $files = @("PROJECT.md", "ARCH.md", "TASKS.md", "PROGRESS.md", "DECISIONS.md", "CONVENTIONS.md")
    foreach ($file in $files) {
        $source = Join-Path $templateCursorDir "context\$file"
        $dest = Join-Path $contextDir $file
        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $dest -Force
            Write-Host "   ✓ $file" -ForegroundColor Green
        }
    }
    
} else {
    # Full version - use original template
    Write-Host "   ℹ️  Full version uses original template" -ForegroundColor Cyan
    Write-Host "   Run the standard setup script instead." -ForegroundColor Yellow
    exit 0
}

# Copy skill (always lean optimized)
$skillSource = Join-Path $templateCursorDir "skills\project-memory\SKILL.md"
$skillDest = Join-Path $cursorDir "skills\project-memory\SKILL.md"
if (Test-Path $skillSource) {
    Copy-Item -Path $skillSource -Destination $skillDest -Force
    Write-Host "   ✓ project-memory skill (optimized)" -ForegroundColor Green
}

# Create minimal rule
$rulePath = Join-Path $cursorDir "rules\context-management.md"
$ruleContent = @"
# Context Management (Token-Optimized)

## AI Synopsis Loading
- Load AI Synopsis first (top bullets of each file)
- Expand details only when needed
- Target: <2,500 tokens for normal catchup

## Update Guidelines
- Suggest updates after: features, decisions, milestones
- Keep updates concise: bullets over prose
- Archive old content in <details> tags

## File Token Targets
- Each file: <500 tokens (main sections)
- Total: <3,000 tokens (all files)
- Synopsis: <400 tokens (all combined)
"@
Set-Content -Path $rulePath -Value $ruleContent -Force
Write-Host "   ✓ context-management rule" -ForegroundColor Green

# Summary
Write-Host "`n" + ("=" * 60) -ForegroundColor Gray
Write-Host "✅ Setup Complete! ($Version Version)" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n📊 What You Got:" -ForegroundColor Cyan
Write-Host "   • Token budget: $($versionInfo[$Version].Tokens)"
Write-Host "   • Files: $($versionInfo[$Version].Files)"
Write-Host "   • Cost factor: $($versionInfo[$Version].Cost) (vs full)"
Write-Host "   • Speed: 2-5x faster context loading"

Write-Host "`n💰 Savings:" -ForegroundColor Green
if ($Version -eq "Minimal") {
    Write-Host "   • 80% fewer tokens vs full version"
    Write-Host "   • 5x faster loading"
    Write-Host "   • ~`$0.01 per catchup (vs ~`$0.05)"
} else {
    Write-Host "   • 60% fewer tokens vs full version"
    Write-Host "   • 3x faster loading"
    Write-Host "   • ~`$0.02 per catchup (vs ~`$0.05)"
}

Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
if ($Version -eq "Minimal") {
    Write-Host "   1. Fill in .cursor/context/CONTEXT.md"
    Write-Host '   2. Ask AI: "Help me initialize the project context"'
} else {
    Write-Host "   1. Fill in AI Synopsis sections in each file"
    Write-Host '   2. Ask AI: "Help me initialize the project context"'
}
Write-Host "   3. Work normally - AI suggests updates"
Write-Host "   4. Use @-mentions: @.cursor/context/TASKS.md"

Write-Host "`n💡 Token-Optimized Features:" -ForegroundColor Cyan
Write-Host "   • AI Synopsis for instant overview"
Write-Host "   • Progressive loading (only load what's needed)"
Write-Host "   • <details> tags for optional content"
Write-Host "   • Bullet lists for efficiency"
Write-Host "   • Table-based summaries"

Write-Host "`n✨ Your context is now lean, fast, and cheap!" -ForegroundColor Green
Write-Host ""
