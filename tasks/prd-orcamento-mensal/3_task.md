# Tarefa 3.0: Frontend — Redesign Category Cards

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `BudgetCategoryCard.tsx` que substitui os itens atuais (linhas simples com Prev/Real/Dif) por cards visuais alinhados ao Paper. Cada card exibe emoji da categoria, nome, diferenca colorida, valores Plan/Real e barra de progresso individual. Substitui a renderizacao nas secoes Gastos e Investimentos do `BudgetPage.tsx`.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-05: Icone/emoji da categoria a esquerda (ou emoji generico se `categoryIcon` for null)
- RF-06: Nome da categoria e diferenca colorida ("+R$ X" verde ou "-R$ X" vermelho) na linha superior
- RF-07: Valores "Plan: R$ X" e "Real: R$ X" na linha inferior
- RF-08: Barra de progresso individual (proporcao real/planejado) com cor dinamica
- RF-26: Exibir o icone da categoria nos cards
</requirements>

## Subtarefas

- [ ] 3.1 Criar componente `BudgetCategoryCard.tsx` com props de `BudgetItemSummary`
- [ ] 3.2 Implementar area do emoji (36x36 container com emoji da categoria ou fallback "📋")
- [ ] 3.3 Implementar linha superior: nome da categoria + diferenca com cor (verde positivo, vermelho negativo, neutro zero)
- [ ] 3.4 Implementar linha inferior: "Plan: R$ X" e "Real: R$ X" em texto menor
- [ ] 3.5 Implementar barra de progresso por item (largura = min(actual/expected, 1) * 100%)
- [ ] 3.6 Atualizar `BudgetPage.css` com estilos dos category cards do Paper (background, border, border-radius, gap)
- [ ] 3.7 Substituir renderizacao de itens em `BudgetPage.tsx` (secoes Gastos e Investimentos) pelo novo componente
- [ ] 3.8 Escrever e executar testes

## Detalhes de Implementacao

Consultar secao "Design de referencia" da techspec.md para tokens de design.

**Design tokens do Paper (category card):**
- Background: `#151A35`
- Border: `1px solid #4F8BFF0F`
- Border-radius: `16px`
- Padding: `14px 16px`
- Gap: `12px`
- Emoji container: `36x36`, border-radius `10px`, background `#ffffff0f`

**Props do componente (modo visualizacao apenas nesta task — modo edicao sera adicionado na Task 4):**
```typescript
interface BudgetCategoryCardProps {
  item: BudgetItemSummary;
}
```

**Formatacao da diferenca:**
- Positiva (sobra): `+R$ X` em verde (`#4ade80`)
- Negativa (estourou): `-R$ X` em vermelho (`#f87171`)
- Zero: `R$ 0` em neutro (`#ffffffcc`)

## Criterios de Sucesso

- Cards substituem o layout antigo de linhas nas secoes Gastos e Investimentos
- Emoji exibido corretamente (ou fallback quando null)
- Cores da diferenca aplicadas corretamente
- Barra de progresso proporcional ao real/planejado
- Layout alinhado ao Paper artboard

## Testes da Tarefa

- [ ] Teste unitario: Renderiza com emoji da categoria quando `categoryIcon` e definido
- [ ] Teste unitario: Renderiza emoji fallback quando `categoryIcon` e null
- [ ] Teste unitario: Diferenca positiva exibe verde e prefixo "+"
- [ ] Teste unitario: Diferenca negativa exibe vermelho e prefixo "-"
- [ ] Teste unitario: Barra de progresso com largura proporcional (ex: 50% quando actual = expected/2)
- [ ] Teste unitario: Barra nao ultrapassa 100% quando actual > expected

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/components/BudgetCategoryCard.tsx` (novo)
- `src/pages/BudgetPage.tsx` (modificar — substituir renderizacao de itens)
- `src/pages/BudgetPage.css` (modificar — adicionar estilos dos cards)
- **Design:** Paper artboard "Orcamento Mensal" (ID 158-0), nodes "Category: Mercado" (16J-0), "Category: Moradia" (16W-0)
