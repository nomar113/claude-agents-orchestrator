# Tarefa 4.0: Backend — REST Controllers + DTOs (Holders e PaymentMethods)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar os controllers REST e DTOs (request/response) para os endpoints de CRUD de titulares, cartoes/meios de pagamento e sub-cartoes. Expor toda a funcionalidade via API REST seguindo os padroes existentes do projeto.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar `HolderController` com endpoints: GET /holders, POST /holders
- Criar `PaymentMethodController` com endpoints: GET /payment-methods (?holderId=), GET /payment-methods/{id}, POST /payment-methods, PUT /payment-methods/{id}, DELETE /payment-methods/{id}
- Criar endpoints de sub-cartoes: POST /payment-methods/{id}/sub-cards, PUT /payment-methods/{id}/sub-cards/{subCardId}, DELETE /payment-methods/{id}/sub-cards/{subCardId}
- Criar request DTOs com @Validated para validacao de entrada
- Criar response DTOs com companion `from()` factory method (padrao existente)
- DELETE deve retornar 204 No Content
- POST deve retornar 201 Created
- Tratar erros: 404 quando entidade nao encontrada, 400 para validacao
</requirements>

## Subtarefas

- [ ] 4.1 Criar request DTOs: `CreateHolderRequest`, `CreatePaymentMethodRequest`, `UpdatePaymentMethodRequest`, `CreateSubCardRequest`, `UpdateSubCardRequest`
- [ ] 4.2 Criar response DTOs: `HolderResponse`, `PaymentMethodResponse`, `SubCardResponse`
- [ ] 4.3 Criar `HolderController` (GET, POST)
- [ ] 4.4 Criar `PaymentMethodController` (CRUD completo + sub-cards)
- [ ] 4.5 Testes com MockMvc

## Detalhes de Implementacao

Consultar secao **Endpoints de API** da `techspec.md` para lista completa de endpoints e formatos de request/response.

Seguir padrao existente em `PurchaseInvoiceController` e `PaymentNotificationController`.

## Criterios de Sucesso

- Todos os endpoints respondem com status codes corretos (200, 201, 204, 400, 404)
- Validacoes de entrada funcionam (@Validated): campos obrigatorios, formatos
- Response DTOs serializam corretamente para JSON (incluindo sub-cartoes aninhados)
- GET /payment-methods retorna cartoes com sub-cartoes inline
- DELETE faz soft delete (nao remove fisicamente)
- Filtro por holderId funciona no GET /payment-methods

## Testes da Tarefa

- [ ] Teste MockMvc: POST /holders cria titular e retorna 201
- [ ] Teste MockMvc: GET /holders lista titulares
- [ ] Teste MockMvc: POST /payment-methods cria cartao e retorna 201 com sub-cartoes
- [ ] Teste MockMvc: GET /payment-methods lista cartoes com sub-cartoes
- [ ] Teste MockMvc: GET /payment-methods?holderId=1 filtra por titular
- [ ] Teste MockMvc: PUT /payment-methods/{id} atualiza cartao
- [ ] Teste MockMvc: DELETE /payment-methods/{id} retorna 204
- [ ] Teste MockMvc: POST /payment-methods/{id}/sub-cards cria sub-cartao
- [ ] Teste MockMvc: validacao falha com 400 para campos obrigatorios ausentes

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/rest/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/rest/request/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/rest/response/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/` (referencia de padrao)
