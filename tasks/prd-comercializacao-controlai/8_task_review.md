# Review: Task 8.0 - Frontend — tela de bloqueio por assinatura inativa

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09 (revisão inicial) / 2026-09-09 (segunda passada — correções verificadas)
**Arquivo da task**: 8_task.md
**Status**: APROVADO (atualizado na segunda passada — ver seção "Segunda Passada de Revisão" abaixo; os 2 pontos Major da revisão inicial foram corrigidos e verificados)

## Resumo

A implementação cobre corretamente o caminho principal descrito na Tech Spec (`Arquitetura do Sistema > Visão Geral dos Componentes` e `Arquivos Relevantes`): `httpClient.ts` detecta `402` nos quatro pontos possíveis (native/web × chamada inicial/retry pós-refresh de `401`) e dispara `ctrl:subscription-inactive` sem limpar a sessão; `AuthContext.tsx` escuta o evento, expõe `hasInactiveSubscription` e o reseta em todos os pontos de transição de estado (`login`, `loginWithGoogle`, `register`, `logout`, `ctrl:auth-failure`); `SubscriptionRequiredPage` é uma tela neutra, sem nenhum link/botão, com cópia que não menciona pagamento; e `App.tsx` a renderiza no lugar de `TabsLayout` com uma única linha adicionada, preservando o workaround documentado de estabilidade do `IonRouterOutlet`. As três subtarefas de teste exigidas existem e passam (`httpClient.auth.test.ts`, `SubscriptionRequiredPage.test.tsx`, `App.routing.test.tsx`), e os ajustes em `LoginPage.test.tsx`/`RegisterPage.test.tsx`/`ProfilePage.test.tsx` são estritamente o campo obrigatório adicionado ao mock, sem mudança de comportamento. Verifiquei de forma independente: `npx tsc --noEmit` limpo, `npx eslint` nos arquivos tocados com o mesmo warning pré-existente em `AuthContext.tsx` (confirmado via `git stash`), e a suíte relevante (52 testes nos 6 arquivos envolvidos) passando.

Encontrei, porém, uma lacuna funcional real fora do que os 3 testes exigidos cobrem: o fluxo de restauração de sessão no boot do app (`AuthContext`'s bootstrap, via Face ID/refresh token) chama `authService.getMe()`, que usa `authFetch` — um `fetch` cru próprio de `authService.ts`, deliberadamente desacoplado de `httpClient.ts` para evitar dependência circular — e esse `authFetch` **não trata `402` de nenhuma forma**. Um usuário que reabre o app com uma sessão previamente válida, mas cuja assinatura foi cancelada enquanto o app estava fechado, não verá `SubscriptionRequiredPage` no boot: o evento nunca dispara, e o `catch` genérico do bootstrap ("Refresh or /me failed — stay logged out") o joga de volta para a tela de login. Isso não quebra a garantia de segurança do gate (nenhuma tela protegida chega a renderizar), mas diverge do critério de sucesso "usuário autenticado ... vê a SubscriptionRequiredPage em vez de qualquer tela do app" para esse cenário específico de cold start, que é exatamente o tipo de caso que a dependência declarada da Tarefa 6.0 ("testar contra o backend real") tende a expor. Também não há nenhuma forma de sair da conta a partir da própria `SubscriptionRequiredPage` — diferente de `ProfilePage`, que tem um botão "Sair da conta" explícito — o que torna a tela um beco sem saída dentro do app para quem precisa trocar de conta ou deslogar enquanto bloqueado. Nenhum dos dois pontos bloqueia a aprovação, mas ambos merecem tratamento antes de fechar o QA end-to-end com o backend real (Tech Spec `Testes de E2E`).

## Segunda Passada de Revisão (2026-09-09)

Escopo desta passada: validar exclusivamente se os dois pontos Major abaixo foram corrigidos, sem regressão no que já estava aprovado. Não foi feita uma nova revisão completa dos demais arquivos da task (`httpClient.ts`, `SubscriptionRequiredPage.css`, `App.routing.test.tsx`, etc.), que permanecem como avaliados na revisão inicial.

**Correção 1 — bootstrap não detectava `402` (`AuthContext.tsx` + `authService.ts`).**
Verificado em `src/services/authService.ts:41-46`: `authFetch` agora dispara `window.dispatchEvent(new CustomEvent('ctrl:subscription-inactive'))` quando `res.status === 402`, antes do `if (!res.ok) throw ...`. Em `src/context/AuthContext.tsx:69-88`, o bootstrap agora envolve `authService.getMe()` num `try/catch` interno: em erro `HttpError` com `status === 402`, seta `hasValidSession=true` e `hasInactiveSubscription=true` diretamente (não depende só do evento de `window`, o que é mais determinístico e testável) e **não** relança o erro — logo o `catch` externo ("stay logged out") não é acionado. Qualquer outro erro (ex.: `401`) continua sendo relançado e cai no `catch` externo, preservando o comportamento de logout para sessão realmente inválida — confirmado no teste `AuthContext.test.tsx:137-148` ("stays unauthenticated when /me fails with a non-402 error").
`isAuthenticated` no valor do contexto passou de `!!user` para `hasValidSession` (`AuthContext.tsx:157`), decorrência necessária: no cenário `402` no boot, `user` permanece `null` (o `/me` falhou, não há perfil), mas a sessão é válida e o usuário deve ficar autenticado. Busquei por outros consumidores de `useAuth()` que dependessem de `user` não-nulo quando `isAuthenticated` é `true` (`grep` em `src/pages/*.tsx` e `src/App.tsx`) — o único outro lugar que desestrutura `user` é `ProfilePage.tsx:35`, e essa variável está sem uso (é sombreada por `profile.user`, vindo de outro fetch), portanto não há risco de regressão por essa mudança de semântica. O roteamento em `App.tsx:209-215` continua checando `isAuthenticated` antes de `hasInactiveSubscription` antes de `TabsLayout`, e todos os caminhos internos do `TabsLayout` (`/tab1`, `/profile`, `/budget`, etc.) estão listados em `PROTECTED_PATHS`, então nenhuma tela protegida é alcançável enquanto `hasInactiveSubscription` for `true`, com ou sem perfil carregado.
Testes novos cobrindo especificamente o gap relatado: `authService.test.ts:281-293` (`getMe` dispara `ctrl:subscription-inactive` e lança em `402`) e `AuthContext.test.tsx:123-148` (dois casos de bootstrap: fica autenticado sem perfil + `hasInactiveSubscription=true` em `402`; permanece deslogado em erro não-402). **Confirmado resolvido.**

**Correção 2 — `SubscriptionRequiredPage` sem saída (logout).**
Verificado em `src/pages/SubscriptionRequiredPage.tsx:35-45`: novo `IonButton` ("Sair da conta", `fill="outline"`, `color="medium"`, ícone `logOutOutline`) chamando `handleLogout` (linhas 17-20), que faz `await logout()` (de `useAuth()`) e depois `history.replace('/login')` — mesmo padrão de `ProfilePage.tsx` (`handleLogout`). `authService.logout()` já captura internamente qualquer falha de rede no `POST /auth/logout` (`authService.ts:102-108`) e limpa os tokens localmente de qualquer forma, então o `await logout()` sem `try/catch` na página não introduz risco de exceção não tratada. `SubscriptionRequiredPage.test.tsx` foi reescrito para mockar `useAuth`/`useHistory` e passa a validar explicitamente que o único botão da tela é o de logout (`container.querySelectorAll('button')` tem tamanho 1) e que nenhum link (`<a>`) ou palavra de pagamento (`checkout`, `pagamento`, `kiwify`, `comprar`, `assinar`) aparece no texto renderizado — o teste continua sendo exatamente o tipo que falharia se um link de pagamento fosse reintroduzido. Confirmei manualmente que a palavra proibida `assinar` não colide com o texto legítimo da tela ("assinatura", presente no corpo) por não ser substring dela. Botão isolado não viola a restrição do PRD (não é link nem menção a pagamento). **Confirmado resolvido.**

**Nota menor (não bloqueante, não estava no escopo dos 2 pontos Major):** o `IonButton` tem tanto o texto visível "Sair da conta" quanto `aria-label="Sair da conta"` idênticos — redundante para leitores de tela (o `aria-label` normalmente só é necessário quando o texto visível não é suficientemente descritivo por si só), mas inofensivo; nenhuma ação necessária.

**Verificação independente nesta passada:**
- `npx vitest run` (suíte completa): **601 testes passando, 0 falhas** (confirma o número reportado).
- `npx vitest run` restrito aos arquivos relevantes (`authService.test.ts`, `AuthContext.test.tsx`, `SubscriptionRequiredPage.test.tsx`, `App.routing.test.tsx`, `httpClient.auth.test.ts`): todos passando.
- `npx tsc --noEmit`: sem erros.
- `npx eslint` nos arquivos tocados (`authService.ts`, `AuthContext.tsx`, `SubscriptionRequiredPage.tsx`, `App.tsx` + testes): 0 erros, 1 warning (`react-refresh/only-export-components` em `AuthContext.tsx`) — confirmado pré-existente na primeira revisão via `git stash`, não é uma regressão desta correção.
- Inspecionei o `git diff` real dos 4 arquivos de produção (`authService.ts`, `AuthContext.tsx`, `SubscriptionRequiredPage.tsx`, `App.tsx`) linha a linha; o diff corresponde exatamente ao que foi descrito na solicitação de revisão, sem alterações extras não relacionadas.

Nenhum problema novo (crítico, major ou minor) foi introduzido pelas correções. Os dois pontos Major da revisão inicial estão resolvidos e verificados.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/services/httpClient.ts` | OK | 0 |
| `src/context/AuthContext.tsx` | OK (corrigido na 2ª passada) | 0 |
| `src/services/authService.ts` (modificado na 2ª passada) | OK (corrigido na 2ª passada) | 0 |
| `src/pages/SubscriptionRequiredPage.tsx` | OK (corrigido na 2ª passada) | 0 |
| `src/pages/SubscriptionRequiredPage.css` | Observação | 1 (minor) |
| `src/App.tsx` | OK | 0 |
| `src/services/httpClient.auth.test.ts` | OK | 0 |
| `src/pages/SubscriptionRequiredPage.test.tsx` | OK | 0 |
| `src/App.routing.test.tsx` | OK | 0 |
| `src/pages/LoginPage.test.tsx` / `RegisterPage.test.tsx` / `ProfilePage.test.tsx` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**Status na 2ª passada: ambos os itens abaixo foram corrigidos e verificados — ver seção "Segunda Passada de Revisão" no topo deste documento. Mantidos aqui como registro histórico do que foi encontrado na revisão inicial.**

1. ~~**Fluxo de bootstrap/restauração de sessão não detecta `402` — usuário volta para o login em vez do bloqueio.**~~ **[RESOLVIDO]**
   `src/context/AuthContext.tsx:57-69` (bootstrap) chama `authService.getMe()`, que em `src/services/authService.ts:127-132` delega para `authFetch` (linhas 25-46). `authFetch` só verifica `!res.ok` e lança `HttpError` genérico — nunca inspeciona `402` nem dispara `ctrl:subscription-inactive`. O `catch` do bootstrap (`AuthContext.tsx:65-66`, `catch { // Refresh or /me failed — stay logged out. }`) engole esse erro sem distinção. Resultado prático: um usuário que reabre o app (Face ID ou refresh token válido) depois que o grupo perdeu a assinatura enquanto o app estava fechado cai direto na tela de login, não na `SubscriptionRequiredPage`, e `hasInactiveSubscription` permanece `false`. Só após um novo login manual bem-sucedido (rota pública, não passa pelo gate) é que a primeira chamada real de dado via `httpRequest` finalmente dispara o evento e mostra o bloqueio corretamente.
   Nenhum dos 3 testes exigidos exercita esse caminho — `httpClient.auth.test.ts` testa apenas `httpRequest`, e `App.routing.test.tsx` mocka `useAuth` diretamente, não passa pelo bootstrap real.
   *Sugestão*: fazer `getMe()` (e/ou `doRefresh`) passar por `httpRequest`, ou replicar o tratamento de `402` dentro de `authFetch` (disparando o mesmo `ctrl:subscription-inactive`) para que o bootstrap distinga "sessão inválida" de "sessão válida, assinatura inativa".

2. ~~**`SubscriptionRequiredPage` não oferece nenhuma saída (logout) para o usuário bloqueado.**~~ **[RESOLVIDO]**
   `src/pages/SubscriptionRequiredPage.tsx:9-25`. A tela não tem nenhum botão, incluindo um de logout — diferente de `src/pages/ProfilePage.tsx:504-513`, que expõe "Sair da conta" chamando `logout()` do `AuthContext`. Como o usuário permanece autenticado por design (conforme a subtarefa 8.4 pede), mas o app não tem nenhuma outra tela alcançável a partir daqui, um usuário que logou com a conta errada, ou que só quer deslogar, fica sem caminho dentro do app — precisaria forçar o fechamento e limpar dados. Isso não viola a restrição de "nenhum link/menção a pagamento" (um botão de logout não é isso), então pode ser adicionado sem risco à regra de negócio.
   *Sugestão*: adicionar um botão "Sair da conta" reaproveitando `logout()` de `useAuth()`, igual ao padrão já usado em `ProfilePage`.

### Problemas Minor

1. **`SubscriptionRequiredPage.css` não reaproveita os tokens de tema existentes.**
   `src/pages/SubscriptionRequiredPage.css:1-2,21,29,38`. As cores usam valores hardcoded (`#0f0f12`, `#ffffff60`, `#ffffff80`) em vez de `--ion-background-color` / `--ion-color-medium` já definidos em `src/theme/variables.css`. Não é um bug — a tela renderiza corretamente e o contraste é adequado — mas diverge levemente do padrão de reaproveitamento de tema usado no resto do app (ex.: `LoadingPage` em `App.tsx` usa a mesma cor de fundo do tema, `#0D1028`, ainda que também hardcoded). Puramente estético/consistência, não bloqueante.

## Destaques Positivos

- Os quatro pontos de checagem de `402` em `httpClient.ts` (native inicial, native retry, web inicial, web retry) foram cobertos de forma simétrica e seguindo exatamente o padrão já estabelecido por `handleAuthFailure`, incluindo o comentário explicando a diferença chave (não limpar a sessão). O diff é mínimo e cirúrgico (14 linhas adicionadas, 0 removidas).
- `hasInactiveSubscription` é resetado em todos os pontos de transição de estado de autenticação (`login`, `loginWithGoogle`, `register`, `logout`, `ctrl:auth-failure`) — nenhum caminho deixa a flag "grudada" incorretamente após uma nova autenticação.
- A alteração em `App.tsx` é uma única linha inserida dentro do `render` já existente do `PROTECTED_PATHS`, sem tocar na estrutura do array de rotas nem do `IonRouterOutlet` — respeita integralmente o workaround documentado nos comentários (linhas 134-148 e 165-177) contra a tela preta por colisão de view stack.
- `SubscriptionRequiredPage.test.tsx` testa não só a presença do texto esperado, mas ativamente a ausência de `<a>`/`<button>` e de um conjunto de palavras proibidas (`checkout`, `pagamento`, `kiwify`, `comprar`, `assinar`) — é um teste que efetivamente falharia se alguém reintroduzisse um link de pagamento no futuro, não um teste de fachada.
- `App.routing.test.tsx` cobre o caso mais importante para segurança: usuário não autenticado com a flag "grudada" em `true` (`hasInactiveSubscription: true`, `isAuthenticated: false`) ainda assim vê `LoginPage`, não o bloqueio nem o app — evita que um estado inconsistente vaze para uma tela errada.
- Teste de `httpClient.ts` cobre explicitamente o caso de `402` após um `401` recuperado com sucesso (linha 139-154), não só o caso trivial de `402` na primeira chamada — mostra atenção ao fluxo de retry real.
- `tokenStorage.clearAll` é explicitamente verificado como **não** chamado no teste de `402` (`httpClient.auth.test.ts:134`), validando a garantia central do requisito ("mantendo o usuário autenticado").
- Estilo de mock de `@ionic/react` em `SubscriptionRequiredPage.test.tsx` segue exatamente a convenção já usada em outros testes de página do projeto (ex.: `AssociatePage.test.tsx`, `BudgetPage.test.tsx`).
- `npx tsc --noEmit` e `npx eslint` reexecutados de forma independente confirmam exatamente o que a task reportou, incluindo a confirmação (via `git stash`) de que o warning em `AuthContext.tsx` é pré-existente.

**Destaques adicionais da 2ª passada:**
- O tratamento de `402` no bootstrap é feito de forma determinística (seta o estado diretamente a partir do `catch` tipado, não depende de esperar o evento de `window` propagar), o que é mais robusto e testável do que depender só do `CustomEvent` — boa decisão de design que vai além do mínimo pedido.
- O `catch` diferenciado (`HttpError` com `status === 402` vs. qualquer outro erro) preserva com precisão cirúrgica o comportamento antigo de logout para sessão realmente inválida (ex. `401`, refresh token expirado) — nenhuma regressão no caminho de segurança mais crítico do fluxo de auth.
- `AuthContext.test.tsx` usa `vi.hoisted()` para expor uma classe `HttpError` de teste compatível com `instanceof` ao mock de `authService`, resolvendo corretamente a ordem de hoisting do `vi.mock` — solução tecnicamente correta para um problema comum em testes com Vitest.
- `SubscriptionRequiredPage.test.tsx` reescrito continua na mesma linha rigorosa do teste original: em vez de testar só a presença do botão de logout, testa que ele é o **único** botão da tela, prevenindo regressão futura de um link de pagamento sendo adicionado ao lado do logout.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK |
| Logging | N/A (sem alteração de logging nesta task) |
| React/Ionic | OK (corrigido na 2ª passada — ver Major #2, resolvido) |
| Testes | OK (corrigido na 2ª passada — ver Major #1, resolvido) |

## Recomendacoes

1. ~~Tratar o `402` também no caminho de bootstrap~~ — **feito e verificado na 2ª passada.**
2. ~~Adicionar um botão de logout em `SubscriptionRequiredPage`~~ — **feito e verificado na 2ª passada.**
3. Opcional/não bloqueante, ainda em aberto: alinhar as cores de `SubscriptionRequiredPage.css` aos tokens de `theme/variables.css` por consistência visual (não fazia parte do escopo desta 2ª passada).
4. Opcional/não bloqueante, novo: remover a redundância entre o texto visível "Sair da conta" e o `aria-label` idêntico no botão de `SubscriptionRequiredPage.tsx` — puramente cosmético para leitores de tela, sem impacto funcional.
5. Nenhuma ação obrigatória antes de mergear. Task 8.0 está pronta para o QA end-to-end contra o backend real (Tarefa 6.0), incluindo o cenário de cold start com assinatura cancelada enquanto o app estava fechado, que foi exatamente o gap coberto nesta correção.

## Veredito (revisão inicial — histórico)

Aprovado com observações. As quatro subtarefas (8.1-8.4) e os três testes exigidos foram implementados corretamente, seguindo fielmente os padrões já estabelecidos no `httpClient.ts`/`AuthContext.tsx`/`App.tsx` existentes, sem nenhum link, botão ou texto de checkout na tela de bloqueio (validado por teste dedicado), e sem nunca expor uma tela do app a um usuário com assinatura inativa — inclusive no caso adversarial de flag "grudada" com usuário deslogado. `tsc`, `eslint` e a suíte de testes relevante foram reexecutados de forma independente e confirmam o que foi reportado. As duas observações Major (bootstrap não detecta `402` via `authService`/`authFetch`, e ausência de logout na tela de bloqueio) são gaps reais de UX/fluxo que vale corrigir como follow-up antes do QA E2E contra o backend real, mas não bloqueiam esta task: nenhuma tela protegida chega a vazar para um usuário sem assinatura ativa, e a regra central do PRD (zero menção a pagamento) está corretamente implementada e testada.

## Veredito Final (2ª passada — 2026-09-09)

**Aprovado.** Os dois pontos Major identificados na revisão inicial foram corrigidos corretamente e verificados de forma independente nesta segunda passada:

1. O bootstrap agora trata `402` explicitamente em `AuthContext.tsx` (capturando `HttpError` do `authService.getMe()`) e `authFetch` em `authService.ts` dispara `ctrl:subscription-inactive` em `402`, cobrindo o cenário de cold start com assinatura cancelada enquanto o app estava fechado — o usuário passa a ver `SubscriptionRequiredPage` no boot em vez de ser jogado para o login. Comportamento de logout para sessão realmente inválida (`401`) preservado sem regressão.
2. `SubscriptionRequiredPage` agora tem um botão "Sair da conta" funcional, seguindo o padrão já usado em `ProfilePage`, sem violar a restrição de zero menção a pagamento (validado por teste que garante ser o único botão da tela).

Verificação independente nesta passada: suíte completa `npx vitest run` com 601/601 testes passando, `npx tsc --noEmit` sem erros, `npx eslint` nos arquivos tocados sem novos problemas (só o warning pré-existente em `AuthContext.tsx`, já confirmado como tal na revisão inicial). Diff real dos 4 arquivos de produção inspecionado linha a linha e corresponde ao que foi reportado. Nenhuma regressão foi encontrada nos pontos já aprovados na revisão inicial (os quatro pontos de checagem de `402` em `httpClient.ts`, o reset de `hasInactiveSubscription` em todas as transições de auth, o workaround do `IonRouterOutlet` em `App.tsx`, e a garantia de que nenhuma tela protegida vaza para um usuário sem assinatura ativa). Task 8.0 está pronta para prosseguir ao QA end-to-end contra o backend real (Tarefa 6.0).
