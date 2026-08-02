# Tarefa 9.0: Verificacao final — checks, smoke E2E e verificacao manual

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fechar a feature com a suite completa verde nos dois projetos, smoke E2E opcional em Cypress e verificacao manual obrigatoria via `ionic serve` (CLAUDE.md do frontend), incluindo o gesto do sheet no simulador iOS (risco conhecido da techspec: `IonModal` sheet em WebKit).

<skills>
### Conformidade com Skills Padroes

- `clean-code` — revisao final de nomes, duplicacoes e responsabilidade unica antes de concluir.
- `ionic-design` — validacao visual no dark theme e tap targets nas superficies novas.
</skills>

<requirements>
- Todos os checks verdes: `typecheck`, `test`, `build`, `lint` no `controlai-frontend`; testes e build no `controlai` (backend).
- Consistencia de numeros entre widget Tab1, Orcamento Mensal e tela "Por categoria" para o mesmo periodo (restricao do PRD), com a diferenca documentada do total (compras sem categoria fora do resumo da tela).
- Verificacao manual obrigatoria via `ionic serve`; gesto de arrastar e scroll interno do sheet (`expandToScroll`) no simulador iOS.
- O projeto usa Cypress (nao Playwright) para E2E.
</requirements>

## Subtarefas

- [x] 9.1 Rodar e corrigir: `typecheck`, `test`, `build`, `lint` no frontend; suite de testes e build no backend.
- [x] 9.2 Smoke E2E Cypress (opcional): Tab1 → tela "Por categoria" → tocar linha estourada → sheet com "Estourou em R$" → filtrar por cartao.
- [x] 9.3 Verificacao manual via `ionic serve`: jornada principal do PRD (percepcao → diagnostico → compra especifica em 2 toques), navegacao de meses, estados vazios, consistencia de numeros entre as tres superficies.
- [ ] 9.4 Verificar gesto do sheet (arrastar para fechar, expandir, scroll interno) no simulador iOS. **Pendente de verificacao pelo usuario** — gesto de toque no simulador nao e automatizavel neste ambiente; dismiss por botao e por breakpoint 0 validados via Cypress/testes de unidade.
- [x] 9.5 Validar acessibilidade: `aria-label` das linhas, anuncio do titulo do sheet, estouro nao comunicado apenas por cor.

## Detalhes de Implementacao

Ver techspec.md, secoes "Testes de E2E", "Riscos Conhecidos" e "Monitoramento e Observabilidade".

## Criterios de Sucesso

- Todos os checks verdes nos dois projetos.
- Jornada principal do PRD validada manualmente sem atraso perceptivel (restricao de performance).
- Numeros identicos entre widget, Orcamento Mensal e tela para o mesmo mes.
- Sem regressoes nos fluxos existentes (Tab1, BudgetPage, MonthSelector, listagem de notificacoes).

## Testes da Tarefa

- [x] Testes de unidade (suite completa em regressao — 410 frontend, 363 backend)
- [x] Testes de integracao (suite completa em regressao)
- [x] Testes E2E (smoke Cypress `by-category-smoke.cy.ts` 3/3 verde + verificacao via browser real contra API; gesto iOS pendente do usuario)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/` (suite completa, Cypress, `ionic serve`)
- `controlai/` (suite de testes e build do backend)
- `tasks/prd-grafico-petalas-categoria/prd.md` e `techspec.md` (criterios de aceitacao)
