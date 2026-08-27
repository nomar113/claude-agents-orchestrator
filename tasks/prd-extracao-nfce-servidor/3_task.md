# Tarefa 3.0: API HTTP do microservico (POST /extract, GET /health)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Expor a orquestracao da Tarefa 2.0 via HTTP, criando o servidor do `nfce-extraction-service` com os endpoints `POST /extract` (interno, protegido por header compartilhado) e `GET /health` (healthcheck). Este e o contrato que o backend Kotlin vai consumir a partir da Tarefa 5.0.

<skills>
### Conformidade com Skills Padroes

Nao ha skill dedicada a APIs Node/Express no repositorio. Nenhuma skill padrao do orquestrador se aplica diretamente alem das boas praticas gerais de codigo limpo.
</skills>

<requirements>
- `POST /extract`: recebe `{ invoiceUrl: string }`, chama `extractInvoice` (Tarefa 2.0), retorna `ExtractionResult` (`{ status, data?, message? }`) conforme Tech Spec.
- `POST /extract` deve exigir o header `X-Internal-Key` com o valor configurado via variavel de ambiente; requisicoes sem o header correto retornam `401`.
- `POST /extract` **nao** deve ser exposto publicamente — validar via configuracao de bind/porta que o servico so escuta na rede interna (documentar a decisao, a aplicacao efetiva de rede fica a cargo da Tarefa 4.0/infra).
- `GET /health` retorna `200` com um payload minimo (ex: `{ status: "ok" }`) sem exigir autenticacao, para uso do Docker healthcheck.
- Validar o corpo de `POST /extract` (campo `invoiceUrl` obrigatorio e string) e retornar `400` em caso de payload invalido, antes de acionar o Playwright.
- Log estruturado leve por requisicao (esta tarefa apenas prepara os pontos de log; log estruturado completo com `pino` fica na Tarefa 4.0).
</requirements>

## Subtarefas

- [x] 3.1 Escolher e configurar o framework HTTP minimo (Express ou Fastify) em `src/server.ts`.
- [x] 3.2 Implementar o middleware de autenticacao por `X-Internal-Key`, lendo o valor esperado de variavel de ambiente.
- [x] 3.3 Implementar `POST /extract`: validacao de payload, chamada a `extractInvoice`, serializacao da resposta conforme `ExtractionResult`.
- [x] 3.4 Implementar `GET /health`.
- [x] 3.5 Escrever testes de integracao com `supertest` contra o servidor local, usando o servidor de fixtures da Tarefa 2.0 (nunca a SEFAZ real): sucesso, bloqueio, timeout, payload invalido, header ausente/invalido.
- [x] 3.6 Documentar no `README.md` do `nfce-extraction-service` as variaveis de ambiente necessarias (`X_INTERNAL_KEY`, timeout, porta).

## Detalhes de Implementacao

Ver Tech Spec, secao "Endpoints de API" (`POST /extract`, `GET /health`, autenticacao via `X-Internal-Key`) e "Abordagem de Testes" > "Testes de Integracao" (Node): `supertest` contra servidor local com fixtures, nunca a SEFAZ real em CI.

## Criterios de Sucesso

- `POST /extract` com header valido e URL de fixture de sucesso retorna `200` com `status: "READY"` e os dados extraidos.
- `POST /extract` sem header ou com header incorreto retorna `401` e nao aciona o Playwright.
- `POST /extract` com payload invalido (`invoiceUrl` ausente) retorna `400` e nao aciona o Playwright.
- `GET /health` retorna `200` sem exigir autenticacao.

## Testes da Tarefa

- [x] Testes de integracao (`supertest`) cobrindo os cenarios de sucesso, bloqueio, timeout, payload invalido e autenticacao ausente/invalida em `POST /extract`.
- [x] Teste de integracao de `GET /health`.
- [x] Testes E2E: nao aplicavel nesta tarefa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `nfce-extraction-service/src/server.ts` (novo)
- `nfce-extraction-service/src/middleware/internal-auth.ts` (novo)
- `nfce-extraction-service/src/routes/extract.ts`, `health.ts` (novo)
- `nfce-extraction-service/test/server/extract.test.ts`, `health.test.ts` (novo)
- `nfce-extraction-service/README.md` (novo/atualizado)
