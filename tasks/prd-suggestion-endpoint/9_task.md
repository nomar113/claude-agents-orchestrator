# Tarefa 9.0: Testes Unitarios Frontend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar testes unitarios para a `SuggestionsPage` cobrindo os principais estados e interacoes: loading, lista com resultados, estado vazio e navegacao.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar `SuggestionsPage.test.tsx` seguindo padrao de testes do projeto
- Mockar `getInvoiceSuggestions` do service
- Mockar `useHistory` e `useParams` do React Router
- Cobrir cenarios: loading state, lista com resultados, estado vazio, navegacao ao clicar em card, navegacao ao clicar em "Associar manualmente"
</requirements>

## Subtarefas

- [ ] 9.1 Criar arquivo `SuggestionsPage.test.tsx` com setup (mocks de service, router)
- [ ] 9.2 Teste: exibe skeleton loading enquanto carrega
- [ ] 9.3 Teste: exibe lista de sugestoes quando API retorna resultados
- [ ] 9.4 Teste: primeiro card tem badge "Melhor match" e destaque visual
- [ ] 9.5 Teste: exibe estado vazio quando API retorna lista vazia
- [ ] 9.6 Teste: ao clicar em card de sugestao, navega com `location.state` correto (invoice + notification)
- [ ] 9.7 Teste: ao clicar em "Associar manualmente", navega com `location.state` correto (apenas invoice)
- [ ] 9.8 Teste: fallback de busca via API quando `location.state` nao tem dados do invoice
- [ ] 9.9 Rodar todos os testes e verificar que passam

## Detalhes de Implementacao

Consultar a secao "Testes Unitarios > Frontend" da `techspec.md`. Seguir o padrao de testes ja existentes no projeto `controlai-frontend`.

## Criterios de Sucesso

- Todos os testes passando
- Cobertura dos 3 estados da pagina (loading, com dados, vazio)
- Cobertura das navegacoes (card tap, associar manualmente)
- Build e testes completos passam

## Testes da Tarefa

- [ ] Todos os testes unitarios listados acima passando
- [ ] Typecheck passa (`npx tsc --noEmit`)
- [ ] Build passa sem erros
- [ ] Nenhum teste existente quebrado

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/SuggestionsPage.test.tsx` — novo arquivo (controlai-frontend)
- `src/pages/SuggestionsPage.tsx` — pagina a ser testada (tarefa 7.0)
- `src/services/purchaseService.ts` — service a ser mockado
- Testes existentes no projeto como referencia de padrao
