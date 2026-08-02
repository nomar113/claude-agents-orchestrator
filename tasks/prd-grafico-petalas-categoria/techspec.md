# Tech Spec — Gráfico de Pétalas por Categoria (Tela "Por Categoria" + Detalhe de Categoria)

PRD de referência: `tasks/prd-grafico-petalas-categoria/prd.md`.
Dependência: `tasks/prd-grafico-petalas-distribuicao/techspec.md` (componente `PetalDistributionChart`).

## Resumo Executivo

A funcionalidade adiciona uma nova página Ionic (`ByCategoryPage`, rota `/by-category?month=YYYY-MM`) e um bottom sheet de detalhe de categoria (`CategoryDetailSheet`, `IonModal` sheet). A página consome o endpoint existente `GET /budgets?month=` (`BudgetSummary`) — a mesma fonte do widget da Tab1 e do Orçamento Mensal — garantindo por construção a consistência de números entre as três superfícies. O gráfico reutiliza o componente `PetalDistributionChart` definido na techspec de distribuição, agora parametrizado pelo mês selecionado.

A lista de compras do sheet consome `GET /payments/notifications`, que já recorta por períodos de fatura (`findByBudgetPeriods`) — o mesmo recorte usado pela agregação do `BudgetSummary`. A única mudança de backend é a adição de dois parâmetros a esse endpoint: `paymentMethodId` (filtro por cartão que agrega sub-cartões ao cartão pai, conforme decisão de clarificação) e `sort` (`recent` | `amount`). O total do card de resumo é a **soma dos `actual` dos itens EXPENSE** do `BudgetSummary` (bate com gráfico e lista, decisão de clarificação).

## Arquitetura do Sistema

### Visão Geral dos Componentes

**Novos (frontend — `controlai-frontend`):**

- `src/pages/ByCategoryPage.tsx` + `.css` + `.test.tsx` — página da rota `/by-category`. Orquestra: mês selecionado (query param `month`, default mês corrente), `getBudgetSummary(month)`, cabeçalho com resumo, `PetalDistributionChart`, lista de categorias com ordenação e abertura do sheet.
- `src/components/CategoryConsumptionList.tsx` + `.test.tsx` — lista de categorias (linha: cor, nome, "R$ gasto · de R$ limite", %, barra de progresso, badge "Estourou") com seletor de ordenação ("% do limite" padrão desc | "valor gasto" desc). Recebe `BudgetItemSummary[]` filtrado e callback `onCategoryClick`.
- `src/components/CategoryDetailSheet.tsx` + `.css` + `.test.tsx` — bottom sheet (`IonModal` com `breakpoints={[0, 0.75, 1]}`, `initialBreakpoint={0.75}`, seguindo o padrão do `CategoryBottomSheet` existente). Cabeçalho (categoria, "N compras · Mês Ano", estouro em R$, fechar), card gasto vs. limite com barra, abas de ordenação (Recentes | Maiores), filtro por cartão e lista de compras. **Nome distinto do `CategoryBottomSheet` existente**, que é um seletor de categoria e não será tocado.

**Modificados (frontend):**

- `src/App.tsx` — nova rota `<Route exact path="/by-category">`.
- `src/components/MonthSelector.tsx` — nova prop opcional `maxMonth?: string`; quando presente, desabilita o botão "próximo" ao atingir o limite (PRD 5.1 — sem meses futuros).
- `src/pages/Tab1.tsx` — o botão "Ver gastos detalhados" do `PetalDistributionChart` passa a navegar para `/by-category?month={currentMonth}` (decisão de clarificação; substitui o scroll definido na techspec de distribuição).
- `src/pages/BudgetPage.tsx` — linhas de categoria passam a abrir o `CategoryDetailSheet` (mês do BudgetPage) e ganha acesso à tela `/by-category?month={mês selecionado}` (PRD 6.2). Sem gráfico novo nesta feature (decisão de clarificação).
- `src/services/purchaseService.ts` — `getNotifications` ganha parâmetros `paymentMethodId` e `sort`.

**Modificados (backend — `controlai`, Kotlin/Spring Boot):**

- `PaymentNotificationController.listNotifications` — novos `@RequestParam paymentMethodId: Long?` e `sort: String?` (valores `recent` default | `amount`).
- `PaymentNotificationRepository.findByBudgetPeriods` / `countByBudgetPeriods` — cláusulas `AND (:paymentMethodId IS NULL OR pn.payment_method_id = :paymentMethodId)` e `ORDER BY` condicional (`purchased_at DESC` | `amount DESC`).

