# Tech Spec: Gestao de Cartoes e Meios de Pagamento

## Resumo Executivo

Esta especificacao define a implementacao de um CRUD completo de cartoes e meios de pagamento para o ControlAI, criando um novo bounded context `payment_methods` seguindo a arquitetura hexagonal existente. A solucao modela uma hierarquia de duas camadas (cartao principal + sub-cartoes) com tabela de titulares independente, soft delete via `@SQLRestriction`, e dupla FK nas despesas (cartao obrigatorio + sub-cartao opcional). O frontend substituira os dados mockados por dados reais via API REST, mantendo o layout card-stack atual.

## Arquitetura do Sistema

### Visao Geral dos Componentes

**Backend (Kotlin/Spring Boot 3.5) — Novo bounded context `payment_methods`:**

- **`Holder`** — Entidade de dominio representando um titular (Ramon, Aline). Tabela independente referenciada por FK nos cartoes.
- **`PaymentMethod`** — Entidade principal representando um cartao de credito ou meio de pagamento (Pix, Dinheiro). Possui tipo, titular, bandeira, dia de fechamento e soft delete.
- **`SubCard`** — Entidade filha representando variantes de um cartao (fisico titular, fisico dependente, virtual, virtual temporario, carteira digital). Cada um com ultimos 4 digitos e soft delete.
- **`HolderController`** — REST endpoints para CRUD de titulares.
- **`PaymentMethodController`** — REST endpoints para CRUD de cartoes/meios e sub-cartoes.
- **`PaymentMethodProvider`** — Adapter JPA implementando os gateways de persistencia.

**Frontend (React 19/Ionic 8) — Modificacoes:**

- **`services/paymentMethodService.ts`** (novo) — Camada de servico centralizada para chamadas HTTP ao novo contexto.
- **`pages/Tab1.tsx`** (modificado) — Substituir `STATIC_CARDS` e `FRONT_CARD` por dados reais da API.
- **`pages/PaymentMethodsPage.tsx`** (novo) — Tela de gestao de cartoes (listagem, formulario CRUD).
- **`components/PaymentMethodSelector.tsx`** (novo) — Seletor de cartao para o formulario de despesas (futuro vinculo).

**Fluxo de dados:**

```
Frontend → REST API → Controller → UseCase → Gateway(interface) → Provider(JPA) → MySQL
```

## Design de Implementacao

### Interfaces Principais

```kotlin
// Domain - Gateways (Ports)
fun interface SavePaymentMethodGateway {
    fun execute(paymentMethod: PaymentMethod): Result<PaymentMethod>
}

fun interface ListPaymentMethodsGateway {
    fun execute(holderId: Long?): Result<List<PaymentMethod>>
}

fun interface FindPaymentMethodGateway {
    fun execute(id: Long): Result<PaymentMethod>
}

fun interface UpdatePaymentMethodGateway {
    fun execute(paymentMethod: PaymentMethod): Result<PaymentMethod>
}

fun interface DeactivatePaymentMethodGateway {
    fun execute(id: Long): Result<Unit>
}

// Sub-card gateways seguem o mesmo padrao
fun interface SaveSubCardGateway {
    fun execute(subCard: SubCard): Result<SubCard>
}

fun interface DeactivateSubCardGateway {
    fun execute(id: Long): Result<Unit>
}
```

### Modelos de Dados

**Tabela `holders`:**

| Coluna     | Tipo                | Restricao       |
|------------|---------------------|-----------------|
| id         | BIGINT AUTO_INCREMENT | PK             |
| name       | VARCHAR(100)        | NOT NULL, UNIQUE |
| created_at | TIMESTAMP           | DEFAULT NOW()   |
| updated_at | TIMESTAMP           | ON UPDATE NOW() |

**Tabela `payment_methods`:**

| Coluna       | Tipo                | Restricao                |
|--------------|---------------------|--------------------------|
| id           | BIGINT AUTO_INCREMENT | PK                      |
| name         | VARCHAR(100)        | NOT NULL                 |
| type         | ENUM('CREDIT_CARD', 'PIX', 'CASH') | NOT NULL       |
| holder_id    | BIGINT              | NOT NULL, FK → holders   |
| brand        | VARCHAR(50)         | NULL (opcional)          |
| closing_day  | INT                 | NULL (so cartao credito) |
| deleted_at   | TIMESTAMP           | NULL                     |
| created_at   | TIMESTAMP           | DEFAULT NOW()            |
| updated_at   | TIMESTAMP           | ON UPDATE NOW()          |

**Tabela `sub_cards`:**

