# Tarefa 4.0: Fluxo "Novo" na web aponta para ManualEntryPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

No app mobile, o botão "Novo" (tab bar e/ou sidebar) navega para `/scanner`, que depende de câmera nativa (`@capacitor-mlkit/barcode-scanning`), indisponível em navegador. Esta tarefa faz esse destino ser condicional à plataforma: em builds não nativos (`!Capacitor.isNativePlatform()`), o botão "Novo" deve levar diretamente para `/manual-entry`, reaproveitando a `ManualEntryPage` já existente e seu fluxo `processInvoice(url)`.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se ao ajuste do item de navegação já existente.
- `clean-code` — checagem de plataforma centralizada em um único ponto, sem espalhar `Capacitor.isNativePlatform()` por múltiplos componentes.
</skills>

<requirements>
- Tech Spec `Arquitetura do Sistema`: "Novo" navega para `/manual-entry` quando `!Capacitor.isNativePlatform()`; `ScannerPage` permanece exclusiva do build nativo, sem ser referenciada pelo shell web.
- Tech Spec `Decisões Principais`: reaproveitar `ManualEntryPage` como único fluxo de NFC-e na web nesta primeira versão (sem upload de imagem/QR).
- Não alterar `ScannerPage.tsx` nem `ManualEntryPage.tsx` (lógica de negócio) — apenas o destino de navegação do botão "Novo" nos componentes de shell (`TabsLayout`/`WebSidebarMenu`, da Tarefa 3.0).
</requirements>

## Subtarefas

- [x] 4.1 Adicionar a checagem de plataforma (`Capacitor.isNativePlatform()`) no ponto onde o destino do botão "Novo" é definido, tanto na `IonTabBar` quanto no `WebSidebarMenu`.
- [x] 4.2 Garantir que, em build nativo, o comportamento atual (`/scanner`) permanece 100% inalterado.
- [x] 4.3 Garantir que, em build web, o clique em "Novo" leva a `/manual-entry` e que o fluxo de registro de compra funciona ponta a ponta a partir dali.

## Detalhes de Implementação

Ver Tech Spec `Pontos de Integração` (item SEFAZ/NFC-e) e `Arquitetura do Sistema > Visão Geral dos Componentes` (itens "`ManualEntryPage`" e "`ScannerPage`").

## Critérios de Sucesso

- Build nativo (iOS/Android): botão "Novo" continua abrindo o scanner de câmera, sem regressão.
- Build web: botão "Novo" abre `/manual-entry` diretamente, e o usuário consegue registrar uma compra manualmente a partir dele.

## Testes da Tarefa

- [x] Teste de unidade: com `Capacitor.isNativePlatform()` mockado como `false`, o destino de navegação do botão "Novo" é `/manual-entry`.
- [x] Teste de unidade: com `Capacitor.isNativePlatform()` mockado como `true`, o destino permanece `/scanner`.
- [x] Teste de integração: fluxo completo de `ManualEntryPage` a partir do clique em "Novo" no build web (sem regressão no `processInvoice`).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/App.tsx`
- `controlai-frontend/src/components/WebSidebarMenu.tsx`
- `controlai-frontend/src/pages/ManualEntryPage.tsx` (referência, sem alteração de lógica)
- `controlai-frontend/src/pages/ScannerPage.tsx` (referência, sem alteração)
- Depende de: Tarefa 3.0 (shell de navegação)
