# Review: Task 1.0 - Nucleo de extracao (Node): logica pura de deteccao/parsing

**Revisor**: AI Code Reviewer
**Data**: 2026-08-27
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Tarefa 1.0 portou com fidelidade as tres funcoes de `extract_data_scripts/rj.js` (`isInvoiceReadyRJ`, `getBlockMessageRJ`, `extractDataFromRJ`) para TypeScript puro, testavel via JSDOM, sem qualquer acoplamento a Playwright/rede — exatamente o escopo definido na tarefa. O codigo foi organizado em funcoes pequenas e coesas (`extractItems`, `extractTotals`, `extractPayments`, `extractDate`), o tipo `ExtractedInvoice` cobre todos os campos exigidos pela Tech Spec, e `npm run typecheck` e `npm test` rodam limpos (8/8 testes passando, `tsc --noEmit` sem erros).

A logica de parsing numerico (remocao de separador de milhar, troca de virgula por ponto, ordem das operacoes) foi reproduzida com fidelidade 1:1 em relacao ao `rj.js` original. Ha, porem, dois pontos que merecem atencao antes de avancar para a Tarefa 2.0 (integracao com Playwright/pagina real):

1. As fixtures HTML nao sao capturas reais anonimizadas da SEFAZ, como pedido explicitamente no requisito da tarefa — sao HTML sinteticos minimos, escritos sob medida para bater com os seletores ja portados, o que reduz a confianca de que o parsing sobrevivera a estrutura real da pagina.
2. A troca de `outerText` por `textContent` em `extractDate` (`extract.ts`), embora necessaria por causa da ausencia de layout no JSDOM, introduz uma comparacao de igualdade estrita (`el.textContent === ' Emissão: '`) que e mais fragil a variacoes de espacamento/quebra de linha no HTML de origem do que o `outerText` original.

Nenhum dos dois pontos é um bug hoje (os testes passam porque as fixtures foram desenhadas para o codigo atual), mas ambos representam risco real de regressao quando o parsing for exercitado contra HTML real da SEFAZ-RJ.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `nfce-extraction-service/package.json` | OK | 0 |
| `nfce-extraction-service/tsconfig.json` | OK | 0 |
| `nfce-extraction-service/jest.config.js` | OK | 0 |
| `nfce-extraction-service/src/types.ts` | OK | 0 |
| `nfce-extraction-service/src/extractor/readiness.ts` | OK | 0 (observacao minor) |
| `nfce-extraction-service/src/extractor/block-detection.ts` | Problemas | 1 minor |
| `nfce-extraction-service/src/extractor/extract.ts` | Problemas | 1 major, 2 minor |
| `nfce-extraction-service/test/extractor/readiness.test.ts` | OK | 0 |
| `nfce-extraction-service/test/extractor/block-detection.test.ts` | OK | 0 |
| `nfce-extraction-service/test/extractor/extract.test.ts` | OK | 0 |
| `nfce-extraction-service/test/fixtures/*.html` | Problemas | 1 major |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**1. Fixtures HTML sao sinteticas, nao capturas reais anonimizadas (`test/fixtures/*.html`)**

O requisito da tarefa pede explicitamente: *"Salvar fixtures HTML reais (anonimizadas de dados pessoais quando necessario)"*. As quatro fixtures (`rj-success.html`, `rj-blocked.html`, `rj-blocked-keyword.html`, `rj-loading.html`) sao paginas minimas escritas a mao, contendo apenas os elementos estritamente necessarios para os seletores passarem (`MERCADO EXEMPLO LTDA`, `Rua Exemplo, 123` etc.), sem o "ruido" estrutural tipico de uma pagina JSF/PrimeFaces real da SEFAZ (wrappers extras, scripts, atributos, elementos duplicados com a mesma classe, indentacao irregular).

Isso significa que os testes atuais validam a *consistencia interna* do codigo portado (o parsing bate com um HTML desenhado para ele), mas nao validam a *fidelidade* do parsing contra a estrutura real da pagina de consulta da SEFAZ-RJ — que e justamente o maior risco tecnico apontado na Tech Spec para este fluxo. Por exemplo, seletores genericos como `document.querySelector('.text')` (usado para CNPJ) podem casar com o elemento errado numa pagina real com mais elementos `.text`, e isso nunca seria detectado por uma fixture construida para ter exatamente um `.text`.

**Correcao sugerida**: antes de (ou durante) a Tarefa 2.0, capturar ao menos uma pagina real de sucesso e uma de bloqueio da SEFAZ-RJ (via "Salvar como" no navegador ou `view-source`), anonimizar CNPJ/nome do estabelecimento/endereco, e substituir/complementar as fixtures atuais por essas capturas. Isso e citado na propria Tech Spec como o ponto de maior incerteza do projeto ("Riscos Conhecidos"), entao vale tratar como bloqueante antes do rollout, mesmo que nao bloqueie esta tarefa isoladamente.

