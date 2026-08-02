# Tech Spec — Novo Estilo de Exibição de Datas do Período de Fatura do Cartão

## Resumo Executivo

Refatoração puramente visual/comportamental da seção de períodos de fatura: o componente `BudgetPeriodCard` existente ganha um banner horizontal compacto no topo (com ícone de calendário + intervalo de datas em linha) que sobrepõe levemente o corpo do card via CSS `z-index`/`margin-top`. A edição de período é desacoplada do modo de edição global — qualquer toque no banner abre um `IonModal` bottom sheet com dois `IonDatetime` para início e fim; ao confirmar, a API é chamada diretamente e o budget é recarregado silenciosamente. Nenhuma alteração de backend, tipo ou endpoint é necessária.

## Arquitetura do Sistema

### Visão Geral dos Componentes

| Componente | Status | Responsabilidade |
|---|---|---|
| `CardPeriodBanner` | **NOVO** | Exibe `📅 DD/MM/YYYY  até  DD/MM/YYYY` em linha; captura toque para edição |
| `PeriodEditModal` | **NOVO** | `IonModal` bottom sheet com dois `IonDatetime`; salva via API ao confirmar |
| `BudgetPeriodCard` | **MODIFICAR** | Remove campos "De/Até"; integra `CardPeriodBanner` no topo; repassa `budgetId` |
| `BudgetPeriodSection` | **MODIFICAR** | Remove props de edição global (`isEditing`, `editValues`, callbacks); recebe `budgetId` |
| `Tab1.tsx` | **MODIFICAR** | Remove estado `editPeriods`, `periodErrors` e handlers de período |
| `BudgetPage.tsx` | **MODIFICAR** | Idem Tab1; remove período do `handleSaveAll` |
| `BudgetPage.css` | **MODIFICAR** | Adiciona classes de banner; ajusta `.period-card` para overlap |

Fluxo de dados: `BudgetSummary.periods[]` → `BudgetPeriodSection` → `BudgetPeriodCard` → `CardPeriodBanner` → (toque) → `PeriodEditModal` → `updateBudgetPeriods()` → `onPeriodSaved()` → reload silencioso.

## Design de Implementação

### Interfaces Principais

```tsx
// CardPeriodBanner
interface CardPeriodBannerProps {
  startDate: string; // ISO: 'YYYY-MM-DD'
  endDate: string;
  onTap: () => void;
}

// PeriodEditModal
interface PeriodEditModalProps {
  isOpen: boolean;
  budgetId: number;
  paymentMethodId: number;
  startDate: string;  // ISO
  endDate: string;
  onConfirmed: () => void;
  onDismiss: () => void;
}

// BudgetPeriodSection (props que mudam)
interface BudgetPeriodSectionProps {
  periods: BudgetPaymentPeriod[];
  isOpen: boolean;
  onToggle: () => void;
  budgetId: number;        // NOVO
  onPeriodSaved: () => void; // NOVO — substitui props de edição global
  // REMOVIDOS: isEditing, editValues, onStartChange, onEndChange, errors
}
```

### Modelos de Dados

Sem alterações. `BudgetPaymentPeriod`, `UpdateBudgetPeriodsRequest` e `PeriodEntry` em `src/types/budget.ts` permanecem intactos. O endpoint existente `PUT /budgets/{budgetId}/periods` é suficiente — o payload envia apenas o período editado (array com 1 elemento).

### Endpoints de API

Sem novos endpoints. A edição de período usa `updateBudgetPeriods(budgetId, { periods: [{ paymentMethodId, startDate, endDate }] })` já existente em `budgetService.ts`.

## Layout CSS — Efeito de Sobreposição

```
┌──────────────────────────────────────────┐  ← .period-banner-wrapper
│ 📅  04/06/2026   até   03/07/2026        │  ← .period-date-banner (border-radius: 16px 16px 0 0)
│                                          │
└────────────────────┐ ┌───────────────────┘
                     │ │  ← overlap via margin-top: -12px + z-index: 1
┌──────────────────────────────────────────┐
│ [NU]  Nubank  · Fecha dia 10   R$ 1.200  │  ← .period-card (border-radius: 16px)
└──────────────────────────────────────────┘
```

Classes CSS novas/alteradas:
- `.period-banner-wrapper` — `position: relative` no container
- `.period-date-banner` — `border-radius: 16px 16px 0 0`, `min-height: 44px`, `cursor: pointer`, `display: flex`, cor de fundo levemente diferente do card (`#1C2240`)
- `.period-date-banner-icon` — ícone de calendário com cor `#ffffff60`
- `.period-date-banner-text` — data formatada com `font-family: 'IBM Plex Mono'`
- `.period-date-banner-sep` — separador "até" com `opacity: 0.5`, menor weight
- `.period-card` — adicionar `position: relative; z-index: 1; margin-top: -12px` (o overlap)

## Pontos de Integração

Sem integrações externas novas. O `IonModal` com `breakpoints={[0, 0.6]}` e `initialBreakpoint={0.6}` já é padrão no projeto (ver `CategoryDetailSheet`). O `IonDatetime` com `presentation="date"` e `locale="pt-BR"` é suportado pelo pacote `@ionic/react` já presente.

## Abordagem de Testes

### Testes Unidade

**`CardPeriodBanner.test.tsx`**
- Renderiza datas no formato DD/MM/YYYY a partir de ISO
- Exibe ícone de calendário
- Chama `onTap` ao clicar
- `aria-label` contém descrição completa do período

