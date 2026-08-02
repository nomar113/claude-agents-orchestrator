# Tech Spec — Gráfico de Pétalas (Distribuição de Gastos)

PRD de referência: `tasks/prd-grafico-petalas-distribuicao/prd.md`.

## Resumo Executivo

O gráfico de pétalas será um novo componente React (`PetalDistributionChart`) renderizado dentro de `src/pages/Tab1.tsx`, **substituindo a seção atual “GASTOS POR CATEGORIA”** quando o orçamento existe e o usuário **não está em modo de edição**. No modo de edição (`isEditing === true`), o app continua exibindo a lista atual de `BudgetCategoryCard`, garantindo que o fluxo de criar/editar/remover itens do orçamento siga inalterado.

O componente é construído com **SVG puro renderizado pelo React** e utiliza `d3-shape` + `d3-scale` apenas para gerar paths radiais e escalas — sem manipulação imperativa de DOM por D3. A fonte de dados é o `BudgetSummary` já carregado por `loadBudget()`; nenhum endpoint novo é necessário. O toque em uma pétala reutiliza o `handleCategoryClick` existente (seta `selectedCategoryFilter` e rola até `PurchaseList`). O botão “Ver gastos detalhados” faz `scrollIntoView` em direção à seção “Últimas Compras” já presente na Tab1.

## Arquitetura do Sistema

### Visão Geral dos Componentes

Novos:

- `src/components/PetalDistributionChart.tsx` — componente principal. Recebe os itens do orçamento e callbacks; renderiza o SVG da flor, legenda, indicador de limite (100%), botão “Ver gastos detalhados” e estado vazio. Decide internamente quais itens entram no chart (`expected > 0` e `actual > 0`).
- `src/components/PetalDistributionChart.css` — estilos, alinhados ao tema escuro existente (`#0D1028`–`#0E1832`), tipografia IBM Plex.
- `src/components/PetalDistributionChart.test.tsx` — testes unitários (Vitest + Testing Library) seguindo o padrão dos componentes existentes.
- `src/utils/categoryColors.ts` — paleta fixa + função pura `getCategoryColor(categoryId, index)` para atribuir cor determinística por categoria, e `getOverflowColor()` para o estado de alerta.
- `src/utils/categoryColors.test.ts` — testes da função pura.

Modificados:

- `src/pages/Tab1.tsx` — na renderização da seção `expenses`, ramificar entre `PetalDistributionChart` (modo leitura) e a lista atual de `BudgetCategoryCard` (modo edição). Adicionar `ref` para a seção `purchasesSectionRef` (já existente) como destino do scroll do botão “Ver gastos detalhados”.
- `package.json` — adicionar `d3-shape` e `d3-scale` como dependências (`^3`).

Relacionamentos / fluxo de dados:

```
Tab1.tsx
  ├─ loadBudget() → setSummary(BudgetSummary)
  ├─ if (!isEditing && summary)
  │     └─ <PetalDistributionChart
  │           items={summary.items.filter(EXPENSE)}
  │           onPetalClick={handleCategoryClick}
  │           onViewDetailsClick={() => purchasesSectionRef.current?.scrollIntoView(...)}
  │        />
  └─ else
        └─ map(BudgetCategoryCard)  // fluxo atual de edição
```

Dentro de `PetalDistributionChart`:

```
items → filterEligible() → geometry(items)
                              ├─ angleScale (d3-scale)
                              └─ petalPath(angle, percentNormalized, isOverflow)
                                    ↳ produz <path d="..."> via d3-shape (lineRadial)
```

## Design de Implementação

### Interfaces Principais

```ts
// PetalDistributionChart.tsx
import type { BudgetItemSummary } from '../types/budget';

export interface PetalDistributionChartProps {
  items: BudgetItemSummary[];                  // todos os EXPENSE do BudgetSummary
  onPetalClick: (categoryId: number) => void;  // reusa handleCategoryClick
  onViewDetailsClick: () => void;              // dispara scroll para PurchaseList
}

const PetalDistributionChart: React.FC<PetalDistributionChartProps> = (...);
export default PetalDistributionChart;
```

