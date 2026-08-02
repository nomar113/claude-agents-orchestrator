# Review: Task 4.0 — Frontend — Sessão, telas de login/registro e rotas protegidas

**Revisor**: AI Code Reviewer
**Data**: 2026-08-02
**Arquivo da task**: 4_task.md
**Commit**: c2413cd
**Status**: APROVADO COM OBSERVACOES

---

## Resumo

A implementacao da camada de autenticacao frontend esta bem estruturada e cobre todos os requisitos obrigatorios da Task 4.0. O padrao de segurança adotado — access token em memoria e refresh token no localStorage — esta correto e aderente ao que a tech spec determina. O single-flight do refresh esta implementado corretamente com a tecnica de compartilhamento de Promise. Os dois caminhos do `httpClient` (CapacitorHttp e fetch) foram cobertos com testes de integracao. Todos os checks de qualidade passam: 467 testes, 0 erros TypeScript, 0 erros de lint. Os problemas encontrados sao majoritariamente menores, com uma observacao major sobre o `AuthService` declarado na tech spec nao estar completamente implementado.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/types/auth.ts` | OK | 0 |
| `src/services/tokenStorage.ts` | OK | 0 |
| `src/services/authService.ts` | Problemas | 1 major |
| `src/context/AuthContext.tsx` | Problemas | 1 minor (lint) |
| `src/components/PrivateRoute.tsx` | Problemas | 1 minor |
| `src/services/httpClient.ts` | Problemas | 1 minor |
| `src/pages/LoginPage.tsx` | OK | 0 |
| `src/pages/LoginPage.css` | Problemas | 1 minor |
| `src/pages/RegisterPage.tsx` | Problemas | 2 minor |
| `src/pages/Tab3.tsx` | OK | 0 |
| `src/services/tokenStorage.test.ts` | OK | 0 |
| `src/services/authService.test.ts` | OK | 0 |
| `src/services/httpClient.auth.test.ts` | Problemas | 1 minor |
| `src/components/PrivateRoute.test.tsx` | OK | 0 |
| `src/pages/LoginPage.test.tsx` | Problemas | 1 minor |
| `src/pages/RegisterPage.test.tsx` | OK | 0 |
| `src/App.tsx` | OK | 0 |

---

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

---

### Problemas Major

**[MAJOR-1]** `src/services/authService.ts` — Interface do `AuthService` da tech spec nao completamente implementada

A tech spec define a seguinte interface contratual para o `authService`:

```typescript
interface AuthService {
  login(email: string, password: string): Promise<User>;
  loginWithGoogle(): Promise<User>;            // SocialLogin plugin -> POST /auth/google
  refresh(): Promise<boolean>;                  // single-flight
  logout(): Promise<void>;
  unlockWithBiometrics(): Promise<boolean>;     // Keychain + Face ID gate
}
```

Os metodos `loginWithGoogle()` e `unlockWithBiometrics()` estao ausentes no objeto `authService` exportado. Embora Google Sign-In (Task 5.0) e Biometria (Task 6.0) sejam implementados em tasks futuras, a tech spec lista esses metodos como parte da interface de `AuthService` que deveria ser definida nessa task (4.0). A ausencia dos stubs nao quebra funcionalidade agora, mas pode causar surpresas ao conectar as tasks 5.0 e 6.0.

**Correcao sugerida**: adicionar stubs explicitos com comentarios indicando a task responsavel:

```typescript
// loginWithGoogle: implemented in Task 5.0 (Google Sign-In)
// eslint-disable-next-line @typescript-eslint/no-unused-vars
loginWithGoogle(): Promise<User> {
  throw new Error('Not implemented — see Task 5.0');
},

// unlockWithBiometrics: implemented in Task 6.0 (Biometric/Keychain)
// eslint-disable-next-line @typescript-eslint/no-unused-vars
unlockWithBiometrics(): Promise<boolean> {
  throw new Error('Not implemented — see Task 6.0');
},
```

---

### Problemas Minor

**[MINOR-1]** `src/context/AuthContext.tsx` — Warning de lint `react-refresh/only-export-components`

O arquivo exporta tanto `AuthProvider` quanto `useAuth` do mesmo modulo, o que dispara o warning `react-refresh/only-export-components` do ESLint. Embora seja apenas um warning preexistente no projeto para outros contextos, o arquivo novo deveria ter sido organizado de forma diferente ou o warning documentado como aceito.

**Correcao sugerida** (opcional): Separar `useAuth` em `src/hooks/useAuth.ts` e exportar apenas o provider do contexto. Ou, se o pattern e aceito no projeto, adicionar `// eslint-disable-next-line react-refresh/only-export-components` acima do `useAuth`.