**2. Risco de regressao na extracao de data por troca de `outerText` para `textContent` (`extract.ts:68-75`)**

```ts
function extractDate(doc: Document): string {
  const label = Array.from(doc.querySelectorAll('strong')).find((el) => el.textContent === ' Emissão: ');
  const rawDate = label!.nextSibling!.textContent!.trim();
  return rawDate.substring(0, DATE_FIELD_LENGTH);
}
```

A troca de `outerText` (que nao existe no JSDOM) por `textContent` e a decisao correta para viabilizar testes sem browser real, e o comentario no codigo documenta bem a limitacao. Porem a comparacao usada e uma igualdade estrita contra a string literal `' Emissão: '` (um espaco antes, um depois). `outerText` reflete o texto *renderizado*, que o motor de layout colapsa (multiplas quebras de linha/espacos viram um unico espaco); `textContent` reflete o texto *bruto* do DOM, sem colapsar nada. Se o HTML real da SEFAZ tiver esse `<strong>` formatado em multiplas linhas ou com indentacao (comum em paginas geradas por JSF/PrimeFaces, que e o padrao usado por `*.faces`), `textContent` pode retornar algo como `"\n  Emissão:\n"` em vez de `" Emissão: "`, o `.find` nao encontra nenhum elemento, `label` fica `undefined`, e `label!.nextSibling` lanca `TypeError` em produção — quebrando a extracao de data em toda nota, nao so em casos extremos.

Essa fragilidade ja existe de forma latente no `rj.js` original (a comparacao exata contra `' Emissão: '` ja era arriscada), mas a troca para `textContent` a torna mais provavel de falhar com variacoes de espacamento no HTML de origem, exatamente onde o script original era mais tolerante (por depender de layout/colapso de espacos).

**Correcao sugerida**: normalizar o texto antes de comparar, do mesmo jeito que o restante do arquivo ja faz (`.replace(/\s+/g, ' ').trim()`), em vez de depender de espacos literais na string de busca:

```ts
function extractDate(doc: Document): string {
  const label = Array.from(doc.querySelectorAll('strong')).find(
    (el) => el.textContent?.replace(/\s+/g, ' ').trim() === 'Emissão:',
  );
  const rawDate = label!.nextSibling!.textContent!.trim();
  return rawDate.substring(0, DATE_FIELD_LENGTH);
}
```

Isso mantem o mesmo comportamento para as fixtures atuais e remove a dependencia de espacamento exato do HTML de origem, reduzindo o risco identificado acima. Vale validar contra uma fixture real (ver problema anterior) antes de considerar o ponto fechado.

### Problemas Minor

1. **`extract.ts`** — `extractDataFromRJ`, `extractTotals` e `getBlockMessageRJ` (`block-detection.ts`) tem linhas em branco dentro do corpo das funcoes (ex: `extract.ts:80-88`, `extract.ts:36-45`, `block-detection.ts:19-24`), o que viola literalmente o padrao "sem linhas em branco dentro de metodos/funcoes" do checklist do projeto. Na pratica isso nao prejudica a legibilidade — pelo contrario, agrupa passos logicos — mas fica registrado por aderencia estrita ao padrao adotado no repositorio.
2. **`block-detection.ts:27`** — `bodyText.slice(0, 200)` usa o numero magico `200` (ja presente no `rj.js` original). Sugestao: extrair para uma constante nomeada, ex. `const MAX_BLOCK_MESSAGE_LENGTH = 200;`, na linha do que ja foi feito com `DATE_FIELD_LENGTH` em `extract.ts`.
3. **`readiness.ts`** — o `rj.js` original tem um comentario de topo explicando por que a prontidao precisa ser feita por polling (reCAPTCHA v3 + desafio F5/TSPD recarregam o documento varias vezes). Esse contexto se perdeu na portagem e sera util para quem implementar o polling na Tarefa 2.0. Sugestao: trazer uma versao curta desse comentario para `readiness.ts`.
4. **`extract.ts`** — uso extensivo de non-null assertions (`!`) ao encadear `querySelector`/`textContent` (ex. linhas 14-19, 78-86). E fiel ao comportamento do `rj.js` original (que tambem quebra silenciosamente se um elemento nao existir) e aceitavel para esta tarefa de paridade comportamental, mas vale ter em mente na Tarefa 2.0/3.0 se for necessario diferenciar "pagina mudou de estrutura" de outros tipos de erro antes de estourar um `TypeError` generico.

## Destaques Positivos

