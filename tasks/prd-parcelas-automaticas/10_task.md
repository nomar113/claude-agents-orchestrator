# Tarefa 10.0: Frontend — Card de projecao de comprometimento futuro na Tab1

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar card na Home (Tab1) mostrando o total comprometido com parcelas nos proximos meses. O card ajuda o usuario a planejar novos gastos sabendo quanto ja esta comprometido.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Buscar projecao via `installmentService.getProjection()`
- Exibir card com titulo "Parcelas Futuras" ou "Comprometimento com Parcelas"
- Mostrar os proximos 3 meses com total e quantidade de parcelas por mes
- Formato: "Mai/2026 — R$ 1.589,23 (8 parcelas)"
- Loading skeleton enquanto carrega
- Empty state quando nao ha parcelas futuras (nao exibir o card)
- Posicionar entre o card de resumo e a secao de cartoes, ou apos os cartoes
</requirements>

## Subtarefas

- [ ] 10.1 Buscar projecao via `getProjection()` no `Tab1`
- [ ] 10.2 Criar componente/secao de card de projecao com estilo
- [ ] 10.3 Implementar loading skeleton e empty state
- [ ] 10.4 Testes

## Detalhes de Implementacao

Consultar secao "RF06 - Projecao de Comprometimento Futuro" do `prd.md`.

O card deve seguir o estilo visual existente do `Tab1` (classes `ctrl-*`). Sugestao de posicao: apos o `CardStack` de cartoes e antes da secao "Ultimas Compras".

Para formatar o mes, usar array de nomes de meses em portugues (jan, fev, mar...) ja presente em `Tab2.tsx`.

## Criterios de Sucesso

- Card exibe projecao correta dos proximos 3 meses
- Card nao aparece quando nao ha parcelas futuras
- Loading skeleton exibido durante carregamento
- Visual consistente com o design system existente
- Build e testes passam

## Testes da Tarefa

- [ ] Testes de unidade: card renderiza 3 meses com valores corretos (mock de getProjection)
- [ ] Testes de unidade: card nao renderiza quando projecao e vazia
- [ ] Testes de unidade: loading skeleton exibido durante carregamento

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/Tab1.tsx` (modificar)
- `src/pages/Tab1.css` (modificar)
- `src/services/installmentService.ts` (da tarefa 6)
- `src/types/installment.ts` (da tarefa 6)
