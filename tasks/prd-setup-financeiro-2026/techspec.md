# Tech Spec: Setup Financeiro 2026

## Resumo Executivo

Esta Tech Spec detalha a implementacao de categorias de gastos no Controlai, seguindo a arquitetura hexagonal existente. A abordagem cria um novo bounded context `categories` com CRUD completo no backend (Kotlin/Spring Boot), migracoes Flyway para schema e seed data (9 categorias genericas), e telas no frontend (Ionic React) seguindo o padrao visual ja estabelecido em PaymentMethodsPage. A vinculacao com compras sera feita adicionando `category_id` (FK) em `payment_notifications` e `purchase_invoices`, substituindo o campo texto livre existente. O frontend mantera o visual de chips dinamicos no formulario de registro.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Novos componentes:**

- **`domain/categories/entity/Category.kt`** — Entidade de dominio com `id`, `name`. Validacao de nome unico.
- **`domain/categories/gateway/`** — Interfaces de saida: `SaveCategoryGateway`, `UpdateCategoryGateway`, `ListCategoriesGateway`, `FindCategoryGateway`, `DeleteCategoryGateway`, `CountPurchasesByCategoryGateway`.
- **`domain/categories/usecase/`** — Use cases: `SaveCategoryUseCase`, `UpdateCategoryUseCase`, `ListCategoriesUseCase`, `FindCategoryUseCase`, `DeleteCategoryUseCase`.
- **`application/categories/entrypoint/rest/CategoryController.kt`** — Controller REST com endpoints CRUD.
- **`application/categories/entrypoint/database/model/CategoryModel.kt`** — Modelo JPA com soft delete (`deleted_at`, `@SQLRestriction`).
- **`application/categories/entrypoint/database/repository/CategoryRepository.kt`** — Spring Data JPA repository.
- **`application/categories/converter/CategoryConverter.kt`** — Conversao bidirecional Entity <-> Model.
- **`application/categories/application/*Provider.kt`** — Implementacoes dos gateways.
- **Frontend: `CategoriesPage.tsx`** — Tela CRUD seguindo padrao PaymentMethodsPage.
- **Frontend: `CategoryChips.tsx`** — Componente reutilizavel de selecao por chips (substitui array hardcoded).
- **Frontend: `categoryService.ts`** — Servico HTTP para API de categorias.

**Componentes modificados:**

- **`PurchaseProjection.kt`** — Adicionar campo `categoryName` na interface de projecao.
- **`PurchaseRepository.kt`** — Incluir `category_id` e JOIN com `categories` na UNION query.
- **`PaymentNotification.kt` (model)** — Adicionar campo `category_id` (FK), manter `category` (texto) para retrocompatibilidade.
- **`PurchaseInvoice.kt` (model)** — Adicionar campo `category_id` (FK).
- **`ManualPaymentNotificationRequest.kt`** — Trocar `category: String` por `categoryId: Long`.
- **`ManualEntryPage.tsx`** — Substituir array CATEGORIES hardcoded por CategoryChips dinamico.
- **`PurchaseDetail.tsx`** — Exibir categoria via `categoryName` do backend; remover fallback `getCategoryLabel()`.

**Fluxo de dados:**
```
[CRUD Categorias]
Frontend → CategoryController → UseCase → Gateway/Provider → CategoryRepository → MySQL

[Registro de Compra com Categoria]
ManualEntryPage → PaymentNotificationController → UseCase → Provider → MySQL (com category_id FK)

[Leitura de Compras]
PurchaseList → PurchaseController → PurchaseRepository (UNION + JOIN categories) → PurchaseProjection → Response
```

## Design de Implementacao

### Interfaces Principais

```kotlin
// Domain Gateways
fun interface SaveCategoryGateway {
    fun execute(category: Category): Result<Category>
}

fun interface ListCategoriesGateway {
    fun execute(): Result<List<Category>>
}

fun interface FindCategoryGateway {
    fun execute(id: Long): Result<Category>
}

fun interface UpdateCategoryGateway {
    fun execute(category: Category): Result<Category>
}

fun interface DeleteCategoryGateway {
    fun execute(id: Long): Result<Unit>
}

fun interface CountPurchasesByCategoryGateway {
    fun execute(categoryId: Long): Result<Long>
}
```

```kotlin
// Use Case — DeleteCategoryUseCase (logica de negocio)
@Component
class DeleteCategoryUseCase(
    private val countPurchases: CountPurchasesByCategoryGateway,
    private val deleteCategory: DeleteCategoryGateway
) {
    fun execute(id: Long): Result<Unit> = runCatching {
        val count = countPurchases.execute(id).getOrThrow()
        if (count > 0) throw IllegalStateException(
            "Categoria vinculada a $count compra(s). Remova os vinculos antes de excluir."
        )
        deleteCategory.execute(id).getOrThrow()
    }
}
```

### Modelos de Dados

**Tabela `categories`:**

