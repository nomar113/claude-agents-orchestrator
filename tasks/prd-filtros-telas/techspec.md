# Tech Spec - Filtros para Telas do ControlAI

## Resumo Executivo

A implementacao adiciona filtros de mes e categoria nas telas Tab1 (Home) e Tab2 (Notas Fiscais), com range de datas customizado na Tab2. No backend, os endpoints `GET /payments/notifications` e `GET /purchases/invoices` receberao query params de filtragem por mes/periodo e paginacao. No frontend, um `FilterContext` centraliza o estado de filtros por tela, e dois componentes reutilizaveis (`MonthSelector` e `CategoryFilterBar`) sao criados para consistencia visual. A filtragem por categoria e aplicada localmente no frontend sobre dados ja carregados do backend.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (Kotlin/Spring Boot):**

- `PaymentNotificationController` — Recebe novos query params `month`, `page`, `size` no endpoint `GET /payments/notifications`.
- `PurchaseInvoiceController` — Recebe novos query params `month`, `startDate`, `endDate`, `page`, `size` no endpoint `GET /purchases/invoices`.
- `PurchaseRepository` — Nova query `findInvoicesByDateRange` com filtro de periodo e paginacao.
- `PaymentNotificationRepository` — Nova query `findByMonth` com filtro de mes e paginacao.

**Frontend (React/Ionic):**

- `FilterContext` (novo) — Context React que armazena estado de filtros por tela (mes, categoria, modo periodo, range de datas). Persiste durante a sessao.
- `MonthSelector` (novo) — Componente reutilizavel de navegacao por mes com setas prev/next. Extraido do padrao existente no BudgetPage.
- `CategoryFilterBar` (novo) — Barra horizontal de chips de categoria com scroll, chip "Todas" padrao.
- `Tab1.tsx` (modificado) — Integra MonthSelector e CategoryFilterBar, consome FilterContext.
- `Tab2.tsx` (modificado) — Integra MonthSelector, CategoryFilterBar, toggle Mes/Periodo e DateRange picker.
- `purchaseService.ts` (modificado) — Novas funcoes com suporte a query params de mes, periodo e paginacao.

**Fluxo de dados:**
1. Usuario interage com MonthSelector ou CategoryFilterBar.
2. FilterContext atualiza o estado da tela ativa.
3. Tab1/Tab2 reagem a mudanca via useEffect e disparam chamadas ao backend com novos params.
4. Backend retorna dados filtrados e paginados.
5. Frontend aplica filtro de categoria localmente sobre os dados retornados.

## Design de Implementacao

### Interfaces Principais

```typescript
// FilterContext - Estado por tela
interface FilterState {
  month: string;              // "YYYY-MM"
  selectedCategory: string | null; // null = "Todas"
  mode: 'month' | 'period';  // Apenas Tab2
  startDate: string | null;   // "YYYY-MM-DD", modo period
  endDate: string | null;     // "YYYY-MM-DD", modo period
  page: number;
  hasMore: boolean;
}

interface FilterContextType {
  tab1: FilterState;
  tab2: FilterState;
  updateTab1: (partial: Partial<FilterState>) => void;
  updateTab2: (partial: Partial<FilterState>) => void;
  resetTab1: () => void;
  resetTab2: () => void;
}
```

```kotlin
// Backend - Controller params
// GET /payments/notifications?month=2026-05&page=0&size=50
fun listNotifications(
    @RequestParam month: String?,    // "YYYY-MM"
    @RequestParam(defaultValue = "0") page: Int,
    @RequestParam(defaultValue = "50") size: Int,
): Page<PaymentNotificationResponse>

// GET /purchases/invoices?month=2026-05&page=0&size=50
// GET /purchases/invoices?startDate=2026-01-15&endDate=2026-02-15&page=0&size=50
fun listInvoices(
    @RequestParam month: String?,       // "YYYY-MM"
    @RequestParam startDate: String?,   // "YYYY-MM-DD"
    @RequestParam endDate: String?,     // "YYYY-MM-DD"
    @RequestParam(defaultValue = "0") page: Int,
    @RequestParam(defaultValue = "50") size: Int,
): Page<PurchaseResponse>
```

### Modelos de Dados

Nao ha alteracao de schema no banco de dados. As tabelas `payment_notifications` e `purchase_invoices` ja possuem os campos `purchased_at`/`date` e `category_id` necessarios para filtragem.

**Tipo de resposta paginada:**

