# Review: Task 9.0 - Acessibilidade WCAG 2.1 AA nas telas principais

**Revisor**: AI Code Reviewer
**Data**: 2026-09-11
**Arquivo da task**: 9_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementação cobre corretamente o núcleo da tarefa: auditoria automatizada com `vitest-axe` nas quatro telas (`Tab1`, `PaymentMethodsPage`, `PurchaseDetail`, `ByCategoryPage`), correção de ~30 declarações de contraste de texto abaixo de 4.5:1, conversão de `<div onClick>` para elementos semânticos/operáveis por teclado (`<h2><button aria-expanded>`, `<button>`), e adição de `role="dialog"`/`aria-modal`/`aria-labelledby`/Escape/foco-inicial em todos os modais customizados via um hook compartilhado bem escrito (`useDialogA11y`). O bug real encontrado pelo axe (`<li role="button">` em `PetalDistributionChart`) foi corrigido corretamente, com teste atualizado.

Verifiquei manualmente uma amostra dos cálculos de contraste (fórmula WCAG completa, luminância relativa) contra o fundo `#0D1028` e todos batem com os valores documentados; a distinção entre texto (alvo ~4.5:1, geralmente superado com folga para ~0xa6/8:1) e ícones puramente gráficos (alvo 3:1 via SC 1.4.11, ex. `pd-edit-icon` corrigido de ~2.2:1/2.7:1 para ~3.8:1) está tecnicamente correta e é um detalhe que muita implementação erra. Rodei `npx tsc --noEmit` (limpo), `npx eslint` nos arquivos alterados (0 erros, 1 warning pré-existente e não relacionado em `Tab1.tsx`), `npm run build` (sucesso) e a suíte completa `npx vitest run` (64 arquivos, 642 testes, todos passando — confirma o número reportado na tarefa).

O ponto que impede o "APROVADO" sem ressalvas é o critério de sucesso "auditoria automatizada (axe-core) não reporta violações de nível AA nas quatro telas revisadas": a regra `color-contrast` está desabilitada nos quatro testes (razoável, dado que é uma limitação real e documentada do jsdom) **e**, adicionalmente, nenhum dos testes de `PaymentMethodsPage` e `PurchaseDetail` abre os modais/diálogos customizados que foram justamente o principal trabalho de a11y desta tarefa — então o axe nunca varre o `role="dialog"` do `PaymentMethodForm` nem os três diálogos inline de `PurchaseDetail`. Isso não invalida o trabalho (a marcação está correta por inspeção manual e há testes unitários dedicados para `ConfirmDialog`), mas significa que o critério de sucesso, como está redigido, não está 100% coberto pela automação tal como ela existe hoje.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/hooks/useDialogA11y.ts` (novo) | OK | 0 |
| `src/components/ConfirmDialog.tsx` | OK | 0 |
| `src/components/ConfirmDialog.test.tsx` (novo) | OK | 0 |
| `src/components/PaymentMethodCard.tsx` | OK | 0 |
| `src/components/PaymentMethodForm.tsx` | OK | 1 minor |
| `src/components/BudgetCategoryCard.tsx` | OK | 0 |
| `src/components/BudgetPeriodSection.tsx` | Problemas | 1 major |
| `src/components/PetalDistributionChart.tsx` | OK | 1 minor |
| `src/components/PetalDistributionChart.css` | OK | 0 |
| `src/components/PetalDistributionChart.test.tsx` | OK | 0 |
| `src/pages/Tab1.tsx` | OK | 1 minor (formatação) |
| `src/pages/Tab1.css` | OK | 0 |
| `src/pages/Tab1.a11y.test.tsx` (novo) | OK | 0 |
| `src/pages/PaymentMethodsPage.tsx` | OK | 0 |
| `src/pages/PaymentMethodsPage.css` | OK | 0 |
| `src/pages/PaymentMethodsPage.a11y.test.tsx` (novo) | Problemas | 1 major |
| `src/pages/PurchaseDetail.tsx` | OK | 0 |
| `src/pages/PurchaseDetail.css` | OK | 0 |
| `src/pages/PurchaseDetail.a11y.test.tsx` (novo) | Problemas | 1 major |
| `src/pages/ByCategoryPage.a11y.test.tsx` (novo) | OK | 0 |
| `src/pages/BudgetPage.css` | OK | 0 |
| `src/setupTests.ts` | OK | 1 minor |
| `package.json` / `package-lock.json` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema crítico encontrado.

### Problemas Major

1. **`aria-controls`/`id` fixo em `BudgetPeriodSection.tsx` (linha ~29, `id="budget-period-section-content"`) pode colidir quando renderizado em `Tab1` e `BudgetPage` simultaneamente.**
   `BudgetPeriodSection` é usado tanto em `src/pages/Tab1.tsx:400` quanto em `src/pages/BudgetPage.tsx:308`, e ambas as páginas vivem na mesma `IonTabs`/`IonRouterOutlet` (`src/App.tsx:81-82`). O `IonRouterOutlet` do Ionic mantém páginas já visitadas na árvore DOM (ocultas via `ion-page-hidden`, não desmontadas) para permitir transições de "voltar" — então, após o usuário navegar entre Tab1 e Orçamento, é plausível haver duas instâncias de `#budget-period-section-content` simultaneamente no DOM, um HTML inválido (`duplicate-id`/`duplicate-id-aria`, que o próprio axe-core reportaria) e que deixa `aria-controls` ambíguo para leitores de tela. Os `id`s equivalentes criados em `Tab1.tsx` (`tab1-incomes-content`, `tab1-expenses-content`) não têm esse risco porque são exclusivos daquela página.
   **Sugestão**: gerar o id com `useId()` dentro do próprio `BudgetPeriodSection` (como já foi feito em `ConfirmDialog`/`PurchaseDetail`/`PaymentMethodForm` para `titleId`), em vez de uma string fixa.
   ```tsx
   const contentId = useId();
   // ...
   <button aria-controls={contentId} ...>
   // ...
   <div id={contentId} className="period-section-content">
   ```

