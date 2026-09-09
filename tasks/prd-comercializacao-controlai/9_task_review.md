# Review: Task 9.0 - Frontend — remoção do fluxo de cadastro público

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 9_task.md
**Status**: APROVADO

## Resumo

A implementação remove corretamente a rota pública `/register`, o botão "Criar conta" da `LoginPage` e os arquivos `RegisterPage.tsx/.css/.test.tsx`, alinhada à decisão de negócio de que o único ponto de entrada de novas contas passa a ser a compra na Kiwify (espelhando a Tarefa 7.0 no backend). `tsc --noEmit` está limpo e a suíte `vitest` (594 testes) passa, incluindo o novo teste de roteamento que confirma que `/register` não renderiza mais nenhuma página.

**Atualização desta revisão**: os achados Major #1 e Minor #1 da versão anterior deste review (teste E2E Playwright órfão referenciando `/register`) foram corrigidos:
- `e2e/auth.spec.ts` — o teste `'register → login → empty state on tab1'` foi reescrito para `'new user login → empty state on tab1'`: em vez de navegar para `/register` e preencher o formulário de cadastro (que não existe mais), agora faz login direto via `loginSession: fixtures.newUserSession` e valida o mesmo estado vazio em `/tab1`, com um comentário explicando a mudança de fluxo.
- `e2e/helpers/apiMocks.ts` — a opção `registerSession` e o mock de `POST /auth/register` foram removidos por terem ficado sem uso.
- `e2e/diag.spec.ts` e `e2e/debug.spec.ts` — os testes de diagnóstico que apontavam para `/register` foram removidos, mantendo os equivalentes para `/login`/`/tab1`.

Validei de forma independente: `grep -rni register e2e/` só retorna um comentário informativo (nenhuma referência funcional restante); `npx tsc --noEmit` e `npx eslint e2e/debug.spec.ts e2e/diag.spec.ts e2e/auth.spec.ts e2e/helpers/apiMocks.ts` sem problemas; `npx playwright test --list` nesses três arquivos coleta os 7 testes esperados sem erro, incluindo o teste renomeado; e `fixtures.newUserSession`/`newUserProfile` continuam com uso real (não viraram código morto).

