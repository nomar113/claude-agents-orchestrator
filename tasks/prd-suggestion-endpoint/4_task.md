# Tarefa 4.0: Controller SuggestionController + Response DTO

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o controller REST `SuggestionController` que expoe o endpoint `GET /purchases/invoices/{id}/suggestions` e o DTO `SuggestionResponse` que formata a resposta. O controller delega ao use case e converte os resultados para o formato de resposta.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar `SuggestionController` como `@RestController` dedicado
- Endpoint: `GET /purchases/invoices/{id}/suggestions`
- Injetar `FindInvoiceSuggestionsUseCase`
- Retornar `List<SuggestionResponse>` com status 200
- Retornar 404 quando invoice nao encontrado (`NoSuchElementException`)
- Retornar lista vazia (nao erro) quando nao houver sugestoes
- Criar data class `SuggestionResponse` com companion object `from()` que calcula `timeDeltaMinutes`
- Campos do DTO: `id`, `cardLastDigits`, `purchasedAt`, `amount`, `merchantName`, `numberOfInstallments`, `category`, `categoryId`, `origin`, `originType`, `timeDeltaMinutes`
- Testes unitarios para o DTO (calculo do timeDeltaMinutes)
</requirements>

## Subtarefas

- [ ] 4.1 Criar data class `SuggestionResponse` com metodo `from(notification, invoiceDate)`
- [ ] 4.2 Criar `SuggestionController` com endpoint GET
- [ ] 4.3 Implementar tratamento de erro 404 para invoice nao encontrado
- [ ] 4.4 Escrever testes unitarios para `SuggestionResponse.from()` (calculo de `timeDeltaMinutes`)
- [ ] 4.5 Rodar build e testes

## Detalhes de Implementacao

Consultar as secoes "Endpoints de API" e "Modelos de Dados" da `techspec.md` para a assinatura do endpoint e campos do DTO.

## Criterios de Sucesso

- Endpoint responde corretamente nos 3 cenarios: com sugestoes, sem sugestoes, invoice inexistente
- DTO calcula `timeDeltaMinutes` corretamente
- Segue padrao de controllers existentes no projeto

## Testes da Tarefa

- [ ] Teste unitario: `SuggestionResponse.from()` calcula delta corretamente para diferentes cenarios
- [ ] Teste unitario: delta de 0 minutos, 30 minutos, 59 minutos
- [ ] Build (`./gradlew build`) passa sem erros

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/payments_notification/entrypoint/rest/PaymentNotificationController.kt` — referencia de padrao
- `src/main/kotlin/br/com/nomar/controlai/application/purchase_invoice/entrypoint/rest/PurchaseInvoiceController.kt` — referencia de padrao
- `src/main/kotlin/br/com/nomar/controlai/domain/payments_notifications/model/PaymentNotification.kt`