```sql
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Seed data (mesma migracao):**

```sql
INSERT INTO categories (name) VALUES
('Gastos Gerais'), ('Mercado'), ('Veiculos'), ('Pets'), ('Moradia'),
('Remedios'), ('Medicos'), ('Transporte'), ('Viagens'), ('Assinaturas'),
('Lazer'), ('Educacao'), ('Vestuario'), ('Beleza'), ('Presentes');
```

**Alteracoes em tabelas existentes (migracao separada):**

```sql
-- Adicionar category_id em payment_notifications
ALTER TABLE payment_notifications
    ADD COLUMN category_id BIGINT NULL DEFAULT NULL,
    ADD CONSTRAINT fk_pn_category FOREIGN KEY (category_id) REFERENCES categories (id);

-- Adicionar category_id em purchase_invoices
ALTER TABLE purchase_invoices
    ADD COLUMN category_id BIGINT NULL DEFAULT NULL,
    ADD CONSTRAINT fk_pi_category FOREIGN KEY (category_id) REFERENCES categories (id);
```

> O campo `category` (VARCHAR) em `payment_notifications` sera mantido para retrocompatibilidade. Compras existentes continuam com o texto livre ate serem recategorizadas.

**Entidade de dominio:**

```kotlin
data class Category(
    val id: Long = 0,
    val name: String
)
```

**JPA Model:**

```kotlin
@Entity
@Table(name = "categories")
@SQLRestriction("deleted_at IS NULL")
data class CategoryModel(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(name = "name", length = 50, nullable = false, unique = true)
    val name: String = "",
    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null,
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    val createdAt: LocalDateTime? = null,
    @UpdateTimestamp
    @Column(name = "updated_at")
    val updatedAt: LocalDateTime? = null
)
```

**Request/Response DTOs:**

```kotlin
data class CreateCategoryRequest(
    @field:NotBlank @field:Size(max = 50)
    val name: String
)

data class UpdateCategoryRequest(
    @field:NotBlank @field:Size(max = 50)
    val name: String
)

data class CategoryResponse(
    val id: Long,
    val name: String
) {
    companion object {
        fun from(entity: Category) = CategoryResponse(id = entity.id, name = entity.name)
    }
}
```

**Tipo TypeScript (frontend):**

```typescript
export interface Category {
    id: number;
    name: string;
}
```

### Endpoints de API

| Metodo | Caminho | Descricao |
|--------|---------|-----------|
| `GET` | `/categories` | Listar todas as categorias (ordenadas por nome) |
| `GET` | `/categories/{id}` | Buscar categoria por ID |
| `POST` | `/categories` | Criar nova categoria |
| `PUT` | `/categories/{id}` | Atualizar nome da categoria |
| `DELETE` | `/categories/{id}` | Soft delete (retorna 409 se vinculada a compras) |

**Respostas de erro:**
- `409 Conflict` — Tentativa de excluir categoria vinculada a compras (body com mensagem e contagem).
- `409 Conflict` — Tentativa de criar categoria com nome duplicado.
- `404 Not Found` — Categoria nao encontrada.

## Pontos de Integracao

Nao ha integracoes externas. Toda a comunicacao e interna entre frontend Ionic e backend Spring Boot via HTTP REST.

**Comunicacao HTTP (padrao existente):**
- Nativo (Capacitor): `CapacitorHttp.get/post/put/request`
- Web (dev): `fetch`
- Base URL: `https://api.opencod3.com.br`

## Abordagem de Testes

### Testes Unitarios

- **DeleteCategoryUseCase**: Testar que impede exclusao quando `countPurchases > 0`. Testar exclusao bem-sucedida quando `countPurchases == 0`. Usar lambda `fun interface` para mockar gateways (padrao existente).
- **SaveCategoryUseCase**: Testar criacao com nome valido.
- **CategoryConverter**: Testar conversao bidirecional Entity <-> Model.

### Testes de Integracao

- **CategoryController**: Testar ciclo CRUD completo (criar, listar, editar, excluir). Testar unicidade case-insensitive do nome. Testar exclusao bloqueada quando vinculada (inserir compra com category_id, tentar DELETE). Usar H2 em memoria (padrao existente, ver `ControllerIntegrationTest.kt` de payment_methods como referencia).
- **Migracao**: Testar que seed data e inserido corretamente (ver `MigrationIntegrationTest.kt`).

### Testes E2E

- Testar fluxo de gerenciamento de categorias no app (criar, editar, excluir) usando Playwright.
- Testar registro de compra manual com selecao de categoria via chips.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migracao Flyway** — Criar tabela `categories` + seed data + adicionar `category_id` FK em `payment_notifications` e `purchase_invoices`. Fundacao para todo o resto.
2. **Backend: Domain layer** — Entity, gateways, use cases. Sem dependencias externas.
3. **Backend: Application layer** — Model JPA, repository, converter, providers, controller, DTOs. Depende do domain.
4. **Backend: Testes** — Unitarios e integracao. Validar antes de ir pro frontend.
5. **Backend: Atualizar PurchaseProjection** — Incluir `categoryName` na UNION query com JOIN. Atualizar response.
6. **Backend: Atualizar ManualPaymentNotificationRequest** — Trocar `category: String` por `categoryId: Long`. Atualizar controller e provider.
7. **Frontend: categoryService.ts + tipos** — Servico HTTP e interface TypeScript.
8. **Frontend: CategoriesPage.tsx** — Tela CRUD seguindo padrao PaymentMethodsPage.
9. **Frontend: CategoryChips.tsx** — Componente reutilizavel, carrega categorias do backend.
10. **Frontend: Integrar no ManualEntryPage** — Substituir chips hardcoded por CategoryChips.
11. **Frontend: Atualizar PurchaseDetail** — Exibir categoria do backend, remover getCategoryLabel fallback.
12. **Frontend: Roteamento** — Adicionar rota para CategoriesPage no App.tsx.