```ts
// utils/categoryColors.ts
export interface CategoryColor {
  base: string;   // cor da pétala normal
  text: string;   // cor do texto do percentual sobre a pétala
}

export function getCategoryColor(categoryId: number, index: number): CategoryColor;
export function getOverflowColor(): CategoryColor;  // #FF6B6B
```

```ts
// internal helpers (PetalDistributionChart.tsx) — NÃO exportados
interface PetalDatum {
  categoryId: number;
  categoryName: string;
  expected: number;
  actual: number;
  percent: number;          // arredondado para inteiro
  ratio: number;            // actual / expected (sem cap)
  isOverflow: boolean;      // ratio > 1
  color: CategoryColor;
  angle: number;            // radianos, distribuído por 2π / N
}

function buildPetals(items: BudgetItemSummary[]): PetalDatum[];
function petalPath(angle: number, ratio: number, baseRadius: number, maxRadius: number): string;
```

### Modelos de Dados

Nenhuma alteração em modelos de domínio. Reaproveita:

- `BudgetSummary.items: BudgetItemSummary[]` (já carregado por `getBudgetSummary`).
- Filtro aplicado dentro do componente:
  - `item.type === 'EXPENSE'`
  - `item.expected > 0` (categoria com orçamento definido)
  - `item.actual > 0` (categoria com gasto > 0 no mês)

Cálculo:

- `ratio = item.actual / item.expected`
- `percent = Math.round(ratio * 100)`
- `isOverflow = ratio > 1`
- Para geometria, o comprimento normalizado da pétala é `min(ratio, OVERFLOW_CAP)` com `OVERFLOW_CAP = 1.5` (categorias com mais de 150% ainda crescem até o cap visual; texto exibe o percentual real).

### Endpoints de API

Nenhum endpoint novo. Consumo do endpoint existente: `GET /budgets?month=YYYY-MM` (via `getBudgetSummary`).

### Geometria das Pétalas

- Centro do SVG: `(cx, cy)`. `viewBox="0 0 300 300"` (escala responsiva via CSS).
- `baseRadius` = raio do círculo central (botão preto da imagem) ≈ `cx * 0.08`.
- `limitRadius` = raio do círculo de referência “Limite = 100%” ≈ `cx * 0.6`.
- `maxRadius` = raio máximo da pétala em overflow ≈ `cx * 0.9`.
- Cada pétala ocupa um setor angular `2π / N` e é desenhada como uma forma de “folha/amêndoa” via `d3.lineRadial`:
  - Pontos do contorno: arco saindo de `(baseRadius, angle - halfWidth)`, indo até `(petalLength, angle)` na ponta, voltando por `(baseRadius, angle + halfWidth)`.
  - `halfWidth` ≈ `(2π / N) * 0.45` para sobreposição visual harmoniosa.
  - `petalLength = baseRadius + (maxRadius - baseRadius) * min(ratio, OVERFLOW_CAP) / OVERFLOW_CAP`.
- O círculo tracejado de limite é renderizado em `r = limitRadius` com `stroke-dasharray`.

## Pontos de Integração

Não há integrações externas novas. Pontos internos relevantes:

- **Filter scroll**: o callback `onPetalClick` invoca `handleCategoryClick(categoryId)` do `Tab1.tsx`, que já seta `selectedCategoryFilter` e chama `contentRef.current?.scrollToBottom(300)`.
- **Ver gastos detalhados**: o callback `onViewDetailsClick` deve fazer `purchasesSectionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })`. A `ref` já existe; só precisa ser passada.
- **Acessibilidade**: cada `<path>` de pétala recebe `role="button"`, `tabIndex={0}`, `aria-label="{categoryName}: {percent}% do limite{overflow ? ', acima do limite' : ''}"`, `onClick` e `onKeyDown` (Enter/Space).

## Abordagem de Testes

### Testes Unitários (Vitest + @testing-library/react)

`PetalDistributionChart.test.tsx`:

