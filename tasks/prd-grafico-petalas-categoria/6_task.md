# Tarefa 6.0: `CategoryDetailSheet` — bottom sheet de detalhe da categoria

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `src/components/CategoryDetailSheet.tsx`: bottom sheet (`IonModal` com `breakpoints={[0, 0.75, 1]}`, `initialBreakpoint={0.75}`, padrao do `CategoryBottomSheet` existente — que e um seletor de categoria e **nao sera tocado**). Contem: cabecalho (categoria, "N compras · Mes Ano", estouro em R$, fechar), card gasto vs. limite com barra, abas de ordenacao (Recentes | Maiores), filtro por cartao e lista de compras. Integrar a `ByCategoryPage`: linha da lista abre o sheet. Depende das Tarefas 2.0 e 5.0.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — `IonModal` sheet com gesto de arrastar, dark theme, tap targets ≥ 44pt nas abas e filtro.
- `vercel-react-best-practices` — busca refeita por mudanca de `sort`/`paymentMethodId` via `useEffect` com dependencias corretas; cache local de `listPaymentMethods()`.
- `clean-code` — componente com responsabilidade unica; formatacoes nomeadas.
</skills>

<requirements>
- PRD 4.1: cabecalho com nome da categoria, "N compras · Mes Ano" e botao de fechar.
- PRD 4.2: quando `actual > expected`, exibir "Estourou em R$ X" (`actual - expected`, formatado via `utils/currency`).
- PRD 4.3: card com gasto e limite lado a lado, percentual e barra de progresso, estilo de alerta acima de 100% — valores vindos do `BudgetItemSummary` (consistencia com a tela).
- PRD 4.4: item de compra com descricao/estabelecimento, cartao com final (ex.: "Nubank Ramon · **** 4521") ou meio de pagamento (ex.: "Pix recorrente"), valor e data/hora. Nome do metodo via `listPaymentMethods()` (join client-side, cacheado no estado do sheet).
- PRD 4.5: ordenacoes "Recentes" (padrao) e "Maiores" — refetch com `sort`.
- PRD 4.6: filtro "Cartao" — refetch com `paymentMethodId`; estado ativo claramente indicado.
- PRD 4.7: dispensavel por botao de fechar e gesto de arrastar para baixo (`breakpoints` com `0`).
- PRD 7.2: filtro sem resultados exibe "nenhuma compra" mantendo o filtro visivel para ajuste.
- Acessibilidade: sheet anuncia o titulo ao abrir (`aria-labelledby` no padrao `ion-modal`) e e dispensavel por leitor de tela.
</requirements>

## Subtarefas

- [x] 6.1 Criar `CategoryDetailSheet.tsx` + `.css` com props conforme techspec (`isOpen`, `month`, `item: BudgetItemSummary | null`, `onDismiss`) e estado interno `sort` / `paymentMethodId`.
- [x] 6.2 Implementar cabecalho (categoria, contagem de compras, periodo, estouro em R$, fechar) e card gasto/limite com barra e alerta.
- [x] 6.3 Implementar lista de compras via `getNotifications(month, page, size, categoryId, null, paymentMethodId, sort)` com exibicao de cartao/PIX por compra.
- [x] 6.4 Implementar abas de ordenacao (Recentes | Maiores) e filtro por cartao com refetch e estado "nenhuma compra".
- [x] 6.5 Integrar a `ByCategoryPage`: `onCategoryClick` abre o sheet com o `BudgetItemSummary` da categoria e o mes selecionado.
- [x] 6.6 Testes de unidade (Vitest, mocks de `purchaseService`/`paymentMethodService`): cabecalho ("N compras · Mes Ano"; "Estourou em R$ X" so quando estourou); card com estilo de alerta; troca de ordenacao refaz busca com `sort`; filtro refaz busca com `paymentMethodId`; estado "nenhuma compra" com filtro visivel; exibicao de cartao com final e de PIX; dismiss por botao.
- [x] 6.7 Teste de integracao na `ByCategoryPage`: clique em linha abre o sheet com os dados da categoria.

## Detalhes de Implementacao

Ver techspec.md, secoes "Interfaces Principais" (`CategoryDetailSheetProps`), "Fluxo de dados", "Modelos de Dados" (exibicao do cartao) e "Riscos Conhecidos" (join client-side de metodos de pagamento; gesto do sheet em iOS/WebKit).

## Criterios de Sucesso

- Funil completo em 2 toques: linha da categoria → sheet com compras.
- Valores de gasto/limite/estouro identicos aos da lista (mesma fonte `BudgetSummary`).
- Ordenacoes e filtro corretos com paginacao (feitos no backend).
- Sheet dispensavel por botao e gesto; acessivel por leitor de tela.
- Testes do componente e da integracao verdes.

## Testes da Tarefa

- [x] Testes de unidade
- [x] Testes de integracao (`ByCategoryPage` abre o sheet)
- [ ] Testes E2E (nao aplicavel nesta tarefa — smoke na Tarefa 9.0)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/components/CategoryDetailSheet.tsx|.css|.test.tsx` (novos)
- `controlai-frontend/src/pages/ByCategoryPage.tsx` (integracao)
- `controlai-frontend/src/services/purchaseService.ts` (Tarefa 2.0)
- `controlai-frontend/src/services/paymentMethodService.ts`, `src/types/paymentMethod.ts` (consultados)
- `controlai-frontend/src/components/CategoryBottomSheet.tsx` (referencia de padrao, NAO alterar)
