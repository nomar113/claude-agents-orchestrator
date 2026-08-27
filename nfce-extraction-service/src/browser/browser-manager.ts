import { chromium as playwrightChromium, Browser, BrowserContext } from 'playwright';
import { addExtra } from 'playwright-extra';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const stealthPlugin = require('puppeteer-extra-plugin-stealth');

const chromium = addExtra(playwrightChromium);
chromium.use(stealthPlugin());

let browserPromise: Promise<Browser> | null = null;
let openContextCount = 0;

async function getBrowser(): Promise<Browser> {
  if (!browserPromise) {
    browserPromise = chromium.launch({ headless: true });
  }
  return browserPromise;
}

export function getOpenContextCount(): number {
  return openContextCount;
}

export async function withBrowserContext<T>(fn: (context: BrowserContext) => Promise<T>): Promise<T> {
  const browser = await getBrowser();
  const context = await browser.newContext();
  openContextCount += 1;
  try {
    return await fn(context);
  } finally {
    await context.close();
    openContextCount -= 1;
  }
}

export async function closeBrowser(): Promise<void> {
  if (browserPromise) {
    const browser = await browserPromise;
    browserPromise = null;
    await browser.close();
  }
}
