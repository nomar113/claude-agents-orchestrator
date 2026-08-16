# Tarefa 9.0: Testes E2E de consistencia entre telas (Cypress)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Tarefa final de validacao ponta a ponta: com todo o backend e frontend ja migrados (Tarefas 1-8), esta tarefa adiciona cenarios Cypress que comprovam, na experiencia real do usuario, que o card "Total Filtrado" bate com a listagem, e que o resumo por categoria e por meio de pagamento sao consistentes entre si no mesmo mes — cobrindo diretamente as Historias de Usuario do PRD.

<skills>
### Conformidade com Skills Padroes

- Segue a convencao de E2E ja usada no projeto (Cypress, nao Playwright), conforme `controlai-frontend/CLAUDE.md` e a tech spec da feature anterior (`prd-compras-parceladas-fechamento-fatura`).
</skills>

<requirements>
- PRD "Historias de Usuario": total da tela Inicio bate com a soma dos itens listados; compra a vista/Pix/dinheiro contabilizada no mes correto; compra parcelada perto do fechamento contabilizada na fatura correta.
- Ver Tech Spec, secao "Testes de E2E".
</requirements>

## Subtarefas

- [ ] 9.1 Cenario: registrar uma compra a vista no Pix; confirmar que o card "Total Filtrado" da tela Inicio bate exatamente com a soma dos itens listados logo abaixo (regressao do bug relatado no PRD).
- [ ] 9.2 Cenario: registrar uma compra parcelada cruzando meses; confirmar consistencia entre a listagem principal, o resumo por categoria (`CategoryDetailSheet`) e o resumo por meio de pagamento no mesmo mes.
- [ ] 9.3 Cenario: registrar uma compra a vista no cartao de credito perto do fechamento da fatura; confirmar que ela aparece no mes da fatura correta (nao necessariamente o mes calendario da compra).
- [ ] 9.4 Cenario: registrar uma compra em dinheiro; confirmar que aparece sempre no mes calendario da compra.
- [ ] 9.5 Rodar a suite Cypress completa (`npm run test.e2e`) e confirmar que nenhum cenario existente quebrou.

## Detalhes de Implementacao

Ver Tech Spec, secao "Testes de E2E": cenarios descritos ali sao o escopo minimo desta tarefa.

## Criterios de Sucesso

- Todos os cenarios da secao "Subtarefas" passam de forma reprodutivel via `npm run test.e2e`.
- Nenhum cenario Cypress pre-existente regride.
- Os cenarios cobrem explicitamente o bug original do PRD (card "Total Filtrado" divergente da listagem).

## Testes da Tarefa

- [ ] Testes E2E: novos specs Cypress cobrindo os 4 cenarios das subtarefas 9.1-9.4.
- [ ] Suite completa: `npm run test.e2e` verde, incluindo os specs pre-existentes.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `e2e/` (Cypress) — novo(s) spec(s) de consistencia entre telas
- `controlai-frontend/CLAUDE.md` (convencao de E2E do projeto)