- Fidelidade de port muito boa: toda a logica de normalizacao numerica (`replace(/\./g, '')` + `replace(',', '.')` + `parseFloat`) foi extraida para o helper `toNumber`, mantendo exatamente a mesma ordem de operacoes do `rj.js` original em todos os campos (`quantity`, `unitPrice`, `totalPrice`, `totalItems`, `subtotal`, `discount`, `total`, `taxes`, valores de `payments`).
- Remocao correta da variavel `taxesIndex` em `extractPayments` — ela existia no `rj.js` original mas nunca era usada; a remocao e uma limpeza segura que nao muda o comportamento observavel.
- Boa decomposicao em funcoes pequenas e nomeadas por verbo (`extractItems`, `extractTotals`, `extractPayments`, `extractDate`), facilitando a leitura em relacao ao bloco unico e denso do script original.
- `DATE_FIELD_LENGTH` como constante nomeada em vez do literal `"00/00/0000 00:00:00-00:00".length` espalhado inline — boa pratica de clean code.
- Fixture extra `rj-blocked-keyword.html`, cobrindo o caminho de bloqueio sem `.avisoErro` (fallback por palavra-chave no corpo da pagina) — vai alem do minimo pedido na tarefa (que citava so 3 fixtures) e cobre um ramo de logica real do `getBlockMessageRJ`.
- `tsconfig.json` com `strict`, `noUnusedLocals` e `noUnusedParameters` habilitados desde o inicio do projeto.
- Escopo respeitado: nenhuma chamada de rede, Playwright ou timer real nas funcoes portadas; tudo opera sobre `Document` recebido por parametro, como pedido nos criterios de sucesso.
- `rj.js` original nao foi modificado (verificado).

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas (blank lines internas, 1 magic number — ambos minor) |
| TypeScript/Node.js | OK (`strict` habilitado, `tsc --noEmit` limpo) |
| REST/HTTP | Nao aplicavel nesta tarefa |
| Logging | Nao aplicavel nesta tarefa |
| React | Nao aplicavel |
| Testes | OK, com ressalva major sobre realismo das fixtures |

## Recomendacoes

1. (Bloqueante antes do rollout, nao necessariamente antes da Tarefa 2.0) Capturar HTML real anonimizado de ao menos um caso de sucesso e um de bloqueio da SEFAZ-RJ e usar essas capturas para validar/complementar as fixtures atuais.
2. Ajustar `extractDate` em `extract.ts` para normalizar espacos antes de comparar o rotulo `Emissão:`, em vez de igualdade estrita contra `' Emissão: '` — reduz risco de `TypeError` em producao por variacao de espacamento no HTML de origem.
3. Extrair o `200` de `block-detection.ts` para uma constante nomeada, seguindo o padrao ja usado com `DATE_FIELD_LENGTH`.
4. Considerar trazer de volta, em `readiness.ts`, uma versao curta do comentario original sobre o motivo do polling (reCAPTCHA v3 / desafio F5-TSPD), util para quem implementar a Tarefa 2.0.
5. Opcional: revisitar as linhas em branco dentro de funcoes em `extract.ts`/`block-detection.ts` se a equipe quiser aderencia estrita ao padrao de "sem blank lines em metodos" do projeto.

## Resolucao pos-review

- **Major #2 (fragilidade de `extractDate`)**: corrigido. `extractDate` agora normaliza espacos/quebras de linha (`.replace(/\s+/g, ' ').trim()`) antes de comparar o rotulo `Emissão:`, igual ao padrao ja usado no resto do arquivo. `npm run typecheck` e `npm test` seguem limpos (8/8) apos a mudanca.
- **Minor `MAX_BLOCK_MESSAGE_LENGTH`**: corrigido. Numero magico `200` extraido para constante nomeada em `block-detection.ts`.
- **Minor comentario de `readiness.ts`**: corrigido. Reintroduzido um resumo curto do motivo do polling (reCAPTCHA v3 / desafio F5-TSPD), util para a Tarefa 2.0.
- **Minor blank lines internas**: nao alterado — mantidas por legibilidade (agrupam passos logicos), conforme opcao explicitamente marcada como opcional na review.
- **Major #1 (fixtures sinteticas, nao capturas reais)**: **nao resolvido nesta tarefa** — nao havia acesso, no ambiente de implementacao, a uma pagina real da SEFAZ-RJ nem a uma chave de acesso valida para gerar um scan real. Documentado em `nfce-extraction-service/test/fixtures/README.md` como limitacao conhecida, com recomendacao explicita de substituir/complementar por capturas reais anonimizadas antes da Tarefa 8.0 (smoke test manual/rollout). Fica como item aberto para quem tiver acesso a um scan real.

## Veredito

Codigo aprovado com observacoes. A portagem e fiel ao `rj.js` original, o typecheck e os testes rodam limpos, e a arquitetura de funcoes puras cumpre exatamente o que a Tarefa 1.0 pedia. As duas observacoes major (fixtures sinteticas e a fragilidade de `extractDate` apos a troca de `outerText` por `textContent`) nao invalidam o trabalho feito, mas sao riscos reais e concretos para quando essa logica for exercitada contra a pagina real da SEFAZ-RJ na Tarefa 2.0 — recomenda-se trata-las antes de considerar a extracao pronta para producao, idealmente durante a validacao manual contra a SEFAZ real ja prevista no sequenciamento da Tech Spec.