```kotlin
// Spring Page wrapper - retorna automaticamente:
{
  "content": [...],
  "totalElements": 150,
  "totalPages": 3,
  "number": 0,       // pagina atual
  "size": 50,
  "last": false
}
```

```typescript
// Frontend - tipo paginado generico
interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  last: boolean;
}
```

### Endpoints de API

| Metodo | Endpoint | Params Novos | Descricao |
|--------|----------|-------------|-----------|
| GET | `/payments/notifications` | `month`, `page`, `size` | Lista notificacoes filtradas por mes, paginadas |
| GET | `/purchases/invoices` | `month`, `startDate`, `endDate`, `page`, `size` | Lista invoices por mes ou range de datas, paginadas |

**Regras de filtragem:**
- Se `month` fornecido: filtra registros do primeiro ao ultimo dia do mes.
- Se `startDate` e `endDate` fornecidos (invoices): filtra registros no range inclusivo.
- Se nenhum param de data: retorna mes corrente (nao mais tudo).
- `month` e `startDate/endDate` sao mutuamente exclusivos — se ambos enviados, `startDate/endDate` tem precedencia.

### Queries SQL

**Notifications por mes:**
```sql
SELECT pn.*, c.name AS category
FROM payment_notifications pn
LEFT JOIN categories c ON pn.category_id = c.id
WHERE pn.deleted_at IS NULL
  AND pn.purchased_at >= :startOfMonth
  AND pn.purchased_at < :startOfNextMonth
ORDER BY pn.purchased_at DESC
LIMIT :size OFFSET :offset
```

**Invoices por range de datas:**
```sql
SELECT pi.id, pi.date, pi.total, pi.merchant_name AS merchantName,
       pi.total_items AS totalItems, pi.description, c.name AS categoryName
FROM purchase_invoices pi
LEFT JOIN categories c ON pi.category_id = c.id
WHERE pi.deleted_at IS NULL
  AND pi.date >= :startDate
  AND pi.date < :endDate
ORDER BY pi.date DESC
LIMIT :size OFFSET :offset
```

## Pontos de Integracao

- `getPaymentMethodsSummary(month)` — Ja aceita mes, sera chamado com o mes do FilterContext em vez de `getCurrentMonth()`.
- `getBudgetCompactSummary(month)` — Ja aceita mes, BudgetSummaryCard passa a usar o mes do FilterContext.
- `getProjection()` — Nao tem filtro de mes (projeta futuro), permanece inalterado.
- `IonDatetime` (Ionic) — Componente nativo para selecao de datas no range picker da Tab2.

## Abordagem de Testes

### Testes Unitarios

**Backend:**
- `PaymentNotificationController`: testar query param `month` com formato valido/invalido, paginacao com page/size, retorno vazio para mes sem dados.
- `PurchaseInvoiceController`: testar `month`, `startDate/endDate`, validacao de startDate <= endDate, paginacao.
- Repository queries: testar filtragem correta por range de datas, soft delete respeitado, ordenacao DESC.

**Frontend:**
- `FilterContext`: testar estado inicial, update parcial, reset, independencia entre telas.
- `MonthSelector`: testar navegacao prev/next, transicao de ano (dez→jan), callback onChange.
- `CategoryFilterBar`: testar selecao/deselecao, chip "Todas", categorias extraidas dos dados.

### Testes de Integracao

- Fluxo completo: alterar mes no MonthSelector → verificar chamada ao backend com param correto → verificar lista atualizada.
- Filtro de categoria: carregar dados → selecionar categoria → verificar lista filtrada e total recalculado.
- Range de datas: alternar modo Periodo → selecionar datas → verificar chamada com startDate/endDate.

### Testes E2E

- **Playwright**: Navegar Tab1 → trocar mes → verificar cards e lista atualizados.
- **Playwright**: Tab2 → alternar para modo Periodo → selecionar range → verificar dados filtrados.
- **Playwright**: Navegar entre Tab1 e Tab2 → verificar filtros persistidos ao voltar.
- **Playwright**: Limpar filtros → verificar retorno ao estado padrao.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Backend: Query params nos endpoints** — Adicionar `month`, `startDate/endDate`, `page/size` nos controllers e repositorios. Bloqueia o frontend de consumir filtros por mes.
2. **Frontend: FilterContext** — Criar contexto de estado de filtros por tela. Fundacao para todos os componentes.
3. **Frontend: MonthSelector** — Componente reutilizavel extraido do padrao do BudgetPage.
4. **Frontend: Integracao MonthSelector na Tab1** — Conectar seletor de mes, atualizar chamadas ao backend (notifications, cardSummaries, budgetSummary).
5. **Frontend: CategoryFilterBar** — Componente de chips de categoria com scroll horizontal.
6. **Frontend: Integracao filtros na Tab1** — CategoryFilterBar + filtro local + total recalculado + limpar filtros.
7. **Frontend: Integracao filtros na Tab2** — MonthSelector + CategoryFilterBar + toggle Mes/Periodo + IonDatetime para range.
8. **Frontend: Persistencia e limpar filtros** — Validar persistencia entre navegacao de tabs, botao limpar.

