# Tarefa 8.0: Frontend — tela de bloqueio por assinatura inativa

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Tratar a resposta `402` do backend (Tarefa 6.0) no `controlai-frontend`, exibindo uma tela de bloqueio (`SubscriptionRequiredPage`) para usuários autenticados cujo grupo não tem assinatura ativa — sem nenhum link ou menção a pagamento dentro do app, conforme restrição do PRD. Depende da Tarefa 6.0 estar disponível (ao menos em ambiente de desenvolvimento) para testar contra o backend real.

<skills>
### Conformidade com Skills Padrões

- `ionic-design` — componente de página seguindo os padrões visuais Ionic já usados no restante do app (ex.: `LoadingPage` em `App.tsx`).
- `frontend-design` — qualidade visual da tela de bloqueio, mesmo sendo uma tela simples.
</skills>

<requirements>
- Tech Spec `Arquitetura do Sistema`: tratamento do `402` sem nenhum link de pagamento.
- Tech Spec `Arquivos Relevantes`: novo evento equivalente a `ctrl:auth-failure` em `httpClient.ts`, nova `SubscriptionRequiredPage.tsx`.
- Restrição do PRD: o app não deve conter nenhum link ou menção ao checkout de pagamento externo.
</requirements>

## Subtarefas

- [x] 8.1 No `httpClient.ts`, detectar respostas `402` e disparar um novo evento (ex.: `ctrl:subscription-inactive`), seguindo o mesmo padrão já usado para `ctrl:auth-failure`.
- [x] 8.2 No `AuthContext.tsx` (ou um novo contexto dedicado), escutar esse evento e expor um estado `hasInactiveSubscription` (ou equivalente) para o roteamento.
- [x] 8.3 Criar `src/pages/SubscriptionRequiredPage.tsx`: tela informativa (sem link de pagamento) explicando que o acesso está indisponível, com texto neutro definido em conjunto com o usuário (ex.: orientando a verificar o e-mail cadastrado na compra).
- [x] 8.4 Em `App.tsx`, renderizar `SubscriptionRequiredPage` no lugar de `TabsLayout` quando `hasInactiveSubscription` for verdadeiro, mantendo o usuário autenticado (não deslogar).

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (fluxo de gate) e `Arquivos Relevantes`. Seguir o padrão já documentado nos comentários de `App.tsx` sobre o `IonRouterOutlet` (não desmontar o outlet, apenas trocar o que é renderizado).

## Critérios de Sucesso

- Um usuário autenticado cujo grupo perdeu a assinatura (testável simulando um `402` do backend) vê a `SubscriptionRequiredPage` em vez de qualquer tela do app.
- A tela de bloqueio não contém nenhum link, botão ou texto direcionando a um checkout externo.
- Um usuário grandfathered ou com assinatura ativa nunca vê essa tela.

## Testes da Tarefa

- [x] Teste de unidade do `httpClient.ts` validando o disparo do evento em resposta `402`.
- [x] Teste de unidade/componente da `SubscriptionRequiredPage` (render básico, ausência de links de pagamento).
- [x] Teste de integração do roteamento em `App.tsx` mostrando a tela correta conforme o estado de assinatura.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/services/httpClient.ts` (modificado)
- `src/context/AuthContext.tsx` (modificado)
- `src/pages/SubscriptionRequiredPage.tsx` (novo)
- `src/App.tsx` (modificado)
- Depende de: Tarefa 6.0
