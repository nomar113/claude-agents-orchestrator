# Tarefa 3.0: Shell de navegação desktop (IonSplitPane + WebSidebarMenu)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Introduzir um shell de navegação alternativo para telas largas, usando `IonSplitPane` + um novo `IonMenu` (`WebSidebarMenu`), que substitui visualmente a tab bar inferior a partir do breakpoint `lg` (992px). Abaixo desse breakpoint, o comportamento atual (tab bar inferior) permanece exatamente como está hoje. Nenhuma rota, guard de autenticação ou página existente é alterada nesta tarefa.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se diretamente ao uso de `IonSplitPane`/`IonMenu`/`IonMenuToggle`.
- `clean-code` — aplica-se ao novo componente `WebSidebarMenu` (responsabilidade única: apresentação de navegação).
</skills>

<requirements>
- Tech Spec `Interfaces Principais`: `WebSidebarMenuProps { activePath: string }`.
- Tech Spec `Arquitetura do Sistema`: `TabsLayout`/`App.tsx` reaproveita 100% das rotas e guards existentes (`PROTECTED_PATHS`, `ProtectedShell`); a única mudança é o wrapper de apresentação.
- Os mesmos destinos hoje na tab bar (Início, Buscar, Novo, Cartões, Config) devem estar no `WebSidebarMenu`, mais Perfil.
- Não modificar `ScannerPage`, `ManualEntryPage` ou qualquer service/context nesta tarefa (isso é escopo da Tarefa 4.0 em diante).
</requirements>

## Subtarefas

- [x] 3.1 Criar `src/components/WebSidebarMenu.tsx` com os itens de navegação (Início `/tab1`, Buscar `/tab2`, Novo, Cartões `/payment-methods`, Config `/tab3`, Perfil `/profile`), destacando visualmente o item ativo via `activePath`.
- [x] 3.2 Envolver `TabsLayout` em `src/App.tsx` com `IonSplitPane` (`when="lg"`) e `contentId` apontando para o `IonRouterOutlet` existente, mantendo a `IonTabBar` inalterada para viewports abaixo do breakpoint.
- [x] 3.3 Garantir que a troca entre sidebar e tab bar não remonte o `IonRouterOutlet` (mesma preocupação já documentada em `App.tsx` sobre não remontar o outlet).
- [x] 3.4 Ajustar CSS mínimo necessário para o `IonMenu` não conflitar com o tema escuro existente (`theme/variables.css`).

## Detalhes de Implementação

Ver Tech Spec `Design de Implementação > Interfaces Principais` e `Arquitetura do Sistema > Visão Geral dos Componentes` (itens "`AppShell`/`TabsLayout`" e "`WebSidebarMenu`").

## Critérios de Sucesso

- Em viewport ≥ 992px, a sidebar substitui visualmente a tab bar e permite navegar para todas as rotas protegidas existentes.
- Em viewport < 992px, o comportamento é idêntico ao app mobile atual (nenhuma regressão).
- Nenhuma rota, redirect ou guard de autenticação foi alterado.

## Testes da Tarefa

- [x] Testes de unidade do `WebSidebarMenu`: renderização dos itens, destaque do item ativo, chamada de navegação ao clique.
- [x] Teste de integração do `TabsLayout`/`App.tsx`: alternância entre sidebar e tab bar conforme breakpoint simulado (mock de `matchMedia`), garantindo que o outlet não remonta.
- [x] Regressão: suíte existente de `App.routing.test.tsx` continua passando sem alteração.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/App.tsx`
- `controlai-frontend/src/components/WebSidebarMenu.tsx` (novo)
- `controlai-frontend/src/components/WebSidebarMenu.test.tsx` (novo)
- `controlai-frontend/src/App.routing.test.tsx`
