# Tarefa 6.0: Frontend — installmentService + tipos TypeScript

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o servico HTTP e os tipos TypeScript para comunicacao com a API de parcelas. Este servico sera usado por todas as tarefas frontend subsequentes.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Criar `src/types/installment.ts` com interfaces: `Installment`, `MonthlyProjection`, `ActiveInstallment`, `UpdateInstallmentRequest`
- Criar `src/services/installmentService.ts` com funcoes: `listInstallments(parentId)`, `getProjection()`, `getActiveInstallments()`, `cancelFutureInstallments(parentId)`, `updateInstallment(id, data)`
- Seguir o padrao existente de `categoryService.ts` e `paymentMethodService.ts` (helper `httpRequest` com CapacitorHttp/fetch)
</requirements>

## Subtarefas

- [ ] 6.1 Criar `src/types/installment.ts` com todas as interfaces
- [ ] 6.2 Criar `src/services/installmentService.ts` com todas as funcoes
- [ ] 6.3 Testes unitarios do servico

## Detalhes de Implementacao

Consultar secao "Modelos de Dados" (tipos TypeScript) e "Endpoints de API" da `techspec.md`.

Seguir exatamente o padrao de `categoryService.ts`:
- Helper `httpRequest` com suporte a CapacitorHttp (nativo) e fetch (web)
- Tratamento de erros com throw customizado para status codes especificos

## Criterios de Sucesso

- Todas as funcoes do servico estao implementadas e tipadas
- Testes cobrem todos os endpoints (mock de fetch)
- Build do frontend passa sem erros

## Testes da Tarefa

- [ ] Testes de unidade: `listInstallments` — mock GET com parentId, verifica retorno tipado
- [ ] Testes de unidade: `getProjection` — mock GET, verifica array de MonthlyProjection
- [ ] Testes de unidade: `cancelFutureInstallments` — mock DELETE, verifica chamada correta
- [ ] Testes de unidade: `updateInstallment` — mock PATCH, verifica body e retorno

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/types/installment.ts` (novo)
- `src/services/installmentService.ts` (novo)
- `src/services/installmentService.test.ts` (novo)
- `src/services/categoryService.ts` (referencia de padrao)
