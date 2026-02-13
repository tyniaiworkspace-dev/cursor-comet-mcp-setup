# Cursor MCP Setup - Restore Comet + poe2-optimizer config after clone
# Run from repo root: .\setup.ps1
# Requires: Node.js (npx), PowerShell

$ErrorActionPreference = "Stop"
$CursorDir = Join-Path $env:USERPROFILE ".cursor"
$RepoRoot = $PSScriptRoot

Write-Host "[setup] Cursor config dir: $CursorDir" -ForegroundColor Cyan
if (-not (Test-Path $CursorDir)) {
    New-Item -ItemType Directory -Path $CursorDir -Force | Out-Null
    Write-Host "[setup] Created $CursorDir" -ForegroundColor Green
}

# Copy comet wrapper and package.json so .cursor has its own node_modules
Copy-Item (Join-Path $RepoRoot "comet-auto-space.js") -Destination $CursorDir -Force
Copy-Item (Join-Path $RepoRoot "package.json") -Destination $CursorDir -Force
Write-Host "[setup] Copied comet-auto-space.js and package.json to $CursorDir" -ForegroundColor Green

# Install deps in .cursor (chrome-remote-interface for comet-auto-space.js)
Push-Location $CursorDir
try {
    npm install 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
    Write-Host "[setup] npm install in $CursorDir OK" -ForegroundColor Green
} finally {
    Pop-Location
}

# Generate mcp.json from template (escape backslashes for JSON)
$templatePath = Join-Path $RepoRoot "mcp.json.template"
$template = Get-Content $templatePath -Raw
$cursorDirEscaped = $CursorDir -replace '\\', '\\\\'
$mcpJson = $template -replace '\{\{CURSOR_DIR\}\}', $cursorDirEscaped
$mcpPath = Join-Path $CursorDir "mcp.json"
Set-Content -Path $mcpPath -Value $mcpJson -Encoding UTF8 -NoNewline
Write-Host "[setup] Wrote $mcpPath" -ForegroundColor Green

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Yellow
Write-Host "  1. Ensure Node.js and npx are on PATH (comet-mcp runs via npx)."
Write-Host "  2. Optional: pip install poe2-mcp if you use the poe2-optimizer server."
Write-Host "  3. Restart Cursor (or reload window) so it picks up the new mcp.json."
Write-Host ""
