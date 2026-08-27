import { Router } from 'express';
import { internalAuth } from '../middleware/internal-auth';
import { extractInvoice } from '../extractor/orchestrator';

export const extractRouter = Router();

extractRouter.use(internalAuth);

interface ExtractRequestBody {
  invoiceUrl: string;
}

function isValidBody(body: unknown): body is ExtractRequestBody {
  return (
    typeof body === 'object' &&
    body !== null &&
    typeof (body as Record<string, unknown>).invoiceUrl === 'string' &&
    (body as Record<string, unknown>).invoiceUrl !== ''
  );
}

extractRouter.post('/extract', async (req, res) => {
  const startedAt = Date.now();

  if (!isValidBody(req.body)) {
    res.status(400).json({ error: 'invoiceUrl é obrigatório e deve ser uma string não vazia' });
    return;
  }

  try {
    const result = await extractInvoice(req.body.invoiceUrl);
    console.log(
      JSON.stringify({ route: 'POST /extract', status: result.status, durationMs: Date.now() - startedAt }),
    );
    res.status(200).json(result);
  } catch (error) {
    console.error(
      JSON.stringify({
        route: 'POST /extract',
        status: 'ERROR',
        durationMs: Date.now() - startedAt,
        message: error instanceof Error ? error.message : String(error),
      }),
    );
    res.status(500).json({ error: 'Erro inesperado ao processar a extração' });
  }
});
