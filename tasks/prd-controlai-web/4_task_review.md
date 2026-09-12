# Review: Task 4.0 - Fluxo "Novo" na web aponta para ManualEntryPage

**Revisor**: AI Code Reviewer
**Data**: 2026-09-11
**Arquivo da task**: 4_task.md
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A implementação cumpre exatamente o que a Tarefa 4.0 pedia: um único ponto de checagem de plataforma (`getNewEntryPath()` em `src/config/platform.ts`) decide o destino do botão "Novo" — `/scanner` em build nativo, `/manual-entry` em build web — e tanto o `IonTabButton` (`App.tsx`) quanto o `WebSidebarMenu` passam a consumir essa mesma função, em vez de espalhar `Capacitor.isNativePlatform()` por múltiplos componentes (exigência explícita da skill `clean-code` no arquivo da tarefa). `ScannerPage.tsx` e `ManualEntryPage.tsx` não foram tocados por esta tarefa — confirmei isso por `git diff` de conteúdo e por timestamp de arquivo (ambos com última modificação em 9/set 20:26, dois dias antes dos arquivos desta tarefa, criados em 11/set entre 09:41 e 09:43), então as mudanças que aparecem nesses dois arquivos no working tree são de outra frente de trabalho (fix de URL SEFAZ http→https e reposicionamento do botão "voltar"), não desta tarefa.

Os três testes exigidos pelo arquivo da tarefa existem e passam: unidade de `getNewEntryPath` para os dois cenários de plataforma (`platform.test.ts`), unidade do item "Novo" do `WebSidebarMenu` para os dois cenários (`WebSidebarMenu.test.tsx`), e um teste de integração a nível de `App` (`App.newEntry.test.tsx`, novo) que confirma o `href` do `ion-tab-button[tab="novo"]` e que a rota certa monta a página certa (`ManualEntryPage` vs. `ScannerPage`) em cada plataforma. Reexecutei de forma independente: `npx vitest run` (607/607), `npx tsc --noEmit` (sem erros), `npx eslint` nos arquivos tocados por esta tarefa (sem problemas) e `npm run build` (build de produção concluído) — todos os relatos do executor se confirmaram.