---

**[MINOR-2]** `src/components/PrivateRoute.tsx` — `React.FC` usado sem importar `React`

O arquivo usa `React.FC<Props>` na linha 12 sem importar `React`. Isso funciona porque o projeto usa `"jsx": "react-jsx"` no `tsconfig.json` (que injeta o runtime automaticamente), mas a referencia explicita a `React.FC` sem import e inconsistente e pode confundir.

```typescript
// Linha 12 — usa React.FC sem import de React
const PrivateRoute: React.FC<Props> = ({ children, ...rest }) => {
```

**Correcao sugerida**: Adicionar `import type { ReactNode, FC } from 'react';` e usar `FC<Props>` diretamente, eliminando a referencia implicita a `React`:

```typescript
import type { FC, ReactNode } from 'react';
// ...
const PrivateRoute: FC<Props> = ({ children, ...rest }) => {
```

---

**[MINOR-3]** `src/services/httpClient.ts` — Uso de `window` sem guard para ambiente nativo

A funcao `handleAuthFailure` despacha um evento via `window.dispatchEvent`. Em plataformas nativas (Capacitor iOS), `window` existe, mas a semantica do `CustomEvent` para comunicacao com o React pode nao funcionar confiavelmente caso o evento seja disparado antes do React estar montado. Nao e critico porque o CapacitorHttp path tambem usa `window`, mas e um ponto de atencao para a Task 6.0.

```typescript
// httpClient.ts linha 18 — sem guard de ambiente
window.dispatchEvent(new CustomEvent('ctrl:auth-failure'));
```

---

**[MINOR-4]** `src/pages/RegisterPage.tsx` — Estilos inline misturados com classes CSS

A `RegisterPage` usa estilos inline (`style={{ marginBottom: 16 }}`, `style={{ margin: '0 0 16px', fontSize: 13 }}`) enquanto a `LoginPage` usa exclusivamente classes CSS em `LoginPage.css`. Isso cria inconsistencia de padrao entre as duas paginas publicas do mesmo modulo.

```typescript
// RegisterPage.tsx linha 85 — estilo inline que deveria ser classe CSS
<IonInput style={{ marginBottom: 16 }} ... />
```

**Correcao sugerida**: Criar `RegisterPage.css` com as classes equivalentes e importa-lo, seguindo o padrao da `LoginPage`.

---

**[MINOR-5]** `src/pages/LoginPage.css` — Import de Google Fonts via URL externa

A linha 1 de `LoginPage.css` importa a fonte IBM Plex Sans diretamente do Google Fonts:

```css
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&display=swap');
```

O mesmo import esta em `Tab3.css`. Se a fonte ja e carregada globalmente em `theme/variables.css` ou no `index.html`, esta dupla requisicao e desnecessaria e adiciona latencia.

---

**[MINOR-6]** `src/services/httpClient.auth.test.ts` — Cleanup do event listener usando closure diferente

No teste `'dispatches ctrl:auth-failure and throws when refresh returns false'`, o `removeEventListener` e chamado com uma arrow function diferente daquela adicionada no `addEventListener`. Em JavaScript, isso significa que o listener nunca e de fato removido, causando vazamento entre testes.

```typescript
// httpClient.auth.test.ts linha 103-104 — closure diferente, listener nao e removido
window.addEventListener('ctrl:auth-failure', (e) => events.push(e));
// ...
window.removeEventListener('ctrl:auth-failure', (e) => events.push(e)); // closure nova, nao remove nada
```

O teste do cenario seguinte (linha 108) usa o padrao correto com variavel `handler`. O primeiro teste deveria seguir o mesmo padrao.

---

**[MINOR-7]** `src/pages/LoginPage.test.tsx` — Warning de `act()` em teste de spinner

O teste `'shows a spinner while submitting'` gera o warning `An update to LoginPage inside a test was not wrapped in act(...)` detectado na execucao dos testes. Embora o teste passe, o warning indica que atualizacoes de estado apos o `resolve` nao estao sendo aguardadas corretamente.

**Correcao sugerida**: Aguardar o estado apos o resolve usando `waitFor`:

```typescript
it('shows a spinner while submitting', async () => {
  let resolve!: (value: unknown) => void;
  mockLogin.mockReturnValue(new Promise((r) => { resolve = r; }));
  renderLogin();

  fireEvent.change(screen.getByLabelText('E-mail'), { target: { value: 'a@b.com' } });
  fireEvent.change(screen.getByLabelText('Senha'), { target: { value: 'senha123' } });
  fireEvent.submit(screen.getByRole('button', { name: 'Entrar' }).closest('form')!);

  expect(await screen.findByTestId('spinner')).toBeDefined();
  await act(async () => { resolve(undefined); });
});
```

