# Tech Spec: ControlAI Web

## Resumo Executivo

Reaproveitamento do projeto `controlai-frontend` (Ionic React + Capacitor) como fonte única de UI: um novo alvo de build ("web", sem Capacitor) usando o mesmo router, services, contexts e páginas do app mobile, acrescido de um shell de navegação desktop (`IonSplitPane` + `IonMenu`) que substitui a tab bar inferior acima do breakpoint `lg` (992px). O backend Kotlin/Spring Boot já expõe JWT + refresh token e CORS parametrizado — nenhuma nova regra de negócio ou endpoint é criada; a única mudança de backend é liberar o(s) domínio(s) da web em `CORS_ALLOWED_ORIGIN_PATTERNS`. O fluxo de leitura de NFC-e por câmera (indisponível em navegador) é substituído pela `ManualEntryPage` já existente. Deploy como site estático (Vercel ou Netlify) a partir do `dist/` gerado por `vite build`, com CDN/HTTPS gerenciados pela plataforma.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **`controlai-frontend`** (existente, modificado): mesmo repositório/código hoje usado pelo app mobile passa a ter dois destinos de build: nativo (Capacitor, inalterado) e web (novo, `vite build` puro, sem `cap copy`).
- **`AppShell`/`TabsLayout`** (`src/App.tsx`, modificado): passa a renderizar via `IonSplitPane` com um novo `IonMenu` quando a viewport atinge o breakpoint `lg`; abaixo disso mantém a `IonTabBar` atual, inalterada. Roteamento (`IonRouterOutlet`, lista de rotas, guards de autenticação) é 100% reaproveitado.
- **`WebSidebarMenu`** (novo, `src/components/WebSidebarMenu.tsx`): menu lateral com os mesmos destinos hoje presentes na tab bar (Início, Buscar, Novo, Cartões, Config) + Perfil; usa `IonMenuToggle`/`useHistory` para navegação, sem lógica de negócio própria.
- **Páginas existentes** (`Tab1`, `Tab2`, `Tab3`, `BudgetPage`, `PaymentMethodsPage`, `CategoriesPage`, `PurchaseDetail`, `ByCategoryPage`, etc.): reaproveitadas integralmente; recebem apenas ajustes de CSS/breakpoint (`IonGrid`/`size-lg`) para ocupar melhor telas largas, sem mudança de lógica.
- **`ManualEntryPage`** (existente, sem alteração de lógica): passa a ser o ponto de entrada único do fluxo "Novo" no build web; o botão "Novo" navega direto para `/manual-entry` (em vez de `/scanner`) quando `!Capacitor.isNativePlatform()`.
- **`ScannerPage`/`@capacitor-mlkit/barcode-scanning`** (existente, inalterado): permanece exclusivo do build nativo; não é referenciado pelo shell web.
- **`tokenStorage`/`biometricService`/`AuthContext`** (existentes, sem alterações): já implementam o branch `web` (localStorage) usado hoje por Android, reaproveitado também pelo build web.
- **Backend `SecurityConfig`/`CorsConfig`** (existente, sem alteração de código): apenas nova configuração de ambiente (`CORS_ALLOWED_ORIGIN_PATTERNS`) incluindo o(s) domínio(s) do ControlAI Web.
- **Pipeline de deploy** (novo): projeto Vercel ou Netlify apontando para o mesmo repositório `controlai-frontend`, branch de produção, comando `npm run build`, publicando `dist/`.

Fluxo de dados: idêntico ao mobile — a SPA React consome a mesma API REST (`api.opencod3.com.br`) via `httpClient.ts`/`authService.ts`; autenticação por JWT de acesso em memória + refresh token rotativo persistido em `localStorage`. Nenhum dado é duplicado ou sincronizado separadamente — web e mobile leem/escrevem a mesma base via a mesma API, portanto a consistência de dados (RF-8 do PRD) é consequência direta de reaproveitar o mesmo backend, sem mecanismo adicional de sincronização.

## Design de Implementação

### Interfaces Principais

