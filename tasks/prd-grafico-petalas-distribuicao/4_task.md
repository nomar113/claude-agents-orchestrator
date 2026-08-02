# Tarefa 4.0: Titulo, indicador de limite, legenda e CSS do tema

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Completar o visual do widget: titulo "DISTRIBUICAO" no topo, circulo tracejado de referencia com indicador "Limite = 100%", legenda com nome e cor de cada categoria exibida, e o arquivo `PetalDistributionChart.css` alinhado ao tema escuro do app. Corresponde aos requisitos 1.5–1.7 do PRD.

<skills>
### Conformidade com Skills Padroes

- `frontend-design` — hierarquia visual do widget como destaque da Tab1; legibilidade do percentual sobre fundo escuro (peso e contraste da fonte).
- `ionic-design` — padroes mobile-first; escala responsiva do SVG via CSS.
- `clean-code` — estilos organizados por bloco do componente, sem valores magicos repetidos.
</skills>

<requirements>
- Titulo "DISTRIBUIÇÃO" no topo do widget (requisito 1.5 do PRD).
- Circulo tracejado de referencia renderizado em `r = limitRadius` com `stroke-dasharray`, com indicador textual "Limite = 100%" visivel no topo do grafico (requisito 1.6).
- Legenda abaixo do grafico com nome e cor de cada categoria visivel, cores identicas as das petalas (requisito 1.7) — mesma fonte de cor (`getCategoryColor`).
- `PetalDistributionChart.css` alinhado ao tema escuro existente (`#0D1028`–`#0E1832`) e tipografia IBM Plex.
- Numero da petala legivel mesmo em petalas pequenas (ex.: 24%) — fonte com peso e contraste apropriados.
- Sem `filter:` complexos ou gradientes SVG arriscados em WebKit — estilos chapados (ver "Riscos Conhecidos" na techspec).
</requirements>

## Subtarefas

- [x] 4.1 Renderizar titulo "DISTRIBUIÇÃO", circulo tracejado de limite e indicador "Limite = 100%".
- [x] 4.2 Renderizar a legenda com nome e cor de cada categoria visivel (itens ainda sem interacao — clique vem na Tarefa 6.0).
- [x] 4.3 Criar `PetalDistributionChart.css` com tema escuro, tipografia e estados visuais (overflow, foco, toque).
- [x] 4.4 Ampliar `PetalDistributionChart.test.tsx` com os casos de titulo, indicador e legenda.
- [x] 4.5 Executar testes e validar visualmente no `ionic serve` (incluindo petalas pequenas).

## Detalhes de Implementacao

Ver secoes "Geometria das Petalas" (circulo tracejado em `limitRadius`) e "Visao Geral dos Componentes" (CSS alinhado ao tema) na `techspec.md`. Referencias de tokens: `src/theme/variables.css` e `src/pages/Tab1.css`.

## Criterios de Sucesso

- Widget visualmente completo no modo com dados: titulo, flor, circulo de referencia, indicador e legenda.
- Cores da legenda batem com as cores das petalas para as mesmas categorias.
- Percentuais legiveis em petalas pequenas sobre o fundo escuro.

## Testes da Tarefa

- [x] Testes de unidade (`PetalDistributionChart.test.tsx`):
  - Exibe o titulo "DISTRIBUIÇÃO".
  - Exibe o indicador "Limite = 100%".
  - Legenda lista cada categoria visivel com nome e cor correspondente a petala.
  - Categorias filtradas (sem orcamento/sem gasto) NAO aparecem na legenda.
- [ ] Testes de integracao: cobertos na Tarefa 7.0 via `Tab1.test.tsx`.
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PetalDistributionChart.tsx` (modificado)
- `src/components/PetalDistributionChart.css` (novo)
- `src/components/PetalDistributionChart.test.tsx` (modificado)
- `src/theme/variables.css` e `src/pages/Tab1.css` (tokens de cor/tipografia — consulta)
