# Tarefa 14.0: [BUGFIX MINOR] Melhorias de qualidade — N+1, CSS, mensagens e acento

<critical>Ler os arquivos de prd.md, techspec.md e review_all_tasks.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Corrigir os 5 problemas minor identificados na review: N+1 query de categorias, classes CSS semanticamente incorretas, mensagens de excecao em portugues, e acento ausente no nome do mes.

<skills>
### Conformidade com Skills Padroes

- `executar-bugfix` — Seguir o procedimento completo de correcao de bugs
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Resolver N+1 query de nomes de categorias no `GetBudgetSummaryProvider`
- Corrigir classes CSS de meios de pagamento (usar `budget-payment-method` em vez de `budget-income`)
- Padronizar mensagens de excecao do backend para ingles
- Corrigir "Marco" para incluir acento correto nos nomes dos meses
</requirements>

## Subtarefas

- [ ] 14.1 Resolver N+1 em `GetBudgetSummaryProvider.kt`: buscar nomes de categorias em uma unica query ou JOIN
- [ ] 14.2 Criar classes CSS proprias para meios de pagamento (`budget-payment-method`, `budget-payment-method-label`) em BudgetPage.css
- [ ] 14.3 Atualizar BudgetPage.tsx para usar as novas classes CSS nos elementos de meios de pagamento
- [ ] 14.4 Padronizar mensagens de excecao do backend para ingles (ex: "Budget not found", "Item not found")
- [ ] 14.5 Corrigir "Marco" para o acento correto em `monthNames` no BudgetPage.tsx

## Detalhes de Implementacao

### N+1 Query (GetBudgetSummaryProvider.kt)
```kotlin
// ANTES: N chamadas queryCategoryName() por item
// DEPOIS: buscar todos os nomes em uma unica query
val categoryIds = items.map { it.categoryId }
val categoryNames = categoryRepository.findNamesByIds(categoryIds) // Map<Long, String>
```

### CSS (BudgetPage.css e BudgetPage.tsx)
```css
/* Adicionar classes proprias */
.budget-payment-method { /* estilos */ }
.budget-payment-method-label { /* estilos */ }
```

### Mensagens de Excecao
```kotlin
// ANTES
throw NoSuchElementException("Planejamento nao encontrado")
// DEPOIS
throw NoSuchElementException("Budget not found")
```

### Acento
```typescript
// ANTES
const monthNames = ['Janeiro', 'Fevereiro', 'Marco', ...];
// DEPOIS  
const monthNames = ['Janeiro', 'Fevereiro', 'Março', ...];
```

## Criterios de Sucesso

- Query de categorias executa em uma unica consulta (verificar via logs SQL)
- Classes CSS semanticamente corretas para meios de pagamento
- Todas as mensagens de excecao do bounded context budget em ingles
- "Março" exibido corretamente na interface
- Backend e frontend compilam sem erros
- Testes existentes continuam passando