2. **Os testes de a11y de `PaymentMethodsPage` e `PurchaseDetail` não abrem nenhum modal/diálogo, deixando a marcação de diálogo (o principal entregável da subtarefa 9.4 para esses componentes) fora da cobertura do axe.**
   - `src/pages/PaymentMethodsPage.a11y.test.tsx`: só renderiza a lista de cartões carregada; nunca aciona "Adicionar cartão" (abriria `PaymentMethodForm`) nem um fluxo de exclusão (abriria `ConfirmDialog`).
   - `src/pages/PurchaseDetail.a11y.test.tsx`: só renderiza a tela de detalhe carregada; nunca aciona "Cancelar compra"/"Excluir"/"Cancelar parcelas", que abrem os três `<div role="dialog">` inline adicionados nesta tarefa.
   Isso é o motivo direto pelo qual o critério de sucesso "auditoria automatizada não reporta violações AA nas quatro telas" precisa de ressalva: o axe nunca varre o HTML novo mais complexo (diálogos) introduzido pela própria tarefa. A marcação está correta pela inspeção manual que fiz e há teste unitário dedicado para `ConfirmDialog` (sem axe, mas com asserções de `role`, `aria-modal`, nome acessível, foco e Escape), o que mitiga bastante o risco — mas recomendo fortemente adicionar pelo menos um `it` por página que dispare a abertura do modal/diálogo antes de rodar `axe(container)`, para que o critério de sucesso esteja de fato coberto pela automação e não apenas por revisão estática.

### Problemas Minor

1. **`PetalDistributionChart.tsx` (linha ~232): `onKeyDown={handleCategoryActivateKeyDown}` ficou redundante no item de legenda após a conversão de `<li role="button">` para `<button>` real dentro do `<li>`.** Um `<button>` nativo já dispara `click` em Enter/Espaço sem handler manual; o `event.preventDefault()` dentro do handler evita a duplicidade de disparo (confirmado: o comportamento padrão do navegador é cancelado antes de sintetizar o clique), então não há bug funcional, mas o handler e o comentário "Space scrolls the page by default" (que não se aplica mais a um `<button>` real) ficaram obsoletos. Os outros elementos convertidos para `<button>` nesta mesma tarefa (`budget-section-header`, `pm-card-main`) corretamente não têm `onKeyDown` manual — vale alinhar este caso também, por consistência.
2. **`src/setupTests.ts`: importar de `vitest-axe/dist/matchers.js` (caminho interno, não documentado como API pública do pacote) para contornar um bug de empacotamento do `vitest-axe@0.1.0`.** A justificativa está bem documentada em comentário, mas é um acoplamento frágil a um caminho de build interno de uma dependência — se uma futura versão do pacote reorganizar `dist/`, o import quebra silenciosamente sem aviso de tipo (import de valor sem checagem contra a API pública). Nada a fazer agora além de deixar registrado; se o pacote for atualizado, revalidar esse import.
3. **Indentação no `<div id="tab1-expenses-content">` em `Tab1.tsx` (linhas ~490-524)**: o novo `<div>` que envolve o conteúdo condicional (`isEditing ? <>...</> : <PetalDistributionChart .../>`) não foi reindentado — o bloco interno ficou no mesmo nível do `<div>` pai. Não é um erro funcional, apenas uma inconsistência de formatação que destoa do padrão do resto do arquivo.

## Destaques Positivos

- **Hook `useDialogA11y` bem projetado e reutilizado 5 vezes** (`ConfirmDialog`, os 3 diálogos inline de `PurchaseDetail`, `PaymentMethodForm`) em vez de duplicar a lógica de Escape/foco-inicial em cada componente — está exatamente alinhado com `clean-code` (função pequena, um propósito, sem duplicação). O uso de `useRef` para manter `onClose` sempre atual sem recriar o listener a cada render mostra atenção a um detalhe de correção real (evitar closures obsoletas), com comentário explicando o porquê.
- **Distinção correta entre limiar de contraste para texto (4.5:1) e para ícones/componentes gráficos (3:1, SC 1.4.11)** nas correções de `PurchaseDetail.css` (`pd-hero-edit-icon`, `pd-desc-icon`, `pd-edit-icon` foram levados a ~0.4 de opacidade / ~3.8:1, não aos ~0.65 usados para texto) — verifiquei os cálculos e batem; é um erro comum tratar tudo com a régua de 4.5:1 ou, pior, não tratar ícones informativos nenhuma régua, e aqui foi feito com critério.
- **O bug real do axe (`<li role="button">`) foi corrigido pela causa raiz** (mover a interatividade para um `<button>` real dentro do `<li>`, preservando a semântica de lista) em vez de suprimir a regra do axe para aquele componente, e o teste existente foi atualizado para refletir a nova estrutura (`legendItem.tagName === 'BUTTON'`) em vez de checar `role`/`tabindex` que deixaram de existir.
- **Padrão ARIA de accordion aplicado corretamente** (`<h2><button aria-expanded aria-controls></button></h2>` com `aria-controls` apontando para o painel, mais reset de CSS explícito no botão — `background: none; border: none; font: inherit; color: inherit; text-align: left` — preservando o layout visual original ao trocar `div`/`h2` solto por `button` nativo). Conferi que `display: flex` já preexistia nas regras reaproveitadas, então a conversão para `<button>` não quebrou o layout.
- **Notas de implementação em `9_task.md` transparentes sobre as limitações do ambiente** (sem VoiceOver/NVDA, sem backend local) em vez de simplesmente marcar as subtarefas 9.5 como concluídas sem ressalva — inclui recomendação explícita de repetir a validação com AT real antes do lançamento, o que é a atitude correta dado que o ambiente realmente não permite outra coisa.
- Checks de qualidade (`tsc`, `eslint`, `build`, suíte de 642 testes) todos confirmados limpos nesta revisão, batendo com o que a tarefa reportou.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | N/A |
| Logging | N/A |
| React | OK (ver observação sobre `id` fixo em `BudgetPeriodSection`) |
| Testes | Problemas (gap de cobertura do axe em diálogos, ver Major #2) |

## Recomendacoes

1. **(Prioridade alta, mas não bloqueante)** Trocar o `id="budget-period-section-content"` fixo em `BudgetPeriodSection.tsx` por um `useId()` gerado por instância, para eliminar o risco de IDs duplicados quando `Tab1` e `BudgetPage` coexistem no DOM do `IonRouterOutlet`.
2. **(Prioridade alta, mas não bloqueante)** Adicionar pelo menos um caso de teste por página (`PaymentMethodsPage.a11y.test.tsx`, `PurchaseDetail.a11y.test.tsx`) que abra o modal/diálogo relevante antes de chamar `axe(container)`, para que o critério de sucesso da tarefa cubra de fato a marcação de diálogo introduzida.
3. **(Prioridade baixa)** Remover o `onKeyDown` redundante do item de legenda em `PetalDistributionChart.tsx` agora que é um `<button>` nativo, por consistência com as demais conversões desta tarefa.
4. **(Prioridade baixa)** Ajustar a indentação do novo wrapper `<div id="tab1-expenses-content">` em `Tab1.tsx`.
5. **(Já registrado pela própria tarefa, reforçando)** Repetir a validação de teclado e leitor de tela com VoiceOver/NVDA reais contra um ambiente com backend antes do lançamento público — a verificação estática feita aqui é uma boa aproximação, mas não substitui teste com tecnologia assistiva real, especialmente para o comportamento de foco dos diálogos (ver observação abaixo sobre ausência de retorno de foco).

## Veredito

A implementação cumpre bem o escopo da tarefa: navegação por teclado corrigida com padrões ARIA adequados, contraste corrigido com metodologia correta (inclusive a distinção texto vs. ícone), diálogos customizados com semântica e comportamento de teclado (Escape, foco inicial) via um hook limpo e reutilizado, e um bug real de acessibilidade encontrado e corrigido pela causa raiz. Não há problemas críticos.

Quanto aos pontos levantados pelo solicitante:
- **Divs convertidas para `<button>`/`<h2><button>` não quebraram CSS/layout** — conferi os resets de `display`/`background`/`border`/`font` em cada seletor tocado; o layout visual é preservado.
- **Foco preso/retorno de foco nos diálogos**: nenhum dos diálogos implementa *focus trap* (Tab pode sair do diálogo para o conteúdo por trás, já que são `div`s sobre a página, não `<dialog>`/`IonModal` nativos) nem devolve o foco ao elemento que abriu o diálogo ao fechar. Isso não é uma falha literal de nenhum critério WCAG 2.1 AA listado (não é "keyboard trap" ao contrário — o problema aqui seria o foco vazar para fora, não ficar preso — e não há SC específico de "retorno de foco" em 2.1 AA, é convenção do ARIA Authoring Practices Guide). Dado o escopo da tarefa (WCAG 2.1 AA, não "melhor prática ARIA completa"), considero **aceitável para este PRD**, mas registro como dívida técnica: recomendo tratar isso numa iteração futura, especialmente o retorno de foco ao fechar, que é bastante perceptível para quem navega por teclado/leitor de tela.
- **Correções de contraste**: conferi os cálculos (fórmula de luminância relativa completa) para várias declarações e todas as batem com o texto atingindo >4.5:1 e os ícones >3:1; a metodologia de calcular contra o fundo plano `#0D1028` é uma aproximação razoável, já que os elementos comumente têm folga suficiente (na amostra que testei sobre um card com overlay de 4% branco, a contração ficou em ~7.85:1 em vez de ~8.24:1 calculado — ainda folgadamente acima do mínimo).
- **Desabilitar `color-contrast` no axe**: razoável e bem documentado (limitação real e conhecida do jsdom, não do código da aplicação) — a alternativa de "resolver de outra forma" seria migrar para uma suíte de a11y baseada em navegador real (Playwright + `@axe-core/playwright`), o que é um investimento de infraestrutura maior do que o escopo desta tarefa; não vejo isso como bloqueante, mas pode ser proposto como evolução do Tech Spec.
- **Critério de sucesso do axe cobrindo as 4 telas**: como detalhado no Major #2, a automação hoje não abre os diálogos custom, então o critério está coberto apenas parcialmente pela automação (o restante pela revisão estática/testes unitários dedicados). Não considero isso motivo para reprovar a tarefa, mas é motivo suficiente para "aprovado com observações" em vez de aprovação plena.

**Próximos passos**: pode prosseguir no workflow (não há bloqueio), mas recomendo endereçar os dois itens Major (id duplicado em `BudgetPeriodSection`, cobertura de axe nos diálogos) antes ou logo após o deploy do ControlAI Web, e manter a recomendação já registrada de validação com AT real antes do lançamento público.

## Correções aplicadas após esta review

Ambos os problemas Major e o Minor #3 foram corrigidos antes de finalizar a tarefa:

1. **Major #1 (id fixo em `BudgetPeriodSection`)**: substituído por `useId()`, eliminando o risco de colisão quando `Tab1` e `BudgetPage` coexistem no DOM do `IonRouterOutlet`.
2. **Major #2 (axe não cobria os diálogos)**: adicionados novos casos de teste que abrem os diálogos antes de rodar `axe(container)` — `PaymentMethodsPage.a11y.test.tsx` ganhou 2 novos `it` (form de criar cartão `PaymentMethodForm`, e `ConfirmDialog` de desativar cartão); `PurchaseDetail.a11y.test.tsx` ganhou 2 novos `it` (diálogos inline "Cancelar compra" e "Excluir registro"). Isso imediatamente revelou **3 violações reais** que a auditoria anterior não cobria: dois `<select>` sem nome acessível e um botão de excluir sub-cartão sem `aria-label` em `PaymentMethodForm.tsx`/`PaymentMethodCard.tsx` — todos corrigidos com `aria-label` (incluindo, por consistência, os campos de texto que só tinham `placeholder`). O critério de sucesso "auditoria automatizada não reporta violações AA nas quatro telas" agora está coberto também para os diálogos customizados.
3. **Minor #3 (indentação em `Tab1.tsx`)**: o wrapper `<div id="tab1-expenses-content">` foi reindentado para refletir seu nível real de aninhamento.
4. **Minor #1 (onKeyDown redundante no item de legenda)**: mantido deliberadamente — em jsdom (ambiente dos testes), um `<button>` nativo não sintetiza `click` a partir de `keyDown` como um navegador real faz, então remover o handler manual quebraria a suíte existente sem ganho real (o `preventDefault()` já evita o disparo duplicado em navegadores reais). Registrado aqui como decisão consciente, não como pendência.

Após as correções: `npx tsc --noEmit`, `npx eslint src` e `npm run build` seguem limpos; `npx vitest run` passou com 64 arquivos e 646 testes (4 novos testes de diálogo + o ajuste dos existentes).
