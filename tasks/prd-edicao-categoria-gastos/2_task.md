# Tarefa 2.0: Frontend — Service function e tipos

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a funcao de servico `updatePaymentNotificationCategory` no frontend e expandir o tipo `PaymentNotification` em Tab1.tsx para incluir os campos `categoryId` e `category`. Isso prepara a camada de dados para os componentes de UI das tasks seguintes.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Criar funcao `updatePaymentNotificationCategory(id, categoryId)` em `purchaseService.ts`
- A funcao deve fazer `PATCH /payments/notifications/{id}/category` com body `{ categoryId }`
- Aceitar `categoryId: number | null` (null para remover categoria)
- Retornar `PaymentNotificationDetail` completo
- Expandir o tipo `PaymentNotification` em Tab1.tsx com `categoryId: number | null` e `category: string | null`
</requirements>

## Subtarefas

- [ ] 2.1 Adicionar funcao `updatePaymentNotificationCategory` em `purchaseService.ts`
- [ ] 2.2 Expandir tipo `PaymentNotification` em `Tab1.tsx` com campos `categoryId` e `category`
- [ ] 2.3 Escrever testes unitarios da funcao de servico

## Detalhes de Implementacao

Consultar a secao **"Design de Implementacao > Interfaces Principais"** da `techspec.md` para assinaturas das funcoes de servico.

**Padrao de referencia:** A funcao `updatePaymentNotificationDescription` em `purchaseService.ts` serve como modelo exato.

## Criterios de Sucesso

- Funcao `updatePaymentNotificationCategory` exportada e funcional
- Tipo `PaymentNotification` em Tab1.tsx inclui `categoryId` e `category`
- Testes unitarios passam
- Nenhuma regressao na listagem de notifications (Tab1)

## Testes da Tarefa

- [ ] Testes de unidade: funcao faz chamada HTTP correta (metodo, URL, body)
- [ ] Testes de unidade: funcao retorna tipo correto

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Modificar:**
- `src/services/purchaseService.ts` (no projeto controlai-frontend)
- `src/pages/Tab1.tsx` (no projeto controlai-frontend)

**Referencia:**
- `src/services/purchaseService.ts` — funcao `updatePaymentNotificationDescription` como padrao
