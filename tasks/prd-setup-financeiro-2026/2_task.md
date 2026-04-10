# Tarefa 2.0: Backend — Domain layer de categorias

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de dominio do bounded context `categories`: entidade, interfaces de gateway (output ports) e use cases. Camada pura sem dependencias de framework.

<skills>
### Conformidade com Skills Padroes

- **`kotlin-springboot`**: Use cases como `@Component`, gateways como `fun interface`.
- **`clean-code`**: Responsabilidade unica, nomes expressivos.
</skills>

<requirements>
- Entidade `Category` com `id: Long` e `name: String`
- 6 gateways: SaveCategoryGateway, UpdateCategoryGateway, ListCategoriesGateway, FindCategoryGateway, DeleteCategoryGateway, CountPurchasesByCategoryGateway
- 5 use cases: SaveCategoryUseCase, UpdateCategoryUseCase, ListCategoriesUseCase, FindCategoryUseCase, DeleteCategoryUseCase
- DeleteCategoryUseCase deve verificar se ha compras vinculadas antes de excluir
- Todos retornam `Result<T>` (padrao do projeto)
- Gateways como `fun interface` (padrao do projeto)
</requirements>

## Subtarefas

- [ ] 2.1 Criar `domain/categories/entity/Category.kt`
- [ ] 2.2 Criar 6 interfaces de gateway em `domain/categories/gateway/`
- [ ] 2.3 Criar 5 use cases em `domain/categories/usecase/`
- [ ] 2.4 Escrever testes unitarios dos use cases

## Detalhes de Implementacao

Consultar a secao **Interfaces Principais** da `techspec.md` para as assinaturas dos gateways e a logica do DeleteCategoryUseCase.

Referencia de domain layer: `domain/payment_methods/` (mesmo padrao).

## Criterios de Sucesso

- Entidade, gateways e use cases criados seguindo padrao hexagonal
- DeleteCategoryUseCase impede exclusao quando ha compras vinculadas
- Testes unitarios passam com gateways mockados via lambda

## Testes da Tarefa

- [ ] Teste unitario: DeleteCategoryUseCase bloqueia exclusao com compras vinculadas (count > 0)
- [ ] Teste unitario: DeleteCategoryUseCase permite exclusao sem compras (count == 0)
- [ ] Teste unitario: SaveCategoryUseCase delega para gateway corretamente
- [ ] Teste unitario: ListCategoriesUseCase retorna lista do gateway

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/.../domain/payment_methods/entity/PaymentMethod.kt` — Referencia de entidade
- `controlai/src/main/kotlin/.../domain/payment_methods/gateway/` — Referencia de gateways
- `controlai/src/main/kotlin/.../domain/payment_methods/usecase/` — Referencia de use cases
- `controlai/src/test/kotlin/.../domain/payment_methods/PaymentMethodsUseCasesTest.kt` — Referencia de testes
