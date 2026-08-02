# Tarefa 6.0: Frontend — Componente InvoiceSuggestionsSection

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `InvoiceSuggestionsSection.tsx`, que exibe a lista de NFs candidatas com botões "Associar" e "Ignorar". O estado de descarte temporário (`dismissedInvoiceIds`) é gerenciado em memória React (sem persistência no servidor). Pode ser desenvolvido com mocks do service. Depende da Tarefa 5.0 (tipos).

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — componente puro com props bem definidas; estado local com `useState`; sem lógica de negócio acoplada ao componente.
- `ionic-design` — usar componentes Ionic para lista e botões, mantendo aparência nativa; borda âmbar sutil conforme design.
</skills>

<requirements>
- Criar `InvoiceSuggestionsSection.tsx` em `src/pages/` (ou pasta de componentes do projeto).
- Props:
  - `suggestions: InvoiceSuggestionItem[]`
  - `onAssociate: (invoiceId: number) => void`
  - `onDismiss: (invoiceId: number) => void`
- Renderizar cada item com: razão social, CNPJ, quantidade de itens e total da NF (RF-03).
- Cada item deve ter botão "Associar" que chama `onAssociate(id)` e botão "Ignorar" que chama `onDismiss(id)` (RF-04).
- Itens com `id` presente em `dismissedInvoiceIds` não devem ser renderizados.
- Seção não renderiza nada (`null`) se `suggestions` está vazio ou todos foram descartados (RF-07).
- Estilo: borda âmbar sutil, conforme design (artboard "Detalhe — Notificação / Sugestão de NF" no Paper/ControlAI).
</requirements>

## Subtarefas

- [ ] 6.1 Criar `InvoiceSuggestionsSection.tsx` com as props definidas
- [ ] 6.2 Implementar listagem de itens com razão social, CNPJ, totalItems e total
- [ ] 6.3 Implementar botões "Associar" e "Ignorar" com callbacks corretos
- [ ] 6.4 Implementar lógica de descarte temporário (itens ignorados não aparecem)
- [ ] 6.5 Adicionar estilos em `PurchaseDetail.css` (borda âmbar, layout da seção)
- [ ] 6.6 Escrever testes unitários do componente
- [ ] 6.7 Verificar que typecheck e build passam sem erros

## Detalhes de Implementacao

Ver `techspec.md` — seção "Decisões Principais" (`dismissedInvoiceIds: Set<number>` em estado React, sessão apenas) e `prd.md` — RF-03, RF-04, RF-06, RF-07.

O estado `dismissedInvoiceIds` pode ficar no componente pai (`PurchaseDetail`) e ser passado como prop, ou internamente, conforme a estrutura do projeto.

## Criterios de Sucesso

- Componente renderiza todos os candidatos não descartados.
- `onAssociate` é chamado com o `id` correto ao clicar "Associar".
- `onDismiss` é chamado com o `id` correto ao clicar "Ignorar".
- Item ignorado não aparece na mesma sessão.
- Componente retorna `null` quando lista está vazia ou todos foram ignorados.
- Testes unitários passam.

## Testes da Tarefa

- [ ] Testes de unidade: `InvoiceSuggestionsSection.test.tsx`
  - Renderiza corretamente os campos de cada sugestão
  - Chama `onAssociate` com ID correto ao clicar "Associar"
  - Chama `onDismiss` com ID correto ao clicar "Ignorar"
  - Não renderiza item após ser ignorado
  - Retorna null quando lista está vazia
- [ ] Testes de integração: não aplicável nesta tarefa
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/InvoiceSuggestionsSection.tsx` — novo
- `src/pages/PurchaseDetail.css` — modificado (estilos da seção de sugestão)
- `src/services/purchaseService.ts` — leitura (tipos da tarefa 5.0)
- `src/test/pages/InvoiceSuggestionsSection.test.tsx` — novo
- `tasks/prd-notificacao-sugestao-nf/prd.md` — referência (RF-03, RF-04, RF-06, RF-07)
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência
