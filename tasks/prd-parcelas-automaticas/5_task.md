# Tarefa 5.0: Backend — InstallmentController (listagem, projecao, cancelamento, edicao)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o `InstallmentController` com endpoints para listar parcelas de uma compra, obter projecao de comprometimento futuro, listar compras parceladas ativas, editar parcela individual e cancelar parcelas futuras.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- `GET /installments?parentId={id}` — listar parcelas de uma compra ordenadas por numero
- `GET /installments/projection` — projecao de comprometimento dos proximos 6 meses
- `GET /installments/active` — listar compras parceladas ativas com info do pai (merchantName, description, category, paymentMethod)
- `PATCH /installments/{id}` — editar valor de uma parcela futura (rejeitar edicao de parcelas passadas)
- `DELETE /installments/future?parentId={id}` — soft delete (set cancelled_at) de parcelas futuras (due_date > hoje)
</requirements>

## Subtarefas

- [ ] 5.1 Criar `InstallmentController` com `GET /installments?parentId={id}`
- [ ] 5.2 Implementar `GET /installments/projection` usando query nativa `getMonthlyProjection`
- [ ] 5.3 Implementar `GET /installments/active` com JOIN em payment_notifications para dados do pai
- [ ] 5.4 Implementar `PATCH /installments/{id}` com validacao de data futura
- [ ] 5.5 Implementar `DELETE /installments/future?parentId={id}` com soft delete
- [ ] 5.6 Testes de integracao para todos os endpoints

## Detalhes de Implementacao

Consultar secao "Endpoints de API" da `techspec.md` para formatos de request/response de cada endpoint.

Para o endpoint `active`, criar uma query nativa ou JPQL que faca JOIN com `payment_notifications` para retornar merchantName, description, categoryName, paymentMethodName junto com os dados de parcela.

Localizacao: `br.com.nomar.controlai.application.installments.entrypoint.rest.InstallmentController`

## Criterios de Sucesso

- Todos os 5 endpoints respondem corretamente
- Projecao retorna totais mensais corretos agrupados por ano/mes
- Cancelamento faz soft delete apenas de parcelas futuras
- Edicao rejeita parcelas com due_date no passado
- Build e testes existentes passam

## Testes da Tarefa

- [ ] Testes de integracao: GET por parentId retorna parcelas ordenadas
- [ ] Testes de integracao: GET projection retorna totais corretos por mes
- [ ] Testes de integracao: DELETE future cancela apenas parcelas futuras, mantem passadas
- [ ] Testes de integracao: PATCH com novo valor atualiza parcela futura
- [ ] Testes de integracao: PATCH em parcela passada retorna 400

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `InstallmentController.kt` (novo)
- `InstallmentRepository.kt` (da tarefa 2 — pode precisar de queries adicionais)
- `InstallmentResponse.kt` (da tarefa 2)
- `MonthlyProjectionResponse.kt` (da tarefa 2)
- `PaymentNotification.kt` (referencia para JOIN)
