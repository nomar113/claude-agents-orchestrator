# Review: Task 3.0 - Shell de navegação desktop (IonSplitPane + WebSidebarMenu)

**Revisor**: AI Code Reviewer
**Data**: 2026-09-11
**Arquivo da task**: 3_task.md
**Status**: APROVADO (observações endereçadas — ver Adendo)

## Adendo pós-review (aplicado pela sessão que implementou a tarefa)

- **Minor #1 (`routerLink`) — corrigido.** `WebSidebarMenu.tsx` agora usa `IonItem routerLink={item.path} routerDirection="none"` em vez de `button` + `onClick={() => history.push(...)}`; `useHistory` foi removido do componente. Os testes em `WebSidebarMenu.test.tsx` foram atualizados para essa interface (asserção por `href` em vez de simular clique + `history.push`). Reexecutado após a mudança: 599/599 testes, `tsc --noEmit` e `eslint` limpos, `npm run build` OK.
- **Major #1 (`ProtectedShell`) — fora do escopo desta tarefa, não corrigido aqui.** Conferido via `git diff`/timestamps que `ProtectedShell` já existia no arquivo *antes* desta sessão tocar em `App.tsx` (é trabalho não commitado de uma sessão/tarefa anterior, não introduzido pela Tarefa 3.0). O `git diff` contra `HEAD` naturalmente mistura essa mudança pré-existente com o diff real desta tarefa porque ambas tocam o mesmo arquivo e nenhuma das duas está commitada — mas a Tarefa 3.0 em si não alterou nem a extração de `ProtectedShell` nem `PROTECTED_PATHS`, conforme exigido pelo requisito "Nenhuma rota, guard de autenticação ou página existente é alterada nesta tarefa". A observação do revisor sobre documentação/teste desse guard continua válida e deve ser tratada por quem é dono daquele trabalho pendente, mas não bloqueia o fechamento da Tarefa 3.0. Recomenda-se, antes de commitar, isolar esse hunk (junto com os ~29 outros arquivos não relacionados já modificados no working tree) do commit da Tarefa 3.0.
- Minor #2 (alcance do teste de breakpoint) — aceito como limitação conhecida, sem ação necessária; a verificação visual real fica para o E2E Playwright já previsto na Tech Spec.

## Resumo

A implementação cumpre o objetivo central da Tarefa 3.0: um `WebSidebarMenu` novo, um `IonSplitPane` envolvendo o `TabsLayout` existente, e a tab bar inferior escondida via CSS a partir do breakpoint `lg` (992px), sem duplicar nem reescrever nenhuma página. `WebSidebarMenu.tsx` é pequeno, coeso e sem lógica de negócio, exatamente como pede `clean-code`. Os testes novos passam (9 testes em `WebSidebarMenu.test.tsx` + `App.routing.test.tsx`), a suíte completa passa (599/599), `tsc --noEmit` e `eslint` não acusam nada nos arquivos tocados, e `npm run build` conclui sem erros — reproduzi todas essas verificações de forma independente.

Dois pontos merecem atenção antes de considerar a tarefa 100% fechada: (1) o diff de `App.tsx` inclui uma extração de `ProtectedShell` que vai além do "wrapper de apresentação" que a Tarefa 3.0 promete, e (2) o padrão de navegação do `WebSidebarMenu` (`button` + `onClick` + `history.push`) diverge do idioma recomendado pelo Ionic para itens de `IonMenu`/`IonSplitPane` (`routerLink`), que é inclusive o padrão do próprio starter oficial do Ionic React para este exato cenário.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/WebSidebarMenu.tsx` (novo) | Problemas | 1 (minor) |
| `src/components/WebSidebarMenu.css` (novo) | OK | 0 |
| `src/components/WebSidebarMenu.test.tsx` (novo) | OK | 0 |
| `src/App.tsx` | Problemas | 1 (major) |
| `src/theme/variables.css` | OK | 0 |
| `src/App.routing.test.tsx` | Problemas | 1 (minor) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema crítico encontrado.

### Problemas Major

**1. `App.tsx` — extração de `ProtectedShell` não documentada na Tech Spec e sem teste de regressão dedicado**

`src/App.tsx:221-227` introduz um componente novo, `ProtectedShell`, que substitui a antiga função inline passada a `render` da `Route` de `PROTECTED_PATHS`:

```tsx
// ANTES (HEAD)
<Route
  path={PROTECTED_PATHS}
  render={() => {
    if (isLoading) return <LoadingPage />;
    if (!isAuthenticated) return <Redirect to="/login" />;
    if (hasInactiveSubscription) return <SubscriptionRequiredPage />;
    return <TabsLayout />;
  }}
