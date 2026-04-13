# Tarefa 9.0: Frontend — Componente seletor de cartao para despesas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `PaymentMethodSelector` que permite selecionar um cartao/meio de pagamento (e opcionalmente um sub-cartao) ao registrar uma despesa. O componente sera integrado ao fluxo de registro de despesas existente. Cartoes aparecem agrupados por titular com icones identificando o tipo de sub-cartao.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar componente `PaymentMethodSelector.tsx` reutilizavel
- Listar cartoes ativos agrupados por titular
- Ao selecionar cartao principal, mostrar opcao de selecionar sub-cartao (opcional)
- Seletor de sub-cartao exibe: ultimos 4 digitos, tipo (com icone), apelido
- Icones por tipo: fisico (card), virtual (cloud), carteira digital (phone/wallet)
- Callback `onSelect(paymentMethodId, subCardId?)` para o componente pai
- Pre-selecionar ultimo cartao utilizado (opcional, via localStorage)
- Usar componentes Ionic (IonActionSheet ou IonModal com IonList)
- Seguir dark theme existente
- Integrar no fluxo de despesas: adicionar o seletor no contexto onde despesas sao registradas
</requirements>

## Subtarefas

- [ ] 9.1 Criar `PaymentMethodSelector.tsx` com listagem agrupada por titular
- [ ] 9.2 Implementar selecao de sub-cartao apos selecionar cartao principal
- [ ] 9.3 Adicionar icones por tipo de sub-cartao
- [ ] 9.4 Criar `PaymentMethodSelector.css`
- [ ] 9.5 Integrar seletor no fluxo de registro de despesas (InvoiceProcessingContext ou ScannerPage)
- [ ] 9.6 Implementar pre-selecao do ultimo cartao usado (localStorage)
- [ ] 9.7 Testes E2E

## Detalhes de Implementacao

Consultar secao **Experiencia do Usuario — Fluxo principal — Registro de despesa** e **Funcionalidades Principais — 3. Vinculacao de Despesas a Cartoes** do `prd.md`.

O componente deve ser desacoplado: recebe lista de cartoes como prop ou busca via service, e retorna IDs selecionados via callback.

## Criterios de Sucesso

- Seletor exibe todos os cartoes ativos agrupados por titular
- Sub-cartoes sao exibiveis apos selecionar cartao principal
- Icones corretos para cada tipo de sub-cartao
- Callback retorna IDs corretos (paymentMethodId obrigatorio, subCardId opcional)
- Ultimo cartao utilizado e pre-selecionado na proxima vez
- Interface rapida e fluida (poucos toques para selecionar)

## Testes da Tarefa

- [ ] Teste E2E Playwright: abrir seletor e ver cartoes agrupados por titular
- [ ] Teste E2E Playwright: selecionar cartao principal e ver sub-cartoes
- [ ] Teste E2E Playwright: selecionar sub-cartao e validar callback
- [ ] Teste E2E Playwright: re-abrir seletor e ver ultimo cartao pre-selecionado

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/components/PaymentMethodSelector.tsx` (novo)
- `controlai-frontend/src/components/PaymentMethodSelector.css` (novo)
- `controlai-frontend/src/context/InvoiceProcessingContext.tsx` (modificado — integrar seletor)
- `controlai-frontend/src/pages/ScannerPage.tsx` (possivelmente modificado)
- `controlai-frontend/src/services/paymentMethodService.ts` (dependencia da task 6.0)
- `controlai-frontend/src/types/paymentMethod.ts` (dependencia da task 6.0)
