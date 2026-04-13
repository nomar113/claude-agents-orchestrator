# Tarefa 2.0: Backend — Domain layer do bounded context payment_methods

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de dominio do novo bounded context `payment_methods`, incluindo entidades de dominio, enums, interfaces de gateway (ports) e use cases. Seguir o padrao hexagonal existente no projeto (domain/entity, domain/usecase, domain/gateway).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar entidade de dominio `Holder` (data class, sem JPA)
- Criar entidade de dominio `PaymentMethod` com campos conforme techspec
- Criar entidade de dominio `SubCard` com campos conforme techspec
- Criar enums: `PaymentMethodType` (CREDIT_CARD, PIX, CASH), `SubCardType` (PHYSICAL_HOLDER, PHYSICAL_DEPENDENT, VIRTUAL, VIRTUAL_TEMPORARY, DIGITAL_WALLET), `WalletPlatform` (APPLE_PAY, GOOGLE_PAY, SAMSUNG_PAY, OTHER)
- Criar interfaces de gateway (fun interface) conforme techspec: Save, List, Find, Update, Deactivate para PaymentMethod; Save, Deactivate para SubCard; Save, List para Holder
- Criar use cases que delegam para gateways, retornando Result<T>
- Seguir padrao existente: domain entities sao data classes imutaveis, gateways sao fun interfaces, use cases sao @Component
</requirements>

## Subtarefas

- [ ] 2.1 Criar enums `PaymentMethodType`, `SubCardType`, `WalletPlatform`
- [ ] 2.2 Criar entidade de dominio `Holder`
- [ ] 2.3 Criar entidade de dominio `PaymentMethod`
- [ ] 2.4 Criar entidade de dominio `SubCard`
- [ ] 2.5 Criar interfaces de gateway para Holder (Save, List)
- [ ] 2.6 Criar interfaces de gateway para PaymentMethod (Save, List, Find, Update, Deactivate)
- [ ] 2.7 Criar interfaces de gateway para SubCard (Save, Update, Deactivate)
- [ ] 2.8 Criar use cases para Holder
- [ ] 2.9 Criar use cases para PaymentMethod (CRUD + Deactivate)
- [ ] 2.10 Criar use cases para SubCard (Save, Update, Deactivate)
- [ ] 2.11 Testes unitarios dos use cases

## Detalhes de Implementacao

Consultar a secao **Interfaces Principais** e **Modelos de Dados** da `techspec.md`.

Seguir o padrao existente em `domain/purchases_invoices/` como referencia de estrutura de pacotes e convencoes.

## Criterios de Sucesso

- Todas as entidades, enums, gateways e use cases compilam sem erro
- Use cases delegam corretamente para gateways e retornam Result<T>
- Nenhuma dependencia de JPA ou Spring na camada de dominio (exceto @Component nos use cases)
- Testes unitarios com 100% de cobertura nos use cases

## Testes da Tarefa

- [ ] Testes unitarios: cada use case testado com gateway mockado (sucesso e falha)
- [ ] Testes unitarios: validar que enums contem todos os valores esperados
- [ ] Testes unitarios: validar construcao das entidades de dominio

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/entity/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/usecase/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/payment_methods/gateway/` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/` (referencia de padrao)
