# Review: Task 5.0 - Layout responsivo — Dashboard e Cartões

**Revisor**: AI Code Reviewer
**Data**: 2026-09-11
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A implementação cumpre o objetivo da tarefa: `Tab1.tsx`/`Tab1.css` e `PaymentMethodsPage.tsx`/`.css` ganharam hooks de CSS Grid (`ctrl-dashboard-grid`, `pm-cards-grid`) que passam a ocupar bem o espaço em telas ≥992px, e os overlays (`PaymentMethodSelector`, `AddItemModal`) tiveram sua apresentação ajustada para não ficarem esticados full-bleed em desktop. A regra é 100% aditiva dentro de `@media (min-width: 992px)` — nenhuma regra existente fora desses blocos foi alterada, então o layout mobile fica provadamente intacto (confirmado lendo o diff completo de cada arquivo, não apenas o resumo). `npx tsc --noEmit` está limpo, a suíte completa (`npx vitest run`) passou 610/610 quando reexecutada de forma independente nesta revisão, e o eslint não introduziu erros novos nos arquivos tocados (o único warning encontrado em `Tab1.tsx:123` é pré-existente, de um commit de 2026-05-06, não relacionado a esta tarefa).

A decisão de não tocar `CardStack.tsx` foi verificada e está correta: `grep` confirma que o componente só é referenciado por ele mesmo e por um `vi.mock` obsoleto em `Tab1.test.tsx` — não é renderizado por nenhuma tela real.

