# Tarefa 1.0: Backend — Endpoint PATCH de categoria

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o endpoint `PATCH /payments/notifications/{id}/category` que permite atualizar o `categoryId` de um payment_notification existente. Seguir o padrao ja estabelecido pelo endpoint de descricao (`PATCH /notifications/{id}/description`).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Criar Request DTO `UpdateCategoryRequest` com campo `categoryId: Long?`
- Criar endpoint PATCH no `PaymentNotificationController`
- Validar que `categoryId` corresponde a uma categoria existente (quando nao-null) usando `CategoryRepository.findById()`
- Retornar 400 se categoria nao existir
- Retornar 404 se notification nao existir ou estiver soft-deleted
- Ao salvar, sincronizar o campo legado `category` (string) com `categoryModel.name`
- Quando `categoryId` for null, limpar ambos os campos (`categoryId` e `category`)
- Retornar `PaymentNotificationResponse` completo
</requirements>

## Subtarefas

- [ ] 1.1 Criar `UpdateCategoryRequest.kt` no pacote `entrypoint/rest/request/`
- [ ] 1.2 Adicionar metodo `updateCategory` no `PaymentNotificationController`
- [ ] 1.3 Injetar `CategoryRepository` no controller para validacao
- [ ] 1.4 Implementar logica de sync do campo legado `category` (string)
- [ ] 1.5 Escrever testes unitarios do endpoint
- [ ] 1.6 Escrever testes de integracao (fluxo completo: criar → categorizar → verificar)

## Detalhes de Implementacao

Consultar a secao **"Design de Implementacao > Interfaces Principais"** e **"Endpoints de API"** da `techspec.md` para assinaturas exatas do endpoint, request/response e validacoes.

**Padrao de referencia:** O endpoint existente `updateDescription` em `PaymentNotificationController.kt` (linhas 53-62) serve como modelo exato para a implementacao.

## Criterios de Sucesso

- `PATCH /payments/notifications/{id}/category` com `categoryId` valido retorna 200 com notification atualizada
- `PATCH` com `categoryId: null` retorna 200 com campos de categoria nulos
- `PATCH` com `categoryId` inexistente retorna 400
- `PATCH` com `id` inexistente retorna 404
- Campo `category` (string) reflete o nome da categoria apos update
- Todos os testes passam

## Testes da Tarefa

- [ ] Testes de unidade: cenarios de sucesso, categoria invalida, notification inexistente, remocao de categoria
- [ ] Testes de integracao: fluxo criar notification → PATCH categoria → GET verificar campos atualizados
- [ ] Teste de integracao: verificar que budget summary reflete gasto apos categorizacao

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Criar:**
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/request/UpdateCategoryRequest.kt`

**Modificar:**
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt`

**Referencia (padrao):**
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/request/UpdateDescriptionRequest.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/categories/entrypoint/database/repository/CategoryRepository.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/categories/entrypoint/database/model/CategoryModel.kt`
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt`
