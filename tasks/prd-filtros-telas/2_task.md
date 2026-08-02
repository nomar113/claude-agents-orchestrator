# Tarefa 2.0: Backend - Filtro por mes, range de datas e paginacao no endpoint de Invoices

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar query params `month`, `startDate`, `endDate`, `page` e `size` ao endpoint `GET /purchases/invoices` para que retorne notas fiscais filtradas por mes ou range de datas customizado, com paginacao. Quando nenhum param de data for enviado, retorna o mes corrente.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-1.4: Alterar o mes deve atualizar total e lista de notas.
- RF-3.1 a RF-3.5: Suporte a range de datas (startDate/endDate).
- Endpoint deve aceitar `month` (YYYY-MM), `startDate` (YYYY-MM-DD), `endDate` (YYYY-MM-DD), `page` (default 0), `size` (default 50).
- Se `month` e `startDate/endDate` ambos enviados, `startDate/endDate` tem precedencia.
- Se nenhum param de data fornecido, usar mes corrente.
- Validar que `startDate` <= `endDate`, retornar 400 se invalido.
- Retornar `Page<PurchaseResponse>` em vez de `List<PurchaseResponse>`.
- Manter query apenas sobre `purchase_invoices` (sem UNION).
</requirements>

## Subtarefas

- [ ] 2.1 Criar nova query no `PurchaseRepository` que filtre invoices por range de datas com `Pageable`.
- [ ] 2.2 Atualizar `PurchaseInvoiceController.listInvoices()` para aceitar `@RequestParam month`, `startDate`, `endDate`, `page`, `size`.
- [ ] 2.3 Implementar logica de resolucao de datas: month → range, ou startDate/endDate direto, ou default mes corrente.
- [ ] 2.4 Adicionar validacao: `startDate` nao pode ser posterior a `endDate` (retornar 400).
- [ ] 2.5 Escrever testes unitarios e de integracao.

## Detalhes de Implementacao

Consultar `techspec.md` secoes:
- "Interfaces Principais" — assinatura do controller com params.
- "Queries SQL" — query de invoices por range.
- "Endpoints de API" — contrato e regras de precedencia.

**Nota:** A query atual em `PurchaseRepository.findAllInvoices()` e native SQL. A nova query tambem sera native SQL com parametros de data adicionados. O `Pageable` do Spring Data pode ser usado com native queries via `@Query` + `countQuery`.

## Criterios de Sucesso

- `GET /purchases/invoices?month=2026-05` retorna apenas invoices de maio/2026.
- `GET /purchases/invoices?startDate=2026-01-15&endDate=2026-02-15` retorna invoices no range.
- `GET /purchases/invoices` (sem params) retorna invoices do mes corrente.
- `GET /purchases/invoices?month=2026-05&startDate=2026-01-01&endDate=2026-06-30` usa startDate/endDate (precedencia).
- `GET /purchases/invoices?startDate=2026-03-01&endDate=2026-01-01` retorna erro 400.
- Resposta inclui campos de paginacao.
- Registros soft-deleted nao aparecem.

## Testes da Tarefa

- [ ] Teste unitario: controller com `month` valido retorna dados filtrados.
- [ ] Teste unitario: controller com `startDate/endDate` retorna range correto.
- [ ] Teste unitario: precedencia de `startDate/endDate` sobre `month`.
- [ ] Teste unitario: sem params usa mes corrente.
- [ ] Teste unitario: `startDate > endDate` retorna 400.
- [ ] Teste unitario: paginacao com `page/size`.
- [ ] Teste de integracao: query filtra corretamente no banco.
- [ ] Teste de integracao: soft delete respeitado.
- [ ] Teste de integracao: ordenacao por `date DESC`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai/src/.../purchases_invoices/entrypoint/rest/PurchaseInvoiceController.kt`
- `/controlai/src/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt`
- `/controlai/src/.../purchases_invoices/entrypoint/database/model/PurchaseInvoiceModel.kt`
- `/controlai/src/.../purchases_invoices/entrypoint/database/model/PurchaseProjection.kt`
