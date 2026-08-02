# Tarefa 6.0: Interacao por toque/teclado e acessibilidade

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Tornar o widget interativo e acessivel: toque em petala e em item da legenda dispara `onPetalClick(categoryId)`, suporte a teclado (Enter/Space), rotulos acessiveis para leitores de tela e area de toque minima em petalas pequenas. Corresponde a funcionalidade 4 do PRD (requisitos 4.1–4.3) e aos requisitos de acessibilidade.

<skills>
### Conformidade com Skills Padroes

- `frontend-design` — microinteracoes (estados de foco/toque) e acessibilidade como requisito de qualidade.
- `ionic-design` — tap targets minimos recomendados para mobile.
- `vercel-react-best-practices` — callbacks estabilizados com `useCallback`; sem recriar handlers por petala a cada render.
- `clean-code` — handler unico parametrizado por `categoryId`, compartilhado entre petala e legenda.
</skills>

<requirements>
- Toque em petala dispara `onPetalClick(categoryId)` com o id correto (requisito 4.1 do PRD — a navegacao/filtro real e conectada na Tarefa 7.0).
- Toque no item da legenda dispara o MESMO `onPetalClick` da petala correspondente (requisito 4.3).
- Cada `<path>` de petala recebe `role="button"`, `tabIndex={0}`, `onClick` e `onKeyDown` (Enter e Space) — ver "Pontos de Integracao" na techspec.
- `aria-label` no formato `"{categoryName}: {percent}% do limite"`, com sufixo `", acima do limite"` quando overflow (requisitos de acessibilidade do PRD).
- Area de toque minima de 44x44 pt por petala: garantir `petalLength` minimo (~30% do raio do limite) e/ou overlay invisivel sobre petalas curtas (ver "Riscos Conhecidos" na techspec; requisito 4.2 do PRD).
- Estado de foco visivel para navegacao por teclado.
</requirements>

## Subtarefas

- [x] 6.1 Adicionar `role`, `tabIndex`, `aria-label`, `onClick` e `onKeyDown` (Enter/Space) as petalas.
- [x] 6.2 Tornar os itens da legenda clicaveis, reutilizando o mesmo handler por `categoryId`.
- [x] 6.3 Garantir tap target minimo (comprimento minimo de petala + overlay invisivel 44x44 pt quando necessario) e estado de foco visivel no CSS.
- [x] 6.4 Ampliar `PetalDistributionChart.test.tsx` com os casos de interacao e acessibilidade.
- [x] 6.5 Executar testes e validar toque/teclado no `ionic serve`.

## Detalhes de Implementacao

Ver "Pontos de Integracao" (acessibilidade e filter scroll) e "Riscos Conhecidos" (area de toque pequena) na `techspec.md`.

## Criterios de Sucesso

- Petala e legenda da mesma categoria disparam o mesmo callback com o mesmo `categoryId`.
- Widget navegavel por Tab + Enter/Space com foco visivel.
- Leitor de tela anuncia categoria, percentual e estouro quando aplicavel.
- Nenhuma petala com area tocavel abaixo do minimo recomendado.

## Testes da Tarefa

- [x] Testes de unidade (`PetalDistributionChart.test.tsx`):
  - Clique na petala dispara `onPetalClick` com o `categoryId` correto.
  - Clique na legenda da categoria dispara o mesmo `onPetalClick`.
  - Tecla Enter na petala focada dispara `onPetalClick`.
  - Tecla Space na petala focada dispara `onPetalClick`.
  - `aria-label` da petala segue o formato `"{categoria}: {n}% do limite"`.
  - `aria-label` inclui `", acima do limite"` quando overflow.
  - Petalas possuem `role="button"` e `tabIndex={0}`.
- [ ] Testes de integracao: cobertos na Tarefa 7.0 via `Tab1.test.tsx` (filtro do `PurchaseList`).
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PetalDistributionChart.tsx` (modificado)
- `src/components/PetalDistributionChart.css` (modificado — foco/toque)
- `src/components/PetalDistributionChart.test.tsx` (modificado)