**Fluxo de dados:**

```
ByCategoryPage (month)
  ├─ getBudgetSummary(month) → BudgetSummary
  │    ├─ card resumo: Σ actual (items EXPENSE), nº categorias com actual > 0,
  │    │  badge: count(actual > expected)
  │    ├─ PetalDistributionChart (items EXPENSE; mesmas regras da distribuição)
  │    └─ CategoryConsumptionList (mesmo filtro do gráfico: expected > 0 && actual > 0)
  └─ onCategoryClick(categoryId)
       └─ CategoryDetailSheet (categoryId, month, item: BudgetItemSummary)
            ├─ getNotifications(month, page, size, categoryId, null, paymentMethodId, sort)
            └─ listPaymentMethods() → opções do filtro + nome do cartão por compra
```

## Design de Implementação

### Interfaces Principais

```ts
// src/pages/ByCategoryPage.tsx — lê ?month= via useLocation; default mês corrente
// navegação de meses via <MonthSelector month={month} onChange={...} maxMonth={currentMonth} />

// src/components/CategoryConsumptionList.tsx
export interface CategoryConsumptionListProps {
  items: BudgetItemSummary[];              // já filtrados (EXPENSE, expected>0, actual>0)
  onCategoryClick: (categoryId: number) => void;
}
// ordenação interna: 'percent' (default) | 'amount'

// src/components/CategoryDetailSheet.tsx
export interface CategoryDetailSheetProps {
  isOpen: boolean;
  month: string;                            // "YYYY-MM"
  item: BudgetItemSummary | null;           // gasto/limite vêm do summary (consistência)
  onDismiss: () => void;
}
// estado interno: sort ('recent' | 'amount'), paymentMethodId (number | null)
```

```ts
// src/services/purchaseService.ts — assinatura estendida (params opcionais no fim)
export function getNotifications(
  month: string, page = 0, size = 100,
  categoryId?: number | null, cardLastDigits?: string | null,
  paymentMethodId?: number | null, sort?: 'recent' | 'amount',
): Promise<PageResponse<PaymentNotification>>;
```

```kotlin
// PaymentNotificationController
@GetMapping("/notifications")
fun listNotifications(
    @RequestParam month: String? = null,
    @RequestParam(defaultValue = "0") page: Int,
    @RequestParam(defaultValue = "100") size: Int,
    @RequestParam categoryId: Long? = null,
    @RequestParam cardLastDigits: String? = null,
    @RequestParam paymentMethodId: Long? = null,
    @RequestParam(defaultValue = "recent") sort: String,  // recent | amount
): Map<String, Any>
```

### Modelos de Dados

Nenhuma entidade nova. Reaproveita `BudgetSummary`/`BudgetItemSummary`, `PageResponse<PaymentNotification>` e `PaymentMethod`/`SubCard`.

Cálculos (frontend, derivados do `BudgetSummary`):

- Itens visíveis (gráfico e lista): `type === 'EXPENSE' && expected > 0 && actual > 0` (regra colocalizada já definida na distribuição).
- Total do mês (card resumo): `Σ actual` dos itens EXPENSE (todas as categorias com orçamento, mesmo sem gasto — soma igual à dos itens visíveis pois `actual = 0` não contribui).
- Categorias com movimento: `count(actual > 0)`.
- Acima do limite: `actual > expected`; badge "N acima do limite" quando `N > 0`.
- Estouro em reais: `actual - expected` (equivale a `-difference`), formatado via `utils/currency`.
- Percentual: `Math.round((actual / expected) * 100)` — idêntico à distribuição.
- Exibição do cartão por compra: `paymentMethodId` → nome/holder via `listPaymentMethods()`; sufixo `**** {cardLastDigits}` quando presente; métodos PIX/CASH exibem apenas o nome (ex.: "Pix recorrente" via descrição/nome do método).

Semântica de período (PRD 5.4): o recorte por `budget_payment_periods` já entrega meses passados fechados por completo e o mês corrente até a data atual — comportamento existente do `BudgetSummary` e da listagem; nenhuma lógica nova de pró-rata.

### Endpoints de API

