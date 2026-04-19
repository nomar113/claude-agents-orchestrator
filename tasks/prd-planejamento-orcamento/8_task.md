# Tarefa 8.0: Frontend — BudgetPage: tela completa de planejamento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a pagina principal de planejamento orcamentario (`/budget`), seguindo o design criado no Paper (artboard "Orcamento Mensal"). A tela exibe o resumo do mes, gastos por categoria, investimentos, receitas e totais por meio de pagamento em secoes colapsaveis, com edicao inline dos valores de expectativa.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Header com botao voltar e titulo "Orcamento Mensal"
- Seletor de mes com navegacao anterior/proximo
- Card resumo: Planejado vs Real, barra de progresso, percentual, receitas/saldo/investido
- Secao "Gastos por Categoria": rows com emoji, nome, diferenca colorida (verde/vermelho/amarelo), mini progress bar
- Secao "Investimentos": rows com mesmo padrao de categorias, barra roxa
- Secao "Receitas": lista com label e valor
- Secao "Meios de Pagamento": lista com badges coloridos por cartao
- Todas as secoes colapsaveis (IonAccordion ou estado local)
- Edicao inline: tap no valor de expectativa abre input, salva ao perder foco
- Botoes: "Duplicar Mes" e "Editar"
- Loading states e empty states
- Cores: verde (dentro do orcamento), amarelo (>80%), vermelho (acima), roxo (investimentos)
- Formato monetario: R$ com Intl.NumberFormat pt-BR
</requirements>

## Subtarefas

- [ ] 8.1 Criar `BudgetPage.tsx` com estrutura base e seletor de mes
- [ ] 8.2 Implementar card resumo com barra de progresso
- [ ] 8.3 Implementar secao de gastos por categoria com rows e progress bars
- [ ] 8.4 Implementar secao de investimentos
- [ ] 8.5 Implementar secao de receitas
- [ ] 8.6 Implementar secao de meios de pagamento
- [ ] 8.7 Implementar edicao inline de valores de expectativa
- [ ] 8.8 Implementar botoes Duplicar Mes e Editar
- [ ] 8.9 Criar `BudgetPage.css` com estilos dark theme
- [ ] 8.10 Testes do componente

## Detalhes de Implementacao

Consultar o design no Paper (artboard "Orcamento Mensal") para visual. Consultar a `techspec.md` para os endpoints e tipos. Seguir o padrao de componentes existentes (Tab1.tsx, PaymentMethodsPage.tsx) para estado, loading e error handling.

## Criterios de Sucesso

- Tela renderiza com dados reais da API
- Navegacao entre meses funciona
- Secoes colapsam/expandem
- Edicao inline salva valor de expectativa
- Cores indicam status correto (verde/amarelo/vermelho)
- Layout responsivo e consistente com o design system do app

## Testes da Tarefa

- [ ] Teste: pagina renderiza com dados mockados
- [ ] Teste: navegacao entre meses atualiza dados
- [ ] Teste: secoes colapsam/expandem ao clicar no header
- [ ] Teste: edicao inline salva novo valor

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/BudgetPage.tsx` (novo)
- `src/pages/BudgetPage.css` (novo)
- `src/pages/BudgetPage.test.tsx` (novo)
- `src/services/budgetService.ts` (criado na task 7)
- `src/types/budget.ts` (criado na task 7)
- `src/pages/Tab1.tsx` (referencia de padrao)
- `src/pages/PaymentMethodsPage.tsx` (referencia de padrao)
- Design no Paper: artboard "Orcamento Mensal"