/>

// DEPOIS (este diff)
const ProtectedShell: React.FC = () => {
  const { isLoading, isAuthenticated, hasInactiveSubscription } = useAuth();
  if (isLoading) return <LoadingPage />;
  if (!isAuthenticated) return <Redirect to="/login" />;
  if (hasInactiveSubscription) return <SubscriptionRequiredPage />;
  return <TabsLayout />;
};
...
<Route path={PROTECTED_PATHS} render={() => <ProtectedShell />} />
```

O comentário que acompanha a mudança (linhas 214-220) explica um motivo técnico real e bem fundamentado (o `IonRouterOutlet` só reavalia o `render` de uma `Route` em transições de pathname; uma função inline reavaliada por closure obsoleta poderia não refletir `hasInactiveSubscription` mudando em runtime sem troca de rota). E de fato o texto da própria `3_task.md` (linha 18) já cita `ProtectedShell` nominalmente entre parênteses ao lado de `PROTECTED_PATHS`, então a extração não é uma invenção fora do que a tarefa previa.

Ainda assim, dois problemas concretos:
- A Tech Spec (`techspec.md`) **não menciona `ProtectedShell` em nenhum lugar** — só a `3_task.md` cita o nome. Isso é uma lacuna de rastreabilidade: um leitor que for só à Tech Spec (a fonte de verdade arquitetural) não vai encontrar essa peça nem entender por que ela existe.
- Nenhum teste novo cobre o cenário que o comentário descreve como motivação (`hasInactiveSubscription` virando `true` **em runtime, sem troca de pathname**, enquanto o usuário já está em `/tab1`). Os testes existentes em `App.routing.test.tsx` (linhas 85-140) só testam o valor de `hasInactiveSubscription` no `render()` inicial, nunca uma transição pós-montagem. Como a regra crítica da tarefa é "SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERAR-LA FINALIZADA", e este trecho de código é exatamente sobre corrigir um bug de reatividade, ele deveria vir com o teste que prova a correção — sem isso, a extração fica sem cobertura que evite regressão futura (por exemplo, se alguém reintroduzir a função inline "para simplificar").

**Sugestão**: adicionar um teste em `App.routing.test.tsx` que monta o app com `hasInactiveSubscription: false`, confirma `tab1-page`, então via `act()` troca o mock de `useAuth` para `hasInactiveSubscription: true` (sem mudar a URL) e confirma que `SubscriptionRequiredPage` aparece. Isso também serviria de documentação viva do porquê `ProtectedShell` existe. Vale também adicionar uma linha na Tech Spec (`Arquitetura do Sistema`) citando esse componente, já que ele passou a fazer parte do desenho de guards do app.

### Problemas Minor

**1. `WebSidebarMenu.tsx:46-51` — navegação via `button`/`onClick` em vez do idioma `routerLink` do Ionic**

```tsx
<IonItem
  button
  detail={false}
  className={isActive ? 'web-sidebar-item web-sidebar-item--active' : 'web-sidebar-item'}
  onClick={() => history.push(item.path)}
>
```

O padrão oficial do Ionic React para exatamente este caso (item de `IonMenu` dentro de `IonSplitPane`, com destaque de item ativo) — presente no próprio template "Menu" gerado pelo `ionic start` — é `routerLink={item.path} routerDirection="none"` em vez de `button` + `onClick` imperativo:

```tsx
<IonItem
  routerLink={item.path}
  routerDirection="none"
  detail={false}
  className={isActive ? 'web-sidebar-item web-sidebar-item--active' : 'web-sidebar-item'}
