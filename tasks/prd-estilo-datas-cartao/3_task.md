# Tarefa 3.0: Refatorar `BudgetPeriodCard`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Refatorar o componente `BudgetPeriodCard` para integrar `CardPeriodBanner` (task 1) e `PeriodEditModal` (task 2), removendo os inputs inline "De/Até" que existiam antes. O componente passa a receber `budgetId` como nova prop e gerencia o estado de abertura do modal internamente.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — manter padrões visuais do card (badge, nome, valor) inalterados
- `executar-task` — executar typecheck, testes e lint antes de marcar concluída
</skills>

<requirements>
- Remover inputs inline "De" e "Até" e toda lógica de edição global associada
- Integrar `CardPeriodBanner` no topo do card (passando `startDate`, `endDate` e `onTap`)
- Integrar `PeriodEditModal` controlado por estado local `isEditModalOpen`
- Adicionar prop `budgetId: number` à interface do componente
- Manter prop `onPeriodSaved: () => void` para notificar o pai após salvar
- Exportar `toDisplay`, `toIso` e `applyMask` (se existirem) para não quebrar outros consumidores
- Atualizar testes: remover casos de inputs "De/Até", adicionar caso de renderização do banner com datas
</requirements>

## Subtarefas

- [ ] 3.1 Adicionar `budgetId` e `onPeriodSaved` à interface de props do `BudgetPeriodCard`
- [ ] 3.2 Remover os inputs inline de período ("De" / "Até") e suas classes CSS associadas do componente
- [ ] 3.3 Adicionar estado local `isEditModalOpen` (boolean)
- [ ] 3.4 Renderizar `CardPeriodBanner` acima do corpo do card, passando `onTap={() => setIsEditModalOpen(true)}`
- [ ] 3.5 Renderizar `PeriodEditModal` com `isOpen={isEditModalOpen}`, `onConfirmed={() => { setIsEditModalOpen(false); onPeriodSaved(); }}` e `onDismiss={() => setIsEditModalOpen(false)}`
- [ ] 3.6 Atualizar `BudgetPeriodCard.test.tsx`: remover testes de inputs inline; adicionar teste de renderização do `CardPeriodBanner` com datas corretas

## Detalhes de Implementacao

Ver `techspec.md` — seções:
- **Visão Geral dos Componentes** → linha `BudgetPeriodCard` (MODIFICAR)
- **Fluxo de dados** → `BudgetSummary.periods[]` → ... → `CardPeriodBanner` → `PeriodEditModal`
- **Dependências Técnicas** → exportar `toDisplay`/`toIso`/`applyMask`

## Criterios de Sucesso

- `BudgetPeriodCard` renderiza `CardPeriodBanner` com as datas do período
- Toque no banner abre `PeriodEditModal`
- Nenhum input "De/Até" presente no componente
- Badge com iniciais e nome do método de pagamento ainda renderiza corretamente
- Testes atualizados passam (`vitest run`)
- Sem erros de TypeScript (`tsc --noEmit`)
- Lint sem warnings (`eslint`)

## Testes da Tarefa

- [ ] Testes de unidade (`BudgetPeriodCard.test.tsx`):
  - Renderiza `CardPeriodBanner` com as datas do período (startDate e endDate corretos)
  - Mantém: renderiza badge com iniciais e nome do método de pagamento
  - Remove: testes de inputs inline "De" / "Até"
- [ ] Testes de integração: N/A
- [ ] Testes E2E: N/A nesta task

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/BudgetPeriodCard.tsx` ← MODIFICAR
- `src/components/BudgetPeriodCard.test.tsx` ← ATUALIZAR
- `src/components/CardPeriodBanner.tsx` ← DEPENDÊNCIA (task 1)
- `src/components/PeriodEditModal.tsx` ← DEPENDÊNCIA (task 2)
- `tasks/prd-estilo-datas-cartao/techspec.md` ← LEITURA OBRIGATÓRIA
