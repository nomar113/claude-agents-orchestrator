# Tarefa 8.0: Pontos de entrada — Tab1 e BudgetPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Conectar os pontos de entrada da tela "Por categoria" (PRD 6.x): o botao "Ver gastos detalhados" do widget da Tab1 passa a navegar para `/by-category?month={mes corrente}` (substituindo o scroll definido na techspec de distribuicao — decisao de clarificacao), e a `BudgetPage` ganha link "Por categoria" preservando o mes selecionado, alem de abrir o `CategoryDetailSheet` ao tocar nas linhas de categoria (atende PRD 4.8 sem grafico novo na BudgetPage).

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — callbacks estaveis de navegacao; sem estado global novo (mes via query param).
- `ionic-design` — link/botao com tap target adequado; `IonBackButton` retorna a origem.
- `clean-code` — reuso do `CategoryDetailSheet` sem duplicacao de logica.
</skills>

<requirements>
- PRD 6.1: widget da Tab1 da acesso a tela com o mes corrente (`history.push('/by-category?month=' + currentMonth)` no callback `onViewDetailsClick`).
- PRD 6.2: BudgetPage da acesso a tela preservando o mes selecionado no Orcamento Mensal.
- PRD 6.3: botao de voltar retorna a tela de origem (React Router 5 preserva o historico).
- PRD 4.8: linhas de categoria da BudgetPage abrem o `CategoryDetailSheet` com o mes da BudgetPage.
- Sem grafico novo na BudgetPage (decisao de clarificacao da techspec).
</requirements>

## Subtarefas

- [x] 8.1 Tab1: redirecionar o botao "Ver gastos detalhados" do `PetalDistributionChart` para `/by-category?month={currentMonth}` e ajustar o teste da distribuicao.
- [x] 8.2 BudgetPage: adicionar link/botao "Por categoria" com o mes selecionado (`/by-category?month={mes}`).
- [x] 8.3 BudgetPage: abrir `CategoryDetailSheet` ao tocar em linha de categoria (mes do BudgetPage).
- [x] 8.4 Testes de integracao: `Tab1.test.tsx` (botao navega para `/by-category?month=...`); `BudgetPage.test.tsx` (linha abre o sheet; link preserva o mes).
- [x] 8.5 Verificar o fluxo de voltar (tela → origem) nos dois caminhos.

## Detalhes de Implementacao

Ver techspec.md, secoes "Pontos de Integracao" e "Modificados (frontend)" (`Tab1.tsx`, `BudgetPage.tsx`).

## Criterios de Sucesso

- Funil do PRD fechado: Tab1 (ou Orcamento Mensal) → tela "Por categoria" → sheet da categoria em ate 2 toques.
- Mes preservado ao vir da BudgetPage; mes corrente ao vir da Tab1.
- Voltar retorna a tela de origem em ambos os fluxos.
- Testes de integracao verdes, incluindo o ajuste do teste da distribuicao na Tab1.

## Testes da Tarefa

- [x] Testes de unidade (ajustes pontuais)
- [x] Testes de integracao (`Tab1.test.tsx`, `BudgetPage.test.tsx`)
- [x] Testes E2E (nao aplicavel nesta tarefa — smoke na Tarefa 9.0)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx` (+ teste)
- `controlai-frontend/src/pages/BudgetPage.tsx` (+ teste)
- `controlai-frontend/src/components/CategoryDetailSheet.tsx` (reuso, Tarefa 6.0)
