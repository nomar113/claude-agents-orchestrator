# Tarefa 4.0: Backend — Padronizacao de DTOs de request/response

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Padronizar todos os DTOs de request/response que trafegam data/hora, removendo conversoes manuais para `String` (`.toString()`) e formatos customizados (`@JsonFormat`) divergentes entre responses. Passam a usar serializacao nativa de `Instant`/`LocalDate` via `jackson-datatype-jsr310`. Requests que recebem `purchasedAt` do cliente passam a exigir string ISO-8601 com offset/zona explicita.

**Depende das Tarefas 2.0 e 3.0** — os DTOs refletem os tipos de entidade ja padronizados (2.0) e os dados corretamente convertidos pelo parser corrigido (3.0).

<skills>
### Conformidade com Skills Padroes

- `clean-code`: elimina duplicacao de logica de formatacao de data espalhada em multiplos DTOs, delegando a serializacao nativa do Jackson.
</skills>

<requirements>
- Todos os campos de timestamp de evento em responses da API devem usar o mesmo formato de serializacao entre si (PRD requisito 4).
- Todos os campos de data de calendario em responses da API devem usar o mesmo formato de serializacao entre si (PRD requisito 5).
- Requests que recebem data/hora do cliente devem ter seu timezone de origem tratado de forma explicita e nao ambigua pelo backend (PRD requisito 6).
</requirements>

## Subtarefas

- [ ] 4.1 `PaymentNotificationResponse`, `PurchaseResponse`, `PurchaseInvoiceDetailResponse`, `AssociateInvoiceResponse`, `ApiKeyResponse`: remover `.toString()` manual e `@JsonFormat` customizado, expor `Instant`/`LocalDate` nativos.
- [ ] 4.2 `ManualPaymentNotificationRequest`, `UpdatePurchasedAtRequest`: `purchasedAt` passa a exigir string ISO-8601 com offset/zona explicita (ex: `2026-08-23T10:00:00-03:00`), deserializado para `Instant`.
- [ ] 4.3 Adicionar log em nivel `WARN` em qualquer endpoint que receba `purchasedAt` sem offset/zona explicita (fallback de compatibilidade para clientes desatualizados), conforme "Monitoramento e Observabilidade" da techspec.md.
- [ ] 4.4 Escrever testes de unidade e integracao (ver secao de Testes).

## Detalhes de Implementacao

Ver secao "Endpoints de API" e "Modelos de Dados" da `techspec.md` para a lista completa de DTOs afetados e o formato de serializacao resultante (`Instant` → ISO-8601 UTC com `Z`; `LocalDate` → `YYYY-MM-DD`).

## Criterios de Sucesso

- Nenhum DTO afetado usa `.toString()` manual ou `@JsonFormat` customizado para data/hora.
- Requests sem offset/zona explicita ainda sao aceitos (fallback), mas geram log `WARN` para deteccao de clientes desatualizados apos o deploy.
- Contrato de API documentado como breaking change coordenada (backend+frontend implantados juntos, ver Tarefa 7.0).

## Testes da Tarefa

- [ ] Testes de unidade: serializacao Jackson para `Instant`/`LocalDate` em todos os DTOs afetados (conforme "Abordagem de Testes" da techspec.md).
- [ ] Testes de integracao: chamada real aos endpoints `POST /api/v0/payment-notifications/manual` e `PATCH .../purchased-at` com payload ISO-8601 com offset, validando persistencia e response corretos; teste do fallback (payload sem offset) validando log `WARN` emitido.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- DTOs: `PaymentNotificationResponse`, `PurchaseResponse`, `PurchaseInvoiceDetailResponse`, `AssociateInvoiceResponse`, `ApiKeyResponse`, `ManualPaymentNotificationRequest`, `UpdatePurchasedAtRequest`
