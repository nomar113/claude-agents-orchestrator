# Tarefa 2.0: Criar componente `PeriodEditModal`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `PeriodEditModal` — um `IonModal` bottom-sheet com dois `IonDatetime` (data de início e data de fim) que permite ao usuário editar o período de faturamento de um cartão. Ao confirmar, o modal chama `updateBudgetPeriods` diretamente via serviço e dispara o callback `onConfirmed`. O botão "Salvar" é desabilitado quando `endDate < startDate`.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — uso de `IonModal` com `breakpoints={[0, 0.6]}` e `initialBreakpoint={0.6}`; `IonDatetime` com `presentation="date"` e `locale="pt-BR"`
- `executar-task` — executar typecheck, testes e lint antes de marcar concluída
</skills>

<requirements>
- `IonModal` com `breakpoints={[0, 0.6]}` e `initialBreakpoint={0.6}` (padrão do projeto)
- Dois `IonDatetime` com `presentation="date"` e `locale="pt-BR"`
- Botão "Salvar" desabilitado quando `endDate < startDate`
- Ao confirmar: chamar `updateBudgetPeriods(budgetId, { periods: [{ paymentMethodId, startDate, endDate }] })`
- Ao cancelar: chamar `onDismiss` sem chamada de API
- Em caso de erro no save: exibir toast de danger via `useIonToast` (padrão do projeto)
- Após salvar com sucesso: chamar `onConfirmed()` e fechar o modal
</requirements>

## Subtarefas

- [ ] 2.1 Criar `src/components/PeriodEditModal.tsx` com as props definidas na Tech Spec
- [ ] 2.2 Implementar lógica de estado interno: `localStart` e `localEnd` inicializados com as props; atualização via `IonDatetime`
- [ ] 2.3 Implementar validação: desabilitar botão "Salvar" quando `localEnd < localStart`
- [ ] 2.4 Implementar handler de save: chamar `updateBudgetPeriods`, tratar erro com toast, chamar `onConfirmed` no sucesso
- [ ] 2.5 Criar `src/components/PeriodEditModal.test.tsx` com os casos de teste listados abaixo

## Detalhes de Implementacao

Ver `techspec.md` — seções:
- **Interfaces Principais** → `PeriodEditModalProps`
- **Endpoints de API** → `updateBudgetPeriods` em `budgetService.ts`
- **Pontos de Integração** → `IonModal` com `breakpoints`, `IonDatetime` com `keepContentsMounted`
- **Riscos Conhecidos** → IonDatetime e locale pt-BR; dois IonDatetime no mesmo modal em telas pequenas

## Criterios de Sucesso

- Modal renderiza fechado sem chamar API
- Botão "Salvar" chama `updateBudgetPeriods` com o payload correto
- Botão "Cancelar" chama `onDismiss` sem chamada de API
- Botão "Salvar" fica desabilitado quando `endDate < startDate`
- Toast de danger exibido em caso de erro
- Todos os testes passam (`vitest run`)
- Sem erros de TypeScript (`tsc --noEmit`)
- Lint sem warnings (`eslint`)

## Testes da Tarefa

- [ ] Testes de unidade (`PeriodEditModal.test.tsx`):
  - Renderiza modal fechado sem chamar API
  - Botão "Salvar" chama `updateBudgetPeriods` com payload correto (`budgetId`, `paymentMethodId`, `startDate`, `endDate`)
  - Botão "Cancelar" chama `onDismiss` sem API call
  - Botão "Salvar" desabilitado quando `endDate < startDate`
  - Exibe toast de danger quando `updateBudgetPeriods` rejeita
- [ ] Testes de integração: N/A (serviço mockado nos testes de unidade)
- [ ] Testes E2E: N/A nesta task

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PeriodEditModal.tsx` ← CRIAR
- `src/components/PeriodEditModal.test.tsx` ← CRIAR
- `src/services/budgetService.ts` ← SEM ALTERAÇÃO (apenas importar `updateBudgetPeriods`)
- `src/types/budget.ts` ← SEM ALTERAÇÃO (apenas importar tipos)
- `tasks/prd-estilo-datas-cartao/techspec.md` ← LEITURA OBRIGATÓRIA
