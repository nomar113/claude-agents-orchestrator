# Fixtures de teste

As fixtures HTML deste diretório (`rj-success.html`, `rj-blocked.html`, `rj-blocked-keyword.html`, `rj-loading.html`) são páginas sintéticas escritas à mão, construídas para exercitar os mesmos seletores usados por `rj.js`/`readiness.ts`/`block-detection.ts`/`extract.ts` — não são capturas reais da SEFAZ-RJ.

**Limitação conhecida**: sem acesso a uma nota real (chave de acesso válida) no ambiente de implementação, não foi possível capturar e anonimizar uma página real de sucesso/bloqueio. Isso significa que os testes validam a *consistência interna* do parsing, mas não a *fidelidade* contra a estrutura real (mais "ruído" de wrappers/JSF/PrimeFaces) da página da SEFAZ.

**Recomendação**: antes do rollout (Tarefa 8.0), substituir ou complementar estas fixtures por capturas reais anonimizadas (CNPJ, nome do estabelecimento e endereço mascarados) de ao menos um caso de sucesso e um de bloqueio.
