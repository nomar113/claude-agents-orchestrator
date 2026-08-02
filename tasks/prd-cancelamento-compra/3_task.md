# Tarefa 3.0: Use Cases de Cancelamento (Backend)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar os use cases (providers) de cancelamento para ambos os tipos de compra, com validacoes de estado (nao encontrado, ja cancelado, ja excluido).

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de Use Case/Provider do projeto (Result<T>, @Transactional).
</skills>

<requirements>
- Criar `CancelPaymentNotificationUseCase` (interface no domain)
- Criar `CancelPaymentNotificationProvider` (implementacao no application)
- Criar `CancelPurchaseInvoiceUseCase` (interface no domain)
- Criar `CancelPurchaseInvoiceProvider` (implementacao no application)
- Validar: item nao encontrado (404), ja cancelado (409), ja excluido (422)
- Setar `cancelledAt = LocalDateTime.now()` ao cancelar
- Cancelamento e definitivo — nao deve existir metodo de reativacao
</requirements>

## Subtarefas

- [ ] 3.1 Criar interface `CancelPaymentNotificationUseCase` no domain
- [ ] 3.2 Criar `CancelPaymentNotificationProvider` com logica de cancelamento e validacoes
- [ ] 3.3 Criar interface `CancelPurchaseInvoiceUseCase` no domain
- [ ] 3.4 Criar `CancelPurchaseInvoiceProvider` com logica de cancelamento e validacoes
- [ ] 3.5 Registrar beans no contexto Spring (ou via @Service/@Component)

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Interfaces Principais > CancelPaymentNotificationProvider"

Seguir padrao identico ao `DeactivatePaymentNotificationProvider` existente, mas setando `cancelledAt` em vez de `deletedAt`.

## Criterios de Sucesso

- Provider cancela compra com sucesso (seta cancelledAt)
- Retorna erro adequado para item nao encontrado
- Retorna erro adequado para item ja cancelado
- Retorna erro adequado para item ja excluido (deletedAt preenchido)
- Transacao e atomica (@Transactional)

## Testes da Tarefa

- [ ] Testes de unidade: cancelamento com sucesso, item nao encontrado, item ja cancelado, item ja excluido
- [ ] Testes de unidade: verificar que `cancelledAt` e setado com timestamp atual

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../payments_notification/application/DeactivatePaymentNotificationProvider.kt` (referencia de padrao)
- `src/main/kotlin/.../purchases_invoices/application/DeactivatePurchaseInvoiceProvider.kt` (referencia de padrao)
- `src/main/kotlin/.../payments_notification/domain/` (interfaces de use case)
- `src/main/kotlin/.../purchases_invoices/domain/` (interfaces de use case)
