# Tarefa 3.0: Destaque visual de estouro de limite (>100%)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar ao `PetalDistributionChart` o tratamento de categorias que estouraram o limite (`ratio > 1`): a petala cresce alem do circulo de referencia de 100%, recebe cor de alerta e continua exibindo o percentual real sem truncamento. Corresponde a funcionalidade 3 do PRD (requisitos 3.1–3.4).

<skills>
### Conformidade com Skills Padroes

- `frontend-design` — redundancia visual (cor + tamanho) para acessibilidade; contraste do texto sobre a cor de alerta.
- `clean-code` — flag `isOverflow` derivada no `buildPetals`, sem logica duplicada no render.
</skills>

<requirements>
- `isOverflow = ratio > 1` calculado em `buildPetals` (ver `PetalDatum` na techspec.md).
- Petala em overflow renderizada alem do circulo de 100% (`limitRadius`), respeitando o cap visual `OVERFLOW_CAP = 1.5`: acima de 150% a petala para de crescer, mas o texto exibe o percentual real (requisito 3.1 do PRD + "Modelos de Dados" da techspec).
- Petala em overflow usa `getOverflowColor()` (`#FF6B6B`) no lugar da cor da categoria (requisito 3.2).
- Percentual real exibido sem truncar (ex.: `112%`, `187%`) (requisito 3.3).
- `<path>` da petala em overflow recebe `data-overflow="true"` (hook de teste e estilo).
- Destaque nao depende exclusivamente de cor: tamanho alem do circulo de referencia prove redundancia para daltonismo (requisito 3.4).
</requirements>

## Subtarefas

- [x] 3.1 Derivar `isOverflow` em `buildPetals` e aplicar `getOverflowColor()` e `data-overflow="true"` nas petalas em estouro.
- [x] 3.2 Garantir na geometria que a petala em overflow ultrapassa `limitRadius` e respeita o cap de `OVERFLOW_CAP = 1.5`.
- [x] 3.3 Ampliar `PetalDistributionChart.test.tsx` com os casos de overflow.
- [x] 3.4 Executar testes e validar visualmente (render SVG com dados estaticos incluindo categorias estouradas; `ionic serve` fica para a integracao na Tarefa 7.0).

## Detalhes de Implementacao

Ver secoes "Modelos de Dados" (calculo de `ratio`, `percent`, `isOverflow`, `OVERFLOW_CAP`) e "Geometria das Petalas" na `techspec.md`.

## Criterios de Sucesso

- Categoria com 112% aparece maior que o circulo de 100% e em cor de alerta, com texto `112%`.
- Categoria com 200% cresce apenas ate o cap visual, mas exibe `200%`.
- Petalas normais permanecem com cor da categoria e dentro do circulo de referencia.

## Testes da Tarefa

- [x] Testes de unidade (`PetalDistributionChart.test.tsx`):
  - Petala com `actual > expected` recebe `data-overflow="true"` e cor de alerta (`getOverflowColor()`).
  - Petala com `actual > expected` mantem o numero real (ex.: `112%`), sem truncar.
  - Petala com ratio acima do cap (ex.: 200%) exibe o percentual real.
  - Petala com `actual <= expected` NAO recebe `data-overflow`.
- [ ] Testes de integracao: cobertos na Tarefa 7.0 via `Tab1.test.tsx`.
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PetalDistributionChart.tsx` (modificado)
- `src/components/PetalDistributionChart.test.tsx` (modificado)
- `src/utils/categoryColors.ts` (`getOverflowColor`)
