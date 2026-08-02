# Tarefa 6.0: Service Function + Tipo TypeScript no Frontend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar a funcao de servico `getInvoiceSuggestions()` e a interface TypeScript `SuggestionResponse` no arquivo `purchaseService.ts` do projeto `controlai-frontend`. Esta tarefa pode ser executada em paralelo com as tarefas de backend.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar interface `SuggestionResponse` com todos os campos definidos na techspec
- Criar funcao `getInvoiceSuggestions(invoiceId: number): Promise<SuggestionResponse[]>`
- Usar `httpRequest<T>` existente (padrao do projeto via Capacitor HTTP ou fetch)
- Endpoint: `GET /purchases/invoices/${invoiceId}/suggestions`
- Tratar erro 404 adequadamente
</requirements>

## Subtarefas

- [ ] 6.1 Adicionar interface `SuggestionResponse` em `purchaseService.ts`
- [ ] 6.2 Criar funcao `getInvoiceSuggestions()` usando `httpRequest`
- [ ] 6.3 Verificar typecheck (`npx tsc --noEmit`)
- [ ] 6.4 Verificar build (`npm run build` ou equivalente)

## Detalhes de Implementacao

Consultar a secao "Modelos de Dados" (tipo TypeScript) da `techspec.md` para a interface completa.

**Campos da interface:**
- `id: number`
- `cardLastDigits: string | null`
- `purchasedAt: string`
- `amount: number`
- `merchantName: string`
- `numberOfInstallments: number`
- `category: string | null`
- `categoryId: number | null`
- `origin: string | null`
- `originType: string | null`
- `timeDeltaMinutes: number`

## Criterios de Sucesso

- Interface e funcao de servico criadas seguindo padrao existente em `purchaseService.ts`
- TypeScript compila sem erros
- Build passa sem erros

## Testes da Tarefa

- [ ] Typecheck passa (`npx tsc --noEmit`)
- [ ] Build passa sem erros

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/purchaseService.ts` — arquivo a ser modificado (controlai-frontend)
