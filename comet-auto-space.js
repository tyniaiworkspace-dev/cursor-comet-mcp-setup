#!/usr/bin/env node

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Configuration
const MAPPING_FILE = path.join(os.homedir(), '.cursor', 'space-mapping.json');
const COMET_DEBUG_PORT = 9222;

// Get project info
const projectRoot = process.env.CURSOR_PROJECT_ROOT || process.cwd();
const projectName = path.basename(projectRoot);

// Logging helper
function log(msg) {
  console.error(`[Auto-Space] ${msg}`);
}

// Load/save mapping
function loadMapping() {
  if (fs.existsSync(MAPPING_FILE)) {
    return JSON.parse(fs.readFileSync(MAPPING_FILE, 'utf8'));
  }
  return {};
}

function saveMapping(mapping) {
  const dir = path.dirname(MAPPING_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(MAPPING_FILE, JSON.stringify(mapping, null, 2), 'utf8');
}

// Create Space via browser automation
async function createSpaceViaBrowser(projectName) {
  log(`Creating Space for project: ${projectName}`);
  
  try {
    const CDP = require('chrome-remote-interface');
    const client = await CDP({ port: COMET_DEBUG_PORT });
    
    const { Page, Runtime, DOM, Input } = client;
    
    await Page.enable();
    await Runtime.enable();
    await DOM.enable();
    
    // Navigate to Spaces page
    log('Navigating to Perplexity Spaces...');
    await Page.navigate({ url: 'https://www.perplexity.ai/spaces' });
    await Page.loadEventFired();
    
    // Wait for page to fully load
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Find and click "Create Space" button
    log('Looking for Create Space button...');
    const createButtonScript = `
      Array.from(document.querySelectorAll('button, a, div[role="button"]'))
        .find(el => el.textContent.includes('Create') && (el.textContent.includes('Space') || el.textContent.includes('space')))
        ?.click();
      'clicked';
    `;
    
    await Runtime.evaluate({ expression: createButtonScript });
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Fill in Space name
    log('Filling in Space name...');
    const fillNameScript = `
      const input = document.querySelector('input[type="text"], input[placeholder*="name" i], textarea');
      if (input) {
        input.value = '${projectName.replace(/'/g, "\\'")}';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
        'filled';
      } else {
        'not_found';
      }
    `;
    
    const fillResult = await Runtime.evaluate({ expression: fillNameScript });
    log(`Fill result: ${fillResult.result.value}`);
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Click Save/Continue/Create button
    log('Saving Space...');
    const saveButtonScript = `
      const button = Array.from(document.querySelectorAll('button'))
        .find(el => /save|create|continue/i.test(el.textContent));
      if (button) {
        button.click();
        'clicked';
      } else {
        'not_found';
      }
    `;
    
    await Runtime.evaluate({ expression: saveButtonScript });
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Extract the new Space URL from current page
    const urlResult = await Runtime.evaluate({ expression: 'window.location.href' });
    const spaceUrl = urlResult.result.value;
    
    await client.close();
    
    if (spaceUrl && spaceUrl.includes('/spaces/')) {
      log(`Successfully created Space: ${spaceUrl}`);
      return spaceUrl;
    } else {
      log(`Warning: URL doesn't look like a Space: ${spaceUrl}`);
      return spaceUrl;
    }
    
  } catch (error) {
    log(`Error creating Space: ${error.message}`);
    log('Continuing without project-specific Space');
    return null;
  }
}

// Main logic
async function main() {
  log(`Project: ${projectName} (${projectRoot})`);
  
  // Load existing mapping
  const mapping = loadMapping();
  
  let spaceUrl = mapping[projectRoot];
  
  if (!spaceUrl) {
    log('No Space found for this project');
    
    // Try to create one automatically
    spaceUrl = await createSpaceViaBrowser(projectName);
    
    if (spaceUrl) {
      // Save the mapping
      mapping[projectRoot] = spaceUrl;
      saveMapping(mapping);
      log(`Saved Space mapping for future use`);
    }
  } else {
    log(`Using existing Space: ${spaceUrl}`);
  }
  
  // Launch comet-mcp with the Space URL
  const env = { ...process.env };
  if (spaceUrl) {
    env.COMET_TARGET_URL = spaceUrl;
  }
  
  log('Launching comet-mcp...');
  const child = spawn('npx.cmd', ['-y', 'comet-mcp'], {
    stdio: 'inherit',
    env,
    shell: true
  });
  
  child.on('exit', (code) => {
    process.exit(code || 0);
  });
  
  process.on('SIGTERM', () => child.kill('SIGTERM'));
  process.on('SIGINT', () => child.kill('SIGINT'));
}

main().catch(err => {
  log(`Fatal error: ${err.message}`);
  process.exit(1);
});
