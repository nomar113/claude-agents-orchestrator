# Tarefa 3.0: Backend — Application layer de categorias

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de aplicacao do bounded context `categories`: modelo JPA, repository, converter, providers (implementacoes dos gateways) e controller REST com DTOs. Ao final desta task, os endpoints CRUD de categorias estao funcionais.

<skills>
### Conformidade com Skills Padroes

- **`kotlin-springboot`**: JPA entities, Spring Data repositories, `@RestController`, Bean Validation.
- **`clean-code`**: Converter bidirecional, Response com factory method `from()`.
</skills>

<requirements>
- `CategoryModel` JPA com `@SQLRestriction("deleted_at IS NULL")` (soft delete)
- `CategoryRepository` extends JpaRepository com query `findAllByOrderByNameAsc()`
- `CategoryConverter` com `toEntity()` e `toModel()` bidirecionais
- 6 Providers implementando os gateways do domain (Spring `@Component`)
- `DeleteCategoryProvider` faz soft delete (seta `deletedAt = LocalDateTime.now()`)
- `CountPurchasesByCategoryProvider` conta registros com `category_id` em ambas tabelas
- `CategoryController` com 5 endpoints REST (GET list, GET by id, POST, PUT, DELETE)
- `CreateCategoryRequest`, `UpdateCategoryRequest` com `@NotBlank` e `@Size(max=50)`
- `CategoryResponse` com companion object `from(entity)`
- DELETE retorna 409 se categoria vinculada a compras
- POST retorna 409 se nome duplicado
</requirements>

## Subtarefas

- [ ] 3.1 Criar `CategoryModel.kt` em `entrypoint/database/model/`
- [ ] 3.2 Criar `CategoryRepository.kt` em `entrypoint/database/repository/`
- [ ] 3.3 Criar `CategoryConverter.kt` em `converter/`
- [ ] 3.4 Criar 6 providers em `application/` implementando os gateways
- [ ] 3.5 Criar `CreateCategoryRequest.kt`, `UpdateCategoryRequest.kt` em `entrypoint/rest/request/`
- [ ] 3.6 Criar `CategoryResponse.kt` em `entrypoint/rest/response/`
- [ ] 3.7 Criar `CategoryController.kt` em `entrypoint/rest/`
- [ ] 3.8 Escrever testes de integracao do controller

## Detalhes de Implementacao

Consultar as secoes **Modelos de Dados > JPA Model**, **Request/Response DTOs** e **Endpoints de API** da `techspec.md`.

Referencia completa: `application/payment_methods/` (mesmo padrao em todas as camadas).

## Criterios de Sucesso

- Endpoints CRUD funcionais e testados
- Soft delete via `deleted_at` funcionando com `@SQLRestriction`
- Validacao de nome duplicado retorna 409
- Exclusao bloqueada com 409 quando ha compras vinculadas
- Listagem retorna categorias em ordem alfabetica

## Testes da Tarefa

- [ ] Teste de integracao: CRUD completo (criar, listar, buscar, editar, excluir)
- [ ] Teste de integracao: criar com nome duplicado retorna 409
- [ ] Teste de integracao: excluir categoria vinculada retorna 409
- [ ] Teste de integracao: listagem em ordem alfabetica
- [ ] Teste unitario: CategoryConverter toEntity/toModel

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/.../application/payment_methods/` — Referencia completa da application layer
- `controlai/src/main/kotlin/.../application/payment_methods/entrypoint/rest/PaymentMethodController.kt` — Referencia de controller
- `controlai/src/main/kotlin/.../application/payment_methods/converter/PaymentMethodConverter.kt` — Referencia de converter
- `controlai/src/test/kotlin/.../application/payment_methods/ControllerIntegrationTest.kt` — Referencia de testes