Nenhuma interface de serviço nova é necessária — reaproveita `httpClient`, `authService`, `budgetService` etc. já existentes. O único contrato novo é de apresentação:

```ts
// src/components/WebSidebarMenu.tsx
interface WebSidebarMenuProps {
  activePath: string; // usado apenas para destacar visualmente o item ativo
}
```

### Modelos de Dados

Nenhum modelo de dados novo — backend e contratos de API permanecem os mesmos já usados pelo app mobile.

### Endpoints de API

Nenhum endpoint novo. A web consome os mesmos endpoints hoje usados pelo mobile (`/auth/*`, `/purchases-invoices/*`, `/budget/*`, `/payment-methods/*`, `/categories/*` etc.), sem alteração de contrato.

## Pontos de Integração

- **SEFAZ (NFC-e)**: sem integração direta no fluxo web — a entrada é sempre manual via `ManualEntryPage`, que já invoca o mesmo `processInvoice(url)` usado pelo mobile após leitura de câmera; o bloqueio de WAF já conhecido se aplica igualmente.
- **CORS**: backend precisa incluir o(s) domínio(s) de produção/preview do ControlAI Web em `CORS_ALLOWED_ORIGIN_PATTERNS` (variável de ambiente, sem deploy de código).
- **Hospedagem estática (Vercel/Netlify)**: build via `npm run build` (mesmo `vite build` já existente), variável `VITE_API_BASE_URL` apontando para a API de produção.

## Abordagem de Testes

### Testes Unidade

- Páginas/componentes reaproveitados já têm suíte Vitest + Testing Library (ex.: `Tab1.test.tsx`, `BudgetPage.test.tsx`) — sem regressão esperada, pois a lógica não muda.
- Novo `WebSidebarMenu`: teste cobrindo renderização dos itens, destaque do item ativo e navegação ao clique.
- Ajuste em `TabsLayout`: teste garantindo que o shell alterna entre sidebar e tab bar conforme o breakpoint (mock de `matchMedia`).

### Testes de Integração

- Reaproveita testes existentes de sessão (`AuthContext.test.tsx`, `httpClient.auth.test.ts`); adicionar caso cobrindo o botão "Novo" navegando para `/manual-entry` em vez de `/scanner` quando a plataforma não é nativa.

### Testes de E2E

- Usar Playwright (já configurado em `playwright.config.ts`) para o fluxo principal do build web: login → dashboard (Tab1) → cartões → fatura → registrar compra manual → orçamento, em viewport desktop (projeto `chromium`/`Desktop Chrome` já presente na config).
- Adicionar um segundo projeto Playwright com viewport mobile (ex. `devices['iPhone 13']`) cobrindo o mesmo fluxo crítico, já que suporte a navegador mobile também é requisito.
- Suíte Cypress existente (`cypress/e2e/*.cy.ts`) permanece cobrindo as regressões já mapeadas; não é necessário duplicar cenários novos nela.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. Configuração do build web (script dedicado e/ou ajuste de `vite.config.ts` se necessário) e liberação de CORS no backend — pré-requisito para tudo o resto ser testável ponta a ponta.
2. `WebSidebarMenu` + `IonSplitPane` em `App.tsx`, com breakpoint `lg`, reaproveitando as rotas existentes sem tocar nas páginas.
3. Ajustes de CSS/grid responsivo por página (Tab1 → Tab2 → Tab3 → PaymentMethodsPage → BudgetPage → demais), priorizando as telas citadas no PRD (dashboard, cartões, faturas).
4. Redirecionamento do botão "Novo" para `/manual-entry` no build web (checagem `Capacitor.isNativePlatform()`).
5. Acessibilidade: revisão de foco/teclado/contraste nas telas principais (dashboard, cartões, faturas) contra WCAG 2.1 AA.
6. Deploy do projeto Vercel/Netlify e testes E2E Playwright (desktop + mobile browser) contra o ambiente de preview.

### Dependências Técnicas

