# Review: Task 6 - Interacao por toque/teclado e acessibilidade

**Revisor**: AI Code Reviewer
**Data**: 2026-07-18
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task torna o widget de petalas interativo e acessivel: cada `<path>` de petala recebe `role="button"`, `tabIndex={0}`, `aria-label` no formato exigido pelo PRD (com sufixo `", acima do limite"` em overflow), `onClick` e `onKeyDown` (Enter/Space com `preventDefault`). A legenda reutiliza exatamente o mesmo par de handlers, parametrizado por `data-category-id` — um unico par de callbacks estabilizados com `useCallback`, sem closures por petala, como pedido pelas skills `clean-code` e `vercel-react-best-practices`. O tap target minimo e atacado em duas frentes: `MIN_TIP_RADIUS` (30% do raio do limite) em `petalLength()` e overlay invisivel 44x44 sobre petalas curtas. Foco visivel foi adicionado no CSS para petalas (stroke) e legenda (outline), com feedback `:active` em ambas.

Verificacoes revalidadas de forma independente nesta review: 43/43 testes do componente, 394/394 na suite completa, `tsc --noEmit` limpo e ESLint limpo. A recomendacao 1 da review da Task 5 (mover o `console.warn` do `useMemo` para `useEffect`) foi aplicada.

Foram encontrados apenas problemas minor, nenhum bloqueante.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PetalDistributionChart.tsx` | OK | 2 minor |
| `src/components/PetalDistributionChart.css` | OK | 1 minor (compartilhado com o tsx, ver minor #1) |
| `src/components/PetalDistributionChart.test.tsx` | OK | 0 |
| `6_task.md` (checklist) | OK | 1 minor (ver minor #4) |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **Disco central renderizado sobre os overlays intercepta toques na regiao interna** — `PetalDistributionChart.tsx:260-265` e `PetalDistributionChart.css:51-53`. O `__center-disc` e desenhado depois do map de petalas, portanto fica acima dos `__tap-overlay` na ordem de pintura do SVG. Como ele tem `fill` (cor de fundo), e hit-testavel e "rouba" os toques na porcao do overlay que o sobrepoe. Para a petala mais curta (tip = 27, overlay centrado em 19.5, alcance radial -2.5 a 41.5), a faixa de 0 a 12 (raio do disco) fica morta, reduzindo a altura radial efetiva do alvo de 44 para ~30 unidades no pior caso. O impacto pratico e pequeno (perde-se apenas o recorte mais interno do quadrado), mas a correcao e trivial e elimina o problema por completo:

   ```css
   .petal-distribution-chart__center-disc {
     fill: var(--ion-background-color, #0d1028);
     pointer-events: none;
   }
   ```

2. **Overlays de petalas curtas adjacentes podem se sobrepor perto do centro** — `PetalDistributionChart.tsx:215-219, 244-256`. Com muitas categorias de percentual baixo, os quadrados 44x44 centrados a ~19.5 unidades do centro se sobrepoem lateralmente (com 12 petalas, a separacao angular no raio do overlay e de ~10 unidades). Em regioes sobrepostas, o toque resolve para o overlay renderizado por ultimo, que pode nao ser a petala mais proxima do dedo. O comentario no codigo ja documenta o trade-off simetrico (petalas longas nao recebem overlay para nao roubar toques dos vizinhos), e a mitigacao segue exatamente o que a techspec prescreveu em "Riscos Conhecidos". Registrado como limitacao geometrica conhecida; se virar problema real no uso, uma evolucao seria clampar a largura lateral do overlay ao setor angular da petala (mantendo 44 apenas na direcao radial).

3. **`<li role="button">` descarta a semantica de item de lista** — `PetalDistributionChart.tsx:270-279`. Sobrescrever o role do `<li>` faz o `<ul>` conter filhos que nao sao `listitem`, e leitores de tela podem anunciar a lista como vazia ou com contagem errada. O padrao mais idiomatico e manter o `<li>` neutro e colocar a interacao em um elemento interno:

   ```tsx
   <li key={petal.categoryId} className="petal-distribution-chart__legend-item">
     <button
       type="button"
       className="petal-distribution-chart__legend-button"
       data-category-id={petal.categoryId}
       onClick={handleCategoryActivateClick}
     >
       <span className="petal-distribution-chart__legend-swatch" ... />
       {petal.categoryName}
     </button>
   </li>
   ```

   Bonus: `<button>` nativo entrega Enter/Space e `role` de graca, dispensando o `onKeyDown` manual na legenda. Nao bloqueante — o comportamento atual funciona e esta testado; ESLint nao acusa.

4. **Subtarefa 6.5 marcada como concluida, mas o componente ainda nao esta integrado a Tab1** — `6_task.md:33`. `PetalDistributionChart` nao e importado por nenhuma pagina (verificado via grep nesta review); a integracao acontece na Task 7.0. A validacao manual de toque/teclado no `ionic serve` contra a tela real, portanto, so pode ser plenamente executada na 7.0 — mesma situacao ja registrada na review da Task 5 (minor #4). Registrado aqui para garantir que a validacao manual de interacao (toque em petala/legenda, Tab + Enter/Space com foco visivel) seja de fato executada na Task 7.0.

## Destaques Positivos

- **Par unico de handlers compartilhado via `data-category-id`** (`PetalDistributionChart.tsx:149-164`): petala, overlay e legenda usam os mesmos dois callbacks estabilizados com `useCallback` lendo o id de `event.currentTarget` — zero closures por petala recriadas a cada render, exatamente o desenho pedido pela task (skills `clean-code` e `vercel-react-best-practices`).
- **Overlay de toque invisivel bem projetado**: `aria-hidden="true"`, sem `tabIndex` e sem `role` (`PetalDistributionChart.tsx:244-256`) — amplia o alvo de toque sem criar tab stop duplicado nem ruido para leitores de tela; o caminho de teclado permanece no proprio `<path>` da petala. O CSS usa `fill: transparent` (nao `none`) com comentario explicando que isso mantem o retangulo hit-testavel.
- **`MIN_TIP_RADIUS` aplicado no lugar certo**: o `Math.max` em `petalLength()` (`PetalDistributionChart.tsx:99-101`) preserva a ancora da escala piecewise no circulo de limite (ratio = 1 continua exatamente sobre a referencia de 100%), elevando apenas o piso — a semantica visual de overflow das tasks anteriores fica intacta.
- **`petalAriaLabel` cumpre o PRD literalmente** e esta coberto por testes nos dois formatos (normal e `", acima do limite"`), com `preventDefault` no Space acompanhado de comentario justificando (evitar scroll da pagina) e early return para as demais teclas.
- **Foco visivel adequado ao contexto**: stroke branco 2px via `:focus-visible` na petala (outline retangular ficaria estranho em um path organico) e outline com `outline-offset` negativo na legenda; feedback `:active` em ambos.
- **Tap target da legenda ampliado sem quebrar o layout**: padding vertical + margin negativa (`PetalDistributionChart.css:99-111`) alcanca a altura minima de toque sem inflar o grid da legenda — tecnica limpa e comentada, alinhada a skill `ionic-design`.
- **Cobertura de testes acima do pedido**: os 13 testes novos cobrem todos os 7 casos do checklist da task e ainda adicionam teclas ignoradas (Tab/Escape), Enter/Space na legenda, comprimento minimo da petala, presenca/dimensoes/clique do overlay e ausencia do overlay em petalas longas.
- **Recomendacao da review anterior aplicada**: o `console.warn` defensivo migrou do `useMemo` para um `useEffect` dedicado (`PetalDistributionChart.tsx:140-144`), com comentario explicando o porque.
- Constantes nomeadas para todos os numeros novos (`MIN_TIP_RADIUS`, `TAP_TARGET_SIZE`) com comentarios que registram a razao de existir, incluindo a premissa de mapeamento ~1:1 entre unidades do viewBox e pt.
- Comentarios em ingles, seguindo a convencao dos repos controlai.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK (nomes claros, constantes nomeadas, funcoes curtas com acao unica, sem flags booleanas) |
| TypeScript/Node.js | OK (`tsc --noEmit` limpo, sem `any`; `React.MouseEvent<Element>`/`React.KeyboardEvent<Element>` tipados para servir path SVG, rect e li) |
| REST/HTTP | N/A |
| Logging | OK (apenas o warn defensivo pre-existente, agora em `useEffect`) |
| React | OK (handlers com `useCallback` e deps corretas, derivacao com `useMemo`, `currentTarget` usado corretamente para o dataset) |
| Testes | OK (43/43 no componente; 394/394 na suite completa; ESLint limpo) |

## Recomendacoes

1. Adicionar `pointer-events: none` ao `__center-disc` (minor #1) — uma linha, pode entrar junto com a Task 7.0, que ja tocara a integracao.
2. Na Task 7.0, executar a validacao manual de toque/teclado no `ionic serve` (pendencia declarada da subtarefa 6.5, somada a pendencia visual herdada da 5.4): toque em petala e legenda filtrando o `PurchaseList`, navegacao Tab + Enter/Space com foco visivel, e leitor de tela anunciando categoria/percentual/estouro.
3. Considerar refatorar a legenda para `<button>` dentro do `<li>` (minor #3) em um refactor futuro — simplifica o codigo (remove o `onKeyDown` manual) e restaura a semantica de lista.
4. Se surgirem relatos de toque impreciso com muitas categorias pequenas, clampar a largura lateral do overlay ao setor angular da petala (minor #2).

## Veredito

**APROVADO COM OBSERVACOES.** Todos os requisitos da task foram implementados e testados: petala e legenda disparam o mesmo `onPetalClick` com o mesmo `categoryId`, Enter/Space funcionam com `preventDefault`, o `aria-label` segue o formato do PRD (incluindo overflow), o comprimento minimo de petala e o overlay 44x44 garantem o tap target, e ha foco visivel para teclado. Typecheck, lint e as suites de teste passam integralmente (revalidados nesta review). Os quatro apontamentos sao minor e nao bloqueiam o avanco. Proximo passo: seguir para a Task 7.0 (integracao com a Tab1), aplicando a recomendacao 1 e executando a validacao manual pendente (recomendacao 2).
