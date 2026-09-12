# Tarefa 7.0: Layout responsivo — Orçamento e Categorias

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Ajustar o CSS/grid das telas de orçamento e categorias — `BudgetPage`, `BudgetSummarySection`, `BudgetPeriodSection`, `BudgetCategoryCard`, `CategoriesPage` — para telas largas, sem alterar lógica de negócio, chamadas de serviço ou estruturas de dados.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se ao uso de `IonGrid`/breakpoints para os cartões e seções de orçamento por categoria.
- `frontend-design` — aplica-se à qualidade visual do layout desktop dessas telas.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 2`: RF-6 (visualizar e planejar orçamento mensal por categoria).
- Tech Spec `Sequenciamento de Desenvolvimento`: orçamento/categorias é a terceira leva de telas responsivas.
- Não alterar `services/budgetService.ts`, `services/categoryService.ts` ou contratos de API.
</requirements>

## Subtarefas

- [ ] 7.1 Ajustar `BudgetPage.tsx`/`.css` e `BudgetSummarySection.tsx`/`BudgetSummaryCard.tsx` para um layout em grade em telas largas.
- [ ] 7.2 Ajustar `BudgetPeriodSection.tsx`/`BudgetPeriodCard.tsx` e `BudgetCategoryCard.tsx` para exibir múltiplos períodos/categorias lado a lado em desktop.
- [ ] 7.3 Ajustar `CategoriesPage.tsx`/`.css` para uma grade de categorias em telas largas.
- [ ] 7.4 Confirmar que o layout mobile original (incluindo `PetalDistributionChart`) permanece inalterado abaixo do breakpoint.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Páginas existentes") e `Riscos Conhecidos`.

## Critérios de Sucesso

- Orçamento mensal por categoria é navegável e legível em telas ≥ 992px, com melhor aproveitamento de espaço do que a lista vertical mobile.
- Tela de categorias exibe uma grade adequada ao invés de lista única em desktop.
- Nenhuma regressão no layout/comportamento mobile.

## Testes da Tarefa

- [ ] Testes de unidade/RTL existentes (`BudgetPage.test.tsx`, `BudgetSummarySection.test.tsx`, `BudgetPeriodSection.test.tsx`, `CategoriesPage.test.tsx`) continuam passando.
- [ ] Novo teste verificando presença/acessibilidade dos elementos principais dessas telas em viewport desktop simulado.
- [ ] Teste manual visual do fluxo de planejamento de orçamento em desktop.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/BudgetPage.tsx`, `.css`
- `controlai-frontend/src/pages/CategoriesPage.tsx`, `.css`
- `controlai-frontend/src/components/BudgetSummarySection.tsx`, `BudgetSummaryCard.tsx`
- `controlai-frontend/src/components/BudgetPeriodSection.tsx`, `BudgetPeriodCard.tsx`, `BudgetCategoryCard.tsx`
- Depende de: Tarefa 3.0 (shell de navegação)
