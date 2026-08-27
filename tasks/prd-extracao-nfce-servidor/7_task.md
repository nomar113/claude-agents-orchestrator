# Tarefa 7.0: Endpoint Kotlin POST /purchases/invoice/extraction

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar ao `PurchaseInvoiceController` existente o novo metodo `POST /invoice/extraction`, sincrono, reaproveitando a mesma autenticacao JWT do endpoint `/purchases/invoice`. O endpoint recebe a URL escaneada, delega ao `ExtractPurchaseInvoiceUseCase` (Tarefa 6.0) e mapeia cada tipo de falha para o status HTTP correspondente, permitindo que o app diferencie bloqueio de timeout genérico (FR11 do PRD).

<skills>
### Conformidade com Skills Padroes

Aplicar a skill `kotlin-springboot` na implementacao do endpoint REST, seguindo o padrao existente de `ResponseStatusException` por tipo de excecao (ver `mapAssociationError`) e a arquitetura hexagonal do `CLAUDE.md` do backend.
</skills>

<requirements>
- Adicionar `POST /invoice/extraction` ao `PurchaseInvoiceController`, aceitando `ExtractPurchaseInvoiceRequest { invoiceUrl: String }` e retornando `ExtractedPurchaseInvoiceResponse` em caso de sucesso.
- Reaproveitar a autenticacao JWT ja aplicada ao endpoint `/purchases/invoice` (mesmo padrao de seguranca do controller).
- Mapear erros do use case para status HTTP conforme a tabela da Tech Spec (secao "Endpoints de API"):
  - `accessKey` ja registrada -> `409` "Nota ja registrada"
  - SEFAZ bloqueou/recusou (`BLOCKED`) -> `422` com a mensagem repassada de `getBlockMessageRJ`
  - Tempo esgotado (`TIMEOUT`) -> `504` "Tempo esgotado ao consultar a SEFAZ"
  - Falha de navegacao/servico indisponivel (`NAVIGATION_ERROR`) -> `502` "Nao foi possivel consultar a SEFAZ"
- Seguir o padrao existente de mapeamento de excecao para `ResponseStatusException` (ver `mapAssociationError` como referencia).
- `ExtractedPurchaseInvoiceResponse` deve conter os mesmos campos hoje extraidos client-side, no formato pronto para o app montar o `PurchaseInvoiceRequest` do endpoint `/purchases/invoice` sem transformacao adicional.
</requirements>

## Subtarefas

- [ ] 7.1 Criar `ExtractPurchaseInvoiceRequest` e `ExtractedPurchaseInvoiceResponse` em `application/purchases_invoices/entrypoint/rest/request/` e `.../response/`.
- [ ] 7.2 Adicionar o metodo `POST /invoice/extraction` ao `PurchaseInvoiceController`, injetando `ExtractPurchaseInvoiceUseCase`.
- [ ] 7.3 Implementar a funcao de mapeamento de erro (`mapExtractionError` ou similar) seguindo o padrao de `mapAssociationError`, cobrindo os 4 casos da tabela de status HTTP.
- [ ] 7.4 Escrever teste unitario do controller isolado (padrao `PurchaseInvoiceControllerTest.kt`), cobrindo sucesso e os 4 mapeamentos de erro.
- [ ] 7.5 Escrever teste de integracao com `MockMvc` + `NfceExtractionGateway` fake (nao mock de rede), validando a costura controller -> use case -> status HTTP (padrao `AssociateInvoiceControllerIntegrationTest.kt`).

## Detalhes de Implementacao

Ver Tech Spec, secoes "Modelos de Dados" (`ExtractPurchaseInvoiceRequest`, `ExtractedPurchaseInvoiceResponse`), "Endpoints de API" (tabela de mapeamento de erro) e "Abordagem de Testes" > "Testes de Integracao" (Kotlin). Referencias de padrao: `PurchaseInvoiceControllerTest.kt`, `AssociateInvoiceControllerIntegrationTest.kt`, `mapAssociationError`.

## Criterios de Sucesso

- Requisicao valida para uma nota nova retorna `200` com todos os campos de `ExtractedPurchaseInvoiceResponse` preenchidos.
- Requisicao para `accessKey` ja registrada retorna `409` com a mensagem "Nota ja registrada".
- Cada um dos estados de falha do gateway (`BLOCKED`, `TIMEOUT`, `NAVIGATION_ERROR`) retorna o status HTTP e mensagem correspondentes da tabela da Tech Spec.
- O endpoint exige o mesmo JWT ja exigido por `/purchases/invoice` (requisicao sem token autenticado retorna `401`).

## Testes da Tarefa

- [ ] Testes de unidade do controller isolado do Spring context, cobrindo sucesso e os 4 mapeamentos de erro.
- [ ] Testes de integracao com `MockMvc` + gateway fake, validando a costura completa e os status HTTP.
- [ ] Testes E2E: nao aplicavel nesta tarefa (fica para a Tarefa 8.0, smoke test manual).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt` (modificado)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/request/ExtractPurchaseInvoiceRequest.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/response/ExtractedPurchaseInvoiceResponse.kt` (novo)
- `src/test/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/rest/PurchaseInvoiceControllerTest.kt` (estendido)
- `src/test/kotlin/br/com/nomar/controlai/application/purchases_invoices/AssociateInvoiceControllerIntegrationTest.kt` (referencia de padrao para novo teste de integracao)