### Dependencias Tecnicas

- Flyway migracoes devem rodar antes de qualquer teste de integracao.
- Backend CRUD deve estar funcional antes do frontend consumi-lo.
- `category_id` FK nas tabelas de compras e nullable para retrocompatibilidade com dados existentes.

## Monitoramento e Observabilidade

- **Logs**: Seguir padrao existente do Spring Boot — log automatico de requests/responses pelo framework. Log explicito apenas em casos de erro no DeleteCategoryUseCase (tentativa de exclusao bloqueada).
- **Metricas**: Nao requer metricas customizadas para esta feature. Monitoramento padrao do Spring Boot Actuator e suficiente.

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Justificativa | Alternativa rejeitada |
|---------|---------------|----------------------|
| Soft delete com `deleted_at` | Consistencia com padrao do projeto (PaymentMethod, PaymentNotification). | Hard delete — quebraria consistencia. |
| Seed data via Flyway SQL | Reprodutivel, versionado, sem logica de boot. Padrao do projeto. | ApplicationRunner — adiciona complexidade desnecessaria. |
| FK `category_id` em ambas tabelas | Permite categorizar tanto notificacoes quanto notas fiscais. | Tabela associativa — overengineering para relacao N:1 simples. |
| Manter campo `category` (texto) | Retrocompatibilidade com dados existentes. Remocao futura quando todos estiverem migrados. | Remover imediatamente — quebraria registros existentes. |
| Chips dinamicos no frontend | UX ja validada pelo usuario. Apenas trocar fonte de dados (hardcoded → API). | IonSelect — mudaria UX sem necessidade. |
| Unicidade case-insensitive via UNIQUE KEY | MySQL com collation `utf8mb4_unicode_ci` ja e case-insensitive por padrao. Sem necessidade de logica extra. | Validacao no codigo — redundante dado o collation. |

### Riscos Conhecidos

- **Retrocompatibilidade**: Compras existentes com `category` texto livre e `category_id` NULL precisam funcionar ate recategorizacao. O frontend deve tratar ambos os campos.
- **Migracao de dados**: O campo `category` (texto) nao sera migrado automaticamente para `category_id`. Isso e intencional (fora de escopo), mas compras antigas mostrarao categoria como texto ate serem editadas.
- **Unicidade de nomes**: A constraint UNIQUE no banco garante unicidade, mas erros devem ser tratados no controller (retornar 409 com mensagem amigavel, nao 500).

### Conformidade com Skills Padroes

- **`kotlin-springboot`**: Aplicavel ao backend. Seguir padroes de Spring Boot com Kotlin, injecao de dependencias, anotacoes.
- **`ionic-design`**: Aplicavel ao frontend. CategoriesPage e CategoryChips devem usar componentes Ionic nativos (IonList, IonItem, IonButton, IonChip).
- **`clean-code`**: Aplicavel a ambos. Nomes claros, funcoes pequenas, responsabilidade unica.

### Arquivos relevantes e dependentes

**Backend (controlai):**
- `src/main/resources/db/migration/V6__create_payment_methods_table.sql` — Referencia de schema
- `src/main/kotlin/.../domain/payment_methods/` — Referencia de domain layer
- `src/main/kotlin/.../application/payment_methods/` — Referencia de application layer
- `src/main/kotlin/.../application/payments_notification/entrypoint/rest/request/ManualPaymentNotificationRequest.kt` — Sera modificado
- `src/main/kotlin/.../application/payments_notification/entrypoint/database/model/PaymentNotification.kt` — Sera modificado
- `src/main/kotlin/.../application/purchases_invoices/entrypoint/database/model/PurchaseProjection.kt` — Sera modificado
- `src/main/kotlin/.../application/purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt` — Sera modificado
- `src/test/kotlin/.../application/payment_methods/ControllerIntegrationTest.kt` — Referencia de testes

**Frontend (controlai-frontend):**
- `src/pages/PaymentMethodsPage.tsx` — Referencia visual para CategoriesPage
- `src/pages/ManualEntryPage.tsx` — Sera modificado (chips hardcoded → dinamicos)
- `src/pages/PurchaseDetail.tsx` — Sera modificado (exibir categoria do backend)
- `src/services/paymentMethodService.ts` — Referencia para categoryService
- `src/types/paymentMethod.ts` — Referencia para tipos de categoria
- `src/App.tsx` — Sera modificado (nova rota)
