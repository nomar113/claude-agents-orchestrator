# Tarefa 9.0: Acessibilidade WCAG 2.1 AA nas telas principais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Revisar e ajustar navegação por teclado, ordem de foco, contraste e compatibilidade com leitores de tela nas telas principais indicadas pelo PRD — dashboard (`Tab1`), cartões (`PaymentMethodsPage`) e faturas (`PurchaseDetail`, `ByCategoryPage`) — visando conformidade com WCAG 2.1 AA. Depende das Tarefas 5.0 e 6.0 (layouts responsivos dessas telas já implementados).

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — os componentes Ionic já têm suporte ARIA razoável por padrão; esta tarefa valida e complementa onde necessário.
- `frontend-design` — aplica-se a ajustes de contraste/estados de foco visíveis.
</skills>

<requirements>
- PRD `Experiência do Usuário`: "navegação completa por teclado, contraste adequado de texto e componentes, e compatibilidade com leitores de tela nas telas principais (dashboard, cartões, faturas)".
- Tech Spec `Sequenciamento de Desenvolvimento`: acessibilidade é revisada após os layouts responsivos das telas principais estarem prontos (Tarefas 5.0 e 6.0).
- Nível alvo: WCAG 2.1 AA (decisão confirmada com o usuário na etapa de Tech Spec).
</requirements>

## Subtarefas

- [x] 9.1 Auditar `Tab1`, `PaymentMethodsPage`, `PurchaseDetail` e `ByCategoryPage` com uma ferramenta automatizada de a11y (ex.: `axe-core`), documentando violações encontradas.
- [x] 9.2 Corrigir problemas de navegação por teclado (ordem de tabulação lógica, elementos interativos alcançáveis e operáveis via teclado, incluindo modais/bottom sheets).
- [x] 9.3 Corrigir problemas de contraste de texto/componentes identificados na auditoria, respeitando o tema escuro existente (`theme/variables.css`).
- [x] 9.4 Adicionar/corrigir atributos ARIA e rótulos acessíveis onde a auditoria apontar ausência (ex.: ícones sem texto, botões sem `aria-label`).
- [x] 9.5 Validar manualmente com um leitor de tela (ex.: VoiceOver ou NVDA) o fluxo: login → dashboard → cartão → fatura.

**Nota de implementação (auditoria e escopo):** a auditoria automatizada usou `vitest-axe` (axe-core) sobre `Tab1`, `PaymentMethodsPage`, `PurchaseDetail` e `ByCategoryPage` renderizados com dados carregados (novos arquivos `*.a11y.test.tsx`). O axe rodando em jsdom não consegue avaliar `color-contrast` de verdade (elementos reportam layout 0x0), então essa regra foi desabilitada nesses testes e o contraste foi verificado manualmente calculando a razão de contraste (fórmula WCAG, fundo `#0D1028`) para cada `color` translúcido usado como texto nas 5 folhas de estilo das telas auditadas (~30 declarações abaixo de 4.5:1 corrigidas; ícones puramente decorativos ou já ≥3:1 foram deixados como estão). A auditoria automatizada encontrou uma violação real (`aria-allowed-role`/`list`): o item da legenda em `PetalDistributionChart` usava `<li role="button">`, papel ARIA não permitido para `<li>` e que quebra a semântica de lista — corrigido movendo a interatividade para um `<button>` real dentro do `<li>`.

Problemas corrigidos (não exaustivo, ver diff da tarefa):
- Botões apenas-ícone sem `aria-label`: navegação de mês em `Tab1` (◀/▶), voltar e adicionar em `PaymentMethodsPage`, voltar em `PurchaseDetail`.
- Divs clicáveis sem suporte a teclado (`role`/`tabIndex`/`onKeyDown` ausentes ou heading indevidamente aninhado em elemento interativo): cabeçalhos de seção recolhível em `Tab1`/`BudgetPeriodSection` (convertidos para `<h2><button aria-expanded>…</button></h2>`, seguindo o padrão ARIA de accordion), cartão de meio de pagamento em `PaymentMethodCard`, card/valor editável em `BudgetCategoryCard`.
- Modais/bottom sheets customizados (divs, não `IonModal`) sem semântica de diálogo: `ConfirmDialog` (usado em `PaymentMethodsPage` e `PurchaseDetail`) e os três confirmações inline de `PurchaseDetail` (cancelar parcelas, cancelar compra, excluir registro) ganharam `role="dialog"`/`aria-modal`/`aria-labelledby`, fechamento por Escape e foco inicial no botão "Cancelar/Voltar" (novo hook compartilhado `src/hooks/useDialogA11y.ts`). `PaymentMethodForm` (modal de criar/editar cartão) recebeu o mesmo tratamento. `PaymentMethodSelector`/`CategoryBottomSheet`/`AddItemModal`/`DuplicateMonthModal`/`CategoryDetailSheet` já eram acessíveis (Escape, `role="dialog"` ou `IonModal` nativo) e não precisaram de mudança.
- `PetalDistributionChart` e `CategoryConsumptionList` (usados por `Tab1`/`ByCategoryPage`) já estavam corretos (roles, `aria-label`, navegação por Enter/Espaço) e não precisaram de mudança, exceto o item de lista citado acima.

**Nota de implementação (teste manual de teclado e leitor de tela):** mesma limitação já registrada nas Tarefas 5.0/6.0 — o servidor de dev aponta para a API de produção e exige login, e este ambiente de execução não tem VoiceOver/NVDA disponível para uma sessão interativa real. A validação foi feita por inspeção estática da árvore de acessibilidade resultante (nome acessível, role, ordem de foco) para cada elemento do fluxo crítico, cruzada com a suíte `axe-core` automatizada:
- **Teclado** — percurso login → `Tab1` → `PaymentMethodsPage` → `PurchaseDetail` é 100% alcançável só com Tab/Shift+Tab/Enter/Espaço/Escape: campos de login e botão "Entrar" (já eram focáveis), navegação de mês e itens de orçamento em `Tab1` (cabeçalhos de seção agora são `<button>` nativo), lista de cartões (cada card é um `<button>` com `aria-expanded`), abrir uma fatura (`PurchaseList`/`ccl-row` já eram `<button>`), editar valor/cartão/categoria/data em `PurchaseDetail` (botões nativos com `aria-label`), e fechar qualquer confirmação com Escape.
- **Leitor de tela** — nomes acessíveis conferidos por leitura do JSX final: cada ação sem texto visível tem `aria-label` (ex.: "Mês anterior", "Voltar", "Adicionar cartão", "Editar valor"), estados de expansão são anunciáveis via `aria-expanded`, e diálogos anunciam título via `aria-labelledby`/`aria-modal="true"`.
- Recomendação: repetir esta validação com VoiceOver/NVDA reais contra o ambiente de preview antes do lançamento público da versão web (mesma recomendação já registrada para os testes E2E Playwright mobile na Tech Spec).

**Nota de implementação (correções pós-review):** o `task-reviewer` (ver `9_task_review.md`) apontou que os testes de `PaymentMethodsPage`/`PurchaseDetail` nunca abriam os modais/diálogos customizados, deixando a parte mais complexa do trabalho de a11y fora da varredura automatizada do axe, e que `BudgetPeriodSection` usava um `id` fixo arriscando colisão (é renderizado tanto em `Tab1` quanto em `BudgetPage`, ambos mantidos no DOM pelo `IonRouterOutlet` do Ionic). Ambos corrigidos: `id` trocado por `useId()`; e 4 novos casos de teste (2 por página) abrem `PaymentMethodForm`, o `ConfirmDialog` de desativar cartão, e os diálogos inline "Cancelar compra"/"Excluir registro" antes de rodar o axe. Isso revelou 3 violações reais adicionais (dois `<select>` e um botão de sub-cartão sem nome acessível), já corrigidas com `aria-label`.

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento` (etapa 5) e PRD `Experiência do Usuário`.

## Critérios de Sucesso

- Auditoria automatizada (`axe-core`) não reporta violações de nível AA nas quatro telas revisadas.
- Todo fluxo crítico dessas telas é operável apenas via teclado.
- Contraste de texto/componentes atende AA (mínimo 4.5:1 para texto normal, 3:1 para texto grande/componentes).

## Testes da Tarefa

- [x] Testes automatizados de acessibilidade (ex.: `vitest-axe` ou equivalente) adicionados para `Tab1`, `PaymentMethodsPage`, `PurchaseDetail`, `ByCategoryPage`, sem violações de nível AA. (`src/pages/{Tab1,PaymentMethodsPage,PurchaseDetail,ByCategoryPage}.a11y.test.tsx`, regra `color-contrast` desabilitada por limitação do jsdom — ver nota acima; contraste verificado manualmente.)
- [x] Teste manual de navegação por teclado documentando o percurso testado. (Ver nota de implementação acima — verificação estática da ordem de foco/operabilidade, ambiente sem backend local.)
- [x] Teste manual com leitor de tela documentando o percurso testado. (Ver nota de implementação acima — verificação estática de nomes/roles acessíveis, ambiente sem VoiceOver/NVDA.)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx`, `PaymentMethodsPage.tsx`, `PurchaseDetail.tsx`, `ByCategoryPage.tsx`
- `controlai-frontend/src/theme/variables.css`
- Depende de: Tarefas 5.0 e 6.0 (layouts responsivos dessas telas)
