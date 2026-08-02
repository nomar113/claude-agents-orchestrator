# Tarefa 6.0: Query UNION da Listagem

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar a query UNION do `PurchaseRepository` para incluir o campo `cancelled_at` na projection, permitindo que o frontend saiba quais compras estao canceladas.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de native queries e projections do projeto.
</skills>

<requirements>
- Adicionar `pn.cancelled_at AS cancelledAt` no SELECT da parte payment_notifications da UNION
- Adicionar `pi.cancelled_at AS cancelledAt` no SELECT da parte purchase_invoices da UNION
- NAO filtrar canceladas da listagem (elas devem aparecer, apenas com estilo diferente)
- Atualizar `PurchaseProjection` se ainda nao foi feito na Task 2
- Atualizar response DTO da listagem para incluir `cancelledAt`
</requirements>

## Subtarefas

- [ ] 6.1 Atualizar query UNION em `PurchaseRepository.kt` para incluir `cancelled_at` em ambos os SELECTs
- [ ] 6.2 Garantir que `PurchaseProjection` tem getter para `cancelledAt`
- [ ] 6.3 Atualizar o response DTO da listagem de purchases para expor `cancelledAt`
- [ ] 6.4 Verificar que a query continua retornando canceladas (sem WHERE cancelled_at IS NULL)

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > PurchaseRepository"

A query UNION atual seleciona campos de ambas as tabelas. Adicionar `cancelled_at` como mais uma coluna no SELECT de cada lado do UNION.

## Criterios de Sucesso

- Endpoint GET /purchases retorna campo `cancelledAt` para cada item
- Compras canceladas aparecem na listagem (nao sao filtradas)
- Compras ativas retornam `cancelledAt: null`
- Compras canceladas retornam `cancelledAt: "2026-05-16T..."` (ISO 8601)
- Ordenacao cronologica mantida (RF-12)

## Testes da Tarefa

- [ ] Testes de integracao: criar compras ativas e canceladas, verificar que ambas aparecem na listagem
- [ ] Testes de integracao: verificar que `cancelledAt` e retornado corretamente no JSON de response
- [ ] Testes de integracao: verificar ordenacao cronologica (canceladas nao vao para o final)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/.../purchases_invoices/entrypoint/database/repository/PurchaseRepository.kt`
- `src/main/kotlin/.../purchases_invoices/entrypoint/rest/response/` (response DTOs de listagem)
