# Tarefa 1.0: Migration V25 + Model JPA

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a migration V25 que adiciona a coluna `purchase_invoice_id` (nullable, UNIQUE, FK) na tabela `payment_notifications` e atualizar o JPA entity `PaymentNotification.kt` com o novo campo.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Migration V25 cria coluna `purchase_invoice_id` BIGINT NULL em `payment_notifications`
- Foreign key referenciando `purchase_invoices(id)`
- Constraint UNIQUE em `purchase_invoice_id` (relacao 1:1)
- Campo `purchaseInvoiceId: Long?` adicionado ao JPA entity `PaymentNotification.kt`
- Aplicacao inicia corretamente com a migration aplicada
</requirements>

## Subtarefas

- [ ] 1.1 Criar arquivo `V25__add_purchase_invoice_id_to_payment_notifications.sql` na pasta de migrations
- [ ] 1.2 Adicionar campo `purchaseInvoiceId` ao model JPA `PaymentNotification.kt` com `@Column(name = "purchase_invoice_id", nullable = true)`
- [ ] 1.3 Verificar que a aplicacao inicia sem erros com a migration aplicada

## Detalhes de Implementacao

Consultar a secao **Modelos de Dados > Migration V25** da `techspec.md` para o SQL exato e a anotacao JPA.

## Criterios de Sucesso

- Migration roda sem erros em banco limpo e em banco com dados existentes
- Coluna `purchase_invoice_id` existe com FK e UNIQUE constraint
- `PaymentNotification.kt` compila com o novo campo nullable
- Aplicacao Spring Boot inicia sem erros de schema validation

## Testes da Tarefa

- [ ] Teste de integracao: migration aplica corretamente (verificar via startup da aplicacao)
- [ ] Teste manual: confirmar coluna, FK e UNIQUE no banco

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/V25__add_purchase_invoice_id_to_payment_notifications.sql` (criar)
- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/database/model/PaymentNotification.kt` (modificar)
