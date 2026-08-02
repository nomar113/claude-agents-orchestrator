# Tarefa 2.0: Componente base `PetalDistributionChart` com geometria das petalas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar as dependencias `d3-shape` e `d3-scale` e criar o componente `src/components/PetalDistributionChart.tsx` renderizando o SVG da flor: uma petala por categoria elegivel, com tamanho proporcional ao consumo do limite e percentual numerico exibido. Nesta task o componente ainda nao trata overflow, legenda, estado vazio nem interacao — apenas o desenho correto das petalas a partir dos dados.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — memoizar `buildPetals` via `useMemo`; componente controlado por props, sem fetch interno.
- `clean-code` — helpers internos pequenos e nomeados (`buildPetals`, `petalPath`, `filterEligible`).
- `frontend-design` — hierarquia visual e proporcoes conforme a geometria da techspec.
- `ionic-design` — componente vive dentro de `IonContent` como bloco custom (nao ha `IonChart`).
</skills>

<requirements>
- Adicionar `d3-shape ^3` e `d3-scale ^3` ao `package.json` (usar apenas `lineRadial`, `arc`, `scaleLinear`); `vite build` deve continuar passando.
- Componente com a interface `PetalDistributionChartProps` da techspec (`items`, `onPetalClick`, `onViewDetailsClick` — callbacks podem ficar sem efeito nesta task).
- Filtragem interna dos itens elegiveis: `type === 'EXPENSE'`, `expected > 0` e `actual > 0` (requisitos 1.1–1.3 do PRD). A regra fica colocalizada no componente, nao no `Tab1.tsx`.
- Calculo: `ratio = actual / expected`; `percent = Math.round(ratio * 100)` exibido como texto em cada petala (requisitos 1.4 e 2.1 do PRD).
- Geometria conforme "Geometria das Petalas" da techspec: `viewBox 0 0 300 300`, setor angular `2π / N`, forma de folha/amendoa via `d3.lineRadial`, `petalLength` proporcional a `min(ratio, OVERFLOW_CAP)` com `OVERFLOW_CAP = 1.5`.
- Cores das petalas via `getCategoryColor` da Tarefa 1.0.
- Validacao visual com dados estaticos via `ionic serve` antes de finalizar.
</requirements>

## Subtarefas

- [x] 2.1 Adicionar `d3-shape` e `d3-scale` ao `package.json`, instalar e conferir que `vite build` passa.
- [x] 2.2 Criar `PetalDistributionChart.tsx` com `buildPetals()` (filtragem + calculo de `PetalDatum`) e `petalPath()` (geometria radial).
- [x] 2.3 Renderizar o SVG com uma petala por item elegivel, cor por categoria e texto do percentual inteiro.
- [x] 2.4 Validar o visual com dados estaticos no `ionic serve`.
- [x] 2.5 Criar `PetalDistributionChart.test.tsx` cobrindo filtragem e percentuais.
- [x] 2.6 Executar testes, typecheck e build.

## Detalhes de Implementacao

Ver secoes "Interfaces Principais", "Modelos de Dados" e "Geometria das Petalas" na `techspec.md`. Nao ha endpoint novo: os dados chegam por props (`BudgetItemSummary[]`).

## Criterios de Sucesso

- Grafico renderiza corretamente uma flor com N petalas para N categorias elegiveis.
- Percentuais exibidos coincidem com `Math.round(actual / expected * 100)`.
- Itens sem orcamento ou sem gasto nao geram petala.
- `vite build` e typecheck passam com as novas dependencias.

## Testes da Tarefa

- [x] Testes de unidade (`PetalDistributionChart.test.tsx`, Vitest + Testing Library; `BudgetItemSummary[]` inline):
  - Renderiza uma petala por item com `expected > 0` e `actual > 0`.
  - NAO renderiza petala para item com `expected === 0` (sem orcamento).
  - NAO renderiza petala para item com `actual === 0` (sem gasto no mes).
  - NAO renderiza petala para item com `type !== 'EXPENSE'`.
  - Exibe percentual numerico inteiro (ex.: `87%`) por petala.
- [ ] Testes de integracao: cobertos na Tarefa 7.0 via `Tab1.test.tsx`.
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PetalDistributionChart.tsx` (novo)
- `src/components/PetalDistributionChart.test.tsx` (novo)
- `package.json` (modificado: `d3-shape`, `d3-scale`)
- `src/utils/categoryColors.ts` (dependencia da Tarefa 1.0)
- `src/types/budget.ts` (`BudgetSummary`, `BudgetItemSummary` — consulta)
