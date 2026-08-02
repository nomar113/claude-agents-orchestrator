# Review: Task 2.0 - Componente base `PetalDistributionChart` com geometria das petalas

**Revisor**: AI Code Reviewer
**Data**: 2026-07-07
**Arquivo da task**: 2_task.md
**Status**: APROVADO

## Resumo

A task adicionou `d3-shape ^3.2.0` e `d3-scale ^3.3.0` (com os respectivos `@types`) ao `controlai-frontend` e criou o componente `src/components/PetalDistributionChart.tsx`: SVG com `viewBox 0 0 300 300`, uma petala por categoria elegivel (`type === 'EXPENSE' && expected > 0 && actual > 0`), forma de folha/amendoa via `lineRadial` + `curveCatmullRomClosed`, comprimento proporcional a `min(ratio, OVERFLOW_CAP)` com `OVERFLOW_CAP = 1.5` (via `scaleLinear`), cor por `getCategoryColor` da Task 1.0 e texto do percentual inteiro (`Math.round(ratio * 100)`) — inclusive acima de 100% sem truncar. `buildPetals` e memoizado com `useMemo` e a interface `PetalDistributionChartProps` segue exatamente a techspec (callbacks presentes e ainda inertes, conforme o escopo desta task). Acompanham 8 testes Vitest cobrindo filtragem e percentuais. Qualidade geral: muito boa; apenas apontamentos minor de refinamento.

Validacoes executadas nesta review:

- `npx vitest run src/components/PetalDistributionChart.test.tsx` → **8 passed, 0 failed**
- `npx vitest run` (suite completa) → **359 passed, 0 failed**
- `npx tsc --noEmit` → **sem erros**
- `npm run build` (tsc + vite build) → **sucesso** (warning pre-existente de chunk > 500 kB, nao relacionado)
- `npx eslint` nos dois arquivos novos → **sem issues**
- Validacao visual via dev server reportada pelo implementador (screenshot com a flor renderizada) — subtarefa 2.4.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PetalDistributionChart.tsx` | OK | 6 minor |
| `src/components/PetalDistributionChart.test.tsx` | OK | 1 minor |
| `package.json` | OK | 0 |

## Conferencia dos Requisitos da Task

| Requisito | Status |
|-----------|--------|
| `d3-shape ^3` e `d3-scale ^3` no `package.json`; `vite build` passando | OK — apenas `lineRadial`, `curveCatmullRomClosed` (curve factory do `d3-shape`) e `scaleLinear` sao importados; `arc` nao foi necessario |
| Interface `PetalDistributionChartProps` da techspec (`items`, `onPetalClick`, `onViewDetailsClick`) | OK — assinatura identica; callbacks sem efeito, como previsto para esta task (interacao e a Task 5.0) |
| Filtragem colocalizada no componente (`EXPENSE`, `expected > 0`, `actual > 0`) | OK — `filterEligible` interno, requisitos 1.1–1.3 do PRD |
| `ratio = actual / expected`; `percent = Math.round(ratio * 100)` exibido por petala | OK — requisitos 1.4 e 2.1 do PRD; `112%` exibido sem truncar |
| Geometria da techspec: `viewBox 0 0 300 300`, setor `2π / N`, folha via `lineRadial`, `petalLength ∝ min(ratio, OVERFLOW_CAP)`, `OVERFLOW_CAP = 1.5` | OK — `scaleLinear().domain([0, OVERFLOW_CAP]).range([BASE_RADIUS, MAX_RADIUS])` implementa exatamente a formula `baseRadius + (maxRadius - baseRadius) * min(ratio, cap) / cap`; `halfWidth = (2π/N) * 0.45` conforme techspec |
| Cores via `getCategoryColor` (Task 1.0) | OK — chaveado por `categoryId` com `index` como fallback, como especificado |
| Validacao visual com dados estaticos no dev server | OK — reportada com screenshot |
| `buildPetals` memoizado via `useMemo` (skill `vercel-react-best-practices`) | OK |
| Comentarios em ingles (convencao dos repos controlai) | OK |

Itens explicitamente fora do escopo (Tasks 3–7) e corretamente ausentes: overflow visual/cor de alerta (`isOverflow` ja e calculado, preparando a Task 3.0), titulo/legenda/circulo de limite/CSS, estado vazio, acessibilidade/interacao e integracao com `Tab1.tsx`.

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`src/components/PetalDistributionChart.tsx:103-104` — caso degenerado com apenas 1 petala.** Com uma unica categoria elegivel, `halfWidth = 2π * 0.45 ≈ 2.83 rad` (~162° para cada lado), e o contorno Catmull-Rom fecha um "blob" que envolve quase o circulo inteiro, em vez de uma folha. A formula segue a techspec (que nao trata N=1), entao nao e um desvio — mas vale um clamp defensivo antes do polimento visual da Task 4.0:

   ```ts
   const MAX_HALF_WIDTH = Math.PI / 3;
   const halfWidth = petals.length > 0
     ? Math.min(((2 * Math.PI) / petals.length) * PETAL_WIDTH_FACTOR, MAX_HALF_WIDTH)
     : 0;
   ```

   Sugestao: cobrir N=1 com um teste visual/snapshot na Task 4.0.

2. **`src/components/PetalDistributionChart.tsx:119-121, 135-136` — numeros magicos no layout do rotulo.** `0.45` (limiar de "cabe dentro"), `0.72` (posicao radial do texto), `14` (offset externo), `13` (fonte) e `700` (peso) estao inline. O padrao do projeto pede constantes nomeadas:

   ```ts
   const LABEL_FIT_RATIO = 0.45;
   const LABEL_INSIDE_POSITION = 0.72;
   const LABEL_OUTSIDE_OFFSET = 14;
   const LABEL_FONT_SIZE = 13;
   ```

   `fontSize`/`fontWeight` podem tambem migrar para o CSS na Task 4.0.

3. **`src/components/PetalDistributionChart.tsx:143` — cor `#0D1028` hardcoded no circulo central.** Duplica o `PETAL_TEXT_COLOR` de `categoryColors.ts` e a cor de fundo do tema. Extrair para constante nomeada agora, ou mover para o CSS/token de tema (`var(--ion-background-color)`) na Task 4.0 — mesma observacao ja feita na review da Task 1.0 sobre literais de cor.