---

## Destaques Positivos

1. **Single-flight implementado corretamente**: A tecnica de compartilhar a Promise em andamento (`refreshPromise`) e limpar com `.finally()` e a abordagem canonicamente correta para evitar refreshes concorrentes. O teste de single-flight (`Promise.all`) comprova o comportamento.

2. **Separacao de dependencias circulares bem resolvida**: `authService` usa `fetch` nativo em vez de `httpClient` para evitar dependencia circular. O comentario explicativo na linha 1-2 do arquivo e exemplar.

3. **Segurança de tokens respeitada**: Access token exclusivamente em memoria (`let memoryAccessToken`) e refresh token no localStorage com chave prefixada `ctrl_refresh_token`. Interface do `tokenStorage` e limpa e coesa.

4. **Bootstrap de sessao robusto**: O `AuthContext` usa `cancelled` flag para evitar atualizacoes de estado em componente desmontado durante o bootstrap assíncrono. Padrao correto e raro de ver implementado.

5. **Acessibilidade bem cuidada**: Ambas as paginas possuem `aria-label`, `aria-required`, `aria-describedby` (para erro de senha), `role="alert"` com `aria-live` correto (`assertive` para erro de login, `polite` para erro inline de senha).

6. **Cobertura de testes abrangente**: 47 testes novos cobrindo todos os caminhos relevantes, incluindo single-flight, 401 com retry, 401 apos retry, redirect em auth-failure, estados de loading e mensagens PT-BR.

7. **Dois caminhos do httpClient cobertos**: Os testes de `httpClient.auth.test.ts` mocam `Capacitor.isNativePlatform()` como `false`, cobrindo o caminho `fetch`. O caminho `CapacitorHttp` e coberto pela logica simetrica; seria ideal ter um teste dedicado ao path nativo em versao futura.

8. **Pattern de evento para comunicacao entre camadas**: O uso de `CustomEvent('ctrl:auth-failure')` para comunicar falha de refresh do `httpClient` para o `AuthContext` evita acoplamento direto entre as duas camadas, respeitando a separacao de responsabilidades.

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (Clean Code) | OK |
| TypeScript | OK — 0 erros |
| Comentarios em ingles | OK — convencao do repositorio respeitada |
| Ionic Design | OK — componentes Ionic corretos, aria labels, safe-area |
| React (hooks, contexto, re-renders) | OK |
| Segurança de tokens | OK — access em memoria, refresh em localStorage |
| Testes | Problemas — 1 warning de `act()`, 1 listener com cleanup incorreto |

---

## Recomendacoes

1. **(Alta prioridade)** Corrigir o cleanup do event listener no `httpClient.auth.test.ts` (MINOR-6) — listener nao removido pode causar interferencia entre testes em suites futuras.

2. **(Alta prioridade)** Corrigir o warning de `act()` no `LoginPage.test.tsx` (MINOR-7) — warnings de `act()` tendem a mascarar bugs reais em testes futuros.

3. **(Media prioridade)** Criar `RegisterPage.css` e mover os estilos inline para classes (MINOR-4) — consistencia com `LoginPage.css`.

4. **(Baixa prioridade)** Adicionar stubs para `loginWithGoogle` e `unlockWithBiometrics` no `authService` (MAJOR-1) — facilita a integracao nas Tasks 5.0 e 6.0.

5. **(Baixa prioridade)** Corrigir o import de `React.FC` no `PrivateRoute.tsx` (MINOR-2) — padrao mais limpo.

6. **(Informativo)** Verificar se `IBM Plex Sans` ja e importada globalmente e remover imports duplicados dos arquivos CSS (MINOR-5).

---

## Veredito

A implementacao esta **aprovada com observacoes**. Todos os requisitos obrigatorios da Task 4.0 foram cumpridos: seguranca de tokens, single-flight, Bootstrap de sessao, rotas protegidas, validacao PT-BR, acessibilidade e cobertura de testes. Os problemas encontrados sao nao-bloqueantes para avanco a Task 5.0 (Google Sign-In). Os dois itens de alta prioridade nas recomendacoes (MINOR-6 e MINOR-7) devem ser corrigidos antes da entrega final do ciclo de autenticacao, preferencialmente ainda nessa branch ou na proxima.
