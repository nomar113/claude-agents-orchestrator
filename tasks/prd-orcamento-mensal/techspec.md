# Tech Spec: Tela de Orcamento Mensal Editavel

## Resumo Executivo

A implementacao consiste em duas frentes: (1) uma unica migracao Flyway no backend para adicionar o campo `icon` na tabela `categories`, com atualizacao da entidade, model, response e controller; (2) refatoracao completa do `BudgetPage.tsx` no frontend para alinhar ao design Paper e adicionar modo edicao inline com CRUD de itens e receitas, duplicacao de mes, barras de progresso por categoria e cores dinamicas. O `budgetService.ts` ja possui todas as funcoes CRUD necessarias — nenhum endpoint novo e requerido. As alteracoes sao enviadas ao backend em real-time (por acao), sem acumulo em batch.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (alteracoes minimas):**
- `V19__add_icon_to_categories.sql` — Migracao Flyway para campo `icon` (varchar 10, nullable)
- `CategoryModel.kt` — Adicionar campo `icon`
- `Category.kt` — Adicionar campo `icon`
- `CategoryConverter.kt` — Mapear campo `icon`
- `CategoryResponse.kt` — Expor campo `icon` na API

**Frontend (alteracoes principais):**
- `BudgetPage.tsx` — Refatoracao completa: redesign visual, estado `isEditing`, CRUD inline, duplicacao
- `BudgetPage.css` — Novos estilos alinhados ao Paper (summary card, category cards, botoes de acao)
- `BudgetCategoryCard.tsx` — **Novo componente** para card de categoria (emoji, nome, diff colorido, barra de progresso)
- `BudgetSummarySection.tsx` — **Novo componente** para o summary card "Planejado vs Real" com badge de porcentagem, Receitas/Saldo/Investido
- `BudgetIncomeRow.tsx` — **Novo componente** para linha de receita com modo edicao inline
- `AddItemModal.tsx` — **Novo componente** modal para adicionar item (seletor de categoria + tipo + valor)
- `DuplicateMonthModal.tsx` — **Novo componente** modal com IonDatetime presentation="month-year"
- `budget.ts` (types) — Adicionar campo `categoryIcon` em `BudgetItemSummary`

**Fluxo de dados:**
1. `BudgetPage` carrega dados via `getBudgetSummary(month)` (existente)
2. Estado `isEditing` controla visibilidade de botoes +/x e editabilidade dos campos
3. Cada acao CRUD chama o service correspondente e recarrega os dados via `load()`
4. Categorias disponiveis: `GET /categories` filtradas para remover as ja presentes no budget

## Design de Implementacao

### Interfaces Principais

```typescript
// Estado do modo edicao no BudgetPage
interface BudgetPageState {
  isEditing: boolean;
  summary: BudgetSummary | null;
  loading: boolean;
  error: string | null;
  openSections: Record<string, boolean>;
  showAddItemModal: boolean;
  showDuplicateModal: boolean;
}

// Props do BudgetCategoryCard
interface BudgetCategoryCardProps {
  item: BudgetItemSummary;
  isEditing: boolean;
  onUpdateExpected: (itemId: number, value: number) => void;
  onDelete: (itemId: number) => void;
}

// Props do AddItemModal
interface AddItemModalProps {
  isOpen: boolean;
  budgetId: number;
  existingCategoryIds: number[];
  itemType: 'EXPENSE' | 'INVESTMENT';
  onDismiss: () => void;
  onItemAdded: () => void;
}
```

### Modelos de Dados

**Migracao V19 — categories:**
```sql
ALTER TABLE categories ADD COLUMN icon VARCHAR(10) DEFAULT NULL;
```

**Atualizacao CategoryModel.kt:**
```kotlin
@Column(name = "icon", length = 10, nullable = true)
val icon: String? = null
```

**Atualizacao BudgetItemSummary (frontend types):**
```typescript
export interface BudgetItemSummary {
  id: number;
  categoryId: number;
  categoryName: string;
  categoryIcon: string | null;  // novo
  type: 'EXPENSE' | 'INVESTMENT';
  expected: number;
  actual: number;
  difference: number;
}
```

### Endpoints de API

Todos os endpoints ja existem. Unica alteracao:
- `GET /categories` — Response passa a incluir campo `icon: String?` (adicionado ao CategoryResponse)

Backend `GetBudgetSummaryProvider` precisa ser atualizado para incluir o `icon` da categoria no retorno do summary (alem do `categoryName` que ja retorna).

## Pontos de Integracao

**Categorias disponíveis para seletor:**
- Frontend chama `GET /categories` e filtra localmente removendo `categoryIds` ja presentes no budget
- Nao requer novo endpoint

**Duplicacao de budget:**
- Frontend chama `POST /budgets/{id}/duplicate?targetMonth=YYYY-MM` (existente)
- Backend ja trata erro quando mes destino ja tem budget (retorna 409 Conflict — verificar se comportamento atual e sobrescrever ou rejeitar)

## Abordagem de Testes

### Testes Unitarios

**Backend:**
- `CategoryConverterTest` — Verificar mapeamento do campo `icon`
- `GetBudgetSummaryProviderTest` — Verificar que `categoryIcon` aparece no summary

**Frontend:**
- `BudgetCategoryCard` — Renderizacao com/sem emoji, modo visualizacao vs edicao, cores da diferenca
- `BudgetSummarySection` — Calculo de porcentagem, cores do badge, exibicao de Investido
- `AddItemModal` — Filtragem de categorias, validacao de campos

### Testes de Integracao

**Backend:**
- `CategoryControllerIntegrationTest` — Verificar campo `icon` no response
- `BudgetControllerIntegrationTest` — Verificar `categoryIcon` no GET /budgets summary

