# Project Memory Setup Script
# Copies the context management system to a new or existing project

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

Write-Host "`n🚀 Project Memory System Setup" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

# Resolve full path
$ProjectPath = Resolve-Path $ProjectPath -ErrorAction SilentlyContinue
if (-not $ProjectPath) {
    Write-Host "❌ Project path does not exist!" -ForegroundColor Red
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
    $response = Read-Host "Overwrite existing files? (yes/no)"
    if ($response -ne "yes") {
        Write-Host "`n❌ Setup cancelled." -ForegroundColor Red
        exit 0
    }
}

# Create directory structure
Write-Host "`n📁 Creating directory structure..." -ForegroundColor Yellow
$dirs = @(
    (Join-Path $cursorDir "context"),
    (Join-Path $cursorDir "skills\project-memory"),
    (Join-Path $cursorDir "rules")
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "   ✓ Created: $($dir -replace [regex]::Escape($ProjectPath), '.')" -ForegroundColor Green
    } else {
        Write-Host "   ⊙ Exists: $($dir -replace [regex]::Escape($ProjectPath), '.')" -ForegroundColor Gray
    }
}

# Copy template files
Write-Host "`n📄 Copying template files..." -ForegroundColor Yellow

$templateDir = Split-Path -Parent $PSCommandPath
$templateCursorDir = Join-Path $templateDir ".cursor"

# Context files
$contextFiles = @(
    "PROJECT_OVERVIEW.md",
    "ARCHITECTURE.md",
    "PROGRESS.md",
    "DECISIONS.md",
    "TODO.md",
    "CONVENTIONS.md"
)

foreach ($file in $contextFiles) {
    $source = Join-Path $templateCursorDir "context\$file"
    $dest = Join-Path $contextDir $file
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "   ✓ $file" -ForegroundColor Green
    }
}

# Skill file
$skillSource = Join-Path $templateCursorDir "skills\project-memory\SKILL.md"
$skillDest = Join-Path $cursorDir "skills\project-memory\SKILL.md"
if (Test-Path $skillSource) {
    Copy-Item -Path $skillSource -Destination $skillDest -Force
    Write-Host "   ✓ project-memory skill" -ForegroundColor Green
}

# Rule file
$ruleSource = Join-Path $templateCursorDir "rules\context-management.md"
$ruleDest = Join-Path $cursorDir "rules\context-management.md"
if (Test-Path $ruleSource) {
    Copy-Item -Path $ruleSource -Destination $ruleDest -Force
    Write-Host "   ✓ context-management rule" -ForegroundColor Green
}

# Create README in context directory
$readmePath = Join-Path $contextDir "README.md"
$readmeContent = @"
# Project Context Files

This directory contains persistent project knowledge that survives across sessions.

## Files

- **PROJECT_OVERVIEW.md** - High-level project information and current state
- **ARCHITECTURE.md** - Technical structure, stack, and design
- **PROGRESS.md** - Timeline of completed work and milestones
- **DECISIONS.md** - Important decisions and their rationale
- **TODO.md** - Current tasks, priorities, and next steps
- **CONVENTIONS.md** - Project-specific coding standards and patterns

## Usage

### Restore Context
When returning to the project after a break:
``````
Ask AI: "Catch me up on this project" or "What's the current state?"
``````

### Include Context
Use @-mentions to include context in queries:
``````
@.cursor/context/ARCHITECTURE.md How should I structure this new feature?
``````

### Update Context
After completing significant work, the AI will suggest context updates.
You can also manually request: "Update the project context files"

## Maintenance

- **Update frequency**: After features, decisions, or weekly
- **Keep concise**: Each file under 500 lines
- **Archive old content**: Use collapsible sections for history
- **Cross-reference**: Link related information between files

## Automation

The ``project-memory`` skill and ``context-management`` rule work together to:
- Suggest updates at appropriate times
- Help restore context quickly
- Keep files current and actionable

---

**Last setup**: $(Get-Date -Format "yyyy-MM-dd")
"@

Set-Content -Path $readmePath -Value $readmeContent -Force
Write-Host "   ✓ README.md" -ForegroundColor Green

# Summary
Write-Host "`n" + ("=" * 60) -ForegroundColor Gray
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Gray

Write-Host "`n📊 What was installed:" -ForegroundColor Cyan
Write-Host "   • 6 context template files (.cursor/context/)"
Write-Host "   • project-memory skill (.cursor/skills/)"
Write-Host "   • context-management rule (.cursor/rules/)"
Write-Host "   • README.md with usage instructions"

Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Fill in .cursor/context/PROJECT_OVERVIEW.md with your project details"
Write-Host "   2. Update ARCHITECTURE.md with your tech stack"
Write-Host "   3. Add initial tasks to TODO.md"
Write-Host "   4. The skill and rule will activate automatically in Cursor"

Write-Host "`n💡 Quick Start:" -ForegroundColor Cyan
Write-Host '   Ask AI: "Help me fill in the project overview"'
Write-Host '   Or: "@.cursor/context/PROJECT_OVERVIEW.md help me complete this"'

Write-Host "`n🎯 Remember:" -ForegroundColor Green
Write-Host "   • Context files persist across sessions"
Write-Host "   • AI suggests updates automatically"
Write-Host "   • Use @-mentions to include context"
Write-Host "   • Update weekly or after milestones"

Write-Host "`n✨ Your project now has persistent memory!" -ForegroundColor Green
Write-Host ""
"@