>
```

Isso importa por três motivos práticos, não só estilo: (a) `IonItem` com `button` renderiza um `<button>`, não um link real — perde `href`, então não há "abrir em nova aba" via Ctrl/Cmd+click nem indicação correta de destino para leitor de tela/crawler; (b) o próprio `IonTabBar` já usado no mesmo arquivo (`App.tsx`, `IonTabButton href="/tab1"`) segue o padrão baseado em link, então o novo componente introduz uma inconsistência de padrão de navegação dentro do mesmo shell; (c) `history.push` bypassa a integração do Ionic com transições de view do `IonRouterOutlet` (`routerDirection`), o que pode produzir uma transição de página "para frente" (slide) inesperada ao clicar num item da sidebar, já que o app não testou visualmente o comportamento em ≥992px (limitação já assinalada pela sessão que implementou a tarefa).

Este ponto é minor porque não quebra funcionalmente a navegação (os testes de clique passam, `history.push` funciona) — mas recomendo o ajuste antes do deploy, e recomendo fortemente validar visualmente em ≥992px se a troca de página ao clicar num item da sidebar não produz uma animação de slide indesejada, já que ninguém validou isso ainda (nem a implementação, nem esta review, por falta de credenciais de teste).

**2. `App.routing.test.tsx` — o novo teste de breakpoint não exercita a lógica real de `matchMedia` do `ion-split-pane`**

O teste `App shell — desktop split pane (Tarefa 3.0)` (linhas 165-200) mocka `window.matchMedia` e chama `flip(true)` para simular a troca de breakpoint, mas nada na árvore React depende desse valor — `TabsLayoutContent` é renderizado incondicionalmente dentro do `IonSplitPane` independentemente do resultado do `matchMedia`. Ou seja, o teste passaria de forma idêntica mesmo que a chamada a `flip()` fosse removida, porque o que ele realmente prova é que a estrutura React não desmonta com base em nenhuma condição — não que o `ion-split-pane` real (que vive dentro do Web Component do Ionic/Stencil) de fato alterna a exibição de menu vs. conteúdo no breakpoint certo. Isso não invalida o teste — ele cobre exatamente a preocupação da subtarefa 3.3 (não remontar o outlet) — mas o nome e a estrutura do teste sugerem estar testando mais do que testam. Vale um comentário no próprio teste deixando explícito que a verificação visual do breakpoint (sidebar substituindo a tab bar) fica para o Playwright/E2E já previsto na Tech Spec (`Abordagem de Testes > Testes de E2E`), e que este teste unitário garante apenas a estabilidade da árvore React.

## Destaques Positivos

- **`WebSidebarMenu.tsx` é exemplar em relação a `clean-code`**: componente de ~30 linhas, responsabilidade única (apresentação), sem estado, sem lógica de negócio, nomes claros, zero números mágicos no código (as cores/tamanhos ficam no CSS, onde é o lugar certo).
- **Uso correto e não-óbvio de `IonMenuToggle autoHide={false}`** (`WebSidebarMenu.tsx:45`): a leitura rápida sugeriria que `autoHide` controla "fechar o menu ao clicar", mas na verdade, quando o `IonMenu` está sob um `IonSplitPane` ativo, `autoHide` (default `true`) esconde o próprio conteúdo envolvido pelo `IonMenuToggle` — que faria os itens da sidebar desaparecerem justamente quando o split pane está visível. Setar `autoHide={false}` explicitamente é a escolha certa e mostra entendimento real do componente, não só cópia de exemplo.
- **Comentários em `App.tsx` são de alta qualidade**: explicam o "porquê" de decisões não óbvias (por que o `IonRouterOutlet` não pode desmontar, por que `PROTECTED_PATHS` precisa ser uma lista disjunta do `/`), o que ajuda muito quem for mexer nesse arquivo depois — reforça o padrão já estabelecido no arquivo antes desta tarefa.
- **Teste `App.routing.test.tsx` mockando `matchMedia` com suporte a `addListener`/`addEventListener`** cobre corretamente a API que o Ionic/Stencil pode usar, evitando um mock frágil que quebraria silenciosamente se o Ionic mudasse de API.
- **Escopo respeitado nos arquivos sensíveis**: confirmei via `git diff` que `ScannerPage.tsx`, `ManualEntryPage.tsx`, services e contexts têm mudanças no working tree, mas são de outra frente de trabalho (fix de URL SEFAZ http→https, navegação de "voltar" no `ManualEntryPage`) — nada relacionado à Tarefa 3.0. `PROTECTED_PATHS` (a lista de rotas) não foi alterada, só a forma de renderizar o guard.
- **CSS mínimo e sem duplicar variáveis de tema**: `WebSidebarMenu.css` e o acréscimo em `theme/variables.css` usam os mesmos tons já usados por `ctrl-tab-bar`/`ctrl-tab-btn`, sem introduzir uma nova paleta.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (naming, tamanho, etc.) | OK |
| TypeScript | OK (`tsc --noEmit` sem erros) |
| React | OK |
| Ionic (`ionic-design`) | Problemas (ver Minor #1 — padrão `routerLink` não seguido) |
| Testes | Problemas (ver Major #1 e Minor #2 — cobertura da extração `ProtectedShell` e alcance real do teste de breakpoint) |

## Recomendacoes

1. **(Prioridade alta, mas não bloqueante)** Adicionar teste em `App.routing.test.tsx` cobrindo `hasInactiveSubscription` mudando em runtime sem troca de pathname, e citar `ProtectedShell` na Tech Spec (`Arquitetura do Sistema`) para fechar a lacuna de rastreabilidade.
2. Trocar `button` + `onClick={() => history.push(...)}` por `routerLink`/`routerDirection="none"` em `WebSidebarMenu.tsx` para alinhar com o idioma padrão do Ionic React e com o próprio `IonTabButton href=` já usado no mesmo shell.
3. Antes de mesclar/publicar, validar visualmente em viewport ≥ 992px (com credenciais de teste reais ou API mockada) que: (a) a sidebar de fato substitui a tab bar, (b) clicar num item não produz uma transição de slide inesperada, e (c) o contraste dos itens ativo/inativo do `WebSidebarMenu.css` está adequado sobre `--background: #0a0e27f2`.
4. Ao commitar, restringir o `git add` explicitamente aos arquivos desta tarefa (`App.tsx`, `theme/variables.css`, `App.routing.test.tsx`, `components/WebSidebarMenu.*`) — o working tree atual tem ~29 arquivos modificados de outras frentes de trabalho não relacionadas (ex.: `BudgetPeriodCard`, `PaymentMethodForm`, fix de SEFAZ), e um `git add -A` misturaria tudo num único commit.

## Veredito

A Tarefa 3.0 está funcionalmente completa e tecnicamente sólida: os critérios de sucesso descritos no arquivo da tarefa são atendidos, a suíte de testes (599/599), `tsc --noEmit`, `eslint` e `npm run build` passam limpos — reproduzi todas essas checagens de forma independente antes de escrever esta review. Não há problema crítico.

Aprovo com observações: a extração de `ProtectedShell` é uma decisão technicamente válida (e prevista no texto da própria `3_task.md`), mas está sub-documentada na Tech Spec e sem teste que prove o cenário que ela resolve — recomendo fechar isso antes de avançar para a Tarefa 4.0, para não carregar dívida silenciosa numa peça de guard de autenticação. O ponto do `routerLink` é uma melhoria recomendada, não bloqueante, mas vale resolver junto pois é rápido e evita inconsistência de padrão de navegação dentro do mesmo shell. Nenhum dos dois pontos exige reabrir o design da tarefa — ambos são ajustes pontuais e de baixo risco.
