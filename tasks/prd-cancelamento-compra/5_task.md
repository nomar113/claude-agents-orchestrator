# Tarefa 5.0: Queries de Totais (Budget)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar todas as queries de calculo de orcamento e totais para excluir compras canceladas (`cancelled_at IS NOT NULL`).

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de native queries do projeto.
</skills>

<requirements>
- Query `queryActualByCategory()` deve adicionar `AND pn.cancelled_at IS NULL`
- Query `queryPaymentMethodTotals()` deve adicionar `AND pn.cancelled_at IS NULL`
- Qualquer outra query de agregacao/soma deve excluir cancelados
- Totais por cartao nao devem incluir compras canceladas (RF-21)
- Totais por categoria nao devem incluir compras canceladas (RF-22)
</requirements>

## Subtarefas

- [ ] 5.1 Identificar todas as queries de agregacao no `GetBudgetSummaryProvider`
- [ ] 5.2 Adicionar filtro `cancelled_at IS NULL` em `queryActualByCategory()`
- [ ] 5.3 Adicionar filtro `cancelled_at IS NULL` em `queryPaymentMethodTotals()`
- [ ] 5.4 Verificar se ha outras queries de soma/agregacao que precisam do filtro
- [ ] 5.5 Verificar que queries de `purchase_invoices` tambem filtram cancelados (se participam de totais)

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > GetBudgetSummaryProvider"

As queries ja possuem `AND pn.deleted_at IS NULL`. Adicionar `AND pn.cancelled_at IS NULL` no mesmo padrao.

## Criterios de Sucesso

- Total mensal exclui valores de compras canceladas (RF-19)
- Orcamento utilizado nao contabiliza canceladas (RF-20)
- Totais por cartao excluem canceladas (RF-21)
- Totais por categoria excluem canceladas (RF-22)
- Compras ativas continuam sendo contabilizadas normalmente

## Testes da Tarefa

- [ ] Testes de integracao: criar compras, cancelar algumas, verificar que totais refletem apenas compras ativas
- [ ] Testes de integracao: verificar que budget percentUsed calcula corretamente com mix de ativas/canceladas
- [ ] Testes de integracao: verificar totais por categoria com canceladas

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../budget/application/GetBudgetSummaryProvider.kt`
- `src/main/kotlin/.../budget/entrypoint/database/repository/` (repositorios de budget)
