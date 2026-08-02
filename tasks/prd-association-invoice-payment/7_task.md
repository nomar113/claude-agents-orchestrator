# Tarefa 7.0: AssociatePage — Busca Manual

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar nova pagina `AssociatePage.tsx` para busca manual de payment notifications. A pagina exibe resumo do invoice no topo, campos de filtro por valor e data, lista de notifications encontradas, e confirmacao ao selecionar.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o padrao: implementar, testar, commitar
</skills>

<requirements>
- Rota: `/purchase/invoice/:id/associate`
- Recebe dados do invoice via `location.state` (fallback: fetch API)
- Exibe hero com resumo do invoice (merchant, valor, data) — mesmo padrao da SuggestionsPage
- Campos de filtro: valor (input numerico) e data (date picker ou range)
- Botao "Buscar" chama `searchNotifications()` do service
- Lista de notifications em cards (reusar padrao `.sg-card`)
- Ao selecionar notification: abrir confirmacao (ConfirmDialog ou inline)
- Ao confirmar: chamar `associateInvoice()`, redirecionar para PurchaseDetail
- Botao "Pular" navega direto para PurchaseDetail sem associar
- Header com botao voltar
- Loading states e empty state
</requirements>

## Subtarefas

- [x] 7.1 Criar `AssociatePage.tsx` com estrutura base (IonPage, header, hero do invoice)
- [x] 7.2 Implementar campos de filtro: valor (input) e data (date inputs)
- [x] 7.3 Implementar busca chamando `searchNotifications()` com loading state
- [x] 7.4 Renderizar lista de notifications em cards com dados relevantes
- [x] 7.5 Implementar selecao + confirmacao de associacao
- [x] 7.6 Implementar botao "Pular" que navega para PurchaseDetail
- [x] 7.7 Implementar empty state quando busca nao retorna resultados
- [x] 7.8 Criar `AssociatePage.css` com estilos (seguir padrao `.sg-*`)
- [x] 7.9 Atualizar `App.tsx` para usar `AssociatePage` na rota (substituir placeholder da task 5)

## Detalhes de Implementacao

Consultar a secao **Visao Geral dos Componentes > Frontend** da `techspec.md`. Usar `SuggestionsPage.tsx` como referencia de estrutura (hero, cards, loading, empty state). Reusar `ConfirmDialog.tsx` para confirmacao. Seguir convencoes CSS: prefixo `.ap-` para estilos especificos da pagina.

## Criterios de Sucesso

- Pagina acessivel via rota (nao mais tela preta)
- Hero exibe dados do invoice corretamente
- Filtros funcionam: busca por valor, por data, ou ambos
- Cards exibem dados da notification (merchant, valor, data, cartao)
- Selecao + confirmacao chama API e redireciona
- "Pular" navega para PurchaseDetail
- Empty state quando sem resultados
- Loading state durante busca
- Testes passam

## Testes da Tarefa

- [x] Teste unitario: renderiza hero com dados do invoice
- [x] Teste unitario: busca com filtro de valor chama API corretamente
- [x] Teste unitario: busca com filtro de data chama API corretamente
- [x] Teste unitario: selecao de notification abre confirmacao
- [x] Teste unitario: confirmar chama `associateInvoice`
- [x] Teste unitario: "Pular" navega para PurchaseDetail
- [x] Teste unitario: empty state renderiza quando sem resultados

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/AssociatePage.tsx` (criar)
- `src/pages/AssociatePage.css` (criar)
- `src/App.tsx` (modificar — atualizar rota)
- `src/pages/SuggestionsPage.tsx` (referencia de estrutura)
- `src/components/ConfirmDialog.tsx` (reusar)
- `src/services/purchaseService.ts` (importar `searchNotifications`, `associateInvoice`)