- `GET /budgets?month=YYYY-MM` — existente, sem mudança. Meses sem orçamento retornam erro → página exibe estado vazio (7.1) mantendo cabeçalho e navegação.
- `GET /payments/notifications?month=&categoryId=&paymentMethodId=&sort=&page=&size=` — estendido com `paymentMethodId` e `sort` (retrocompatível; defaults preservam comportamento atual).

## Pontos de Integração

Sem integrações externas. Pontos internos:

- **Tab1 → tela**: `history.push('/by-category?month=' + currentMonth)` no callback `onViewDetailsClick` do `PetalDistributionChart`.
- **BudgetPage → tela/sheet**: botão/link "Por categoria" com o mês selecionado do BudgetPage; toque na linha de categoria abre `CategoryDetailSheet` local.
- **Voltar**: `IonBackButton`/`history.goBack()` retorna à origem (PRD 6.3) — React Router 5 preserva o histórico.
- **Acessibilidade**: linhas com `aria-label` `"{Categoria}: R$ {gasto} de R$ {limite}, {n}% do limite"` (+ ", acima do limite"); sheet com `aria-labelledby` apontando para o título (padrão de acessibilidade do `ion-modal`), dispensável por botão e gesto (`breakpoints` com `0`).

## Abordagem de Testes

### Testes Unidade

Frontend (Vitest + Testing Library, padrão dos testes existentes; mocks de `budgetService`/`purchaseService`/`paymentMethodService` via `vi.mock`):

- `ByCategoryPage.test.tsx`: renderiza resumo (total, nº categorias, badge "N acima do limite"); recalcula ao trocar mês; bloqueia navegação além do mês corrente; estado vazio sem orçamento/sem gastos; abre sheet ao clicar em linha/pétala; lê `?month=` da URL.
- `CategoryConsumptionList.test.tsx`: linha completa (valores, %, barra, badge "Estourou" quando `actual > expected`); ordenação padrão "% do limite" desc; alternância para "valor gasto"; mesmas categorias do gráfico; `aria-label` correto; clique dispara callback.
- `CategoryDetailSheet.test.tsx`: cabeçalho ("N compras · Mês Ano", "Estourou em R$ X" só quando estourou); card gasto/limite com estilo de alerta; troca de ordenação refaz busca com `sort`; filtro de cartão refaz busca com `paymentMethodId`; estado "nenhuma compra" mantendo filtro visível; exibição de cartão com final e de PIX; dismiss por botão.
- `MonthSelector.test` (novo caso): `maxMonth` desabilita avanço.

Backend (JUnit, padrão dos testes existentes em `src/test`):

- Repositório/controller: `paymentMethodId` filtra incluindo compras de sub-cartões do método; `sort=amount` ordena por valor desc; `sort=recent` (default) por data desc; params omitidos preservam comportamento atual.

### Testes de Integração

- `Tab1.test.tsx`: botão "Ver gastos detalhados" navega para `/by-category?month=...` (ajuste do teste da distribuição).
- `BudgetPage.test.tsx`: linha de categoria abre o sheet; link "Por categoria" preserva o mês.

### Testes de E2E

O projeto usa **Cypress** (não Playwright). Smoke opcional: Tab1 → tela "Por categoria" → tocar linha estourada → sheet com "Estourou em R$" → filtrar por cartão. Verificação manual obrigatória via `ionic serve` (CLAUDE.md do frontend).

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Backend: params `paymentMethodId` + `sort`** — independente do frontend, destrava o sheet; testes de repositório/controller.
2. **`purchaseService.getNotifications` estendido** — mudança pequena e retrocompatível.
3. **`MonthSelector` com `maxMonth`** — pré-requisito da página.
4. **`ByCategoryPage` (rota, cabeçalho, resumo, lista via `CategoryConsumptionList`, estados vazios)** — funcional sem o gráfico (bloco do gráfico entra depois).
5. **`CategoryDetailSheet`** — integrado à página (linha → sheet).
6. **Integração do `PetalDistributionChart` na página** — depende da feature de distribuição implementada; pétala/legenda → sheet.
7. **Pontos de entrada** — Tab1 (redirecionar botão) e BudgetPage (link + sheet nas linhas).
8. **Testes de integração e verificação manual** (`ionic serve`, simulador iOS).

### Dependências Técnicas