| Coluna             | Tipo                | Restricao                     |
|--------------------|---------------------|-------------------------------|
| id                 | BIGINT AUTO_INCREMENT | PK                           |
| payment_method_id  | BIGINT              | NOT NULL, FK → payment_methods |
| last_four_digits   | CHAR(4)             | NOT NULL                      |
| type               | ENUM('PHYSICAL_HOLDER', 'PHYSICAL_DEPENDENT', 'VIRTUAL', 'VIRTUAL_TEMPORARY', 'DIGITAL_WALLET') | NOT NULL |
| nickname           | VARCHAR(100)        | NULL                          |
| dependent_name     | VARCHAR(100)        | NULL (so PHYSICAL_DEPENDENT)  |
| wallet_platform    | ENUM('APPLE_PAY', 'GOOGLE_PAY', 'SAMSUNG_PAY', 'OTHER') | NULL (so DIGITAL_WALLET) |
| deleted_at         | TIMESTAMP           | NULL                          |
| created_at         | TIMESTAMP           | DEFAULT NOW()                 |
| updated_at         | TIMESTAMP           | ON UPDATE NOW()               |

**Alteracao na tabela `payment_notifications` (migracao):**

| Coluna            | Tipo   | Restricao                        |
|-------------------|--------|----------------------------------|
| payment_method_id | BIGINT | NULL, FK → payment_methods       |
| sub_card_id       | BIGINT | NULL, FK → sub_cards             |

Ambos campos nullable para retrocompatibilidade com despesas existentes.

### Endpoints de API

**Holders:**

| Metodo | Path                | Descricao              |
|--------|---------------------|------------------------|
| GET    | `/holders`          | Listar todos titulares |
| POST   | `/holders`          | Criar titular          |

**Payment Methods:**

| Metodo | Path                              | Descricao                          |
|--------|-----------------------------------|------------------------------------|
| GET    | `/payment-methods`                | Listar todos (query: ?holderId=)   |
| GET    | `/payment-methods/{id}`           | Detalhe com sub-cartoes            |
| POST   | `/payment-methods`                | Criar cartao/meio                  |
| PUT    | `/payment-methods/{id}`           | Atualizar cartao/meio              |
| DELETE | `/payment-methods/{id}`           | Soft delete (set deleted_at)       |

**Sub-cards:**

| Metodo | Path                                          | Descricao             |
|--------|-----------------------------------------------|-----------------------|
| POST   | `/payment-methods/{id}/sub-cards`             | Criar sub-cartao      |
| PUT    | `/payment-methods/{id}/sub-cards/{subCardId}` | Atualizar sub-cartao  |
| DELETE | `/payment-methods/{id}/sub-cards/{subCardId}` | Soft delete sub-cartao|

**Totais (leitura):**

| Metodo | Path                                      | Descricao                         |
|--------|-------------------------------------------|-----------------------------------|
| GET    | `/payment-methods/summary?month=2026-03`  | Total gasto por cartao no mes     |

**Formato de resposta — `GET /payment-methods`:**

```json
[
  {
    "id": 1,
    "name": "Smiles Infinite",
    "type": "CREDIT_CARD",
    "holder": { "id": 1, "name": "Ramon" },
    "brand": "Visa",
    "closingDay": 15,
    "subCards": [
      {
        "id": 1,
        "lastFourDigits": "6668",
        "type": "PHYSICAL_HOLDER",
        "nickname": null
      },
      {
        "id": 2,
        "lastFourDigits": "9687",
        "type": "PHYSICAL_DEPENDENT",
        "dependentName": "Aline"
      }
    ]
  }
]
```

**Formato de resposta — `GET /payment-methods/summary?month=2026-03`:**

```json
[
  {
    "paymentMethodId": 1,
    "name": "Smiles Infinite",
    "holderName": "Ramon",
    "totalSpent": 3245.67,
    "subCardTotals": [
      { "subCardId": 1, "lastFourDigits": "6668", "total": 2100.00 },
      { "subCardId": 2, "lastFourDigits": "9687", "total": 1145.67 }
    ]
  }
]
```

## Pontos de Integracao

Nao ha integracoes externas. Os dados sao inseridos manualmente pelo usuario. A unica integracao interna e a FK entre `payment_notifications` e as novas tabelas `payment_methods`/`sub_cards`.

## Abordagem de Testes

### Testes Unitarios

- **Use Cases**: Testar cada use case isoladamente com gateways mockados. Cenarios: criacao com dados validos, validacao de campos obrigatorios, soft delete idempotente, listagem com filtro por titular.
- **Converters**: Testar mapeamento bidirecional entity ↔ model, garantindo que campos nullable sao tratados.
- **Dominio**: Testar regras de validacao (closing_day entre 1-31, last_four_digits com exatamente 4 digitos, wallet_platform obrigatorio para DIGITAL_WALLET).

### Testes de Integracao

- **Repository + Flyway**: Testar com H2 em memoria que as migrations executam corretamente e as queries JPA retornam dados filtrados por `@SQLRestriction` (registros com deleted_at preenchido nao devem aparecer).
- **Controller**: Testar endpoints com `@SpringBootTest` + `MockMvc` para validar HTTP status codes, serialization JSON e validacoes de request.

### Testes E2E

