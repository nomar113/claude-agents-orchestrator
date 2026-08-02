# Review: Task 4.0 - Titulo, indicador de limite, legenda e CSS do tema

**Revisor**: AI Code Reviewer
**Data**: 2026-07-18
**Arquivo da task**: 4_task.md
**Status**: APROVADO

## Resumo

A task completou o visual do widget: titulo "DISTRIBUIÇÃO" (`<h2>`), indicador "Limite = 100%" renderizado como HTML acima do SVG (decisao documentada em comentario: evita colisao com petalas em overflow proximas das 12h), circulo tracejado de referencia em `r = LIMIT_RADIUS` (`stroke-dasharray: 4 6` via CSS) e legenda (`<ul>`) com swatch circular na mesma cor da petala (`petal.color.base` — inclusive cor de alerta `#FF6B6B` quando a categoria esta em overflow, comportamento coberto por teste) e nome de cada categoria visivel. O novo `PetalDistributionChart.css` esta alinhado ao tema escuro (`#0D1028`), tipografia IBM Plex Sans/Mono (mesmo padrao literal de `Tab1.css`), estados `:active`/`:focus-visible` para o toque/foco futuros (Task 6.0) e **apenas fills chapados — sem `filter:` nem gradientes SVG**, conforme o risco WebKit da techspec. A task tambem fechou as pendencias herdadas das reviews 2.0/3.0: constantes nomeadas de layout (`MAX_HALF_WIDTH`, `PETAL_MID_POSITION`, `LABEL_FIT_RATIO`, `LABEL_INSIDE_POSITION`, `LABEL_OUTSIDE_OFFSET`), clamp de `halfWidth` para N=1 (`Math.PI / 3`, com teste geometrico), cor do disco central movida do `fill` inline para classe CSS, `fontSize`/`fontWeight` do percentual migrados para o CSS e o teste do cap de 150% recomendado na review 3.0. Acompanham 12 novos testes (24 no total no arquivo). O arquivo temporario `__petal_visual__.test.tsx` de uma sessao interrompida foi removido (confirmado ausente). Qualidade geral: muito boa; apenas 3 apontamentos minor nao bloqueantes.

Validacoes executadas nesta review:

- `npx tsc --noEmit` → **sem erros**
- `npx vitest run src/components/PetalDistributionChart.test.tsx src/utils/categoryColors.test.ts` → **28 passed, 0 failed**
- `npx vitest run` (suite completa) → **373 passed, 0 failed** (37 arquivos)
- `npx eslint` nos dois arquivos `.tsx`/`.ts` alterados → **sem issues** (CSS fora do escopo do lint por ausencia de config, esperado)
- **Verificacao numerica do rotulo em petala pequena** (script Node reproduzindo a escala polilinear): petala de 24% tem ponta em r = 30.72 < limiar de 60.75 (`MAX_RADIUS * LABEL_FIT_RATIO`) → rotulo renderizado fora da ponta em r = 44.72, dentro do circulo de limite (90) e sem clipping do viewBox — a heuristica de legibilidade funciona no caso citado pelo PRD.
- Validacao visual via screenshot headless Chromium (viewport 390px) reportada pelo implementador: titulo, indicador, circulo tracejado, rotulo externo legivel em 24%, overflows 112%/187% alem do circulo em cor de alerta, legenda com cores identicas as petalas, N=1 como folha apontando para cima. `ionic serve` de ponta a ponta fica para a Task 7.0, consistente com o precedente da review da Task 3.0.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PetalDistributionChart.tsx` | OK | 1 minor |
| `src/components/PetalDistributionChart.css` | OK | 2 minor |
| `src/components/PetalDistributionChart.test.tsx` | OK | 0 |

## Conferencia dos Requisitos da Task

| Requisito | Status |
|-----------|--------|
| Titulo "DISTRIBUIÇÃO" no topo do widget (PRD 1.5) | OK — `<h2 className="...__title">` (linha 132), primeiro elemento do container; uppercase + letter-spacing no CSS |
| Circulo tracejado em `r = limitRadius` com `stroke-dasharray` + indicador "Limite = 100%" visivel no topo (PRD 1.6) | OK — `<circle r={LIMIT_RADIUS}>` (linhas 143–148) com `stroke-dasharray: 4 6` no CSS; indicador como `<p>` HTML acima do SVG com borda tracejada ecoando o circulo — solucao que garante visibilidade mesmo com petalas em overflow as 12h |
| Legenda com nome e cor de cada categoria visivel, mesma fonte de cor (PRD 1.7) | OK — `petals.map` reusado na legenda (mesmo array do SVG, mesma `petal.color.base` vinda de `getCategoryColor`/`getOverflowColor`); swatch `aria-hidden`; sem interacao, como previsto (clique e a Task 6.0) |
| `PetalDistributionChart.css` alinhado ao tema escuro (`#0D1028`–`#0E1832`) e IBM Plex | OK — fundo transparente sobre o gradiente da Tab1, texto em brancos translucidos, IBM Plex Sans no container e IBM Plex Mono no percentual (mesmo padrao de `Tab1.css`) |
| Percentual legivel em petalas pequenas (ex.: 24%) | OK — peso 700 + Mono 13px; rotulo fora da ponta na cor da petala quando `tipRadius < MAX_RADIUS * LABEL_FIT_RATIO`; verificado numericamente nesta review |
| Sem `filter:`/gradientes SVG (risco WebKit) | OK — apenas fills chapados; comentario no CSS documenta a razao; unico "efeito" e `transition: opacity`, seguro |
| Testes: titulo, indicador, legenda com nome/cor, filtradas fora da legenda | OK — os 4 casos exigidos presentes, mais 3 extras de legenda (cor de alerta em overflow, sem legenda quando vazio) e os testes herdados (cap 150%, N=1) |

