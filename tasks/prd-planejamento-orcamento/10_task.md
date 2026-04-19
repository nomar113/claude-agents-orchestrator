# Tarefa 10.0: Frontend — Roteamento e navegacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar a rota /budget no App.tsx e integrar a navegacao entre Tab1, Tab3 (Config) e BudgetPage. Garantir que todas as transicoes funcionam corretamente no app mobile.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de execucao de tarefas
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Rota /budget no IonRouterOutlet do App.tsx
- Link na Tab3 (Config) para "Orcamento Mensal" (mesmo padrao dos links existentes para Cartoes e Categorias)
- Navegacao Tab1 -> BudgetPage ao clicar no card resumo
- Botao voltar no BudgetPage retorna para Tab1
- Navegacao funcional tanto no browser quanto no Capacitor (iOS/Android)
</requirements>

## Subtarefas

- [ ] 10.1 Adicionar rota /budget no App.tsx
- [ ] 10.2 Adicionar link "Orcamento" na Tab3
- [ ] 10.3 Verificar navegacao Tab1 -> BudgetPage -> Tab1
- [ ] 10.4 Testes E2E de navegacao

## Detalhes de Implementacao

Seguir o padrao das rotas existentes no App.tsx (`/payment-methods`, `/categories`). A Tab3 ja tem links para PaymentMethodsPage e CategoriesPage — adicionar no mesmo padrao.

## Criterios de Sucesso

- /budget renderiza BudgetPage
- Tab3 tem link funcional para Orcamento
- Navegacao ida e volta funciona sem bugs
- Deep link /budget funciona diretamente

## Testes da Tarefa

- [ ] Teste: rota /budget renderiza BudgetPage
- [ ] Teste: link na Tab3 navega para /budget
- [ ] Teste: botao voltar no BudgetPage retorna para pagina anterior
- [ ] Teste E2E: fluxo completo Tab1 -> BudgetPage -> Tab1

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/App.tsx` (modificar)
- `src/pages/Tab3.tsx` (modificar)
- `src/pages/BudgetPage.tsx` (criado na task 8)
- `src/pages/Tab1.tsx` (modificado na task 9)
