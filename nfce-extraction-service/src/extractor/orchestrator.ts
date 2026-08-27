import { Page } from 'playwright';
import { withBrowserContext } from '../browser/browser-manager';
import { isInvoiceReadyRJ } from './readiness';
import { getBlockMessageRJ } from './block-detection';
import { extractDataFromRJ } from './extract';
import { ExtractionResult } from '../types';

// Same order of magnitude as PAGE_LOAD_TIMEOUT_MS in the client-side flow
// (controlai-frontend/src/context/InvoiceProcessingContext.tsx).
const DEFAULT_TIMEOUT_MS = 60_000;
// Same as CONTENT_POLL_INTERVAL_MS in the client-side flow.
const POLL_INTERVAL_MS = 500;

const PAGE_RELOAD_ERROR_MESSAGES = ['Execution context was destroyed', 'Frame was detached', 'Target closed'];

function isPageReloadInterruption(error: unknown): boolean {
  return error instanceof Error && PAGE_RELOAD_ERROR_MESSAGES.some((message) => error.message.includes(message));
}

// The SEFAZ-RJ anti-bot challenge (reCAPTCHA v3 / F5-TSPD) reloads the document
// several times while it runs, which tears down the execution context mid-evaluate.
// Treat that race as "not ready yet" instead of letting it reject extractInvoice.
async function evaluateWhileStable<T>(page: Page, fn: () => T): Promise<T | null> {
  try {
    return await page.evaluate(fn);
  } catch (error) {
    if (isPageReloadInterruption(error)) {
      return null;
    }
    throw error;
  }
}

async function pollForReadyOrBlocked(page: Page, deadline: number): Promise<ExtractionResult> {
  while (Date.now() < deadline) {
    const blockMessage = await evaluateWhileStable(page, getBlockMessageRJ);
    if (blockMessage) {
      return { status: 'BLOCKED', message: blockMessage };
    }

    const ready = await evaluateWhileStable(page, isInvoiceReadyRJ);
    if (ready) {
      const data = await evaluateWhileStable(page, extractDataFromRJ);
      if (data) {
        return { status: 'READY', data };
      }
    }

    await page.waitForTimeout(POLL_INTERVAL_MS);
  }

  return { status: 'TIMEOUT', message: 'Tempo esgotado ao consultar a SEFAZ' };
}

export async function extractInvoice(invoiceUrl: string): Promise<ExtractionResult> {
  const timeoutMs = Number(process.env.EXTRACTION_TIMEOUT_MS) || DEFAULT_TIMEOUT_MS;
  const deadline = Date.now() + timeoutMs;

  return withBrowserContext(async (context) => {
    const page = await context.newPage();

    try {
      await page.goto(invoiceUrl, { waitUntil: 'domcontentloaded', timeout: Math.max(0, deadline - Date.now()) });
    } catch (error) {
      return { status: 'NAVIGATION_ERROR', message: error instanceof Error ? error.message : 'Erro de navegacao' };
    }

    return pollForReadyOrBlocked(page, deadline);
  });
}
