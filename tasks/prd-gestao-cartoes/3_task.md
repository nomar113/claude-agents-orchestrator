# Tarefa 3.0: Backend — Application layer: JPA models, repositories, providers, converters

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de aplicacao (adapters) do bounded context `payment_methods`: models JPA com `@SQLRestriction` para soft delete, repositories Spring Data JPA, providers implementando os gateways da domain layer, e converters para mapeamento entity ↔ model.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar JPA models: `HolderModel`, `PaymentMethodModel`, `SubCardModel`
- `PaymentMethodModel` e `SubCardModel` devem ter `@SQLRestriction("deleted_at IS NULL")` para soft delete
- Usar `@GeneratedValue(GenerationType.IDENTITY)`, `@CreationTimestamp`, `@UpdateTimestamp` conforme padrao existente
- Criar repositories Spring Data JPA para cada model
- PaymentMethodRepository: queries para listar por holderId, buscar ativos
- SubCardRepository: queries para listar por paymentMethodId
- Criar providers (@Component, @Transactional) implementando cada gateway
- Soft delete = setar `deleted_at = now()` (nao deletar fisicamente)
- Criar converters bidirecionais (entity ↔ model) seguindo padrao do PurchaseInvoiceConverter
</requirements>

## Subtarefas

- [ ] 3.1 Criar `HolderModel` com @Entity e repository
- [ ] 3.2 Criar `PaymentMethodModel` com @Entity, @SQLRestriction e repository
- [ ] 3.3 Criar `SubCardModel` com @Entity, @SQLRestriction e repository
- [ ] 3.4 Criar `PaymentMethodConverter` (entity ↔ model bidirecional)
- [ ] 3.5 Criar providers para Holder (SaveHolderProvider, ListHoldersProvider)
- [ ] 3.6 Criar providers para PaymentMethod (Save, List, Find, Update, Deactivate)
- [ ] 3.7 Criar providers para SubCard (Save, Update, Deactivate)
- [ ] 3.8 Testes de integracao

## Detalhes de Implementacao

Consultar secoes **Modelos de Dados** e **Decisoes Principais** (soft delete) da `techspec.md`.

Seguir o padrao existente em `application/purchases_invoices/` para estrutura de pacotes, converters e providers.

## Criterios de Sucesso

- Todos os models, repositories, providers e converters compilam e funcionam
- Soft delete funciona: registros com deleted_at preenchido nao aparecem em queries normais
- @Transactional garante atomicidade nas operacoes de escrita
- Converters mapeiam corretamente todos os campos em ambas direcoes
- Testes de integracao passam com H2

## Testes da Tarefa

- [ ] Teste de integracao: CRUD completo de Holder via provider
- [ ] Teste de integracao: CRUD completo de PaymentMethod via provider
- [ ] Teste de integracao: criar PaymentMethod, soft delete, validar que nao aparece em listagem
- [ ] Teste de integracao: CRUD de SubCard vinculado a PaymentMethod
- [ ] Teste de integracao: soft delete de SubCard nao afeta PaymentMethod pai
- [ ] Teste unitario: converter mapeia todos os campos corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/database/model/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/entrypoint/database/repository/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/application/` (novo — providers)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/payment_methods/converter/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/` (referencia de padrao)
