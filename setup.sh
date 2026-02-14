#!/usr/bin/env bash
# Cursor MCP Setup - Restore Comet + poe2-optimizer config after clone (macOS / Linux)
# Run from repo root: ./setup.sh
# Requires: Node.js (npx), bash

set -e
CURSOR_DIR="${HOME}/.cursor"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "[setup] Cursor config dir: $CURSOR_DIR"
mkdir -p "$CURSOR_DIR"

# Copy comet wrapper and package.json so .cursor has its own node_modules
cp "$REPO_ROOT/comet-auto-space.js" "$CURSOR_DIR/"
cp "$REPO_ROOT/package.json" "$CURSOR_DIR/"
echo "[setup] Copied comet-auto-space.js and package.json to $CURSOR_DIR"

# Install deps in .cursor (chrome-remote-interface for comet-auto-space.js)
(cd "$CURSOR_DIR" && npm install)
echo "[setup] npm install in $CURSOR_DIR OK"

# Generate mcp.json from template (POSIX path, no escaping needed for /)
TEMPLATE_PATH="$REPO_ROOT/mcp.json.template"
MCP_PATH="$CURSOR_DIR/mcp.json"
sed "s|{{CURSOR_DIR}}|$CURSOR_DIR|g" "$TEMPLATE_PATH" > "$MCP_PATH"
echo "[setup] Wrote $MCP_PATH"

echo ""
echo "Done. Next steps:"
echo "  1. Ensure Node.js and npx are on PATH (comet-mcp runs via npx)."
echo "  2. Optional: pip install poe2-mcp if you use the poe2-optimizer server."
echo "  3. Restart Cursor (or Reload Window) so it picks up the new mcp.json."
echo "  4. Open this repo folder in Cursor to use the included .cursor rules/skills."
echo ""
