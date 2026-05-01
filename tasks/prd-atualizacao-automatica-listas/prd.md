# PRD: Atualizacao Automatica de Listas

## Visao Geral

O ControlAI atualmente nao atualiza as listagens da UI apos operacoes de insert, update ou delete. Quando o usuario insere um gasto manual, edita uma categoria ou exclui uma nota fiscal, a lista correspondente continua exibindo dados desatualizados. O usuario precisa reabrir o app para ver as mudancas refletidas, o que gera friccao e sensacao de que o app nao esta funcionando corretamente.

Esta funcionalidade garante que todas as listagens do app sejam atualizadas automaticamente apos qualquer mutacao de dados, mantendo a posicao de scroll do usuario e proporcionando uma experiencia fluida e confiavel.

## Objetivos

- Eliminar a necessidade de refresh manual ou reabertura do app apos qualquer operacao de dados.
- Todas as telas com listagens devem refletir mudancas imediatamente apos insert, update ou delete.
- Manter a posicao de scroll do usuario apos a atualizacao dos dados.
- Reduzir a zero os relatos de "dados desatualizados" na UI.

## Historias de Usuario

- Como usuario, eu quero que ao inserir um gasto manual na ManualEntryPage e voltar para a Tab1, a lista de compras ja mostre o novo registro, para que eu tenha confianca de que o gasto foi salvo.
- Como usuario, eu quero que ao editar a categoria de uma compra no PurchaseDetail, a listagem da Tab1 reflita a nova categoria sem precisar fazer refresh manual.
- Como usuario, eu quero que ao excluir uma nota fiscal na Tab2, o item desapareca da lista imediatamente e os totais sejam recalculados.
- Como usuario, eu quero que ao criar ou editar um orcamento na BudgetPage, os valores e cards de resumo atualizem automaticamente.
- Como usuario, eu quero que ao adicionar ou editar um metodo de pagamento na PaymentMethodsPage, a lista e os totais reflitam a mudanca.
- Como usuario, eu quero que ao criar ou editar uma categoria na CategoriesPage, a lista atualize sem precisar sair e voltar.
- Como usuario, eu quero que a posicao de scroll seja mantida apos qualquer atualizacao, para nao perder o contexto de onde eu estava navegando.

## Funcionalidades Principais

### F1. Atualizacao da Tab1 (Inicio)

A tela principal exibe notificacoes de pagamento, resumo de cartoes, projecao de parcelas e lista de compras. Apos qualquer mutacao que afete esses dados, a Tab1 deve refletir as mudancas ao retornar a ela.

**Requisitos funcionais:**

1. Ao retornar a Tab1 apos insert/update/delete em qualquer outra tela, os dados de notificacoes, cartoes, projecao e compras devem ser recarregados.
2. A posicao de scroll deve ser mantida ao atualizar os dados.
3. Nao deve exibir skeleton/loading completo ao recarregar — os dados existentes devem permanecer visiveis durante o refresh.

### F2. Atualizacao da Tab2 (Notas Fiscais)

A tela lista purchase invoices com totais agregados.

**Requisitos funcionais:**

4. Ao retornar a Tab2 apos insert/update/delete de uma nota fiscal, a lista deve ser recarregada.
5. Ao excluir uma nota fiscal (ja funciona via state local), o total agregado deve ser recalculado.
6. A posicao de scroll deve ser mantida.

### F3. Atualizacao da BudgetPage

A tela exibe orcamentos por categoria com barras de progresso e totais.

**Requisitos funcionais:**

7. Ao retornar a BudgetPage apos criar/editar/excluir um orcamento ou gasto, os dados devem ser recarregados.
8. A posicao de scroll deve ser mantida.

### F4. Atualizacao da CategoriesPage

**Requisitos funcionais:**

9. Ao retornar a CategoriesPage apos criar/editar/excluir uma categoria, a lista deve ser recarregada.
10. A posicao de scroll deve ser mantida.

### F5. Atualizacao da PaymentMethodsPage

**Requisitos funcionais:**

11. Ao retornar a PaymentMethodsPage apos criar/editar/excluir um metodo de pagamento, a lista e totais devem ser recarregados.
12. A posicao de scroll deve ser mantida.

### F6. Atualizacao do PurchaseDetail

**Requisitos funcionais:**

13. Ao retornar ao PurchaseDetail apos editar dados do registro (ex: categoria), os dados devem refletir a mudanca.
14. A posicao de scroll deve ser mantida.

### F7. Propagacao entre telas relacionadas

Algumas operacoes afetam dados exibidos em multiplas telas simultaneamente.

**Requisitos funcionais:**

15. Inserir um gasto na ManualEntryPage deve atualizar Tab1 (compras e totais), Tab2 (notas fiscais) e BudgetPage (progresso do orcamento) ao navegar para qualquer dessas telas.
16. Editar a categoria de um gasto deve atualizar Tab1 (lista de compras) e BudgetPage (distribuicao por categoria).
17. Excluir um registro deve atualizar todas as telas que exibem dados derivados desse registro.

### F8. Experiencia de atualizacao

**Requisitos funcionais:**

18. A atualizacao nao deve exibir tela de loading completa (skeleton) — deve ser um refresh silencioso que mantem os dados existentes visiveis.
19. Em caso de erro no refresh, os dados anteriores devem continuar visiveis (nao substituir por tela de erro).
20. A atualizacao deve ocorrer ao entrar/retornar a tela, nao em tempo real via polling ou websockets.

## Experiencia do Usuario

**Personas:**
- Ramon e esposa — usuarios primarios que gerenciam gastos do casal diariamente.

**Fluxo principal:**
1. Usuario abre ManualEntryPage e insere um gasto.
2. Apos salvar, navega de volta para Tab1.
3. A lista de compras ja mostra o novo gasto, os totais estao atualizados, e o usuario esta na mesma posicao de scroll de antes.

**Consideracoes de UX:**
- O refresh deve ser imperceptivel — sem flicker, sem loading spinner, sem salto de scroll.
- Se o refresh demorar (ex: conexao lenta), os dados anteriores devem continuar visiveis ate os novos chegarem.
- Nenhuma acao adicional deve ser exigida do usuario para ver dados atualizados.

**Acessibilidade:**
- Nenhuma mudanca especifica de acessibilidade — o comportamento deve ser transparente para leitores de tela.

## Restricoes Tecnicas de Alto Nivel

- O app usa Ionic React com Capacitor — a solucao deve ser compativel com o ciclo de vida de paginas do Ionic (tabs com cache).
- O backend atual nao possui websockets — a atualizacao deve ser client-side, disparada por eventos de navegacao.
- A solucao deve funcionar tanto no browser (desenvolvimento) quanto no app nativo (iOS/Android).
- O Ionic mantem componentes de tabs montados em cache — `useEffect` com `[]` so executa uma vez. A solucao precisa considerar este comportamento.

## Fora de Escopo

- Sincronizacao em tempo real via websockets ou server-sent events.
- Cache offline ou persistencia local de dados.
- Push notifications para mudancas de dados.
- Pull-to-refresh (sera tratado em PRD separado).
- Otimistic updates (atualizar a UI antes da resposta do servidor).