- Renderiza uma pétala por item com `expected > 0` e `actual > 0`.
- **Não** renderiza pétala para item com `expected === 0` (sem orçamento) — caso fica oculto.
- **Não** renderiza pétala para item com `actual === 0` (sem gasto no mês).
- Exibe o título “DISTRIBUIÇÃO” e o indicador “Limite = 100%”.
- Exibe percentual numérico inteiro (`87%`, `112%`) por pétala.
- Pétala com `actual > expected` recebe `data-overflow="true"` e cor de alerta (`getOverflowColor()`).
- Pétala com `actual > expected` mantém o número real (ex.: `112%`), sem truncar.
- Legenda lista cada categoria visível com nome e cor.
- Clique na pétala dispara `onPetalClick` com o `categoryId` correto.
- Clique na legenda da categoria dispara o mesmo `onPetalClick`.
- Tecla `Enter` na pétala focada dispara `onPetalClick`.
- Clique no botão “Ver gastos detalhados” dispara `onViewDetailsClick`.
- Estado vazio: quando a lista filtrada está vazia, renderiza mensagem e mantém o botão “Ver gastos detalhados” visível.
- `aria-label` da pétala segue formato `"{categoria}: {n}% do limite"` e inclui `", acima do limite"` quando overflow.

`utils/categoryColors.test.ts`:

- `getCategoryColor` é determinístico para o mesmo `categoryId` em chamadas diferentes.
- A paleta cobre pelo menos 12 cores distintas para evitar colisão em uso comum (até 12 categorias).
- `getOverflowColor()` retorna `#FF6B6B` (alinhado ao restante do app).

Mocks: nenhum serviço externo. `BudgetItemSummary[]` é construído inline em cada teste.

### Testes de Integração

Não há testes de integração separados; cobertura combinada via `Tab1.test.tsx`:

- Renderiza `PetalDistributionChart` (e não a lista de `BudgetCategoryCard`) quando `summary` existe e `isEditing` é `false`.
- Renderiza a lista de `BudgetCategoryCard` quando `isEditing` é `true`.
- Clique em pétala filtra `PurchaseList` (verifica via `selectedCategoryFilter`).
- Clique em “Ver gastos detalhados” foca a seção `Últimas Compras` (verifica `scrollIntoView` mockado).

### Testes E2E

Não obrigatórios para esta feature. Caso o time decida incluir um teste smoke via Cypress, deve cobrir: abrir Tab1 → ver gráfico → tocar pétala → conferir filtro aplicado em `PurchaseList`.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **`utils/categoryColors.ts` + testes** — função pura, sem dependências; libera o uso de cores nos passos seguintes.
2. **Adição das dependências** (`d3-shape`, `d3-scale`) ao `package.json` e instalação. Conferir `vite build` continua passando.
3. **`PetalDistributionChart` (estrutura + geometria)** — primeiro com dados estáticos in-component para validar visual no `ionic serve`.
4. **CSS do componente** — alinhar com tema escuro existente; estados de overflow, foco e toque.
5. **Estado vazio + botão “Ver gastos detalhados”** — incluir os caminhos secundários.
6. **Acessibilidade** — `role`, `aria-label`, `tabIndex`, teclado.
7. **Integração com `Tab1.tsx`** — substituir `expenses` no modo leitura; manter lista no modo edição; passar `purchasesSectionRef` para o callback.
8. **Testes unitários** do componente e do utilitário de cores.
9. **Ajuste de `Tab1.test.tsx`** para cobrir o ramo de exibição leitura/edição.

### Dependências Técnicas

- `d3-shape ^3` e `d3-scale ^3` (utilizar apenas `lineRadial`, `arc`, `scaleLinear`).
- Nenhum endpoint backend novo.
- Pré-requisito de negócio: a categoria precisa ter limite (`expected`) configurado no orçamento mensal — fluxo já existente.

## Monitoramento e Observabilidade

O app não possui infra de métricas (Prometheus/Grafana) no frontend. Observabilidade prática:

- Logs `console.warn` apenas em casos defensivos (ex.: `items` veio nulo) — sem `console.log` ruidoso.
- Em produção, eventos do gráfico podem ser instrumentados em iteração futura (analytics ainda não está integrado no app).
- Verificação manual via `ionic serve` após cada etapa (consistente com a instrução do `CLAUDE.md` do `controlai-frontend`).

## Considerações Técnicas

### Decisões Principais

