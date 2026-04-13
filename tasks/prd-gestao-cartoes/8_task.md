# Tarefa 8.0: Frontend — Dashboard com dados reais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Substituir os dados mockados de cartoes no dashboard (Tab1) por dados reais vindos do endpoint `/payment-methods/summary`. Manter o layout card-stack existente, alimentando-o com cartoes reais do usuario e seus totais mensais.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Remover constantes `STATIC_CARDS` e `FRONT_CARD` de Tab1.tsx
- Chamar `getPaymentMethodsSummary(currentMonth)` via paymentMethodService
- Exibir cartoes reais no card-stack: nome, ultimos 4 digitos do sub-cartao principal, titular, total do mes
- Cartao com maior gasto fica na posicao frontal (FRONT_CARD position)
- Demais cartoes ficam como back cards no stack
- Exibir loading skeleton enquanto carrega dados da API
- Exibir estado vazio se nao houver cartoes cadastrados (com CTA para tela de gestao)
- Manter estetica visual existente do card-stack (gradientes, tipografia, animacoes)
- Tratar erro de API com mensagem e botao de retry
</requirements>

## Subtarefas

- [ ] 8.1 Remover dados mockados (STATIC_CARDS, FRONT_CARD) de Tab1.tsx
- [ ] 8.2 Integrar chamada a `getPaymentMethodsSummary` com mes corrente
- [ ] 8.3 Renderizar card-stack com dados reais (front card = maior gasto)
- [ ] 8.4 Implementar estado vazio (sem cartoes cadastrados)
- [ ] 8.5 Implementar loading e error states para a secao de cartoes
- [ ] 8.6 Testes E2E

## Detalhes de Implementacao

Consultar secao **Experiencia do Usuario — Fluxo principal — Dashboard** do `prd.md`.

Manter a estrutura CSS existente de `.ctrl-card-stack`, `.ctrl-card-back`, `.ctrl-card-front`. Apenas trocar a fonte de dados.

## Criterios de Sucesso

- Zero dados hardcoded de cartoes no Tab1.tsx
- Dashboard exibe cartoes reais com totais corretos do mes
- Cartao com maior gasto esta na posicao frontal
- Loading skeleton aparece enquanto dados carregam
- Estado vazio aparece quando nao ha cartoes (com link para gestao)
- Layout card-stack visual permanece identico ao atual

## Testes da Tarefa

- [ ] Teste E2E Playwright: dashboard carrega e exibe cartoes reais (nao mockados)
- [ ] Teste E2E Playwright: cartao com maior gasto esta na frente
- [ ] Teste E2E Playwright: total exibido confere com soma das despesas do mes
- [ ] Teste E2E Playwright: estado vazio exibido quando nao ha cartoes

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx` (modificado — remover mocks, integrar API)
- `controlai-frontend/src/pages/Tab1.css` (possivelmente ajustes minimos)
- `controlai-frontend/src/services/paymentMethodService.ts` (dependencia da task 6.0)
- `controlai-frontend/src/types/paymentMethod.ts` (dependencia da task 6.0)
