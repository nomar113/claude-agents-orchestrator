# Tarefa 7.0: Frontend — Componente InvoiceAssociatedSection

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `InvoiceAssociatedSection.tsx`, que exibe o card verde com os dados da NF já vinculada à notificação e um link para o detalhe completo da invoice. Pode ser desenvolvido com mocks. Depende da Tarefa 5.0 (tipos).

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — componente apresentacional puro; sem lógica de negócio; props bem tipadas.
- `ionic-design` — usar componentes Ionic para o card e o link de navegação; estilo verde conforme design.
</skills>

<requirements>
- Criar `InvoiceAssociatedSection.tsx` em `src/pages/` (ou pasta de componentes do projeto).
- Props:
  - `invoice: AssociatedInvoiceSummary`
- Exibir: razão social, CNPJ, badge/label "Associada" (confirmação visual verde), quantidade de itens, data de emissão e total da NF (RF-08).
- Exibir link/botão **"Ver detalhes da nota fiscal"** que navega para `/purchase/invoice/{invoice.id}` (RF-09).
- Estilo: borda e label verde, conforme artboard "Detalhe — Notificação / NF Associada" no Paper/ControlAI.
- Componente não renderiza nada (`null`) se `invoice` for `null`.
</requirements>

## Subtarefas

- [ ] 7.1 Criar `InvoiceAssociatedSection.tsx` com as props definidas
- [ ] 7.2 Implementar exibição de razão social, CNPJ, badge "Associada", totalItems, data e total
- [ ] 7.3 Implementar link de navegação para `/purchase/invoice/{id}`
- [ ] 7.4 Adicionar estilos em `PurchaseDetail.css` (card verde, badge)
- [ ] 7.5 Escrever testes unitários do componente
- [ ] 7.6 Verificar que typecheck e build passam sem erros

## Detalhes de Implementacao

Ver `prd.md` — RF-08 e RF-09, e `techspec.md` — seção "Componentes Frontend" (tabela de responsabilidades).

## Criterios de Sucesso

- Componente renderiza todos os campos especificados (RF-08).
- Link "Ver detalhes" aponta para `/purchase/invoice/{invoice.id}` (RF-09).
- Badge/label "Associada" está visualmente destacado em verde.
- Componente retorna `null` quando `invoice` é `null`.
- Testes unitários passam.

## Testes da Tarefa

- [ ] Testes de unidade: `InvoiceAssociatedSection.test.tsx`
  - Renderiza razão social, CNPJ, totalItems, data e total corretamente
  - Badge "Associada" está presente
  - Link navega para `/purchase/invoice/{id}` com o ID correto
  - Retorna null quando invoice é null
- [ ] Testes de integração: não aplicável nesta tarefa
- [ ] Testes E2E: não aplicável nesta tarefa

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/InvoiceAssociatedSection.tsx` — novo
- `src/pages/PurchaseDetail.css` — modificado (estilos do card verde)
- `src/services/purchaseService.ts` — leitura (tipo `AssociatedInvoiceSummary` da tarefa 5.0)
- `src/test/pages/InvoiceAssociatedSection.test.tsx` — novo
- `tasks/prd-notificacao-sugestao-nf/prd.md` — referência (RF-08, RF-09)
- `tasks/prd-notificacao-sugestao-nf/techspec.md` — referência