Três pontos precisam de atenção antes de considerar a tarefa 100% fechada — nenhum é um bug funcional, mas todos são lacunas de verificação/documentação que valem a pena resolver agora, enquanto o contexto está fresco (ver "Problemas Major").

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/Tab1.tsx` | OK | 0 |
| `src/pages/Tab1.css` | Problemas | 1 (major) |
| `src/pages/PaymentMethodsPage.tsx` | OK | 0 |
| `src/pages/PaymentMethodsPage.css` | Problemas | 1 (major) |
| `src/components/PaymentMethodSelector.css` | OK | 0 |
| `src/pages/BudgetPage.css` | OK | 0 |
| `src/pages/Tab1.test.tsx` | Problemas | 1 (major) |
| `src/pages/PaymentMethodsPage.test.tsx` | Problemas | 1 (major, mesmo padrão do arquivo acima) |
| `src/components/CardStack.tsx` (não alterado) | OK | 0 — decisão de não tocar validada via grep |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

**1. `.ctrl-wrapper` é uma classe global compartilhada por 8 páginas — a regra de `max-width`/centralização adicionada afeta 6 telas fora do escopo desta tarefa, sem verificação**

- Arquivo: `src/pages/Tab1.css:7` (definição base) e `src/pages/Tab1.css:916-919` (novo bloco `@media`)
- `Tab1.css` é importado só por `Tab1.tsx` (`import './Tab1.css'`), mas `.ctrl-wrapper` também é usado por `Tab2.tsx`, `Tab3.tsx`, `CategoriesPage.tsx`, `PurchaseDetail.tsx`, `SuggestionsPage.tsx` e `AssociatePage.tsx`. Como os imports de CSS neste projeto são globais (não são CSS Modules), assim que `Tab1.css` é carregado uma vez na sessão da SPA, a regra `.ctrl-wrapper { max-width: 1100px; margin: 0 auto; }` passa a valer para essas 6 outras páginas também, não só para o dashboard.
- Verifiquei o CSS dessas 6 páginas: nenhuma delas tem hoje qualquer `@media` query (`Tab2.css`, `Tab3.css`, `SuggestionsPage.css`, `AssociatePage.css` não têm nenhuma; `CategoriesPage.css`/`PurchaseDetail.css` têm `max-width` só em elementos internos pontuais). Ou seja, hoje elas ficam full-bleed em desktop, e a mudança provavelmente as deixa *melhores* (conteúdo centralizado em vez de esticado) em vez de quebradas — mas isso é uma suposição, não algo verificado. A verificação visual documentada na tarefa cobriu apenas Tab1 (dashboard) e a tela de cartões; as outras 6 telas não foram olhadas.
- Isso também colide com o sequenciamento da Tech Spec (`Sequenciamento de Desenvolvimento > Ordem de Construção`, item 3): "Tab1 → Tab2 → Tab3 → PaymentMethodsPage → BudgetPage → demais" — ou seja, essas telas foram deliberadamente deixadas para tarefas futuras, e esta tarefa já mexeu nelas de forma incidental e não documentada.
- **Sugestão**: (a) fazer uma checagem visual rápida das 6 páginas em ≥992px antes de fechar a tarefa, e (b) adicionar uma nota de implementação em `5_task.md` (no mesmo estilo da nota sobre `CardStack.tsx`) documentando esse efeito colateral, para que a próxima tarefa (Tab2/Tab3) saiba que parte do trabalho de centralização já está feita e não tente duplicá-la ou entre em conflito.

**2. `:has()` é a primeira ocorrência desse seletor no projeto e não é suportado pela matriz de browsers declarada em `.browserslistrc`**

- Arquivo: `src/pages/PaymentMethodsPage.css:427` — `.pm-cards-grid .pm-card:has(.pm-card-expanded) { grid-column: 1 / -1; }`
- `.browserslistrc` do projeto declara `Safari >=14`, `iOS >=14`, `Chrome >=79`, `Firefox >=70`. `:has()` só é suportado a partir de Safari 15.4, Chrome 105 e Firefox 121 — ou seja, o próprio arquivo de configuração de browsers do projeto lista navegadores que não suportam a única regra `:has()` de todo o codebase, e não há precedente/convenção anterior sobre isso (`grep -rn ":has(" src` não retorna mais nenhum resultado).
- O modo de falha é gracioso (a regra simplesmente não casa; o cartão expandido fica espremido em vez de ocupar a linha inteira — não quebra funcionalidade), mas é um comportamento silencioso que diverge do critério de sucesso "sem elementos esticados ou vazios excessivos" nos navegadores mais antigos que o projeto declara suportar.
- **Sugestão preferida**: eliminar a dependência de `:has()` — o componente já sabe qual card está expandido via o estado `expandedId`/prop `isExpanded` em `PaymentMethodsPage.tsx`. Adicionar uma classe modificadora (ex.: `pm-card--expanded`) no `<PaymentMethodCard>` renderizado quando `isExpanded` é true resolve o mesmo problema com CSS 100% suportado e sem gambiarra de seletor, com uma linha a mais de JSX. Alternativa aceitável: manter `:has()` mas registrar explicitamente que é uma degradação graciosa aceita para os browsers mais antigos da lista.

**3. Testes de "desktop viewport" simulam `window.innerWidth`, mas isso não exercita o CSS/`@media` real — a alegação do teste é mais forte do que o que ele de fato verifica**

- Arquivos: `src/pages/Tab1.test.tsx:305-318` e `src/pages/PaymentMethodsPage.test.tsx:172-185` (blocos `describe('desktop viewport (lg breakpoint, 992px)', ...)`)
- `vite.config.ts` configura Vitest com `environment: 'jsdom'` e **sem** `test.css: true` — ou seja, os `import './Tab1.css'`/`import './PaymentMethodsPage.css'` são processados como stubs vazios pelo Vitest (comportamento padrão), e o jsdom não aplica `@media` queries de stylesheets de qualquer forma. Além disso, nenhum componente tocado nesta tarefa escuta `resize`/`matchMedia` em JS (confirmado nos diffs — é só CSS puro).
- Isso significa que `Object.defineProperty(window, 'innerWidth', ...)` + `window.dispatchEvent(new Event('resize'))` no `beforeEach` não têm efeito nenhum sobre o que é renderizado: os testes passariam exatamente igual sem esse setup, porque `.ctrl-dashboard-grid`/`.pm-cards-grid` e seus filhos são renderizados incondicionalmente no JSX, independente de viewport. O teste cumpre a letra do requisito da tarefa ("elementos presentes e acessíveis em viewport desktop simulado"), mas o nome/setup sugere uma cobertura de CSS responsivo que não existe — isso pode gerar falsa confiança em quem ler a suíte depois.
- **Sugestão**: remover a manipulação de `innerWidth`/`resize` (que é decorativa) e deixar claro no nome do teste/comentário que ele verifica apenas a presença dos *hooks estruturais* de grid no DOM (o que já é útil), não o comportamento visual do grid em si — que continua dependendo da verificação manual documentada na tarefa.

### Problemas Minor

1. **Contaminação de escopo em `PaymentMethodsPage.tsx` (não introduzida por esta tarefa, mas presente no mesmo diff)**: `git diff -- src/pages/PaymentMethodsPage.tsx` mostra também a remoção do campo `closingDay` de `formInitial` e de `openEditForm` — isso é uma mudança de lógica/dado real, não de layout. Confirmei que é parte de outro trabalho pendente e não relacionado (o campo `closingDay` foi removido por completo de `types/paymentMethod.ts`, `PaymentMethodForm.tsx` e dos testes, um refactor maior que não tem nada a ver com grid/CSS). Não é um defeito desta implementação, mas é um risco de higiene de commit: como as duas mudanças estão no mesmo arquivo, um `git add src/pages/PaymentMethodsPage.tsx` ingênuo misturaria a mudança de lógica de negócio de outra tarefa dentro do commit da Tarefa 5.0. Recomendo usar `git add -p` (ou equivalente) na hora de commitar, separando os hunks de grid dos hunks de `closingDay`.
2. **Débito técnico pré-existente confirmado, não bloqueante**: `react-hooks/exhaustive-deps` em `Tab1.tsx:123` (dependência `updateTab1` faltando no `useEffect`) já existia antes desta tarefa (commit `2b7cc190`, 2026-05-06). Não é desta tarefa, mas fica registrado.
3. **Limpeza futura sugerida**: `CardStack.tsx` + CSS `.ctrl-card-stack` associado + o `vi.mock('../components/CardStack', ...)` obsoleto em `Tab1.test.tsx:86` continuam no repositório como código morto. A decisão de não tocá-los nesta tarefa é correta (ver Destaques Positivos), mas vale abrir um item de backlog explícito para remover tudo isso, para não virar uma pergunta recorrente em futuras revisões.

## Destaques Positivos

- Mudança de JSX em `Tab1.tsx` é puro reagrupamento estrutural: nenhum handler, estado ou prop foi alterado — confirmado lendo o diff completo linha a linha, não só o resumo.
- Todas as regras CSS novas ficam dentro de `@media (min-width: 992px)`; nenhuma regra fora desses blocos foi tocada em nenhum dos 4 arquivos `.css`, então o layout mobile (<992px) fica provadamente pixel-idêntico, sem depender só do teste manual.
- Breakpoint `992px`/`lg` reaproveitado de forma consistente com o shell já existente (`App.tsx`, `src/theme/variables.css`, criados na Tarefa 3.0) — não foi inventado um novo valor de corte.
- Comentários CSS explicam o "porquê" (raciocínio mobile-first / por que o `:has()` existe) em vez de restatar o óbvio, alinhado com a diretriz de comentários da skill `clean-code`.
- Investigação real (via `grep`) antes de decidir não tocar `CardStack.tsx`, com a decisão documentada diretamente em `5_task.md` — evita o anti-padrão de seguir cegamente uma lista de "Arquivos relevantes" desatualizada.
- Reexecutei de forma independente: `npx tsc --noEmit` limpo, `npx vitest run` 610/610, `npx eslint` nos arquivos `.tsx` tocados sem erros novos — as alegações de verificação da tarefa se confirmaram.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| React | OK (JSX é reagrupamento puro, sem lógica nova) |
| CSS/Responsividade | Problemas (ver Major #1 e #2) |
| Testes | Problemas (ver Major #3 — cobertura real menor do que o nome sugere) |

## Recomendacoes

1. Antes de fechar a tarefa: fazer uma checagem visual rápida (ou ao menos ler o CSS) de `Tab2`, `Tab3`, `CategoriesPage`, `PurchaseDetail`, `SuggestionsPage` e `AssociatePage` em ≥992px, já que todas herdam a nova regra de `.ctrl-wrapper`; documentar o efeito colateral em `5_task.md`.
2. Substituir `.pm-card:has(.pm-card-expanded)` por uma classe modificadora aplicada via JSX (`isExpanded` já existe como prop) para eliminar a dependência de um seletor não suportado pela matriz de browsers do projeto — ou, se optarem por manter `:has()`, registrar explicitamente a degradação graciosa aceita.
3. Simplificar os blocos de teste "desktop viewport" removendo a manipulação inerte de `window.innerWidth`/`resize`, ou deixar explícito no comentário/nome que eles testam apenas a presença dos hooks estruturais de grid, não o CSS responsivo em si.
4. Ao commitar, separar por hunk (`git add -p`) as mudanças de `PaymentMethodsPage.tsx`/`PaymentMethodForm.tsx`/`types/paymentMethod.ts` relacionadas a `closingDay` (outra tarefa) das mudanças de grid desta tarefa.
5. Abrir item de backlog para remover `CardStack.tsx`, seu CSS associado e o mock obsoleto em `Tab1.test.tsx`.

## Veredito

**APROVADO COM OBSERVAÇÕES.** Não há bugs funcionais, quebra de lógica de negócio, ou regressão comprovada no mobile — os critérios de sucesso centrais da tarefa (uso do espaço ≥992px, zero regressão mobile, zero mudança de lógica) estão atendidos dentro do escopo dos arquivos revisados, e as verificações automatizadas (typecheck, lint, suíte de testes) foram reexecutadas de forma independente e confirmadas. Os 3 problemas Major são lacunas de verificação/documentação e um seletor CSS com suporte de browser não confirmado — nenhum é bloqueante por si só, mas recomendo tratá-los (pelo menos os itens 1 e 2 das Recomendações) antes de dar a tarefa 5.0 como definitivamente fechada, para não empurrar risco não verificado para as próximas tarefas (Tab2/Tab3) que dependem do mesmo `.ctrl-wrapper`.

## Atualização pós-revisão — correções aplicadas (2026-09-11)

Os 3 problemas Major foram tratados:

1. **`.ctrl-wrapper` global** — em vez de apenas verificar visualmente as 6 telas fora de escopo (Recomendação 1), a regra de largura/centralização foi movida para uma classe nova e opt-in, `.ctrl-wrapper--wide`, aplicada só em `Tab1.tsx` e `PaymentMethodsPage.tsx`. `Tab2`, `Tab3`, `CategoriesPage`, `PurchaseDetail`, `SuggestionsPage` e `AssociatePage` continuam usando apenas `.ctrl-wrapper` (sem a nova regra) e ficam exatamente como estavam antes desta tarefa — o efeito colateral foi eliminado, não apenas documentado. Isso respeita o sequenciamento da Tech Spec (Tab2/Tab3/demais ficam livres para decidir sua própria estratégia de largura na Tarefa 6.0/7.0/8.0, sem herdar nada desta tarefa).
2. **`:has()`** — removido. `PaymentMethodCard.tsx` agora aplica a classe `pm-card--expanded` no elemento raiz quando `isExpanded` é `true` (a prop já existia, não foi criado estado novo), e `PaymentMethodsPage.css` usa `.pm-cards-grid .pm-card--expanded` em vez de `:has(.pm-card-expanded)`. Comportamento idêntico, com suporte universal de browser. Adicionado `src/components/PaymentMethodCard.test.tsx` (não existia antes) cobrindo a nova classe modificadora nos estados expandido/colapsado e o `onToggle` ao clicar no cabeçalho do card.
3. **Testes "desktop viewport"** — a manipulação inerte de `window.innerWidth`/`resize` foi removida dos dois arquivos de teste; os `describe` foram renomeados (`dashboard grid structure (CSS hooks for the desktop layout)` / `cards grid structure (CSS hook for the desktop layout)`) e ganharam um comentário explicando que jsdom não avalia `@media` queries, então os testes verificam apenas a presença/acessibilidade da estrutura DOM que o CSS real usa como gancho — a cobertura visual continua sendo a verificação manual documentada em `5_task.md`.

Suíte completa reexecutada após as correções: `npx vitest run` → 613/613 (610 anteriores + 3 novos em `PaymentMethodCard.test.tsx`), `npx tsc --noEmit` limpo, `npx eslint` nos arquivos `.tsx` tocados sem erros/warnings novos (o único warning remanescente em `Tab1.tsx` é o `react-hooks/exhaustive-deps` pré-existente já registrado nos Problemas Minor, não relacionado a esta tarefa).

Os 2 itens Minor (contaminação de `closingDay` no diff de `PaymentMethodsPage.tsx`, e limpeza futura de `CardStack.tsx`) não foram alterados — são, respectivamente, um cuidado a ter na hora de commitar (usar `git add -p`) e um item de backlog, ambos fora do escopo de código desta tarefa.

**Status final: APROVADO.**
