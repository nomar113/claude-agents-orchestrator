# Tarefa 3.0: `MonthSelector` com prop `maxMonth` (bloqueio de meses futuros)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar a prop opcional `maxMonth?: string` ao componente existente `src/components/MonthSelector.tsx`: quando presente, o botao "proximo" e desabilitado ao atingir o limite, impedindo navegacao para meses futuros (PRD 5.1). Sem `maxMonth`, o comportamento atual permanece intacto. Pre-requisito da `ByCategoryPage` (Tarefa 5.0).

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — botao desabilitado com estado visual claro e tap target ≥ 44pt.
- `vercel-react-best-practices` — derivacao do estado desabilitado sem estado redundante.
- `clean-code` — prop opcional com comparacao de mes nomeada e legivel.
</skills>

<requirements>
- PRD 5.1: navegacao para meses anteriores livre; retorno ate, no maximo, o mes corrente; sem meses futuros.
- Prop opcional: componentes existentes que usam `MonthSelector` sem `maxMonth` nao mudam de comportamento.
- Formato de mes `"YYYY-MM"`, consistente com o restante do app.
</requirements>

## Subtarefas

- [x] 3.1 Adicionar prop `maxMonth?: string` e desabilitar o botao "proximo" quando `month >= maxMonth`.
- [x] 3.2 Testes de unidade: avanco desabilitado quando `month === maxMonth`; habilitado quando abaixo do limite; comportamento sem `maxMonth` inalterado (casos existentes continuam verdes).

## Detalhes de Implementacao

Ver techspec.md, secao "Modificados (frontend)" — `src/components/MonthSelector.tsx`.

## Criterios de Sucesso

- Com `maxMonth` igual ao mes corrente, o usuario nao consegue avancar alem dele.
- Retrocesso a meses anteriores continua livre.
- Testes existentes do `MonthSelector` continuam passando.

## Testes da Tarefa

- [x] Testes de unidade (novo caso `maxMonth` + regressao dos existentes)
- [ ] Testes de integracao (coberto na Tarefa 5.0 via `ByCategoryPage`)
- [ ] Testes E2E (nao aplicavel nesta tarefa)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/components/MonthSelector.tsx` (+ teste)
