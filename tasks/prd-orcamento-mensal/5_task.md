# Tarefa 5.0: Frontend — CRUD de Receitas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `BudgetIncomeRow.tsx` com edicao inline de label e valor no modo edicao. Adicionar botoes de adicionar (+) e remover (x) receitas na secao Receitas. Integrar com `createBudgetIncome()`, `updateBudgetIncome()` e `deleteBudgetIncome()` do `budgetService.ts`. As operacoes sao salvas em real-time.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-17: Adicionar receita: campos label (texto livre) e valor
- RF-18: Editar receita: label e valor editaveis inline no modo edicao
- RF-19: Remover receita: botao de remover visivel no modo edicao, com confirmacao
</requirements>

## Subtarefas

- [ ] 5.1 Criar componente `BudgetIncomeRow.tsx` com props de `BudgetIncome` e `isEditing`
- [ ] 5.2 Modo visualizacao: exibir label a esquerda e valor a direita (conforme Paper — lista simples)
- [ ] 5.3 Modo edicao: label e valor viram inputs editaveis, botao X aparece
- [ ] 5.4 On blur/Enter do label ou valor: chamar `updateBudgetIncome(budgetId, incomeId, { label, amount })`
- [ ] 5.5 Botao + abaixo da secao Receitas: adicionar nova receita com label e valor padrao
- [ ] 5.6 Implementar formulario inline para nova receita (input label + input valor + botao confirmar)
- [ ] 5.7 Botao X: IonAlert confirmacao → `deleteBudgetIncome(budgetId, incomeId)` → `load()`
- [ ] 5.8 Substituir renderizacao de receitas em `BudgetPage.tsx` pelo novo componente
- [ ] 5.9 Escrever e executar testes

## Detalhes de Implementacao

Consultar secao "Interfaces Principais" da techspec.md.

**Props do componente:**
```typescript
interface BudgetIncomeRowProps {
  income: BudgetIncome;
  budgetId: number;
  isEditing: boolean;
  onUpdate: () => void;  // callback para recarregar dados
  onDelete: () => void;
}
```

**Layout Paper (secao Receitas):**
- Card container: background `#151A35`, border-radius `16px`, padding `16px`, gap `14px`
- Cada linha: label a esquerda (IBM Plex Sans 18px), valor a direita (IBM Plex Sans 18px)
- Separador: `1px solid #ffffff0a` entre linhas

## Criterios de Sucesso

- Receitas exibidas conforme layout Paper em modo visualizacao
- Em modo edicao, label e valor sao editaveis inline
- Adicionar receita cria novo registro no backend
- Remover receita exige confirmacao e deleta do backend
- Editar receita salva automaticamente ao sair do campo

## Testes da Tarefa

- [ ] Teste unitario: `BudgetIncomeRow` modo visualizacao exibe label e valor formatado
- [ ] Teste unitario: `BudgetIncomeRow` modo edicao exibe inputs editaveis e botao remover
- [ ] Teste de integracao: Adicionar receita → verificar que aparece na lista
- [ ] Teste de integracao: Editar label e valor → verificar persistencia
- [ ] Teste de integracao: Remover receita com confirmacao → verificar que desaparece

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/components/BudgetIncomeRow.tsx` (novo)
- `src/pages/BudgetPage.tsx` (modificar — substituir renderizacao de receitas, adicionar botao +)
- `src/pages/BudgetPage.css` (modificar — estilos da secao receitas)
- `src/services/budgetService.ts` (ja tem createBudgetIncome, updateBudgetIncome, deleteBudgetIncome)
- **Design:** Paper artboard "Orcamento Mensal" (ID 158-0), node "Receitas Card" (1B8-0)