4. **`src/components/PetalDistributionChart.tsx:48` — divisao por zero implicita quando nao ha elegiveis.** `sectorAngle = (2 * Math.PI) / eligible.length` vira `Infinity` com lista vazia. E inofensivo hoje (o `map` em array vazio nunca usa o valor), mas um early return deixa a intencao explicita e blinda refactors futuros (a Task 5.0 de estado vazio vai mexer exatamente nesse caminho):

   ```ts
   if (eligible.length === 0) return [];
   ```

5. **`src/components/PetalDistributionChart.tsx:84-88` — gerador `lineRadial` recriado por petala a cada render.** Os accessors de `angle`/`radius` sao estaticos; o gerador pode ser constante de modulo, restando so `.curve(...)` fixo tambem. Micro-otimizacao coerente com a memoizacao ja aplicada em `buildPetals`.

6. **`src/components/PetalDistributionChart.tsx:5` — `CategoryColor` importado como import de valor.** E uma interface usada apenas como tipo; usar `import { getCategoryColor } from ...` + `import type { CategoryColor } from ...` mantem consistencia com a linha 4 (`import type { BudgetItemSummary }`) e evita dependencia do elidir automatico do bundler.

7. **`src/components/PetalDistributionChart.test.tsx:6-9` — `nextId` mutavel de modulo sem reset.** Os ids gerados dependem da ordem de execucao dos testes; hoje e inocuo (unicidade preservada e os asserts relevantes fixam `categoryId`), mas um `beforeEach(() => { nextId = 1; })` melhora o isolamento e a previsibilidade de eventuais snapshots futuros.

