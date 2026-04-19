# Tarefa 2.0: Frontend — Redesign Summary Card

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `BudgetSummarySection.tsx` que substitui o summary card atual por um design alinhado ao Paper. Deve exibir badge de porcentagem com cor dinamica, valores "Planejado" e "Real" lado a lado, barra de progresso, e linha inferior com Receitas, Saldo e Investido. Atualizar `BudgetPage.tsx` para usar o novo componente e `budget.ts` para adicionar `categoryIcon` no tipo.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-01: Badge de porcentagem com cor dinamica (verde <=80%, amarelo >80%, vermelho >100%)
- RF-02: Valores "Planejado" e "Real" lado a lado com barra de progresso entre eles
- RF-03: Linha inferior com tres metricas: Receitas, Saldo e Investido
- RF-04: Calculo de "Investido" = soma dos valores planejados dos itens tipo INVESTMENT (campo `totalInvestmentExpected` ja existe no BudgetSummary)
</requirements>

## Subtarefas

- [ ] 2.1 Atualizar `budget.ts` — adicionar `categoryIcon: string | null` em `BudgetItemSummary`
- [ ] 2.2 Criar componente `BudgetSummarySection.tsx` com props de `BudgetSummary`
- [ ] 2.3 Implementar badge de porcentagem com cor dinamica (verde/amarelo/vermelho)
- [ ] 2.4 Implementar layout "Planejado" e "Real" lado a lado com labels e valores grandes
- [ ] 2.5 Implementar barra de progresso com cor dinamica e largura proporcional
- [ ] 2.6 Implementar linha inferior com Receitas, Saldo e Investido
- [ ] 2.7 Atualizar `BudgetPage.css` com estilos do Paper (gradient do summary card, tipografia, cores)
- [ ] 2.8 Substituir o summary card atual em `BudgetPage.tsx` pelo novo `BudgetSummarySection`
- [ ] 2.9 Escrever e executar testes

## Detalhes de Implementacao

Consultar a secao "Design de referencia" da techspec.md para tokens de design (cores, gradientes, fontes).

**Design tokens do Paper (summary card):**
- Background: gradient `oklab(27.4% -0.002 -0.065)` → `oklab(22.9% 0.003 -0.053)` a 135deg
- Border: `1px solid #4F8BFF14`
- Border-radius: `20px`
- Padding: `24px`
- Gap: `20px`
- Fontes: IBM Plex Sans (labels), IBM Plex Mono (valores)

**Props do componente:**
```typescript
interface BudgetSummarySectionProps {
  summary: BudgetSummary;
}
```

## Criterios de Sucesso

- Summary card exibe todos os 6 valores: %, Planejado, Real, Receitas, Saldo, Investido
- Cores do badge mudam corretamente nos 3 thresholds (<=80%, >80%, >100%)
- Layout alinhado ao artboard Paper "Orcamento Mensal" (ID 158-0)
- Componente antigo removido sem regressao

## Testes da Tarefa

- [ ] Teste unitario: `BudgetSummarySection` renderiza com dados completos
- [ ] Teste unitario: Badge verde quando percentUsed <= 80
- [ ] Teste unitario: Badge amarelo quando percentUsed > 80 e <= 100
- [ ] Teste unitario: Badge vermelho quando percentUsed > 100
- [ ] Teste unitario: Investido exibe `totalInvestmentExpected` corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/components/BudgetSummarySection.tsx` (novo)
- `src/pages/BudgetPage.tsx` (modificar — substituir summary card)
- `src/pages/BudgetPage.css` (modificar — adicionar estilos do Paper)
- `src/types/budget.ts` (modificar — adicionar categoryIcon)
- **Design:** Paper artboard "Orcamento Mensal" (ID 158-0), node "Summary Card" (ID 15O-0)