Pendencias herdadas das reviews 2.0/3.0 enderecadas a esta task — todas resolvidas:

- **Clamp de `halfWidth` para N=1** (2.0, minor 1): `MAX_HALF_WIDTH = Math.PI / 3` aplicado exatamente como sugerido, com teste geometrico que parseia o `d` e garante a folha no semicirculo superior.
- **Constantes de layout do rotulo** (2.0, minor 2): `LABEL_FIT_RATIO`, `LABEL_INSIDE_POSITION`, `LABEL_OUTSIDE_OFFSET` nomeadas com comentarios explicativos; `fontSize`/`fontWeight` migrados para a classe `__percent` no CSS, como recomendado.
- **Cor do disco central fora do inline `fill`** (2.0, minor 3): movida para a classe `__center-disc` no CSS (ver minor 1 abaixo sobre o token).
- **`PETAL_MID_POSITION` (0.55)** (listado na review 3.0): nomeado.
- **Teste do cap de 150%** (3.0, minor 2): implementado exatamente como sugerido (`petalReach` movido para o `describe` de overflow; 150% vs 200% com `toBeCloseTo`).
- (Ja fechados na Task 3.0 e conferidos como mantidos: early return, gerador içado, `type CategoryColor`, reset de `nextId`.)

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`src/components/PetalDistributionChart.css:51-53` — disco central com `#0d1028` literal em vez do token de tema.** A review 2.0 sugeria "CSS **ou** token"; mover para o CSS resolve a pendencia na letra, mas o literal duplica `--ion-background-color: #0D1028` de `variables.css`. Alem disso, o fundo da Tab1 e um **gradiente** (`#0D1028 → #102040 → #0E1832`), entao na posicao vertical em que o widget ficar o disco chapado pode nao casar exatamente com o fundo local (o efeito "furo" fica aproximado). Sugestao barata agora, validacao visual na integracao (Task 7.0):

   ```css
   .petal-distribution-chart__center-disc {
     fill: var(--ion-background-color, #0d1028);
   }
   ```

2. **`src/components/PetalDistributionChart.tsx:139` — `width="100%"` no `<svg>` redundante.** A classe `__svg` ja define `width: 100%; max-width: 320px` no CSS; o atributo duplica a regra em outra camada e pode mascarar futuros ajustes de CSS. Remover o atributo e deixar o dimensionamento inteiro no CSS (que ja e a fonte de verdade do `max-width`).

3. **`src/components/PetalDistributionChart.css:56-63` + legenda — categoria em overflow perde a cor de identidade em todo o widget.** Petala e swatch da legenda ficam ambos `#FF6B6B`; com 2+ categorias estouradas, a cor deixa de distinguir categorias (o nome na legenda preserva a identificacao, e a exigencia da task — "cores identicas as das petalas" — e cumprida e testada). Nao e desvio: e consequencia direta da decisao da Task 3.0 de pintar a petala inteira de alerta. Registrar como decisao de produto; se incomodar na pratica, uma alternativa futura e swatch na cor base com anel/borda de alerta.

Observacao de estilo (nao contabilizada, mesma postura das reviews 2.0/3.0): permanecem linhas em branco dentro de funcoes e comentarios explicativos — todos em ingles (convencao dos repos controlai) e justificados (documentam decisoes nao obvias: indicador em HTML, clamp de N=1, razao do "flat fills only" no CSS). O `cursor: pointer` e o `:focus-visible` nas petalas antecipam a interatividade da Task 6.0 (a subtarefa 4.3 pedia explicitamente os estados de foco/toque); revalidar o contrato `outline: none` + `stroke` quando o `tabIndex` chegar.

