# Review: Task 3.0 - Destaque visual de estouro de limite (>100%)

**Revisor**: AI Code Reviewer
**Data**: 2026-07-09
**Arquivo da task**: 3_task.md
**Status**: APROVADO

## Resumo

A task adicionou ao `PetalDistributionChart` o tratamento de overflow (`ratio > 1`): `isOverflow` derivado em `buildPetals`, cor de alerta via `getOverflowColor()` (`#FF6B6B`) decidida no proprio `buildPetals` (sem logica duplicada no render), atributo `data-overflow="true"` no `<path>` da petala estourada e percentual real exibido sem truncamento (`112%`, `187%`, `200%`). A mudanca central de geometria foi a troca da escala linear simples da Task 2.0 por uma **escala polilinear** `domain([0, 1, OVERFLOW_CAP]) → range([BASE_RADIUS, LIMIT_RADIUS, MAX_RADIUS])`, ancorando `ratio = 1` exatamente no circulo de referencia de 100% — petalas ≤100% ficam dentro do circulo, petalas em overflow o ultrapassam visivelmente (redundancia de tamanho para daltonismo, requisito 3.4) e param de crescer no cap de 150%. Acompanham 5 novos testes de overflow (13 no total no arquivo). Qualidade geral: muito boa; apenas 2 apontamentos minor nao bloqueantes.

Validacoes executadas nesta review:

- `npx tsc --noEmit` → **sem erros**
- `npx vitest run src/components/PetalDistributionChart.test.tsx` → **13 passed, 0 failed**
- `npx vitest run` (suite completa) → **364 passed, 0 failed**
- `npx eslint` nos dois arquivos alterados → **sem issues**
- `npm run build` (tsc + vite) → **sucesso** (reportado pelo implementador)
- **Verificacao numerica da geometria** (script Node com `d3-shape`/`d3-scale` reproduzindo `petalPath` e amostrando as curvas de Bezier geradas): raio maximo da petala com `ratio = 1.0` e **exatamente 90.000** (`LIMIT_RADIUS`) e com `ratio = 2.0` e **exatamente 135.000** (`MAX_RADIUS`) — a curva Catmull-Rom **nao produz overshoot** alem da ancora da ponta. A ancoragem visual exigida pela task esta matematicamente correta.
- Validacao visual com categorias em 112% e 200% reportada pelo implementador (subtarefa 3.4; `ionic serve` fica para a Task 7.0, conforme a task).

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PetalDistributionChart.tsx` | OK | 1 minor |
| `src/components/PetalDistributionChart.test.tsx` | OK | 1 minor |

## Conferencia dos Requisitos da Task

| Requisito | Status |
|-----------|--------|
| `isOverflow = ratio > 1` calculado em `buildPetals` | OK — linha 67; consumido no render apenas como dado pronto (`petal.isOverflow`), conforme a nota de `clean-code` da task |
| Petala em overflow ultrapassa `limitRadius`, respeitando `OVERFLOW_CAP = 1.5` | OK — escala polilinear (linhas 45–47) + clamp `Math.min(ratio, OVERFLOW_CAP)` em `petalLength` (linhas 82–84); verificado numericamente (90.0 em 100%, 135.0 no cap, sem crescimento acima de 150%) |
| Cor de alerta `getOverflowColor()` (`#FF6B6B`) no lugar da cor da categoria | OK — decidida em `buildPetals` (linha 76); `#FF6B6B` confirmado em `categoryColors.ts:7`; requisito 3.2 do PRD |
| Percentual real sem truncar (`112%`, `187%`) | OK — `Math.round(ratio * 100)` sem cap (linha 73); testes cobrem 112%, 187% e 200%; requisito 3.3 |
| `<path>` com `data-overflow="true"` | OK — linha 139; `undefined` quando nao ha overflow remove o atributo (testado via `hasAttribute`) |
| Destaque nao depende so de cor (redundancia para daltonismo) | OK — tamanho alem do circulo de referencia garantido pela ancoragem da escala; coberto pelo teste comparativo de alcance (130% > 100%); requisito 3.4 |

Subtarefas 3.1–3.4 marcadas e verificadas. Os 4 casos de teste exigidos pela secao "Testes da Tarefa" estao presentes (`data-overflow` + cor de alerta; percentual real sem truncar; percentual real acima do cap; `actual <= expected` sem `data-overflow`), mais um quinto teste comparativo de geometria alem do exigido.

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`src/components/PetalDistributionChart.tsx:67,73` — borda de arredondamento: overflow marginal exibe `100%` com cor de alerta.** Com `ratio` em `(1, 1.005)` (ex.: `actual = 1004`, `expected = 1000`), `isOverflow` e `true` (cor `#FF6B6B`, `data-overflow`), mas `Math.round` exibe `100%` — o usuario ve uma petala de alerta rotulada "100%". O simetrico tambem existe (`ratio = 0.996` exibe `100%` em cor normal). A implementacao segue exatamente a definicao da task/techspec (`isOverflow = ratio > 1`), entao **nao e um desvio** — e uma ambiguidade herdada da spec. Se o produto preferir coerencia entre rotulo e alerta, uma opcao e derivar ambos da mesma grandeza:

   ```ts
   const percent = Math.round(ratio * 100);
   const isOverflow = percent > 100;
   ```

   Recomendo apenas registrar a decisao (manter `ratio > 1` e aceitar a borda, ou alinhar ao `percent`), idealmente antes da Task 6.0, que vai compor o `aria-label` "acima do limite" a partir de `isOverflow`.