Não há problema crítico ou major introduzido por esta tarefa. As observações abaixo são de higiene de repositório e de escopo (itens já sinalizados na review da Tarefa 3.0 e ainda não resolvidos por ninguém), não defeitos da implementação da Tarefa 4.0 em si.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/config/platform.ts` (novo) | OK | 0 |
| `src/config/platform.test.ts` (novo) | OK | 0 |
| `src/App.tsx` (mudança da Tarefa 4.0: import + `href={getNewEntryPath()}`) | OK | 0 |
| `src/components/WebSidebarMenu.tsx` | OK | 0 |
| `src/components/WebSidebarMenu.test.tsx` | OK | 0 |
| `src/App.newEntry.test.tsx` (novo) | OK | 1 (minor, ver abaixo) |
| `src/pages/ScannerPage.tsx` | Não alterado por esta tarefa (confirmado) | - |
| `src/pages/ManualEntryPage.tsx` | Não alterado por esta tarefa (confirmado) | - |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**1. `App.newEntry.test.tsx` — o 3º teste exigido ("sem regressão no `processInvoice`") é satisfeito por decomposição, não por exercício direto**

O arquivo da tarefa pede: *"Teste de integração: fluxo completo de `ManualEntryPage` a partir do clique em 'Novo' no build web (sem regressão no `processInvoice`)"*. `App.newEntry.test.tsx` mocka `ManualEntryPage` inteiramente (linha 27-29) — ele prova que a rota `/manual-entry` monta o componente certo (e não `ScannerPage`), mas não invoca `processInvoice` nem nada do fluxo interno da página. A cobertura real de `processInvoice` continua em `ManualEntryPage.test.tsx`, que não foi alterado por esta tarefa (logo, se ele continua passando — e passa, dentro dos 607 — não há regressão). Essa é uma decomposição de responsabilidade razoável e consistente com o padrão já estabelecido em `App.routing.test.tsx` (páginas mockadas, lógica interna testada em suíte própria), mas o nome do teste ("sem regressão no `processInvoice`") sugere mais cobertura do que ele de fato exerce.

**Sugestão**: um comentário de uma linha no teste, ou no `4_task.md`, deixando explícito que a garantia de "sem regressão no `processInvoice`" vem de `ManualEntryPage.test.tsx` permanecer verde (arquivo não tocado), e que este teste cobre apenas roteamento/montagem — evita que um leitor futuro pense que este teste chama `processInvoice` de fato.

**2. Working tree não isolado por tarefa — recomendação da Tarefa 3.0 ainda não endereçada**

O `git status`/`git diff` atual mistura os 6 arquivos desta tarefa com ~29 outros arquivos modificados de frentes de trabalho não relacionadas (`BudgetPeriodCard`, `PaymentMethodForm`, `budgetService`, fix de SEFAZ em `ScannerPage.tsx`, back-button em `ManualEntryPage.tsx`, etc.), nenhum deles commitado. A review da Tarefa 3.0 (`3_task_review.md`, Recomendação 4) já havia sinalizado exatamente este ponto e recomendado isolar o `git add` por tarefa antes de comitar — isso não foi feito entre a 3.0 e a 4.0, e o problema só cresce a cada tarefa que passa sem commit. Não bloqueia a Tarefa 4.0 (a tarefa em si está correta), mas o risco de um `git add -A` acidental misturando tudo num commit só aumenta.

**Sugestão**: antes de comitar a Tarefa 4.0, usar `git add` explícito nos arquivos desta tarefa (`src/config/platform.ts`, `src/config/platform.test.ts`, `src/App.newEntry.test.tsx`, e os hunks relevantes de `src/App.tsx`/`src/components/WebSidebarMenu.tsx`/`src/components/WebSidebarMenu.test.tsx` via `git add -p`, pulando o hunk do `ProtectedShell` em `App.tsx` que não pertence a esta tarefa).

**3. Débito herdado da Tarefa 3.0 ainda aberto (`ProtectedShell` em `App.tsx`)**

A review da Tarefa 3.0 já havia identificado (e confirmado por timestamp, como eu confirmei aqui novamente) que a extração de `ProtectedShell` em `App.tsx` é trabalho pré-existente de outra frente, não desta feature, e recomendou documentá-la na Tech Spec e cobri-la com teste de regressão antes de avançar para a Tarefa 4.0. Isso não foi feito. Não é uma responsabilidade da Tarefa 4.0 corrigir (o arquivo da Tarefa 4.0 não menciona `ProtectedShell` e a própria Tarefa 4.0 não introduziu nem tocou essa lógica), mas sinalizo para visibilidade: o débito continua acumulando silenciosamente numa peça de guard de autenticação.

## Destaques Positivos

- **Ponto único de checagem de plataforma, exatamente como a skill `clean-code` exigia**: `getNewEntryPath()` é a única função que chama `Capacitor.isNativePlatform()` para decidir o destino de "Novo"; `App.tsx` e `WebSidebarMenu.tsx` apenas consomem o resultado. Isso elimina o risco de os dois componentes divergirem no futuro.
- **`WebSidebarMenu.tsx` migrado de constante estática (`SIDEBAR_ITEMS`) para função (`buildSidebarItems()`)** é a mudança mínima e correta para permitir recomputar o path a cada render sem introduzir estado, efeitos colaterais ou complexidade desnecessária.
- **Cobertura de teste mapeia 1:1 com os 3 testes exigidos pelo arquivo da tarefa**, nem mais nem menos — sem testes redundantes ou tautológicos. As asserções verificam atributos reais (`href`) e presença/ausência de `data-testid`, não apenas a ausência de erro.
- **`App.newEntry.test.tsx` segue fielmente o padrão já estabelecido em `App.routing.test.tsx`** (mocks de páginas, `useAuth`, `setPath`/`afterEach` limpando a URL), mantendo consistência de estilo de teste no projeto em vez de introduzir um padrão novo.
- **Verificação de escopo restrito genuinamente cumprida**: `ScannerPage.tsx`/`ManualEntryPage.tsx` de fato não foram tocados por esta tarefa (confirmado por conteúdo do diff e por timestamp de arquivo), atendendo à restrição explícita do `4_task.md`.
- **Todas as validações do executor foram reproduzidas de forma independente e bateram exatamente**: 607/607 testes, `tsc --noEmit` limpo, `eslint` limpo nos arquivos tocados, `npm run build` concluído.
- **`WebSidebarMenu.tsx` já reflete o fix de `routerLink` recomendado no adendo da review da Tarefa 3.0** (`routerLink={item.path} routerDirection="none"`), mostrando continuidade e não regressão entre as tarefas.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (naming, tamanho, magic numbers) | OK |
| TypeScript | OK (`tsc --noEmit` sem erros) |
| React | OK |
| Ionic (`ionic-design`) | OK (nenhuma mudança de componente Ionic nesta tarefa alem do `href`) |
| Testes | OK (ver Minor #1 sobre a interpretação do 3º teste) |

## Recomendacoes

1. **(Antes do commit, não bloqueante para aprovar a tarefa)** Isolar o `git add` da Tarefa 4.0 aos seus próprios arquivos (`git add -p` em `App.tsx`/`WebSidebarMenu.tsx`), deixando as ~29 mudanças não relacionadas (Budget, PaymentMethod, fix SEFAZ, back-button) para seus próprios commits.
2. Adicionar um comentário curto em `App.newEntry.test.tsx` esclarecendo que a garantia de "sem regressão no `processInvoice`" vem de `ManualEntryPage.test.tsx` permanecer verde, já que a página é mockada neste teste de integração.
3. Endereçar separadamente (não bloqueia a Tarefa 4.0) o débito já sinalizado na review da Tarefa 3.0 sobre `ProtectedShell` (documentação na Tech Spec + teste de regressão para o cenário de `hasInactiveSubscription` mudando sem troca de pathname), antes que mais tarefas se acumulem sobre esse guard sem cobertura.

## Veredito

**Aprovado com observações.** A Tarefa 4.0 está funcionalmente completa e correta: os critérios de sucesso e as 3 subtarefas do `4_task.md` foram atendidos, os 3 testes exigidos existem e passam, a checagem de plataforma foi centralizada em um único ponto (`getNewEntryPath`) conforme a skill `clean-code` exigia, e as páginas de negócio (`ScannerPage`/`ManualEntryPage`) permaneceram intocadas, como a restrição do arquivo da tarefa exigia. Reexecutei de forma independente toda a suíte de testes, `tsc --noEmit`, `eslint` nos arquivos tocados e o build de produção — todos limpos, confirmando o relato do executor. Nenhum problema crítico ou major foi encontrado. As três observações minor (documentação do 3º teste, higiene de commit, e o débito herdado da Tarefa 3.0 sobre `ProtectedShell`) não bloqueiam o fechamento desta tarefa, mas devem ser resolvidas antes de comitar/avançar para evitar acúmulo silencioso de dívida técnica no repositório.
