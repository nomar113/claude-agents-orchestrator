# Tarefa 6.0: Frontend — Duplicar Mes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `DuplicateMonthModal.tsx` que permite ao usuario copiar o orcamento atual para outro mes. Usa `IonModal` com `IonDatetime` em `presentation="month-year"` para selecao do mes destino. Integra com endpoint existente `POST /budgets/{id}/duplicate?targetMonth=YYYY-MM`. Trata caso de mes destino ja possuir orcamento.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-20: Botao "Duplicar Mes" no rodape abre seletor de mes destino
- RF-21: O seletor exibe meses futuros e indica quais ja possuem orcamento
- RF-22: Ao confirmar, chama endpoint POST /budgets/{id}/duplicate?targetMonth=YYYY-MM
- RF-23: Exibe toast de sucesso/erro apos a duplicacao
- RF-24: Se o mes destino ja tiver orcamento, exibir alerta de confirmacao para sobrescrever
</requirements>

## Subtarefas

- [ ] 6.1 Criar componente `DuplicateMonthModal.tsx` com IonModal e IonDatetime
- [ ] 6.2 Configurar IonDatetime com `presentation="month-year"` e locale pt-BR
- [ ] 6.3 Ao confirmar mes: chamar `duplicateBudget(budgetId, targetMonth)` do `budgetService.ts`
- [ ] 6.4 Tratar erro 409 (mes destino ja existe): exibir IonAlert pedindo confirmacao para sobrescrever
- [ ] 6.5 Exibir toast de sucesso com "Orcamento duplicado para [mes]"
- [ ] 6.6 Exibir toast de erro em caso de falha
- [ ] 6.7 Integrar modal no `BudgetPage.tsx` com estado `showDuplicateModal`
- [ ] 6.8 Adicionar botao "Duplicar Mes" provisorio (layout final na Task 7)
- [ ] 6.9 Escrever e executar testes

## Detalhes de Implementacao

Consultar secao "Pontos de Integracao > Duplicacao de budget" da techspec.md.

**Props do componente:**
```typescript
interface DuplicateMonthModalProps {
  isOpen: boolean;
  budgetId: number;
  currentMonth: string; // YYYY-MM
  onDismiss: () => void;
  onDuplicated: (targetMonth: string) => void;
}
```

**Comportamento do IonDatetime:**
- `presentation="month-year"` para selecao apenas de mes/ano
- Valor inicial: mes seguinte ao atual
- `onIonChange`: capturar valor selecionado em formato ISO e converter para YYYY-MM

**Tratamento de erro 409:**
- Backend (`DuplicateBudgetProvider`) lanca erro quando mes destino ja existe
- Frontend deve capturar o erro e exibir IonAlert: "Ja existe orcamento para [mes]. Deseja sobrescrever?"
- Se confirmar: deletar budget existente e re-duplicar (ou implementar logica de sobrescrita conforme backend)

## Criterios de Sucesso

- Modal abre com seletor de mes funcional
- Duplicacao cria budget no mes destino com mesmos itens e receitas
- Erro 409 tratado com alerta de confirmacao
- Toast de feedback exibido apos operacao
- Modal fecha apos sucesso

## Testes da Tarefa

- [ ] Teste unitario: `DuplicateMonthModal` renderiza IonDatetime com presentation month-year
- [ ] Teste unitario: Botao confirmar chama `duplicateBudget` com mes selecionado
- [ ] Teste de integracao: Duplicar para mes vazio → verificar budget criado
- [ ] Teste de integracao: Duplicar para mes existente → verificar alerta de confirmacao

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/components/DuplicateMonthModal.tsx` (novo)
- `src/pages/BudgetPage.tsx` (modificar — estado showDuplicateModal, botao provisorio)
- `src/services/budgetService.ts` (ja tem duplicateBudget)
