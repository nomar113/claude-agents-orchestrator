# Tarefa 5.0: Layout responsivo — Dashboard e Cartões

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Ajustar o CSS/grid das telas de maior prioridade citadas no PRD — Dashboard (`Tab1`) e Cartões/Sub-cartões (`PaymentMethodsPage`, `CardStack`, `PaymentMethodCard`, `PaymentMethodSelector`) — para ocupar bem telas largas, usando os breakpoints do `IonGrid` (`size-lg`, etc.). Nenhuma lógica de negócio, chamada de serviço ou estrutura de dados é alterada: é uma tarefa de apresentação.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se diretamente ao uso de `IonGrid`/`IonRow`/`IonCol` com breakpoints responsivos.
- `frontend-design` — aplica-se à qualidade visual do layout desktop (não é só o mobile redimensionado, conforme PRD).
</skills>

<requirements>
- PRD `Funcionalidades Principais > 2`: RF-3 (cartões e sub-cartões, incluindo compartilhados) e a consideração de UX de layout desenhado para tela larga, não mobile redimensionado.
- Tech Spec `Sequenciamento de Desenvolvimento`: dashboard e cartões são a primeira leva de telas a receber ajuste responsivo.
- Tech Spec `Riscos Conhecidos`: revisar apresentação de `IonModal`/bottom sheets (`CategoryBottomSheet`, `AddItemModal`) usados a partir dessas telas, sem reescrever sua lógica.
- Não alterar `services/`, `context/` ou contratos de API.
</requirements>

## Subtarefas

- [x] 5.1 Ajustar `Tab1.tsx`/`Tab1.css` para um layout em grade em telas largas (ex.: cards de resumo lado a lado em vez de empilhados).
- [x] 5.2 Ajustar `PaymentMethodsPage.tsx`/`.css` para exibir múltiplos cartões/sub-cartões em grade ao invés de lista vertical única em telas largas. (`CardStack.tsx` não é renderizado por nenhuma tela do app hoje — ver nota abaixo.)
- [x] 5.3 Revisar a apresentação de modais/bottom sheets acionados a partir dessas telas (`AddItemModal`, `PaymentMethodSelector`) em viewport desktop, ajustando breakpoint de apresentação se necessário (sem alterar a lógica interna).
- [x] 5.4 Confirmar que o layout mobile original permanece pixel-idêntico abaixo do breakpoint usado nas mudanças.

**Nota de implementação:** `CardStack.tsx` (listado nos Arquivos Relevantes) é código morto — não é importado/renderizado por `Tab1.tsx` nem por nenhuma outra tela atual; o dashboard já foi redesenhado como o orçamento mensal antes desta tarefa. Nenhuma alteração foi feita nele (ajustar um componente não renderizado não teria efeito visível); o componente e o CSS `.ctrl-card-stack` associado ficam como possível limpeza futura, fora do escopo desta tarefa.

**Nota de implementação (`.ctrl-wrapper`):** a classe `.ctrl-wrapper` é compartilhada por 8 telas (`Tab1`, `Tab2`, `Tab3`, `PaymentMethodsPage`, `CategoriesPage`, `PurchaseDetail`, `SuggestionsPage`, `AssociatePage`), e os imports de CSS deste projeto são globais. Para não vazar a largura máxima/centralização desta tarefa para as 6 telas fora de escopo (que a Tech Spec deixa para as Tarefas 6.0/7.0/8.0), a regra de desktop foi aplicada a uma classe nova e opt-in, `.ctrl-wrapper--wide`, usada apenas em `Tab1.tsx` e `PaymentMethodsPage.tsx`. As próximas tarefas de responsividade ficam livres para adotar `.ctrl-wrapper--wide` nas telas que ajustarem, ou definir sua própria abordagem.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Páginas existentes") e `Riscos Conhecidos`.

## Critérios de Sucesso

- Dashboard e tela de cartões usam o espaço horizontal disponível em telas ≥ 992px, sem elementos esticados ou vazios excessivos.
- Nenhuma regressão visual ou funcional no layout mobile (< 992px).
- Nenhum teste de lógica de negócio existente quebra.

## Testes da Tarefa

- [x] Testes de unidade/RTL existentes (`Tab1.test.tsx`, `PaymentMethodsPage.test.tsx`) continuam passando sem alteração de asserções sobre dados/comportamento.
- [x] Novo teste verificando que os elementos principais do dashboard/cartões estão presentes e acessíveis em viewport desktop simulado.
- [x] Teste manual visual em pelo menos duas larguras (ex.: 1280px e 1920px). (Servidor de dev aponta para a API de produção e exige login — verificação feita via harness estático com o CSS real das telas, em 1280px real no browser e 1920px confirmado matematicamente: o wrapper tem `max-width: 1100px`, então nada muda acima de 1100px.)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx`, `Tab1.css`
- `controlai-frontend/src/pages/PaymentMethodsPage.tsx`, `PaymentMethodsPage.css`
- `controlai-frontend/src/components/CardStack.tsx`
- `controlai-frontend/src/components/PaymentMethodCard.tsx`, `PaymentMethodSelector.tsx`
- Depende de: Tarefa 3.0 (shell de navegação já disponível para navegar até essas telas em desktop)
