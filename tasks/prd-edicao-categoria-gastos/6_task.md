# Tarefa 6.0: Frontend — Verificacao de orcamento e CTA

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Apos o usuario selecionar uma categoria, verificar se ela consta como item do orcamento do mes correspondente ao gasto. Se nao constar, exibir um banner nao-bloqueante com CTA "Adicionar ao orcamento" que cria o budget item automaticamente via API com valor esperado zerado (R$ 0,00).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Apos salvar categoria (tanto no PurchaseDetail quanto na listagem), verificar se a categoria existe no budget do mes
- Usar `GET /budgets?month=YYYY-MM` (mes extraido da data `purchasedAt` do gasto)
- Verificar se `budget.items` contem item com `categoryId` igual ao selecionado
- Se budget NAO existir para o mes: nao exibir nenhum aviso
- Se budget existir mas categoria NAO estiver nos items: exibir banner informativo
- Banner deve conter texto "Esta categoria nao esta no orcamento de [mes]" e CTA "Adicionar ao orcamento"
- CTA executa `POST /budgets/{budgetId}/items` com `{ categoryId, expected: 0, type: "EXPENSE" }`
- Apos criar item com sucesso, remover o banner
- Banner deve ser discreto e nao bloquear o uso da tela
- Criar funcoes auxiliares em `budgetService.ts`: `checkCategoryInBudget` e `addBudgetItem`
</requirements>

## Subtarefas

- [ ] 6.1 Criar funcao `checkCategoryInBudget(month, categoryId)` em `budgetService.ts`
- [ ] 6.2 Criar funcao `addBudgetItem(budgetId, categoryId, expected, type)` em `budgetService.ts` (se nao existir)
- [ ] 6.3 Criar componente de banner `BudgetCategoryWarning` (ou inline no PurchaseDetail/Tab1)
- [ ] 6.4 Integrar verificacao no PurchaseDetail apos selecao de categoria
- [ ] 6.5 Integrar verificacao na listagem (Tab1) apos selecao de categoria
- [ ] 6.6 Implementar CTA que cria budget item via API
- [ ] 6.7 Escrever testes unitarios

## Detalhes de Implementacao

Consultar a secao **"Pontos de Integracao"** da `techspec.md` para o fluxo completo de verificacao e criacao.

**Logica de verificacao (frontend-side):**
1. Extrair mes do `purchasedAt` do gasto no formato `YYYY-MM`
2. Chamar `GET /budgets?month=YYYY-MM`
3. Se resposta vazia (sem budget): nao exibir aviso
4. Se resposta tem budget: verificar `budget.items.some(item => item.categoryId === selectedCategoryId)`
5. Se nao encontrar: exibir banner

**Criacao de budget item:**
```typescript
POST /budgets/{budgetId}/items
{ categoryId: number, expected: 0, type: "EXPENSE" }
```

## Criterios de Sucesso

- Apos selecionar categoria, verificacao de budget e feita automaticamente
- Banner aparece quando categoria nao esta no orcamento do mes
- Banner NAO aparece quando categoria ja esta no orcamento
- Banner NAO aparece quando nao existe budget para o mes
- CTA cria budget item com sucesso e remove o banner
- Funciona tanto no PurchaseDetail quanto na listagem
- Testes passam

## Testes da Tarefa

- [ ] Testes de unidade: `checkCategoryInBudget` retorna true/false corretamente
- [ ] Testes de unidade: banner renderiza quando categoria nao esta no budget
- [ ] Testes de unidade: banner nao renderiza quando categoria esta no budget
- [ ] Testes de unidade: banner nao renderiza quando nao existe budget para o mes
- [ ] Testes de unidade: CTA chama API de criacao de budget item
- [ ] Testes de unidade: banner desaparece apos criacao bem-sucedida

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Modificar:**
- `src/services/budgetService.ts` (no projeto controlai-frontend)
- `src/pages/PurchaseDetail.tsx` (no projeto controlai-frontend)
- `src/pages/Tab1.tsx` (no projeto controlai-frontend)

**Criar (opcional):**
- `src/components/BudgetCategoryWarning.tsx` (no projeto controlai-frontend)
- `src/components/BudgetCategoryWarning.css` (no projeto controlai-frontend)

**Referencia:**
- `src/services/budgetService.ts` — endpoints de budget existentes
- `src/types/budget.ts` — tipos `BudgetSummary`, `BudgetItemSummary`