**`PeriodEditModal.test.tsx`**
- Renderiza modal fechado sem chamar API
- Botão "Salvar" chama `updateBudgetPeriods` com payload correto
- Botão "Cancelar" chama `onDismiss` sem API call
- Desabilita "Salvar" quando endDate < startDate

**`BudgetPeriodCard.test.tsx`** (atualizar)
- Remover testes de inputs inline ("De" / "Até")
- Adicionar: renderiza `CardPeriodBanner` com as datas do período
- Manter: renderiza badge com iniciais e nome do método de pagamento

**`BudgetPeriodSection.test.tsx`** (atualizar)
- Remover testes de `isEditing` / `editValues`
- Adicionar: prop `budgetId` é repassada para cada `BudgetPeriodCard`

### Testes de Integração

- `BudgetPeriodSection` renderizado com períodos reais: tap no banner do primeiro card abre `PeriodEditModal` com as datas corretas preenchidas

### Testes de E2E

- Playwright: navegar até Tab1 → seção "PERIODO POR MEIO DE PAGAMENTO" → tocar no banner de um cartão → selecionar nova data no IonDatetime → confirmar → verificar que o banner reflete a nova data sem reload da página

## Sequenciamento de Desenvolvimento

1. **`CardPeriodBanner`** (componente puro, sem dependências novas) — criar tsx + CSS + testes
2. **`PeriodEditModal`** (depende de `IonModal` + `IonDatetime` + `updateBudgetPeriods`) — criar tsx + testes mockando o serviço
3. **`BudgetPeriodCard`** refatorado — integra banner e modal; remover campos "De/Até"; atualizar testes
4. **`BudgetPeriodSection`** refatorado — ajustar props (remove edição global, adiciona `budgetId` e `onPeriodSaved`); atualizar testes
5. **`BudgetPage.css`** — adicionar classes de banner, ajustar `.period-card` para overlap
6. **`Tab1.tsx` e `BudgetPage.tsx`** — remover estado de edição de período (`editPeriods`, `periodErrors`, handlers); passar `budgetId` e `onPeriodSaved` ao `BudgetPeriodSection`

### Dependências Técnicas

- `@ionic/react` ≥ 7 (já presente) — `IonModal`, `IonDatetime` com `presentation="date"` e `locale`
- `toDisplay`/`toIso`/`applyMask` exportados de `BudgetPeriodCard.tsx` — manter os exports; apenas o render do componente muda

## Monitoramento e Observabilidade

Sem métricas novas. Erros de save do período devem continuar sendo capturados via `useIonToast` com mensagem de danger (padrão já existente no projeto). Nenhum log novo necessário — a camada é puramente UI.

## Considerações Técnicas

### Decisões Principais

**Edição desacoplada do modo global**: o toque no banner salva o período individualmente via API, sem precisar do botão "Salvar" global. Isso simplifica o fluxo — o usuário não precisa entrar em modo de edição para corrigir uma data. Trade-off: a edição de período não faz mais parte do "Salvar tudo" — mas como período e orçamento são dados distintos com endpoints independentes, o acoplamento era artificial.

**`IonDatetime` com `presentation="date"`**: mais nativo e acessível que inputs mascarados. Evita a necessidade de manter a máscara DD/MM/YYYY manual e lida com validação de datas automaticamente. Trade-off: depende do suporte ao locale `pt-BR` pelo IonDatetime — confirmar em ambiente de build.

**CSS overlap via `margin-top` negativo**: abordagem simples, sem Position Absolute que quebraria o flow do documento. O `z-index: 1` no `.period-card` é suficiente para o efeito visual dentro do wrapper relativo.

### Riscos Conhecidos

- **IonDatetime e locale pt-BR**: testar em iOS e Android físicos — o componente pode exibir o calendário em inglês se o locale não for passado explicitamente (`locale="pt-BR"` na tag `IonDatetime`).
- **Dois IonDatetime no mesmo modal**: se o modal ficar muito alto em telas pequenas, avaliar substituir por um stepper (datas em duas etapas no mesmo modal).
- **Remoção de props de `BudgetPeriodSection`**: `Tab1.tsx` e `BudgetPage.tsx` têm duplicação de lógica de período — ao remover as props, garantir que ambas as pages sejam atualizadas para não quebrar TypeScript.

### Conformidade com Skills Padrões

- `ionic-design` — guia de uso de componentes Ionic; seguir padrões de `IonModal` com `breakpoints` e `IonDatetime` com `keepContentsMounted`
- `executar-task` — cada tarefa deve ter typecheck (`tsc --noEmit`), testes (`vitest run`) e lint (`eslint`) passando antes de marcar concluída

### Arquivos relevantes e dependentes

```
src/components/BudgetPeriodCard.tsx        ← MODIFICAR
src/components/BudgetPeriodCard.test.tsx   ← ATUALIZAR
src/components/BudgetPeriodSection.tsx     ← MODIFICAR
src/components/BudgetPeriodSection.test.tsx ← ATUALIZAR
src/pages/BudgetPage.tsx                   ← MODIFICAR (remover estado de período)
src/pages/BudgetPage.css                   ← MODIFICAR (novas classes CSS)
src/pages/Tab1.tsx                         ← MODIFICAR (remover estado de período)
src/pages/Tab1.css                         ← verificar se há estilos de período
src/services/budgetService.ts              ← SEM ALTERAÇÃO
src/types/budget.ts                        ← SEM ALTERAÇÃO
NEW: src/components/CardPeriodBanner.tsx
NEW: src/components/CardPeriodBanner.test.tsx
NEW: src/components/PeriodEditModal.tsx
NEW: src/components/PeriodEditModal.test.tsx
```
