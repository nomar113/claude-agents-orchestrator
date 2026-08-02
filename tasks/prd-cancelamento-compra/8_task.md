# Tarefa 8.0: Service Frontend (API)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar metodos de cancelamento no service layer do frontend e atualizar os tipos TypeScript para incluir `cancelledAt`.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de services e tipos do projeto frontend.
</skills>

<requirements>
- Adicionar `cancelNotification(id: number): Promise<void>` em `purchaseService.ts`
- Adicionar `cancelInvoice(id: number): Promise<void>` em `purchaseService.ts`
- Atualizar tipo `PaymentNotification` para incluir `cancelledAt: string | null`
- Atualizar tipo de resposta da listagem de purchases para incluir `cancelledAt`
- Usar `httpClient.patch()` para as chamadas
</requirements>

## Subtarefas

- [ ] 8.1 Atualizar interface/tipo `PaymentNotification` com campo `cancelledAt`
- [ ] 8.2 Atualizar tipo de resposta de purchase invoice com campo `cancelledAt`
- [ ] 8.3 Adicionar funcao `cancelNotification(id)` no purchaseService
- [ ] 8.4 Adicionar funcao `cancelInvoice(id)` no purchaseService
- [ ] 8.5 Verificar que o httpClient suporta PATCH (adicionar se necessario)

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Interfaces Principais > Frontend - Service"

Seguir padrao identico aos metodos existentes no purchaseService (ex: `deleteNotification`).

## Criterios de Sucesso

- Funcoes de cancelamento compilam sem erros TypeScript
- Chamadas apontam para os endpoints corretos (`PATCH /payments/notifications/{id}/cancel`)
- Tipos atualizados refletem campo `cancelledAt` nullable

## Testes da Tarefa

- [ ] Verificar compilacao TypeScript sem erros (`tsc --noEmit` ou build)
- [ ] Teste manual: chamar cancelNotification via console do browser e verificar response 200

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/purchaseService.ts`
- `src/services/httpClient.ts`
- `src/types/` (interfaces TypeScript)
