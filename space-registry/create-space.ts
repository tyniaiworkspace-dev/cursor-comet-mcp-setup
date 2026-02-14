/**
 * Perplexity Space Creator
 * Automates Space creation using Puppeteer
 */

import { launch, type Browser, type Page } from "puppeteer";
import { resolve } from "path";

interface SpaceCreationResult {
  success: boolean;
  spaceUrl?: string;
  spaceName?: string;
  error?: string;
}

// Configuration
const CONFIG = {
  BROWSER_DATA_DIR: process.env.PERPLEXITY_BROWSER_DATA_DIR || 
                   resolve(process.env.HOME || process.env.USERPROFILE || "", ".perplexity-mcp"),
  PERPLEXITY_URL: "https://www.perplexity.ai",
  TIMEOUT: 30000,
  HEADLESS: process.env.HEADLESS !== "false", // Set to false for debugging
};

// Selectors (may need adjustment based on Perplexity UI)
const SELECTORS = {
  // Login check
  userMenu: '[data-testid="user-menu"]',
  profileButton: 'button[aria-label*="profile" i], button[aria-label*="account" i]',
  
  // Space creation (these are guesses - will need inspection)
  spacesLink: 'a[href*="/spaces"]',
  newSpaceButton: 'button:has-text("New Space"), button:has-text("Create Space"), [data-testid="new-space"]',
  spaceNameInput: 'input[placeholder*="space name" i], input[name="name"], input[type="text"]',
  createButton: 'button[type="submit"], button:has-text("Create")',
  
  // Space URL extraction
  spaceUrlMeta: 'meta[property="og:url"]',
  urlBar: 'input[type="url"]',
};

/**
 * Wait for element with timeout
 */
async function waitForSelector(page: Page, selector: string, timeout: number = CONFIG.TIMEOUT): Promise<boolean> {
  try {
    await page.waitForSelector(selector, { timeout });
    return true;
  } catch {
    return false;
  }
}

/**
 * Check if user is logged in
 */
async function isLoggedIn(page: Page): Promise<boolean> {
  // Check for user menu or profile button
  const hasUserMenu = await waitForSelector(page, SELECTORS.userMenu, 5000);
  if (hasUserMenu) return true;
  
  const hasProfile = await waitForSelector(page, SELECTORS.profileButton, 5000);
  return hasProfile;
}

/**
 * Create a new Perplexity Space
 */
export async function createSpace(projectName: string): Promise<SpaceCreationResult> {
  let browser: Browser | null = null;
  
  try {
    console.log(`Creating Space for project: ${projectName}`);
    
    // Launch browser with existing profile
    browser = await launch({
      headless: CONFIG.HEADLESS,
      userDataDir: CONFIG.BROWSER_DATA_DIR,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--no-first-run',
        '--no-zygote',
        '--disable-gpu',
      ],
    });
    
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 720 });
    
    // Navigate to Perplexity
    console.log("Navigating to Perplexity...");
    await page.goto(CONFIG.PERPLEXITY_URL, { waitUntil: "networkidle2", timeout: CONFIG.TIMEOUT });
    
    // Check if logged in
    const loggedIn = await isLoggedIn(page);
    if (!loggedIn) {
      return {
        success: false,
        error: "Not logged in to Perplexity. Please login first.",
      };
    }
    
    console.log("Logged in successfully");
    
    // Navigate to Spaces (try multiple approaches)
    console.log("Navigating to Spaces...");
    
    // Approach 1: Direct URL
    try {
      await page.goto(`${CONFIG.PERPLEXITY_URL}/spaces`, { waitUntil: "networkidle2", timeout: 10000 });
    } catch {
      // Approach 2: Click Spaces link
      const spacesLinkFound = await waitForSelector(page, SELECTORS.spacesLink, 5000);
      if (spacesLinkFound) {
        await page.click(SELECTORS.spacesLink);
        await page.waitForNavigation({ timeout: 10000 }).catch(() => {});
      }
    }
    
    // Wait a bit for page to settle
    await page.waitForTimeout(2000);
    
    // Look for "New Space" button (try multiple selectors)
    console.log("Looking for New Space button...");
    
    let buttonFound = false;
    for (const selector of [SELECTORS.newSpaceButton, 'button', '[role="button"]']) {
      const buttons = await page.$$(selector);
      
      for (const button of buttons) {
        const text = await button.evaluate(el => el.textContent?.toLowerCase() || '');
        if (text.includes('new space') || text.includes('create space') || text.includes('add space')) {
          console.log(`Found button: ${text}`);
          await button.click();
          buttonFound = true;
          break;
        }
      }
      
      if (buttonFound) break;
    }
    
    if (!buttonFound) {
      // Log page content for debugging
      const pageContent = await page.content();
      console.error("Could not find New Space button. Page content length:", pageContent.length);
      
      return {
        success: false,
        error: "Could not find 'New Space' button. Perplexity UI may have changed.",
      };
    }
    
    // Wait for Space creation dialog/form
    await page.waitForTimeout(1000);
    
    // Find and fill Space name input
    console.log("Filling Space name...");
    const spaceName = `Project: ${projectName}`;
    
    // Try to find input field
    const inputFound = await waitForSelector(page, SELECTORS.spaceNameInput, 5000);
    if (!inputFound) {
      // Try all text inputs
      const inputs = await page.$$('input[type="text"], input:not([type])');
      if (inputs.length > 0) {
        await inputs[0].type(spaceName);
      } else {
        return {
          success: false,
          error: "Could not find Space name input field",
        };
      }
    } else {
      await page.type(SELECTORS.spaceNameInput, spaceName);
    }
    
    // Click create/submit button
    console.log("Creating Space...");
    await page.waitForTimeout(500);
    
    const submitFound = await waitForSelector(page, SELECTORS.createButton, 5000);
    if (submitFound) {
      await page.click(SELECTORS.createButton);
    } else {
      // Try to find any submit button
      const buttons = await page.$$('button');
      for (const button of buttons) {
        const text = await button.evaluate(el => el.textContent?.toLowerCase() || '');
        if (text.includes('create') || text.includes('submit') || text.includes('save')) {
          await button.click();
          break;
        }
      }
    }
    
    // Wait for navigation to new Space
    await page.waitForNavigation({ timeout: 10000 }).catch(() => {});
    await page.waitForTimeout(2000);
    
    // Extract Space URL
    const spaceUrl = page.url();
    
    if (!spaceUrl.includes('/spaces/')) {
      return {
        success: false,
        error: "Space creation may have failed - URL doesn't contain '/spaces/'",
      };
    }
    
    console.log(`Space created successfully: ${spaceUrl}`);
    
    return {
      success: true,
      spaceUrl,
      spaceName,
    };
    
  } catch (error) {
    console.error("Error creating Space:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error),
    };
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

// CLI interface
if (import.meta.main) {
  const projectName = process.argv[2];
  
  if (!projectName) {
    console.error("Usage: bun create-space.ts <project-name>");
    process.exit(1);
  }
  
  const result = await createSpace(projectName);
  
  if (result.success) {
    console.log("SUCCESS");
    console.log(result.spaceUrl);
  } else {
    console.error("FAILED");
    console.error(result.error);
    process.exit(1);
  }
}