- **`PetalDistributionChart` ainda não implementado** (techspec da distribuição) — bloqueia apenas o passo 6; passos 1–5 podem avançar em paralelo.
- Orçamento mensal com limites configurados (fluxo existente).
- Nenhuma dependência de infraestrutura nova; sem libs novas além das já previstas na distribuição (`d3-shape`, `d3-scale`).

## Monitoramento e Observabilidade

- Frontend sem infra de métricas: `console.warn` apenas defensivo (ex.: falha de `getBudgetSummary` fora do caso "sem orçamento").
- Backend: logs padrão Spring; sem métricas novas — o endpoint estendido mantém a instrumentação existente.
- As métricas de produto do PRD (abertura de sheet, origem de acesso, uso de navegação de meses) ficam para quando houver analytics no app — sem bloqueio nesta versão.

## Considerações Técnicas

### Decisões Principais

- **Reuso integral do `BudgetSummary` como fonte única** — números idênticos entre widget, Orçamento Mensal e a nova tela sem endpoint novo; o recorte por períodos de fatura permanece a semântica oficial de "mês".
- **Filtro e ordenação no backend** (decisão de clarificação) — corretos com paginação; `paymentMethodId` agrega sub-cartões naturalmente porque `payment_notifications.payment_method_id` referencia o cartão pai.
- **Redirecionar "Ver gastos detalhados"** (decisão de clarificação) — um único caminho de aprofundamento; ajuste pequeno sobre a techspec de distribuição.
- **BudgetPage sem gráfico nesta feature** (decisão de clarificação) — atende 4.8 via linhas de categoria; evita inflar o escopo.
- **Total do resumo = Σ categorias com orçamento** (decisão de clarificação) — coerência interna da tela; documentar que pode diferir do `totalActual` da Tab1 (que inclui compras sem categoria).
- **Query param `?month=`** — preserva o mês entre BudgetPage e a tela, permite deep-link e sobrevive a refresh, sem estado global novo.

### Riscos Conhecidos

- **Divergência visual Tab1 vs. tela** se o `PetalDistributionChart` acoplar-se demais à Tab1 durante a implementação da distribuição — mitigar mantendo o contrato de props da techspec de distribuição (componente puro por `items`).
- **Nome do método de pagamento por compra** exige join client-side (`listPaymentMethods`) — cachear em estado local do sheet; volume pequeno (poucos métodos).
- **Meses sem orçamento** retornam erro do `GET /budgets` — tratar como estado vazio (7.1), não como erro de rede; distinguir por status.
- **Sheet + IonModal em iOS (WebKit)** — testar gesto de arrastar e scroll interno (`expandToScroll`) no simulador.

### Conformidade com Skills Padroes

- `frontend-design` / `ionic-design` — página e sheet com componentes Ionic (`IonPage`, `IonModal` sheet), dark theme e tap targets ≥ 44pt.
- `vercel-react-best-practices` — derivações do summary via `useMemo`; callbacks estáveis; busca do sheet disparada por mudança de `sort`/`paymentMethodId` via `useEffect` com dependências corretas.
- `clean-code` — regras de cálculo nomeadas e colocalizadas; componentes pequenos com responsabilidade única.
- `kotlin-springboot` — extensão do controller/repository seguindo o padrão nativo existente (`@Query` nativa com params opcionais).

### Arquivos relevantes e dependentes

**Novos (frontend):** `src/pages/ByCategoryPage.tsx|.css|.test.tsx`, `src/components/CategoryConsumptionList.tsx|.test.tsx`, `src/components/CategoryDetailSheet.tsx|.css|.test.tsx`.

**Modificados (frontend):** `src/App.tsx`, `src/components/MonthSelector.tsx` (+ teste), `src/pages/Tab1.tsx` (+ teste), `src/pages/BudgetPage.tsx` (+ teste), `src/services/purchaseService.ts` (+ teste).

**Modificados (backend):** `application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`, `application/payments_notification/entrypoint/database/repository/PaymentNotificationRepository.kt` (+ testes).

**Dependentes (consultados, não alterados):** `src/types/budget.ts`, `src/types/paymentMethod.ts`, `src/services/budgetService.ts`, `src/services/paymentMethodService.ts`, `src/components/PetalDistributionChart.tsx` (da feature de distribuição), `src/utils/currency.ts`, `application/budget/application/GetBudgetSummaryProvider.kt`.
