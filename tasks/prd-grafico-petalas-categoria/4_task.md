# Tarefa 4.0: `CategoryConsumptionList` — lista de categorias com ordenacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `src/components/CategoryConsumptionList.tsx`: lista de categorias com, por linha, indicador de cor (mesma cor da petala/legenda), nome, "R$ gasto · de R$ limite", percentual, barra de progresso e badge "Estourou" quando acima de 100%. Inclui seletor de ordenacao entre "% do limite" (padrao, decrescente) e "valor gasto" (decrescente). Componente puro: recebe `BudgetItemSummary[]` ja filtrado e callback `onCategoryClick`.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` / `frontend-design` — dark theme, contraste das barras/percentuais nos tons de alerta, tap targets ≥ 44pt nas linhas e abas de ordenacao.
- `vercel-react-best-practices` — ordenacao derivada via `useMemo`; callbacks estaveis.
- `clean-code` — regras de calculo nomeadas e colocalizadas; componente com responsabilidade unica.
</skills>

<requirements>
- PRD 3.1: linha com cor, nome, valor gasto e limite, percentual e barra de progresso proporcional.
- PRD 3.2: badge "Estourou" e estilo de alerta no percentual e na barra quando `actual > expected`.
- PRD 3.3: seletor de ordenacao "% do limite" (padrao desc) | "valor gasto" (desc), com estado ativo claramente indicado.
- PRD 3.4: toque na linha dispara `onCategoryClick(categoryId)`.
- Acessibilidade (PRD): `aria-label` por linha `"{Categoria}: R$ {gasto} de R$ {limite}, {percentual}% do limite"` + ", acima do limite" quando estourada; estouro nunca comunicado apenas por cor.
- Calculos identicos aos da distribuicao: percentual `Math.round((actual / expected) * 100)`; formatacao via `utils/currency`.
</requirements>

## Subtarefas

- [x] 4.1 Criar `CategoryConsumptionList.tsx` com props conforme techspec (`items: BudgetItemSummary[]`, `onCategoryClick`) e ordenacao interna `'percent'` (default) | `'amount'`.
- [x] 4.2 Implementar linha completa (cor, nome, valores, %, barra, badge "Estourou") com estilos de alerta e `aria-label`.
- [x] 4.3 Implementar seletor de ordenacao com indicacao de estado ativo.
- [x] 4.4 Testes de unidade (Vitest + Testing Library): renderizacao completa da linha; badge "Estourou" so quando `actual > expected`; ordenacao padrao "% do limite" desc; alternancia para "valor gasto" desc; `aria-label` correto; clique dispara callback com o `categoryId`.

## Detalhes de Implementacao

Ver techspec.md, secoes "Interfaces Principais" (`CategoryConsumptionListProps`) e "Modelos de Dados" (formulas de percentual, estouro e formatacao).

## Criterios de Sucesso

- Lista exibe exatamente os itens recebidos (o filtro `EXPENSE && expected > 0 && actual > 0` e responsabilidade da pagina).
- Ordenacoes funcionam e o estado ativo e visivel.
- Leitores de tela recebem o rotulo acessivel completo por linha.
- Testes do componente verdes.

## Testes da Tarefa

- [x] Testes de unidade
- [ ] Testes de integracao (coberto na Tarefa 5.0 via `ByCategoryPage`)
- [ ] Testes E2E (nao aplicavel nesta tarefa)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/components/CategoryConsumptionList.tsx` (novo, + teste)
- `controlai-frontend/src/types/budget.ts` (`BudgetItemSummary`, consultado)
- `controlai-frontend/src/utils/currency.ts` (consultado)
