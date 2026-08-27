# Resumo de Tarefas de Implementacao de Extracao Server-Side de Dados de NFC-e (RJ)

## Tarefas

- [x] 1.0 Nucleo de extracao (Node): logica pura de deteccao/parsing
- [x] 2.0 Orquestracao Playwright: maquina de estados READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR
- [x] 3.0 API HTTP do microservico (POST /extract, GET /health)
- [ ] 4.0 Dockerizacao e logging estruturado do microservico
- [ ] 5.0 Gateway/Provider Kotlin: integracao HTTP com o microservico
- [ ] 6.0 Use Case Kotlin: ExtractPurchaseInvoiceUseCase
- [ ] 7.0 Endpoint Kotlin POST /purchases/invoice/extraction
- [ ] 8.0 Validacao manual end-to-end (smoke test) e rollout
