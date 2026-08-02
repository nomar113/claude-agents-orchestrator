# Tarefa 3.0: Frontend — Service `updatePaymentNotificationCard` em `purchaseService.ts`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar a funcao no service do frontend que chama o endpoint criado nas Tarefas 1.0/2.0. Esta funcao e a fronteira HTTP da feature no frontend e deve seguir o helper `httpRequest` ja existente (estrategia dual `CapacitorHttp` nativo / `fetch` web).

<skills>
### Conformidade com Skills Padroes

- **clean-code** — uma funcao com responsabilidade unica, sem duplicar a logica de transport.
- **vercel-react-best-practices** — manter o servico desacoplado da UI; sem `useState`/`useEffect` aqui.
</skills>

<requirements>
- Criar `updatePaymentNotificationCard(id: number, paymentMethodId: number, subCardId: number | null): Promise<PaymentNotificationDetail>` em `src/services/purchaseService.ts`.
- Usar o helper `httpRequest` existente; metodo `PATCH`; path `/payments/notifications/${id}/payment-method`; body `{ paymentMethodId, subCardId }`.
- Sub-cartao opcional deve ser enviado como `null` (e nao omitido) quando o usuario optar por "Continuar sem sub-cartao" ou quando o cartao nao tiver sub-cards.
- Retornar a notificacao atualizada tipada (`PaymentNotificationDetail` ou tipo equivalente ja usado no projeto).
- Nao introduzir novos helpers HTTP; reusar o existente.
</requirements>

## Subtarefas

- [x] 3.1 Implementar `updatePaymentNotificationCard` em `src/services/purchaseService.ts`.
- [x] 3.2 Garantir tipagem do retorno alinhada ao response atual de `PaymentNotificationResponse`.
- [x] 3.3 Escrever testes em `src/services/purchaseService.test.ts`.

## Detalhes de Implementacao

Ver `techspec.md` secao "Interfaces Principais" (assinatura TypeScript) e "Pontos de Integracao" (estrategia HTTP). Nao redefinir o helper `httpRequest`.

## Criterios de Sucesso

- Funcao chamada com `subCardId = null` envia `"subCardId": null` no body (nao omite chave).
- Funcao chamada com `subCardId = 7` envia `7` no body.
- Path correto inclui o `id` no segmento de URL.
- Retorno tipado e utilizavel pelo `PurchaseDetail` na Tarefa 5.0.

## Testes da Tarefa

- [x] Testes de unidade — `purchaseService.test.ts`:
  - chamada com `subCardId = null` -> mock do `httpRequest` recebe `PATCH`, path correto e body `{ paymentMethodId, subCardId: null }`
  - chamada com `subCardId = number` -> body envia o valor numerico
  - falha do `httpRequest` (rede/4xx/5xx) propaga o erro sem swallow

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/purchaseService.ts` (modificar)
- `src/services/purchaseService.test.ts` (modificar)
- `src/services/httpService.ts` (referencia, sem mudanca)
