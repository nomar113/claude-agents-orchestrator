# Tarefa 7.0: Frontend — Tela de gestao de cartoes (CRUD)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a tela de gestao de cartoes e meios de pagamento, acessivel via configuracoes (Tab3). Permitir listar, criar, editar e desativar cartoes e sub-cartoes. Interface simples e direta conforme descrito no PRD.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar `PaymentMethodsPage.tsx` com listagem de cartoes agrupados por titular
- Formulario de criacao/edicao de cartao: nome, tipo (CREDIT_CARD, PIX, CASH), titular (seletor), bandeira (opcional), dia de fechamento (so cartao de credito)
- Secao de sub-cartoes dentro do formulario do cartao principal: ultimos 4 digitos, tipo, apelido, nome do dependente (se PHYSICAL_DEPENDENT), plataforma (se DIGITAL_WALLET)
- Botao de desativar cartao com confirmacao (soft delete)
- Botao de desativar sub-cartao individualmente
- Indicar visualmente o titular de cada cartao
- Usar componentes Ionic (IonList, IonItem, IonInput, IonSelect, IonButton, IonAlert)
- Adicionar rota em App.tsx e link de acesso em Tab3
- Seguir estilo visual existente (dark theme, IBM Plex Sans, cores do variables.css)
</requirements>

## Subtarefas

- [ ] 7.1 Criar `PaymentMethodsPage.tsx` com listagem de cartoes
- [ ] 7.2 Criar formulario de criacao de cartao com campos condicionais
- [ ] 7.3 Criar formulario de edicao de cartao
- [ ] 7.4 Implementar gestao de sub-cartoes (adicionar, editar, desativar) dentro do formulario do cartao
- [ ] 7.5 Implementar desativacao de cartao com confirmacao
- [ ] 7.6 Criar `PaymentMethodsPage.css` com estilo consistente
- [ ] 7.7 Adicionar rota `/payment-methods` em `App.tsx`
- [ ] 7.8 Adicionar link de navegacao em `Tab3.tsx`
- [ ] 7.9 Testes E2E

## Detalhes de Implementacao

Consultar secao **Experiencia do Usuario — Fluxo de gestao de cartoes** e **Fluxo de gestao de sub-cartoes** do `prd.md`.

Usar funcoes do `paymentMethodService.ts` (task 6.0) para todas as chamadas de API.

## Criterios de Sucesso

- Usuario consegue criar um cartao de credito com sub-cartoes
- Usuario consegue criar um meio de pagamento (Pix, Dinheiro) sem sub-cartoes
- Usuario consegue editar dados de um cartao existente
- Usuario consegue desativar cartao e sub-cartao (com confirmacao)
- Listagem mostra cartoes agrupados por titular
- Campos condicionais aparecem/desaparecem conforme tipo selecionado
- Interface segue o dark theme existente

## Testes da Tarefa

- [ ] Teste E2E Playwright: acessar tela de gestao via Tab3
- [ ] Teste E2E Playwright: criar cartao de credito com sub-cartao fisico
- [ ] Teste E2E Playwright: criar meio de pagamento Pix
- [ ] Teste E2E Playwright: editar nome de um cartao
- [ ] Teste E2E Playwright: desativar cartao e verificar que nao aparece mais na lista
- [ ] Teste E2E Playwright: adicionar sub-cartao de carteira digital com plataforma Apple Pay

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/PaymentMethodsPage.tsx` (novo)
- `controlai-frontend/src/pages/PaymentMethodsPage.css` (novo)
- `controlai-frontend/src/App.tsx` (modificado — nova rota)
- `controlai-frontend/src/pages/Tab3.tsx` (modificado — link de navegacao)
- `controlai-frontend/src/services/paymentMethodService.ts` (dependencia da task 6.0)
- `controlai-frontend/src/types/paymentMethod.ts` (dependencia da task 6.0)
