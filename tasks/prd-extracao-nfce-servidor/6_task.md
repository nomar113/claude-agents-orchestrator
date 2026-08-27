# Tarefa 6.0: Use Case Kotlin: ExtractPurchaseInvoiceUseCase

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar `ExtractPurchaseInvoiceUseCase`, responsavel por validar a URL da nota recebida do app, extrair a `accessKey`, checar duplicidade (reaproveitando `PurchaseInvoiceRepository.countByAccessKey`, ja usado por `SavePurchaseInvoiceProvider`) e delegar a extracao ao `NfceExtractionGateway` (Tarefa 5.0). A checagem de duplicidade deve ocorrer **antes** de acionar o gateway, evitando gastar uma sessao headless cara numa nota ja registrada.

<skills>
### Conformidade com Skills Padroes

Aplicar a skill `kotlin-springboot` na implementacao do use case, seguindo o padrao de `Result<T>`/`runCatching` para erros de dominio ja adotado no projeto (ver `CLAUDE.md` do backend).
</skills>

<requirements>
- Implementar `ExtractPurchaseInvoiceUseCase` em `domain/purchases_invoices/usecase/`, com a assinatura definida na Tech Spec (secao "Interfaces Principais"): recebe `InvoiceUrl`, retorna `Result<ExtractedPurchaseInvoice>`.
- Extrair a `accessKey` da URL usando `AccessKey.fromInvoiceUrl(invoiceUrl)` (reaproveitar o value object existente).
- Checar duplicidade via `purchaseInvoiceRepository.countByAccessKey(accessKey.value) == 0L`; se ja existir, retornar falha com mensagem "Nota ja registrada" (mesma mensagem usada no exemplo da Tech Spec).
- So chamar `extractionGateway.extract(invoiceUrl)` apos a checagem de duplicidade passar.
- Propagar corretamente, via `Result`, os diferentes tipos de falha vindos do gateway (bloqueio, timeout, erro de navegacao/servico) para que a Tarefa 7.0 consiga mapea-los a status HTTP distintos.
</requirements>

## Subtarefas

- [ ] 6.1 Implementar `ExtractPurchaseInvoiceUseCase` em `domain/purchases_invoices/usecase/`, injetando `NfceExtractionGateway` e `PurchaseInvoiceRepository`.
- [ ] 6.2 Implementar a validacao de duplicidade antes da chamada ao gateway.
- [ ] 6.3 Garantir que excecoes/falhas do gateway (bloqueio, timeout, erro de navegacao) sejam propagadas de forma identificavel (tipos de excecao distintos ou wrapper de erro) para a camada de controller.
- [ ] 6.4 Escrever testes unitarios (padrao `UseCasesTest.kt`) com `NfceExtractionGateway` mockado como lambda, cobrindo: sucesso, duplicidade, bloqueio, timeout, erro de gateway.

## Detalhes de Implementacao

Ver Tech Spec, secao "Interfaces Principais" (codigo de exemplo de `ExtractPurchaseInvoiceUseCase`) e "Decisoes Principais" ("Checagem de duplicidade antes de acionar o browser"). Referencia de padrao de teste: `UseCasesTest.kt`.

## Criterios de Sucesso

- Para uma `accessKey` ja registrada, o use case retorna falha com "Nota ja registrada" **sem** chamar `extractionGateway.extract`.
- Para uma `accessKey` nova, o use case chama o gateway e retorna o resultado (sucesso ou falha) propagado corretamente.
- Os 5 cenarios de teste do checklist (sucesso, duplicidade, bloqueio, timeout, erro de gateway) passam de forma independente.

## Testes da Tarefa

- [ ] Testes de unidade cobrindo sucesso, duplicidade, bloqueio, timeout e erro de gateway, com `NfceExtractionGateway` mockado como lambda (padrao `UseCasesTest.kt`).
- [ ] Testes de integracao: nao aplicavel nesta tarefa (feita na Tarefa 7.0, via `MockMvc`).
- [ ] Testes E2E: nao aplicavel nesta tarefa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/usecase/ExtractPurchaseInvoiceUseCase.kt` (novo)
- `src/test/kotlin/br/com/nomar/controlai/domain/usecase/UseCasesTest.kt` (estendido com os novos cenarios, ou novo arquivo de teste dedicado seguindo o mesmo padrao)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/entity/value_objects/AccessKey.kt` (reaproveitado)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/entrypoint/database/repository/PurchaseInvoiceRepository.kt` (reaproveitado, `countByAccessKey`)