A decisão de escopo de não remover `register` de `authService.ts`/`AuthContext.tsx` (Recomendação #3 da versão anterior) foi mantida deliberadamente fora desta task, o que é razoável dado que nenhum dos dois arquivos consta na lista de "Arquivos Relevantes" da Tarefa 9.0/Tech Spec para este passo. Continua registrada abaixo como dívida técnica não bloqueante (ver Problemas Minor e Recomendações).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/App.tsx` | OK | 0 |
| `src/pages/LoginPage.tsx` | OK | 0 |
| `src/pages/LoginPage.css` | OK | 0 |
| `src/pages/RegisterPage.tsx` (deletado) | OK | 0 |
| `src/pages/RegisterPage.css` (deletado) | OK | 0 |
| `src/pages/RegisterPage.test.tsx` (deletado) | OK | 0 |
| `src/App.routing.test.tsx` (novo teste adicionado) | OK | 0 |
| `e2e/auth.spec.ts` | OK (corrigido) | 0 |
| `e2e/diag.spec.ts`, `e2e/debug.spec.ts` | OK (corrigido) | 0 |
| `e2e/helpers/apiMocks.ts` | OK (corrigido) | 0 |
| `src/services/authService.ts` / `src/context/AuthContext.tsx` (fora do escopo desta task) | Observação | 1 (minor/dívida técnica) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado. (O achado anterior — teste E2E `e2e/auth.spec.ts` órfão referenciando `/register` — foi corrigido: ver "Resumo" e "Destaques Positivos".)

### Problemas Minor

1. **`src/services/authService.ts:80-82` e `src/context/AuthContext.tsx` — `register` virou código morto de produção.**
   Confirmado via busca (`grep -rln ".register(\|register:" src --include="*.tsx" --include="*.ts"`) que, fora da própria definição em `AuthContext.tsx`, não há nenhum chamador de `register`/`useAuth().register` em `src` depois da remoção de `RegisterPage`. O backend (Tarefa 7.0) já não aceita mais `POST /auth/register`. Manter essa função foi uma decisão de escopo defensável (não está na lista de "Arquivos Relevantes" desta task, e removê-la exigiria atualizar mocks em `AuthContext.test.tsx`, `App.routing.test.tsx`, `LoginPage.test.tsx`, `ProfilePage.test.tsx`), mas é exatamente o tipo de código morto que a subtarefa 9.3 justificou evitar ao deletar `RegisterPage` em vez de só desconectá-la. Sugiro abrir uma tarefa de limpeza dedicada (ver Recomendações) em vez de expandir o escopo desta.

## Destaques Positivos

- Decisão de deletar `RegisterPage.tsx/.css/.test.tsx` em vez de apenas desconectar da rota, evitando código morto na página em si — coerente com a recomendação do próprio arquivo de tarefa.
- `src/App.routing.test.tsx` cobre o caso relevante (`/register` não renderiza `LoginPage` nem `Tab1` nem qualquer texto de "Register"), e o mock de `RegisterPage` órfão foi corretamente removido do arquivo.
- CSS de `LoginPage` ajustado corretamente (`justify-content: space-between` → `center`) para o único link restante, sem deixar espaçamento estranho.
- Nenhum outro ponto do app (menus, textos, CTAs) oferece caminho de autocadastro — confirmado por busca textual (`cadastr`, `criar conta`, `sign up`) em todo `src/`.
- `tsc --noEmit` limpo e suíte `vitest` completa passando (594 testes), validado de forma independente nesta revisão.
- Teste E2E de cadastro corrigido de forma consistente com o resto do fluxo real (login direto de conta nova, em vez de tentar simular um cadastro que não existe mais), com comentário explicando a mudança para quem ler o histórico depois. Fixtures e mocks (`registerSession`, `POST /auth/register`) removidos junto, sem deixar código morto no helper de E2E.
- Especificações de debug (`diag.spec.ts`, `debug.spec.ts`) limpas dos casos que apontavam para `/register`, mantendo os testes de diagnóstico ainda úteis (`/login`, `/tab1`).
- `npx playwright test --list` confirma que os 3 arquivos de E2E tocados continuam coletando corretamente (7 testes), sem erro de sintaxe ou referência quebrada.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| React | OK |
| Testes | OK |

## Recomendacoes

1. Abrir uma tarefa de limpeza técnica (fora desta Tarefa 9.0) para remover `register` de `authService.ts` e `AuthContext.tsx`, atualizando os mocks de teste que hoje dependem dele (`AuthContext.test.tsx`, `App.routing.test.tsx`, `LoginPage.test.tsx`, `ProfilePage.test.tsx`).
2. Antes de commitar, separar por tarefa: o `git status` do repositório mistura as mudanças desta Tarefa 9.0 com trabalho já em andamento de outra tarefa (gate de assinatura/402 em `AuthContext.tsx`, `authService.ts`, `SubscriptionRequiredPage.*`) e com diversos arquivos não relacionados (`BudgetPeriodCard`, `PaymentMethodCard`, `ScannerPage` etc.). Recomendo commitar apenas os arquivos listados em "Arquivos Revisados" acima para esta tarefa, mantendo o restante para os commits das tarefas correspondentes.

## Veredito

A implementação cumpre os critérios de sucesso da Tarefa 9.0: a rota `/register` deixou de existir, o único CTA de autocadastro foi removido da tela de login, e toda a suíte de testes — unitária (`vitest`) e E2E (`playwright`) — está livre de referências ao fluxo de cadastro removido, sem testes órfãos. Não há problemas críticos nem major pendentes.

Está **APROVADO**. A única observação remanescente (`register` morto em `authService.ts`/`AuthContext.tsx`) é dívida técnica fora do escopo desta task, já registrada como recomendação de tarefa futura, e não bloqueia o avanço.