### Dependencias Tecnicas

- Ionic Framework `IonDatetime` — ja disponivel no projeto (Ionic 7+).
- Spring Data `Pageable` — ja disponivel no Spring Boot, sem dependencia nova.
- Nenhuma nova biblioteca ou infraestrutura requerida.

## Monitoramento e Observabilidade

- Logs INFO nos controllers ao receber requests com filtros (month, startDate, endDate).
- Metricas de tempo de resposta dos endpoints filtrados (Spring Actuator existente).
- Log WARN se `startDate > endDate` antes de retornar erro 400.

## Consideracoes Tecnicas

### Decisoes Principais

1. **Filtro de categoria no frontend (nao backend):** Os dados ja retornam com `categoryName`/`category`. Filtrar localmente evita round-trip extra e mantem a UX responsiva. Volume por mes e pequeno (~50-100 registros).

2. **FilterContext em vez de useState local:** O Ionic mantem tabs montadas em background. Um Context sobrevive naturalmente a navegacao entre tabs sem precisar de workarounds com refs.

3. **Paginacao com Spring Page:** Adiciona paginacao aproveitando o suporte nativo do Spring Data. Frontend carrega pagina 0 inicialmente e pode implementar infinite scroll futuramente.

4. **Mes corrente como default (nao "tudo"):** Quando nenhum param de data for enviado, o backend retorna o mes corrente. Isso melhora performance e e o comportamento esperado pelo usuario.

5. **Range de datas apenas na Tab2:** Tab1 e dashboard mensal, faz sentido navegar mes a mes. Tab2 (notas fiscais) tem caso de uso para periodos customizados (ex: ciclo de fatura).

### Riscos Conhecidos

- **Mudanca de contrato da API:** Endpoints passam a retornar `Page<T>` em vez de `List<T>`. Frontend precisa adaptar para consumir `content[]` em vez do array direto. Mitigacao: fazer backend e frontend na mesma branch/iteracao.
- **Performance da query UNION com paginacao:** A query `findAllPurchases` (UNION) nao e afetada — Tab2 usa apenas `findAllInvoices`. Risco baixo.
- **IonDatetime UX mobile:** Selecao de range de datas pode ser confusa em tela pequena. Mitigacao: usar dois campos separados (inicio e fim) em vez de range picker unico.

### Conformidade com Skills Padroes

- `executar-task` — Cada task sera implementada seguindo o fluxo da skill.
- `executar-review` / `task-reviewer` — Review automatico apos cada task.
- `executar-qa` — QA com Playwright MCP para validar filtros nas telas.

### Arquivos relevantes e dependentes

**Backend:**
- `/controlai/src/.../PaymentNotificationController.kt` — Adicionar query params
- `/controlai/src/.../PurchaseInvoiceController.kt` — Adicionar query params
- `/controlai/src/.../PurchaseRepository.kt` — Nova query com filtro de data
- `/controlai/src/.../PaymentNotificationRepository.kt` — Nova query com filtro de mes
- `/controlai/src/.../GetPaymentMethodsSummaryProvider.kt` — Referencia para padrao de filtragem por mes

**Frontend:**
- `/controlai-frontend/src/pages/Tab1.tsx` — Integrar filtros
- `/controlai-frontend/src/pages/Tab2.tsx` — Integrar filtros + range de datas
- `/controlai-frontend/src/pages/BudgetPage.tsx` — Referencia para MonthSelector (linhas 57-59, 121-129, 246-254)
- `/controlai-frontend/src/services/purchaseService.ts` — Adicionar params de filtro
- `/controlai-frontend/src/components/CardStack.tsx` — Recebe dados ja filtrados
- `/controlai-frontend/src/components/BudgetSummaryCard.tsx` — Recebe month do FilterContext
- `/controlai-frontend/src/components/PurchaseList.tsx` — Recebe dados ja filtrados
- `/controlai-frontend/src/context/InvoiceProcessingContext.tsx` — Referencia para padrao de Context
