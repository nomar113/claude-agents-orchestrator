// When the anti-bot check rejects the request SEFAZ serves resultadoQRCode.faces
// (without the "2") carrying only this element, e.g. "Não foi possível validar o acesso."
// There's also a second, unrelated block page (IP reputation list) that carries no
// ".avisoErro" element at all — just plain static text — so it falls through to the
// keyword scan below instead.
//
// This function is passed directly to Playwright's page.evaluate, which serializes it
// via toString() and re-runs it isolated in the browser — any reference to module-level
// scope (constants included) would throw a ReferenceError there, so it must stay self-contained.
export function getBlockMessageRJ(): string | null;
export function getBlockMessageRJ(doc: Document): string | null;
export function getBlockMessageRJ(doc: Document = document): string | null {
  const MAX_BLOCK_MESSAGE_LENGTH = 200;
  const BLOCK_KEYWORD_INDICATORS = [
    'não foi possível localizar a nf-e',
    'não se refere a um documento fiscal eletrônico',
    'página da web não disponível',
    'erro na consulta',
    'serviço indisponível',
    'erro interno do servidor',
    'tempo limite excedido',
    'conexão recusada',
    'acesso negado',
    'nossos serviços de segurança da informação',
  ];

  const el = doc.querySelector('.avisoErro');
  if (el) {
    return (el.textContent ?? '').replace(/\s+/g, ' ').trim();
  }

  const bodyText = (doc.body?.textContent ?? '').replace(/\s+/g, ' ').trim();
  if (bodyText.length === 0) {
    return null;
  }

  const normalized = bodyText.toLowerCase();
  const matched = BLOCK_KEYWORD_INDICATORS.find((indicator) => normalized.includes(indicator));
  return matched ? bodyText.slice(0, MAX_BLOCK_MESSAGE_LENGTH) : null;
}
