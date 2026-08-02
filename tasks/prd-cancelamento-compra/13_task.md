# Tarefa 13.0: Totais Frontend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar o calculo de totais exibidos no frontend para excluir compras canceladas, garantindo que os valores apresentados ao usuario refletem apenas compras ativas.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de calculo de totais do projeto.
</skills>

<requirements>
- O "TOTAL FILTRADO" no Tab1 deve excluir compras com `cancelledAt` preenchido
- O BudgetSummarySection ja recebe dados calculados pelo backend (Task 5 garante isso)
- Verificar que nao ha calculo frontend duplicado que inclua canceladas
- Garantir consistencia entre total exibido na lista e total do budget
</requirements>

## Subtarefas

- [ ] 13.1 Atualizar calculo de `filteredTotal` no Tab1 para filtrar items com `cancelledAt !== null`
- [ ] 13.2 Verificar que BudgetSummarySection reflete corretamente os novos totais do backend
- [ ] 13.3 Verificar se ha outros pontos no frontend que somam valores de compras (e filtrar canceladas)
- [ ] 13.4 Testar cenario end-to-end: cancelar compra e verificar que totais atualizam

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > Tab1.tsx"

O calculo atual no Tab1:
```typescript
const filteredTotal = useMemo(
  () => notifications.reduce((sum, n) => sum + (n.amount ?? 0), 0),
  [notifications],
);
```

Deve ser atualizado para:
```typescript
const filteredTotal = useMemo(
  () => notifications
    .filter(n => !n.cancelledAt)
    .reduce((sum, n) => sum + (n.amount ?? 0), 0),
  [notifications],
);
```

## Criterios de Sucesso

- Total filtrado exclui compras canceladas
- Ao cancelar uma compra, o total atualiza imediatamente
- Budget summary reflete totais corretos (calculados pelo backend)
- Nao ha inconsistencia entre total da lista e total do budget

## Testes da Tarefa

- [ ] Teste manual: verificar total antes e depois de cancelar uma compra
- [ ] Teste manual: verificar que budget summary e total filtrado sao consistentes
- [ ] Teste manual: verificar com filtros de categoria/cartao aplicados

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/Tab1.tsx` (calculo de filteredTotal)
- `src/components/BudgetSummarySection.tsx` (exibicao de totais de budget)
