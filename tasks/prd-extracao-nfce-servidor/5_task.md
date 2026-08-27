# Tarefa 5.0: Gateway/Provider Kotlin: integracao HTTP com o microservico

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar, no backend Kotlin (`controlai`), a interface `NfceExtractionGateway` (no dominio) e sua implementacao `NfceExtractionHttpProvider` (na camada de aplicacao), que chama `POST /extract` do `nfce-extraction-service` (Tarefa 3.0) via HTTP sincrono e traduz o `ExtractionResult` do Node para `Result<ExtractedPurchaseInvoice>`/excecoes de dominio, seguindo o padrao hexagonal ja usado no projeto (`fun interface` + `*Provider`).

<skills>
### Conformidade com Skills Padroes

Aplicar a skill `kotlin-springboot` (boas praticas de Spring Boot + Kotlin) na implementacao do provider, incluindo uso idiomatico de cliente HTTP do Spring Web e tratamento de erros com `Result`/`runCatching`, conforme tambem exigido pelo `CLAUDE.md` do backend (arquitetura hexagonal, `fun interface` para gateways, `*Provider` para implementacoes).
</skills>

<requirements>
- Definir `NfceExtractionGateway` como `fun interface` em `domain/purchases_invoices/gateway/`, com a assinatura `fun extract(invoiceUrl: InvoiceUrl): Result<ExtractedPurchaseInvoice>` (Tech Spec, secao "Interfaces Principais").
- Implementar `NfceExtractionHttpProvider` em `application/purchases_invoices/application/`, usando o cliente HTTP ja disponivel via Spring Web (sem novas dependencias no `build.gradle.kts`, conforme Tech Spec).
- O provider deve enviar o header de autenticacao interno esperado pelo `nfce-extraction-service` (`X-Internal-Key`), lendo o segredo de configuracao (`application.yml`/variavel de ambiente).
- Mapear cada `status` do `ExtractionResult` (`READY`, `BLOCKED`, `TIMEOUT`, `NAVIGATION_ERROR`) para o resultado/excecao de dominio correspondente, preservando a mensagem de bloqueio quando houver.
- Tratar falha de rede/servico indisponivel (`nfce-extraction-service` fora do ar) como equivalente a `NAVIGATION_ERROR`.
- Definir/reaproveitar o modelo `ExtractedPurchaseInvoice` com os campos descritos na Tech Spec (secao "Modelos de Dados").
- Log SLF4J (padrao existente) a cada chamada: resultado (sucesso/bloqueio/timeout/erro) e duracao, sem logar HTML ou dados pessoais da nota.
</requirements>

## Subtarefas

- [ ] 5.1 Criar `ExtractedPurchaseInvoice` (e tipos aninhados de item/pagamento) em `domain/purchases_invoices/entity/` (ou pacote equivalente ao padrao do dominio).
- [ ] 5.2 Criar a `fun interface NfceExtractionGateway` em `domain/purchases_invoices/gateway/`.
- [ ] 5.3 Implementar `NfceExtractionHttpProvider` em `application/purchases_invoices/application/`, com chamada HTTP sincrona ao `nfce-extraction-service`.
- [ ] 5.4 Implementar o mapeamento de `status` do `ExtractionResult` para `Result`/excecoes de dominio (sucesso, bloqueio, timeout, erro de navegacao/servico indisponivel).
- [ ] 5.5 Adicionar configuracao (`application.yml` + variavel de ambiente) para URL base do servico e segredo `X-Internal-Key`.
- [ ] 5.6 Adicionar log SLF4J por chamada (resultado + duracao, sem dados sensiveis).
- [ ] 5.7 Escrever testes unitarios do `NfceExtractionHttpProvider` mockando a chamada HTTP (ex: `MockRestServiceServer`/`WireMock`, conforme o que ja for usado no projeto para testar clientes HTTP), cobrindo os 4 estados + falha de rede.

## Detalhes de Implementacao

Ver Tech Spec, secoes "Interfaces Principais" (assinatura de `NfceExtractionGateway`), "Modelos de Dados" (`ExtractedPurchaseInvoice`), "Pontos de Integracao" (Kotlin <-> Node, autenticacao via header compartilhado) e "Monitoramento e Observabilidade" (log SLF4J por chamada). Referencia de padrao: `SavePurchaseInvoiceProvider.kt`.

## Criterios de Sucesso

- `NfceExtractionHttpProvider.extract(...)` retorna sucesso com os dados extraidos quando o `nfce-extraction-service` responde `READY`.
- Retorna falha/excecao de dominio distinta para cada um dos casos `BLOCKED`, `TIMEOUT`, `NAVIGATION_ERROR` e falha de rede, de forma que a Tarefa 6.0 consiga diferencia-los.
- Nenhuma chamada ao provider loga HTML ou dados pessoais da nota.

## Testes da Tarefa

- [ ] Testes de unidade do `NfceExtractionHttpProvider` cobrindo sucesso, bloqueio, timeout, erro de navegacao e falha de rede/servico indisponivel.
- [ ] Testes de integracao: nao aplicavel nesta tarefa (a costura completa controller -> use case -> gateway e testada na Tarefa 7.0 com gateway fake).
- [ ] Testes E2E: nao aplicavel nesta tarefa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/gateway/NfceExtractionGateway.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/NfceExtractionHttpProvider.kt` (novo)
- `src/main/kotlin/br/com/nomar/controlai/domain/purchases_invoices/entity/ExtractedPurchaseInvoice.kt` (novo, nome de arquivo/pacote a confirmar conforme convencao local)
- `src/test/kotlin/br/com/nomar/controlai/application/purchases_invoices/NfceExtractionHttpProviderTest.kt` (novo)
- `src/main/resources/application.yml` (nova configuracao de URL/segredo)
- `src/main/kotlin/br/com/nomar/controlai/application/purchases_invoices/application/SavePurchaseInvoiceProvider.kt` (referencia de padrao)
