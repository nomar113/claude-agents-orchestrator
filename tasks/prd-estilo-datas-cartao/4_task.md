# Tarefa 4.0: Refatorar `BudgetPeriodSection`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Refatorar `BudgetPeriodSection` para remover as props de edição global (`isEditing`, `editValues`, `onStartChange`, `onEndChange`, `errors`) e adicionar `budgetId` e `onPeriodSaved`. O componente passa a repassar `budgetId` e `onPeriodSaved` para cada `BudgetPeriodCard` filho, eliminando o acoplamento com o modo de edição global das pages pai.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — executar typecheck, testes e lint antes de marcar concluída
</skills>

<requirements>
- Remover props: `isEditing`, `editValues`, `onStartChange`, `onEndChange`, `errors`
- Adicionar props: `budgetId: number` e `onPeriodSaved: () => void`
- Repassar `budgetId` e `onPeriodSaved` para cada `BudgetPeriodCard` renderizado
- Atualizar testes: remover casos de `isEditing`/`editValues`; adicionar caso que verifica repasse de `budgetId`
- Garantir que a interface exportada não quebra `Tab1.tsx` e `BudgetPage.tsx` (esses arquivos serão atualizados na task 5)
</requirements>

## Subtarefas

- [ ] 4.1 Atualizar a interface `BudgetPeriodSectionProps` em `BudgetPeriodSection.tsx`: remover props de edição global, adicionar `budgetId` e `onPeriodSaved`
- [ ] 4.2 Remover toda lógica de renderização de edição inline (inputs de "De/Até", erros de validação) do componente
- [ ] 4.3 Repassar `budgetId` e `onPeriodSaved` para cada `BudgetPeriodCard` no `map` de renderização
- [ ] 4.4 Atualizar `BudgetPeriodSection.test.tsx`: remover testes de `isEditing`/`editValues`; adicionar teste de repasse de `budgetId` para cada card

## Detalhes de Implementacao

Ver `techspec.md` — seções:
- **Interfaces Principais** → `BudgetPeriodSectionProps` (props que mudam)
- **Visão Geral dos Componentes** → linha `BudgetPeriodSection` (MODIFICAR)
- **Riscos Conhecidos** → "Remoção de props de `BudgetPeriodSection`: garantir que ambas as pages sejam atualizadas"

## Criterios de Sucesso

- `BudgetPeriodSection` não contém mais referências a `isEditing`, `editValues`, `onStartChange`, `onEndChange` ou `errors`
- `budgetId` é repassado para cada `BudgetPeriodCard` filho
- Testes atualizados passam (`vitest run`)
- Sem erros de TypeScript (`tsc --noEmit`) — **atenção**: `Tab1.tsx` e `BudgetPage.tsx` ainda passam as props antigas neste ponto; TypeScript vai apontar erros que serão corrigidos na task 5
- Lint sem warnings (`eslint`)

## Testes da Tarefa

- [ ] Testes de unidade (`BudgetPeriodSection.test.tsx`):
  - Prop `budgetId` é repassada para cada `BudgetPeriodCard`
  - Remove: testes que passam `isEditing` / `editValues`
- [ ] Testes de integração: N/A
- [ ] Testes E2E: N/A nesta task

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/BudgetPeriodSection.tsx` ← MODIFICAR
- `src/components/BudgetPeriodSection.test.tsx` ← ATUALIZAR
- `src/components/BudgetPeriodCard.tsx` ← DEPENDÊNCIA (task 3)
- `src/pages/Tab1.tsx` ← SERÁ ATUALIZADO NA TASK 5 (pode ter erros de TS temporariamente)
- `src/pages/BudgetPage.tsx` ← SERÁ ATUALIZADO NA TASK 5 (pode ter erros de TS temporariamente)
- `tasks/prd-estilo-datas-cartao/techspec.md` ← LEITURA OBRIGATÓRIA