- **SVG renderizado pelo React + utilitários D3 mínimos**: aproveita o domínio do D3 para geometria radial sem o custo de uma lib completa de chart. Mantém o stack Ionic/React idiomático e o bundle enxuto para o app mobile com Capacitor.
- **Substituir “Gastos por Categoria” apenas no modo leitura**: preserva integralmente o fluxo de edição (criar item, editar limite, deletar, adicionar categoria) sem reescrever a UI de edição como “sub-form do gráfico”.
- **Reuso de `handleCategoryClick` e de `purchasesSectionRef`**: minimiza estado novo; o gráfico vira uma nova entrada para fluxos já testados.
- **Filtragem dentro do componente**: a regra `expected > 0 && actual > 0` fica colocalizada com o desenho do gráfico, evitando vazar a regra para o `Tab1.tsx`.
- **Paleta fixa com fallback determinístico por `categoryId`**: garante consistência visual entre meses sem exigir mudança no backend / tipo `Category`. Categorias adicionadas no futuro caem na paleta cíclica.

### Trade-offs Considerados

- D3 vs. SVG cru: D3 (apenas `d3-shape`/`d3-scale`) reduz risco de bugs de trigonometria ao custo de ~10 kB gzipped.
- Substituir a seção vs. acrescentar (manter as duas): substituir é o que o produto pediu e evita poluição vertical na Tab1.
- Cor por hash vs. paleta fixa: paleta foi escolhida por previsibilidade visual e alinhamento com a imagem do Paper.

### Riscos Conhecidos

- **Renderização em iOS (WebKit)**: filtros e gradientes em SVG podem render diferente. Mitigação: estilos chapados, sem `filter:` complexos; testar no simulador iOS após o passo 7.
- **Sobreposição visual** das pétalas com muitas categorias (12+): mitigação via cap de `OVERFLOW_CAP` e largura angular calculada por `N`; documentar limite prático visual ~12.
- **Área de toque pequena em pétalas curtas**: pétalas com poucos percentuais (ex.: 24%) podem ficar com área tocável reduzida. Mitigação: garantir `petalLength` mínimo (ex.: 30% do raio do limite) e ampliar via overlay invisível com área mínima de 44×44 pt sobre cada pétala.
- **Sincronização visual com a paleta**: caso categorias sejam reordenadas/renomeadas, a cor pode mudar. Mitigação: chave de cor por `categoryId` (estável), não por nome.

### Conformidade com Skills Padrões

Skills aplicáveis (existentes no projeto):

- `frontend-design` — guidelines de UI de alto padrão; o componente deve cumprir hierarquia visual, microinterações e acessibilidade.
- `ionic-design` — uso correto de componentes Ionic e padrões mobile-first (não há `IonChart`; o componente vive dentro de `IonContent` como bloco custom).
- `vercel-react-best-practices` — memoizar derivações pesadas (`buildPetals`) via `useMemo` e estabilizar callbacks com `useCallback`; evitar re-render desnecessário do `Tab1`.
- `clean-code` — funções pequenas e nomeadas (`buildPetals`, `petalPath`, `getCategoryColor`).

Não há desvios das skills.

### Arquivos relevantes e dependentes

Novos:

- `src/components/PetalDistributionChart.tsx`
- `src/components/PetalDistributionChart.css`
- `src/components/PetalDistributionChart.test.tsx`
- `src/utils/categoryColors.ts`
- `src/utils/categoryColors.test.ts`

Modificados:

- `src/pages/Tab1.tsx` (ramificação leitura/edição da seção de gastos; passar ref e callbacks)
- `src/pages/Tab1.test.tsx` (cobertura do novo ramo)
- `package.json` (`d3-shape`, `d3-scale`)

Dependentes (consultados, não alterados):

- `src/types/budget.ts` (`BudgetSummary`, `BudgetItemSummary`)
- `src/services/budgetService.ts` (`getBudgetSummary`)
- `src/components/BudgetCategoryCard.tsx` (paleta de cores e tons de overflow servem de referência visual)
- `src/components/PurchaseList.tsx` (alvo do scroll do botão “Ver gastos detalhados”)
- `src/theme/variables.css` e `src/pages/Tab1.css` (tokens de cor/tipografia)
