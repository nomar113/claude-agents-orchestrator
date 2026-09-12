# Tarefa 6.0: Layout responsivo — Faturas e compras

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Ajustar o CSS/grid das telas de faturas e detalhamento de compras — `PurchaseDetail`, `ByCategoryPage`, `SuggestionsPage`, `AssociatePage`, `InvoiceAssociatedSection`, `InvoiceSuggestionsSection` — para telas largas, sem alterar lógica de negócio, chamadas de serviço ou estruturas de dados.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se ao uso de `IonGrid`/breakpoints para o detalhamento de fatura por compra e por período de fechamento.
- `frontend-design` — aplica-se à qualidade visual do layout desktop dessas telas.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 2`: RF-4 (faturas, detalhamento por compra e por período de fechamento) e RF-5 (registrar, editar e cancelar compras, incluindo parceladas).
- Tech Spec `Sequenciamento de Desenvolvimento`: faturas/compras é a segunda leva de telas responsivas.
- Não alterar `services/purchaseService.ts`, `services/installmentService.ts` ou contratos de API.
</requirements>

## Subtarefas

- [x] 6.1 Ajustar `PurchaseDetail.tsx`/`.css` para exibir detalhamento de compra (incluindo parcelas — `InstallmentBadge`) de forma legível em telas largas.
- [x] 6.2 Ajustar `ByCategoryPage.tsx`/`.css` para um layout em grade/colunas em telas largas.
- [x] 6.3 Ajustar `SuggestionsPage.tsx` e `AssociatePage.tsx` (fluxo de sugestões/associação de nota fiscal a compras) para telas largas.
- [x] 6.4 Confirmar que o layout mobile original permanece inalterado abaixo do breakpoint.

**Nota de implementação (`PurchaseDetail.tsx`):** as seções de conteúdo (info/nota fiscal + itens/parcelas de um lado, resumo/mapa/pagamento associado do outro) foram reagrupadas em JSX puro — sem alterar handlers, estado ou chamadas de serviço — dentro de um grid `.pd-detail-grid` (`.pd-detail-main` / `.pd-detail-side`), opt-in via `@media (min-width: 992px)` em `PurchaseDetail.css`. Abaixo de 992px essas classes não têm nenhuma regra, então o fluxo continua idêntico (uma seção por linha). A seção "Pagamento associado / Associar pagamento" (antes renderizada após os modais/`budgetWarning`) foi movida para dentro de `.pd-detail-side`, ao lado do Resumo — reordenação segura porque os blocos entre os dois pontos (`CategoryBottomSheet`, `PaymentMethodSelector`, `budgetWarning`) só renderizam para `type === 'notification'`, nunca para `type === 'invoice'`.

**Nota de implementação (`.ctrl-wrapper--wide`):** conforme documentado na Tarefa 5.0, a classe `.ctrl-wrapper` é global (compartilhada por várias páginas) e o tratamento de largura/centralização é opt-in via `.ctrl-wrapper--wide` (definida em `Tab1.css`). Esta tarefa adicionou essa classe também em `PurchaseDetail.tsx`, `SuggestionsPage.tsx` e `AssociatePage.tsx` — sem tocar `Tab2`/`Tab3`/`CategoriesPage`, que continuam sem o tratamento largo. `ByCategoryPage.css`/`.bcp-wrapper` é importado só por essa página, então o `max-width`/centralização foi aplicado diretamente na classe existente, sem precisar de uma variante opt-in.

**Nota de backlog (`budgetWarning`, fora do escopo desta tarefa):** o review da Tarefa 6.0 identificou um risco pré-existente (não introduzido por esta tarefa, e a posição do bloco no JSX não foi alterada): `budgetWarning` em `PurchaseDetail.tsx` é renderizado sem gate por `type`. Hoje só é setado no fluxo de notification, mas se o componente não remontar ao navegar de `/purchase/notification/:id` para `/purchase/invoice/:id`, um valor deixado de uma visita anterior poderia sobreviver à troca de `type`. Registrado para avaliação futura.

**Nota de implementação (teste manual visual):** o servidor de dev aponta para a API de produção e exige login (mesma limitação já registrada na Tarefa 5.0), então a verificação visual foi feita com um harness estático (HTML simples servido localmente, importando o CSS real das 4 páginas) em 1280px e 1920px — confirmando o grid dashboard-style de `PurchaseDetail`, `ByCategoryPage` e `SuggestionsPage`/`AssociatePage`. Em 1920px o conteúdo permanece limitado a 1100px de largura (via `.ctrl-wrapper--wide`), como esperado. O comportamento mobile (<992px) não foi capturado em screenshot (limitação da ferramenta de resize do navegador nesta sessão), mas está garantido por construção: todas as regras novas vivem dentro de `@media (min-width: 992px)`, e as novas divs wrapper (`pd-detail-grid`/`-main`/`-side`, `bcp-content-grid`) não têm nenhum estilo fora desses blocos — abaixo do breakpoint elas são `<div>`s neutras de bloco, sem efeito no layout.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Páginas existentes") e `Riscos Conhecidos`.

## Critérios de Sucesso

- Faturas e detalhamento de compra são legíveis e bem distribuídos em telas ≥ 992px.
- Fluxo de sugestões/associação de NFC-e funciona sem regressão em desktop.
- Nenhuma regressão no layout/comportamento mobile.

## Testes da Tarefa

- [x] Testes de unidade/RTL existentes (`PurchaseDetail.test.tsx`, `ByCategoryPage.test.tsx`, `SuggestionsPage.test.tsx`, `AssociatePage.test.tsx`) continuam passando. (`npx vitest run` → 620/620, suíte completa do projeto.)
- [x] Novo teste verificando presença/acessibilidade dos elementos principais dessas telas em viewport desktop simulado. (7 novos testes: 4 em `PurchaseDetail.test.tsx` — notification e invoice —, 1 em `ByCategoryPage.test.tsx`, 1 em `SuggestionsPage.test.tsx`, 1 em `AssociatePage.test.tsx`, todos verificando os hooks estruturais/CSS do grid, seguindo o mesmo padrão da Tarefa 5.0.)
- [x] Teste manual visual do fluxo: abrir fatura → detalhe de compra → associar/sugestão, em desktop. (Harness estático com o CSS real, 1280px e 1920px — ver nota de implementação acima.)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/PurchaseDetail.tsx`, `.css`
- `controlai-frontend/src/pages/ByCategoryPage.tsx`, `.css`
- `controlai-frontend/src/pages/SuggestionsPage.tsx`, `AssociatePage.tsx`
- `controlai-frontend/src/pages/InvoiceAssociatedSection.tsx`, `InvoiceSuggestionsSection.tsx`
- Depende de: Tarefa 3.0 (shell de navegação)