2. **`src/components/PetalDistributionChart.test.tsx:152-172` — cobertura de geometria do cap ausente.** O teste comparativo `petalReach` cobre "overflow e maior que 100%", mas nenhum teste garante que a petala **para de crescer** no cap (criterio de sucesso "categoria com 200% cresce apenas ate o cap"): hoje isso so foi validado visualmente. O helper `petalReach` ja existente torna o teste barato:

   ```ts
   it('stops growing past the visual cap of 150%', () => {
     renderChart([
       makeItem({ categoryId: 1, expected: 100, actual: 150 }),
       makeItem({ categoryId: 2, expected: 100, actual: 200 }),
     ]);
     const petals = screen.getAllByTestId('petal');
     expect(petalReach(petals[1])).toBeCloseTo(petalReach(petals[0]), 5);
   });
   ```

   Para isso basta mover `petalReach` para o escopo do `describe` de overflow. Nao bloqueia: o caso nao consta da lista de testes exigidos pela task e a verificacao numerica desta review confirma o comportamento.

Observacao de estilo (nao contabilizada, mesma postura da review da Task 2.0): permanecem linhas em branco dentro de `buildPetals`/`petalPath` e comentarios explicativos — todos em ingles (convencao dos repos controlai) e justificados por documentarem convencoes nao obvias (`lineRadial` com 0 rad as 12h, razao do cap, ancoragem da escala).

## Destaques Positivos

- **Escala polilinear resolve uma inconsistencia latente da techspec.** A formula original da techspec (`baseRadius + (max - base) * min(ratio, cap) / cap`) colocaria a petala de 100% em r ≈ 94, **fora** do circulo de limite (r = 90), violando o proprio requisito de que petalas ≤100% fiquem dentro da referencia. O `domain([0, 1, OVERFLOW_CAP])` ancora `ratio = 1` exatamente em `LIMIT_RADIUS`, cumprindo a task com uma unica expressao declarativa — verificado numericamente nesta review (90.000 e 135.000 exatos, sem overshoot da Catmull-Rom).
- **Decisao de cor colocalizada em `buildPetals`** (`isOverflow ? getOverflowColor() : getCategoryColor(...)`): o render consome `petal.color` pronto, sem ramificacao duplicada — exatamente o que a nota de `clean-code` da task pedia.
- **`data-overflow` idiomatico**: `petal.isOverflow ? 'true' : undefined` omite o atributo em vez de emitir `"false"`, e o teste negativo verifica via `hasAttribute` (nao via valor), o contrato correto.
- **4 dos 7 minors da review da Task 2.0 ja incorporados**: early return em `buildPetals` para lista vazia, gerador `lineRadial` içado para constante de modulo, `type CategoryColor` como import de tipo e `beforeEach` resetando `nextId` nos testes — otimo fechamento de ciclo entre tasks.
- **Teste comparativo de alcance geometrico** (`petalReach` extraindo coordenadas do `d` e medindo `Math.hypot`): valida a redundancia de tamanho (requisito 3.4) pelo output renderizado, sem acoplar a internals do componente — vai alem do checklist exigido.
- **Contraste do rotulo em overflow adequado**: texto `#0D1028` sobre `#FF6B6B` rende ~6.6:1 (acima de AA para texto pequeno); e como petalas em overflow sao sempre longas (ponta ≥ 90 > limiar de 60.75 do rotulo interno), o caso "rotulo fora da ponta" nunca combina com overflow — atende a nota de `frontend-design` da task.
- **Comentarios em ingles**, alinhados a convencao dos repos controlai.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (constantes nomeadas para os novos valores `LIMIT_RADIUS`/`OVERFLOW_CAP`; pendencias de numeros magicos de rotulo sao da Task 2.0, enderecadas na 4.0) |
| TypeScript/Node.js | OK (`tsc --noEmit` sem erros, sem `any`, tipos explicitos) |
| REST/HTTP | Nao aplicavel |
| Logging | Nao aplicavel |
| React | OK (`useMemo` mantido em `buildPetals`; escala e gerador como constantes de modulo; sem estado novo) |
| Testes | OK (13/13 no componente; 364/364 na suite; todos os casos exigidos pela task presentes) |

## Recomendacoes

1. (Minor 1) Decidir e registrar o comportamento para overflow marginal (`100.4%` exibido como `100%` em cor de alerta) antes da Task 6.0, que reutilizara `isOverflow` no `aria-label`.
2. (Minor 2) Adicionar o teste de "para de crescer no cap" (150% vs 200% com mesmo alcance) reaproveitando `petalReach` — pode entrar junto da Task 4.0.
3. (Herdado da Task 2.0, enderecar na 4.0) Extrair constantes de layout do rotulo (`0.45`, `0.72`, `14`, `13`, `700`, `0.55`), mover cor do disco central para CSS/token e aplicar clamp de `halfWidth` para N=1.

## Veredito

**APROVADO.** Nenhum problema critico ou major; os 2 minors sao nao bloqueantes (um e ambiguidade herdada da spec, o outro e reforco de cobertura ja validado numericamente nesta review). Todos os requisitos da task e do PRD (3.1–3.4) foram atendidos, com melhoria real sobre a formula da techspec na ancoragem do circulo de 100%. Typecheck, testes (13/13 e 364/364), lint e build passando. Proximo passo: Task 4.0 (titulo, circulo tracejado de limite, legenda e CSS do tema), que ja encontra `LIMIT_RADIUS` definido para renderizar o circulo de referencia.