## Destaques Positivos

- **Indicador "Limite = 100%" fora do SVG e uma decisao de design acima do minimo**: um `<text>` dentro do SVG as 12h colidiria com petalas em overflow (que crescem ate r = 135 justamente onde o indicador ficaria); o `<p>` com borda tracejada ecoa visualmente o circulo que anota e resolve o conflito por construcao — com comentario documentando a razao.
- **Todas as 6 pendencias herdadas das reviews 2.0/3.0 enderecadas a esta task foram fechadas**, varias exatamente com o codigo sugerido (clamp `Math.PI / 3`, teste do cap com `petalReach` + `toBeCloseTo`) — melhor fechamento de ciclo entre tasks da feature ate aqui.
- **Legenda derivada do mesmo `petals` do SVG**: uma unica fonte de dados garante estruturalmente que legenda e flor nunca divergem (mesma cor, mesmo filtro, mesma ordem) — o requisito 1.7 fica correto por construcao, nao por coincidencia de logica duplicada.
- **Teste de N=1 valida geometria pelo output renderizado**: parseia o `d` do path e afirma que todos os pontos ficam no semicirculo superior (com tolerancia para o overshoot da Catmull-Rom) — cobre o clamp sem acoplar a internals, no mesmo espirito do `petalReach` da Task 3.0.
- **Risco WebKit da techspec tratado com disciplina**: nenhum `filter:`/gradiente no CSS, e o comentario "Flat fills only" transforma a restricao em regra explicita para manutencao futura.
- **Constantes com comentarios que explicam o porque, nao o o-que** (ex.: `MAX_HALF_WIDTH` documenta o blob de ~162° que previne) — numeros magicos viraram documentacao de design.
- **Higiene de workspace**: o arquivo temporario `__petal_visual__.test.tsx` da sessao interrompida foi removido em vez de esquecido no working tree.
- **Comentarios em ingles**, alinhados a convencao dos repos controlai.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (todas as constantes de layout agora nomeadas; pendencias de numeros magicos das tasks anteriores zeradas; resta o literal de cor do minor 1) |
| TypeScript/Node.js | OK (`tsc --noEmit` sem erros, sem `any`, `import type` correto) |
| REST/HTTP | Nao aplicavel |
| Logging | Nao aplicavel |
| React | OK (`useMemo` mantido; escala/gerador como constantes de modulo; legenda com `key` estavel por `categoryId`; swatch dinamico via `style` e o uso correto para valor calculado) |
| CSS/Design (`frontend-design`, `ionic-design`) | OK (tema escuro, IBM Plex, mobile-first com `max-width` no SVG, `-webkit-tap-highlight-color` zerado, sem filter/gradiente; fonte hardcoded segue o padrao literal ja usado em `Tab1.css`) |
| Testes | OK (24/24 no componente, 28/28 com `categoryColors`, 373/373 na suite; todos os casos exigidos pela task + herdados presentes) |

## Recomendacoes

1. (Minor 1) Trocar o `#0d1028` do disco central por `var(--ion-background-color, #0d1028)` e conferir na Task 7.0, com o widget na posicao real da Tab1, se o disco chapado casa bem com o fundo em gradiente.
2. (Minor 2) Remover o atributo `width="100%"` do `<svg>`, deixando o dimensionamento so no CSS.
3. (Minor 3) Registrar a decisao de produto sobre a legenda em cor de alerta para categorias estouradas (hoje: identica a petala, coberta por teste).
4. (Herdado da review 3.0, minor 1 — ainda aberto) Decidir o comportamento do overflow marginal (`ratio` em `(1, 1.005)` exibe "100%" com cor de alerta) **antes da Task 6.0**, que vai compor o `aria-label` "acima do limite" a partir de `isOverflow`.
5. (Task 6.0) Ao adicionar `tabIndex`/`role="button"` nas petalas, validar visualmente o par `outline: none` + `stroke` do `:focus-visible` ja deixado pronto no CSS.

## Veredito

**APROVADO.** Nenhum problema critico ou major; os 3 minors sao refinamentos nao bloqueantes (token de cor, atributo redundante e registro de decisao de produto). Todos os requisitos da task e do PRD (1.5–1.7) foram atendidos, o risco WebKit da techspec foi respeitado, e todas as pendencias herdadas das reviews 2.0/3.0 destinadas a esta task foram fechadas — varias com o codigo exatamente como sugerido. Typecheck, testes (28/28 e 373/373), lint e build passando. Proximo passo: Task 5.0 (estado vazio + botao "Ver gastos detalhados"), que ja encontra o container, o titulo e o CSS do tema prontos.