### Testes E2E

**Playwright:**
- Fluxo completo: criar budget → adicionar item → editar valor → remover item
- Fluxo receitas: adicionar receita → editar label/valor → remover
- Fluxo duplicar: duplicar mes → verificar dados no mes destino
- Modo edicao: entrar → verificar elementos visiveis → sair

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Backend: Migracao + entidade Category** — Adicionar campo `icon`, atualizar model/entity/converter/response. Atualizar `GetBudgetSummaryProvider` para retornar `categoryIcon`. Rapido e desbloqueia frontend.

2. **Frontend: Redesign Summary Card** — `BudgetSummarySection` com layout Paper (badge %, Planejado/Real lado a lado, barra de progresso, Receitas/Saldo/Investido). Substitui o card atual.

3. **Frontend: Redesign Category Cards** — `BudgetCategoryCard` com emoji, diff colorido, barra de progresso individual. Substitui os itens atuais.

4. **Frontend: Modo Edicao + CRUD Items** — Estado `isEditing`, botoes Editar/Salvar no rodape, edicao inline de valores, botao remover item, `AddItemModal` com seletor de categoria.

5. **Frontend: CRUD Receitas** — `BudgetIncomeRow` com edicao inline de label/valor, adicionar/remover receita.

6. **Frontend: Duplicar Mes** — `DuplicateMonthModal` com IonDatetime, botao no rodape.

7. **Frontend: Botoes de Acao no Rodape** — Layout final com "Duplicar Mes" (outline) e "Editar" (primary) conforme Paper.

### Dependencias Tecnicas

- Migracao V19 deve ser aplicada antes de testar o frontend com icones
- IonDatetime com `presentation="month-year"` requer Ionic 6+ (ja utilizado no projeto)
- Nenhuma dependencia externa nova necessaria (sem biblioteca de currency mask — usar formatacao manual existente com `Intl.NumberFormat`)

## Monitoramento e Observabilidade

- Logs de erro nos endpoints de budget ja existem no backend (Spring Boot default)
- Frontend: erros de rede ja tratados com estado `error` — adicionar toast de feedback para operacoes CRUD
- Nao requer metricas ou dashboards adicionais para esta feature

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Escolha | Justificativa |
|---------|---------|---------------|
| Persistencia | Real-time por acao | Consistente com padrao atual de edicao inline; evita complexidade de tracking de mudancas em batch |
| Filtro de categorias | Filtrar no frontend | Lista de categorias e pequena; evita endpoint custom no backend |
| Currency mask | Intl.NumberFormat existente | Ja usado no projeto; sem dependencia adicional |
| Seletor de mes (duplicar) | IonModal + IonDatetime | Componente nativo do Ionic, suporte a month-year, consistente com framework |
| Componentes novos | 5 novos componentes | Extrair do BudgetPage para manter arquivo gerenciavel e reutilizavel |

### Riscos Conhecidos

- **Race condition no modo edicao**: Multiplas chamadas simultaneas ao backend podem causar estado inconsistente. Mitigacao: desabilitar inputs durante chamada de rede (loading state por item).
- **Duplicar para mes existente**: Verificar se backend retorna 409 ou sobrescreve. Se rejeitar, frontend deve tratar e exibir confirmacao. Se sobrescrever, garantir que usuario confirme.
- **Emoji rendering**: Emojis podem renderizar diferente entre iOS e Android no Capacitor. Mitigacao: usar emojis simples e comuns (frutas, objetos); fallback para texto.

### Conformidade com Skills Padrao

| Skill | Aplicavel | Observacao |
|-------|-----------|------------|
| `executar-task` | Sim | Implementacao seguira o fluxo de tasks do orquestrador |
| `task-review` | Sim | Review automatico apos cada task |
| `executar-qa` | Sim | QA com Playwright para fluxos E2E |
| `executar-review` | Sim | Code review da branch/feature completa |

### Arquivos relevantes e dependentes

**Backend:**
- `src/main/resources/db/migration/V19__add_icon_to_categories.sql` (novo)
- `src/main/kotlin/.../categories/entity/Category.kt`
- `src/main/kotlin/.../categories/entrypoint/database/model/CategoryModel.kt`
- `src/main/kotlin/.../categories/converter/CategoryConverter.kt`
- `src/main/kotlin/.../categories/entrypoint/rest/response/CategoryResponse.kt`
- `src/main/kotlin/.../budget/provider/GetBudgetSummaryProvider.kt`

**Frontend:**
- `src/pages/BudgetPage.tsx` (refatoracao)
- `src/pages/BudgetPage.css` (refatoracao)
- `src/types/budget.ts` (atualizacao)
- `src/components/BudgetSummarySection.tsx` (novo)
- `src/components/BudgetCategoryCard.tsx` (novo)
- `src/components/BudgetIncomeRow.tsx` (novo)
- `src/components/AddItemModal.tsx` (novo)
- `src/components/DuplicateMonthModal.tsx` (novo)

**Design de referencia:**
- Paper: artboard "Orcamento Mensal" (ID 158-0)
- Cores: fundo `#0D1028`, cards `#151A35`, borda `#4F8BFF0F`, summary gradient `oklab(27.4% -0.002 -0.065)` → `oklab(22.9% 0.003 -0.053)`
- Fontes: IBM Plex Sans (textos), IBM Plex Mono (valores)
- Botao primario: gradiente `oklab(65.5% -0.025 -0.182)` → `oklab(56.9% -0.021 -0.180)`
- Botao outline: background `#4F8BFF1A`, borda `#4F8BFF33`
