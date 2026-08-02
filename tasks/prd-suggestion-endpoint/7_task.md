# Tarefa 7.0: SuggestionsPage + CSS

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a pagina `SuggestionsPage.tsx` e seu arquivo de estilos `SuggestionsPage.css` no projeto `controlai-frontend`. A pagina exibe as sugestoes de associacao retornadas pelo endpoint, com loading skeleton, lista rankeada e estado vazio. Deve seguir fielmente o design de referencia do PRD.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar `SuggestionsPage.tsx` seguindo padrao `IonPage > IonContent > div.ctrl-wrapper`
- Criar `SuggestionsPage.css` com prefixo `sg-` para classes
- Usar `useParams()` para obter `invoiceId` da URL
- Receber dados do invoice via `location.state` (com fallback para API se acesso direto)
- Chamar `getInvoiceSuggestions(invoiceId)` ao montar a pagina
- Exibir skeleton loading enquanto carrega
- Se houver sugestoes: exibir lista conforme design (header com resumo do invoice, section "PAGAMENTOS SUGERIDOS" com badge de contagem, cards com dados, badge "Melhor match" no 1o, borda azul no 1o, delta temporal)
- Se nao houver sugestoes: exibir estado vazio conforme design (ilustracao, titulo, texto explicativo, botao "Associar manualmente")
- Ao tocar em card: navegar passando `location.state` com dados do invoice + notification selecionada (RF21)
- Ao tocar em "Associar manualmente": navegar passando `location.state` com dados do invoice (RF20)
- Botao "Voltar" no header usando `history.goBack()`
- Suporte a dark mode via Ionic CSS palettes
</requirements>

## Subtarefas

- [ ] 7.1 Criar `SuggestionsPage.tsx` com estrutura basica (IonPage, header com back button, resumo do invoice)
- [ ] 7.2 Implementar chamada API e skeleton loading
- [ ] 7.3 Implementar lista de sugestoes com cards (dados, badge "Melhor match", borda azul, delta temporal)
- [ ] 7.4 Implementar estado vazio (ilustracao, titulo, texto, botao)
- [ ] 7.5 Implementar navegacao ao tocar em card (location.state com invoice + notification)
- [ ] 7.6 Implementar link "Associar manualmente" (location.state com invoice)
- [ ] 7.7 Implementar fallback de busca via API quando `location.state` nao tem dados do invoice (RF22)
- [ ] 7.8 Criar `SuggestionsPage.css` com estilos completos e suporte a dark mode
- [ ] 7.9 Verificar typecheck e build

## Detalhes de Implementacao

Consultar as secoes "Design de Referencia" do `prd.md` para os mockups e elementos visuais, e "Arquitetura do Sistema > Frontend" da `techspec.md` para padroes tecnicos.

**Dados passados via `location.state` ao navegar PARA esta tela (RF19):**
- `invoiceId`, `invoiceTotal`, `invoiceDate`, `invoiceMerchantName`

**Dados passados via `location.state` ao navegar DESTA tela para associacao manual (RF20):**
- `invoiceId`, `invoiceTotal`, `invoiceDate`, `invoiceMerchantName`

**Dados passados via `location.state` ao navegar DESTA tela para associacao com sugestao (RF21):**
- `invoiceId`, `invoiceTotal`, `invoiceDate`, `invoiceMerchantName`, `notificationId`, `notificationAmount`, `notificationMerchantName`, `notificationPurchasedAt`, `notificationCardLastDigits`

## Criterios de Sucesso

- Pagina renderiza corretamente nos 3 estados: loading, com sugestoes, sem sugestoes
- Design fiel aos mockups do PRD
- Navegacao funciona corretamente com dados em `location.state`
- Dark mode funciona
- TypeScript compila sem erros

## Testes da Tarefa

- [ ] Typecheck passa (`npx tsc --noEmit`)
- [ ] Build passa sem erros
- [ ] Verificacao visual dos 3 estados (loading, lista, vazio)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/SuggestionsPage.tsx` — novo arquivo (controlai-frontend)
- `src/pages/SuggestionsPage.css` — novo arquivo (controlai-frontend)
- `src/services/purchaseService.ts` — funcao `getInvoiceSuggestions()` (tarefa 6.0)
- `src/pages/PurchaseDetail.tsx` — referencia de padrao de pagina
- `src/pages/PurchaseDetail.css` — referencia de padrao de estilos
- `src/theme/variables.css` — variaveis de tema
- `tasks/prd-suggestion-endpoint/assets/` — mockups de referencia