Observacao de estilo (nao contabilizada): ha linhas em branco dentro de `buildPetals` e `petalPath` e alguns comentarios explicativos. Os comentarios sao justificaveis (documentam convencoes nao obvias do `lineRadial` — 0 rad as 12h, sentido horario — e a razao do cap de overflow) e estao em ingles conforme a convencao do repo; mantidos como aceitos.

## Destaques Positivos

- **Geometria fiel a techspec com codigo declarativo**: o `scaleLinear` com dominio `[0, OVERFLOW_CAP]` e range `[BASE_RADIUS, MAX_RADIUS]` implementa a formula de `petalLength` da techspec de forma exata e legivel, sem trigonometria manual.
- **Recomendacoes da review da Task 1.0 ja incorporadas**: o componente consome `getCategoryColor` com as constantes de modulo (`PETAL_TEXT_COLOR`, `OVERFLOW_COLOR`) e a guarda `toValidKey` que foram sugeridas — bom fechamento de ciclo entre tasks.
- **Preparacao limpa para as proximas tasks**: `PetalDatum` ja carrega `isOverflow`, `ratio` sem cap e `color` completo, deixando a Task 3.0 (overflow visual) como mudanca puramente aditiva.
- **Rotulo legivel em petalas curtas**: a heuristica de posicionar o percentual fora da ponta (na cor da petala) quando ela e curta demais mostra atencao a hierarquia visual (skill `frontend-design`) alem do minimo pedido.
- **Testes objetivos e independentes de implementacao**: uso de `data-testid`/`data-category-id` em vez de acoplamento a estrutura do SVG; cobertura vai alem do exigido (arredondamento `876/1000 → 88%`, "nenhum elegivel" e `>100%` sem truncar).
- **Escopo respeitado**: nada de legenda, overflow, interacao ou CSS vazou para esta task; callbacks existem apenas na interface, como combinado.
- **Comentarios em ingles**, alinhados a convencao dos repos controlai apontada em reviews anteriores.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (minors de constantes nomeadas e formatacao) |
| TypeScript/Node.js | OK (`tsc --noEmit` sem erros, sem `any`, tipos de props explicitos) |
| REST/HTTP | Nao aplicavel |
| Logging | Nao aplicavel |
| React | OK (`useMemo` em `buildPetals`, componente controlado por props, sem fetch interno, keys estaveis por `categoryId`) |
| Testes | OK (8/8 no componente; 359/359 na suite; cobre todos os casos exigidos pela task) |

## Recomendacoes

1. (Opcional, pode ir junto da Task 4.0) Adicionar clamp de `halfWidth` para o caso N=1 (minor 1) e validar visualmente com 1 categoria.
2. (Opcional) Extrair as constantes de layout do rotulo e a cor do circulo central (minors 2 e 3) — parte disso migra naturalmente para o CSS na Task 4.0.
3. (Opcional) Early return em `buildPetals` para lista vazia (minor 4) — a Task 5.0 (estado vazio) e o momento natural.
4. (Opcional) Hoist do gerador `lineRadial`, `import type` para `CategoryColor` e reset de `nextId` nos testes (minors 5–7).

## Veredito

**APROVADO.** Nenhum problema critico ou major. Os 7 apontamentos minor sao refinamentos opcionais, varios com endereco natural nas Tasks 4.0 e 5.0, e nao bloqueiam o merge nem a sequencia. Todos os requisitos da task, do PRD (1.1–1.4, 2.1) e da techspec (interfaces, geometria, filtragem colocalizada) foram atendidos, com typecheck, testes (8/8 e 359/359), build e lint passando. Proximo passo: Task 3.0 (overflow visual com `getOverflowColor` e `data-overflow`), que ja encontra `isOverflow` pronto no `PetalDatum`.