- **Playwright**: Testar fluxo completo de gestao de cartoes no frontend (criar cartao, editar, desativar, verificar que aparece no dashboard). Testar que cartoes desativados nao aparecem no seletor de despesas.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Migracao Flyway + Entidades JPA** — Criar tabelas `holders`, `payment_methods`, `sub_cards` e alterar `payment_notifications`. Base para todo o resto.
2. **Domain layer** — Entidades de dominio, gateways (interfaces), use cases. Sem dependencia de infra.
3. **Application layer — Providers + Repositories** — Implementacoes JPA dos gateways, converters entity ↔ model.
4. **Application layer — Controllers + DTOs** — Endpoints REST com request/response DTOs. Testar com Postman/curl.
5. **Frontend — Service layer** — Criar `paymentMethodService.ts` com chamadas HTTP centralizadas.
6. **Frontend — Tela de gestao** — `PaymentMethodsPage` com CRUD completo, acessivel via Tab3/Config.
7. **Frontend — Dashboard** — Substituir dados mockados em Tab1 por dados reais via endpoint `/payment-methods/summary`.
8. **Frontend — Seletor de cartao** — Componente `PaymentMethodSelector` para vincular despesas (preparacao para integracao futura com formulario de despesas).

### Dependencias Tecnicas

- Backend MySQL rodando (Docker existente)
- Flyway migrations devem executar antes de qualquer teste de integracao
- Endpoints de holders devem existir antes de criar payment methods (FK)

## Monitoramento e Observabilidade

- **Logs**: Usar `LoggerFactory.getLogger()` nos providers e controllers. Level INFO para operacoes de escrita (create, update, delete), WARN para tentativas de acessar registros deletados, ERROR para falhas de persistencia.
- **Actuator**: Os endpoints `/actuator/health` e `/actuator/metrics` ja estao disponiveis via Spring Boot Actuator. Nenhuma configuracao adicional necessaria.
- **Metricas**: Monitorar count de cartoes criados/desativados via logs estruturados. Dashboard Grafana e escopo futuro.

## Consideracoes Tecnicas

### Decisoes Principais

| Decisao | Justificativa | Alternativa rejeitada |
|---------|---------------|-----------------------|
| Tabela `holders` separada | Permite extensibilidade futura (novos membros) e normalizacao | Enum hardcoded — limitaria a 2 valores fixos |
| Dupla FK (cartao + sub-cartao) | Maximo de granularidade: sempre sabe o cartao, opcionalmente o plastico | FK unica para sub-cartao — exigiria sempre selecionar variante |
| Novo bounded context | Separacao clara de responsabilidades, segue padrao existente | Dentro de payments_notifications — acoplaria dominios distintos |
| `@SQLRestriction` + `deleted_at` | Timestamp de desativacao util para auditoria, filtragem automatica | `@SoftDelete` — menos controle; boolean — sem data de desativacao |
| Campos nullable na FK de payment_notifications | Retrocompatibilidade com despesas existentes sem cartao | Campo obrigatorio — quebraria dados historicos |

### Riscos Conhecidos

- **Migracao de dados**: Despesas existentes em `payment_notifications` possuem `card_last_digits` mas nao `payment_method_id`. Sera necessaria uma migracao manual ou script para vincular retroativamente (escopo futuro, nao bloqueante).
- **Consistencia de ENUMs MySQL**: Adicionar novos valores a ENUMs no MySQL requer `ALTER TABLE`. Manter os tipos como VARCHAR se a lista tender a crescer; usar ENUM apenas para conjuntos estáveis.
- **Performance do endpoint summary**: O calculo de totais por cartao exige JOIN entre `payment_notifications` e `payment_methods`. Indexar `payment_method_id` e `sub_card_id` na tabela `payment_notifications`.

### Conformidade com Skills Padrao

| Skill | Aplicabilidade |
|-------|---------------|
| `executar-task` | Cada etapa do sequenciamento deve ser implementada como task individual |
| `task-review` | Review automatico apos cada task completada |
| `executar-review` | Code review completo apos implementacao da feature |
| `executar-qa` | QA com Playwright para fluxos E2E de gestao de cartoes |
| `executar-bugfix` | Correcao de bugs encontrados no QA |

### Arquivos relevantes e dependentes

**Backend (`/Volumes/SSD480GB/projects/controlai`):**

- `src/main/resources/db/migration/` — Adicionar V5, V6, V7 (holders, payment_methods, sub_cards, alter payment_notifications)
- `src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/` — Novo bounded context (entity, usecase, gateway)
- `src/main/kotlin/br/com/nomar/controlai/application/payment_methods/` — Novo (entrypoint/rest, entrypoint/database, application, converter)
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt` — Adicionar FKs
- `src/main/resources/application.yml` — Sem alteracoes necessarias (JPA auto-detect)

**Frontend (`/Volumes/SSD480GB/projects/controlai-frontend`):**

- `src/pages/Tab1.tsx` — Remover STATIC_CARDS/FRONT_CARD, consumir API real
- `src/pages/PaymentMethodsPage.tsx` — Nova tela de gestao
- `src/services/paymentMethodService.ts` — Novo service layer
- `src/components/PaymentMethodSelector.tsx` — Novo componente seletor
- `src/App.tsx` — Adicionar rota para PaymentMethodsPage
- `src/pages/Tab3.tsx` — Link para gestao de cartoes
