# Tarefa 8.0: Layout responsivo — Busca, Config e Perfil

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Ajustar o CSS/grid das telas restantes necessárias para paridade completa com o mobile — `Tab2` (busca), `Tab3` (configurações) e `ProfilePage` — para telas largas, fechando a cobertura de todas as telas do app. Sem alteração de lógica de negócio ou contratos de API.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — aplica-se ao uso de `IonGrid`/breakpoints nessas telas.
- `frontend-design` — aplica-se à qualidade visual do layout desktop.
</skills>

<requirements>
- PRD `Objetivos`: paridade funcional completa entre web e mobile — nenhuma tela do app deve ficar sem versão desktop adequada.
- Tech Spec `Sequenciamento de Desenvolvimento`: busca/config/perfil é a última leva de telas responsivas antes da etapa de acessibilidade.
- Não alterar `services/profileService.ts`, `context/FilterContext.tsx` ou contratos de API.
</requirements>

## Subtarefas

- [ ] 8.1 Ajustar `Tab2.tsx`/`.css` (busca/filtros — `CategoryFilterBar`, `MonthSelector`, `PurchaseList`) para um layout adequado a telas largas.
- [ ] 8.2 Ajustar `Tab3.tsx`/`.css` (configurações) para telas largas.
- [ ] 8.3 Ajustar `ProfilePage.tsx`/`.css` para telas largas.
- [ ] 8.4 Confirmar que o layout mobile original permanece inalterado abaixo do breakpoint em todas as três telas.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (item "Páginas existentes").

## Critérios de Sucesso

- Busca, configurações e perfil ficam com layout adequado a telas ≥ 992px.
- Com esta tarefa concluída, todas as telas listadas no PRD (dashboard, cartões, faturas, orçamento, busca, config, perfil) têm layout desktop.
- Nenhuma regressão no layout/comportamento mobile.

## Testes da Tarefa

- [ ] Testes de unidade/RTL existentes (`Tab2.test.tsx`, `Tab3.test.tsx`, `ProfilePage.test.tsx`) continuam passando.
- [ ] Novo teste verificando presença/acessibilidade dos elementos principais dessas telas em viewport desktop simulado.
- [ ] Teste manual visual das três telas em desktop.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab2.tsx`, `.css`
- `controlai-frontend/src/pages/Tab3.tsx`, `.css`
- `controlai-frontend/src/pages/ProfilePage.tsx`, `.css`
- `controlai-frontend/src/components/CategoryFilterBar.tsx`, `MonthSelector.tsx`, `PurchaseList.tsx`
- Depende de: Tarefa 3.0 (shell de navegação)