- Configuração de `CORS_ALLOWED_ORIGIN_PATTERNS` em produção antes de qualquer teste manual do build web contra a API real.
- Conta Vercel ou Netlify provisionada e conectada ao repositório `controlai-frontend`.

## Monitoramento e Observabilidade

- Reaproveita métricas e logs já existentes no backend (Micrometer/Prometheus, conforme `SecurityConfig`/`ApiKeyAuthFilter` atuais) — nenhuma métrica nova de backend é necessária, pois não há endpoint novo.
- Frontend: usar o tratamento de erro já padrão do React/Ionic; não introduzir ferramenta de observabilidade de frontend nesta fase (fora do escopo do PRD).

## Considerações Técnicas

### Decisões Principais

- **Reaproveitar o codebase Ionic React em vez de um novo projeto web**: elimina duplicação de lógica de negócio e services, atende à restrição do PRD de reutilizar o backend "sem duplicar regras de negócio", e `tokenStorage.ts` já implementa o branch web. Alternativa rejeitada: novo projeto (ex. Next.js) — mais esforço e duplicaria services/testes já validados.
- **`IonSplitPane` + `IonMenu` para navegação desktop**: componente nativo do Ionic cobre exatamente o caso de uso (sidebar acima de um breakpoint, tab bar abaixo), sem biblioteca adicional.
- **Reaproveitar `ManualEntryPage` como único fluxo de NFC-e na web**: decisão do usuário para reduzir escopo nesta primeira versão; upload de imagem com decodificação client-side (ex. `jsQR`) fica como evolução futura caso a entrada manual se mostre insuficiente.
- **Manter `localStorage` para refresh token na web**: paridade com o padrão já usado no build Android, evita mudança de contrato no backend; mitigação de XSS delegada às práticas já vigentes (sanitização de output do React, sem `dangerouslySetInnerHTML` em dados de usuário).
- **Hospedagem Vercel/Netlify**: menor esforço operacional para um site estático, consistente com a direção já considerada para a landing page comercial do PRD "Comercialização do ControlAI".

### Riscos Conhecidos

- Componentes de interação mobile (`CategoryBottomSheet`, `AddItemModal`, outros `IonModal`) podem precisar de ajuste fino de apresentação (bottom-sheet vs. modal centralizado) em telas largas — mitigar revisando cada um durante a etapa 3 do sequenciamento, sem reescrever a lógica.
- Bloqueio de WAF da SEFAZ já conhecido afeta igualmente o fluxo manual na web (mesma URL, mesma chamada) — risco herdado do mobile, não introduzido por esta feature.
- Suporte a navegador mobile amplia a superfície de teste (viewport + touch); mitigar com o segundo projeto Playwright mobile descrito na seção de testes.

### Conformidade com Skills Padrões

- `ionic-design`: aplica-se diretamente ao uso de `IonSplitPane`/`IonMenu`/breakpoints de `IonGrid` para o novo shell desktop.
- `kotlin-springboot`: aplica-se à única mudança de backend (configuração de CORS), mantendo o padrão Gateway/Provider e `SecurityConfig` já existentes sem alteração de código.
- `clean-code`: aplica-se aos novos componentes (`WebSidebarMenu`) e aos ajustes de `App.tsx`.

### Arquivos relevantes e dependentes

- `controlai-frontend/src/App.tsx`
- `controlai-frontend/src/components/WebSidebarMenu.tsx` (novo)
- `controlai-frontend/src/pages/ScannerPage.tsx` / `ManualEntryPage.tsx`
- `controlai-frontend/src/services/tokenStorage.ts`, `biometricService.ts` (referência, sem alteração)
- `controlai-frontend/vite.config.ts`, `package.json`
- `controlai-frontend/playwright.config.ts`, `e2e/*.spec.ts` (novo)
- `controlai/src/main/kotlin/br/com/nomar/controlai/config/CorsConfig.kt` (referência, sem alteração de código)
- `controlai/application.yml` (variável de ambiente `CORS_ALLOWED_ORIGIN_PATTERNS`)
