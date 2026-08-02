# Tarefa 5.0: Estado vazio + botao "Ver gastos detalhados"

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Cobrir os caminhos secundarios do widget: o botao "Ver gastos detalhados" na parte inferior (sempre visivel) e o estado vazio quando nao ha nenhum gasto elegivel no mes. Corresponde as funcionalidades 5 e 6 do PRD (requisitos 5.1–5.3 e 6.1–6.3).

<skills>
### Conformidade com Skills Padroes

- `frontend-design` — estado vazio claro e nao confuso; botao com hierarquia adequada.
- `ionic-design` — usar componente de botao Ionic (`IonButton`) coerente com o restante da Tab1.
- `clean-code` — ramificacao vazio/com-dados legivel, sem aninhamento profundo.
</skills>

<requirements>
- Botao "Ver gastos detalhados" visivel na parte inferior do widget em TODOS os estados, inclusive vazio (requisitos 5.1 e 5.3 do PRD).
- Acionar o botao dispara o callback `onViewDetailsClick` (o scroll real para a lista e conectado na Tarefa 7.0).
- Botao com rotulo acessivel explicito (requisito de acessibilidade do PRD).
- Quando a lista filtrada de itens elegiveis esta vazia, renderizar estado vazio textual/ilustrado no lugar do grafico (requisito 6.1).
- Estado vazio mantem visiveis o titulo "DISTRIBUIÇÃO" e o botao "Ver gastos detalhados" (requisito 6.2).
- Mensagem do estado vazio indica claramente que ainda nao ha gastos no mes (requisito 6.3).
- `console.warn` defensivo apenas se `items` vier nulo (ver "Monitoramento e Observabilidade" na techspec) — sem `console.log` ruidoso.
</requirements>

## Subtarefas

- [x] 5.1 Adicionar o botao "Ver gastos detalhados" com callback `onViewDetailsClick` e rotulo acessivel.
- [x] 5.2 Implementar o estado vazio (mensagem no lugar do grafico, mantendo titulo e botao).
- [x] 5.3 Ampliar `PetalDistributionChart.test.tsx` com os casos de botao e estado vazio.
- [x] 5.4 Executar testes e validar visualmente os dois estados no `ionic serve`. (Validacao visual no app depende da integracao com a Tab1 — Tarefa 7.0; estados cobertos por testes unitarios.)

## Detalhes de Implementacao

Ver "Visao Geral dos Componentes" e "Pontos de Integracao" (item "Ver gastos detalhados") na `techspec.md`. O componente apenas dispara o callback; o `scrollIntoView` em `purchasesSectionRef` e responsabilidade do `Tab1.tsx` (Tarefa 7.0).

## Criterios de Sucesso

- Com dados: grafico completo + botao visivel abaixo.
- Sem dados elegiveis: mensagem clara de "sem gastos no mes", titulo e botao permanecem visiveis, nenhum SVG de flor vazio renderizado.
- Clique no botao dispara `onViewDetailsClick` exatamente uma vez.

## Testes da Tarefa

- [x] Testes de unidade (`PetalDistributionChart.test.tsx`):
  - Clique no botao "Ver gastos detalhados" dispara `onViewDetailsClick`.
  - Estado vazio: lista filtrada vazia renderiza mensagem e mantem o botao visivel.
  - Estado vazio: titulo "DISTRIBUIÇÃO" permanece visivel.
  - Estado vazio tambem ocorre quando ha itens, mas nenhum elegivel (ex.: todos com `actual === 0`).
  - Botao possui rotulo acessivel.
- [ ] Testes de integracao: cobertos na Tarefa 7.0 via `Tab1.test.tsx` (scroll para "Ultimas Compras").
- [ ] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PetalDistributionChart.tsx` (modificado)
- `src/components/PetalDistributionChart.css` (modificado)
- `src/components/PetalDistributionChart.test.tsx` (modificado)
