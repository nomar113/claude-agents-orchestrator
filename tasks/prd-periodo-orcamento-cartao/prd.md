# PRD: Periodo por Meio de Pagamento no Orcamento

## Visao Geral

No ControlAI, o orcamento mensal calcula o valor "Real" (gasto efetivo) com base nas compras registradas. Porem, cada cartao de credito possui um dia de fechamento diferente, o que significa que as compras que entram na fatura de um mes nao coincidem com o mes calendario. Atualmente, nao ha como definir qual intervalo de datas de compras deve ser considerado para cada meio de pagamento dentro de um orcamento mensal.

Esta funcionalidade permite que o usuario configure, para cada meio de pagamento (cartoes de credito e PIX), um range de datas (De/Ate) que define quais compras serao contabilizadas no valor "Real" daquele orcamento. As datas sao pre-sugeridas com base no dia de fechamento do cartao, mas o usuario pode ajusta-las livremente.

## Objetivos

- **Precisao do orcamento**: Garantir que o valor "Real" reflita exatamente as compras que entram na fatura de cada cartao naquele mes.
- **Autonomia do usuario**: Permitir ajuste manual das datas para cobrir cenarios especificos (ferias, compras internacionais com delay, etc.).
- **Reducao de erro**: Eliminar a contabilizacao incorreta de compras que pertencem a faturas de meses diferentes.

Metricas de sucesso:
1. 100% dos meios de pagamento com range de datas configurado ao criar/duplicar um orcamento.
2. Valor "Real" calculado corretamente com base nos ranges configurados.

## Historias de Usuario

1. **Como** usuario do ControlAI, **quero** ver o periodo de datas configurado para cada meio de pagamento no meu orcamento **para que** eu saiba exatamente quais compras estao sendo consideradas.

2. **Como** usuario do ControlAI, **quero** que as datas sejam pre-preenchidas com base no dia de fechamento do cartao **para que** eu nao precise configurar manualmente todo mes.

3. **Como** usuario do ControlAI, **quero** poder editar as datas de cada meio de pagamento **para que** eu ajuste o periodo quando necessario (ex: fechamento cai no fim de semana e o banco antecipa).

4. **Como** usuario do ControlAI, **quero** que o valor "Real" do orcamento considere apenas compras dentro do range configurado **para que** o planejado vs real seja preciso.

## Funcionalidades Principais

### F1. Secao "Periodo por Meio de Pagamento"

Nova secao na tela de Orcamento Mensal, posicionada logo apos o componente "Planejado vs Real". Exibe todos os meios de pagamento (cartoes de credito e PIX) com seus respectivos ranges de datas.

**Requisitos funcionais:**
1. RF01 — A secao deve ser sempre visivel na tela do orcamento (nao apenas em modo edicao).
2. RF02 — A secao deve ser colapsavel, seguindo o padrao das demais secoes (Gastos por Categoria, Investimentos, etc.).
3. RF03 — Cada meio de pagamento deve exibir: badge colorido, nome, dia de fechamento (se aplicavel) e dois campos de data (De e Ate).
4. RF04 — Apenas meios de pagamento do tipo CREDIT_CARD e PIX devem aparecer na secao.
5. RF05 — Meios de pagamento do tipo CASH nao devem aparecer.

### F2. Auto-sugestao de Datas

As datas sao pre-preenchidas automaticamente com base no dia de fechamento do cartao.

**Requisitos funcionais:**
6. RF06 — Para cartoes de credito: a data "De" deve ser o dia seguinte ao fechamento do mes anterior; a data "Ate" deve ser o dia de fechamento do mes corrente.
7. RF07 — Para PIX (sem dia de fechamento): a data "De" deve ser dia 1 do mes do orcamento; a data "Ate" deve ser o ultimo dia do mes do orcamento.
8. RF08 — As datas sugeridas devem ser calculadas ao criar ou duplicar um orcamento.

### F3. Edicao Manual de Datas

O usuario pode alterar as datas livremente.

**Requisitos funcionais:**
9. RF09 — Os campos de data devem ser editaveis apenas quando o orcamento estiver em modo edicao.
10. RF10 — Ao tocar no campo de data, deve abrir um date picker nativo do dispositivo.
11. RF11 — A data "Ate" nao pode ser anterior a data "De" (validacao).
12. RF12 — Alteracoes nas datas devem ser persistidas ao salvar o orcamento.

### F4. Filtragem do Valor "Real"

O range de datas afeta diretamente o calculo do valor "Real" no orcamento.

**Requisitos funcionais:**
13. RF13 — O valor "Real" de cada categoria deve considerar apenas compras cujo meio de pagamento tenha a data da compra dentro do range configurado (De <= data_compra <= Ate).
14. RF14 — O total "Real" do orcamento deve refletir a soma filtrada.
15. RF15 — A secao "Meios de Pagamento" deve refletir os totais filtrados pelo range.
16. RF16 — O percentual "Planejado vs Real" deve ser recalculado com base nos valores filtrados.

## Experiencia do Usuario

### Fluxo principal
1. Usuario acessa o Orcamento Mensal de um mes.
2. Abaixo do "Planejado vs Real", ve a secao "Periodo por Meio de Pagamento" com os cartoes e datas ja preenchidas.
3. Os valores "Real" nas categorias ja refletem as compras filtradas pelo range.
4. Se precisar ajustar, clica em "Editar", altera as datas e salva.

### UI/UX
- Visual consistente com o design system existente (dark theme, IBM Plex Sans, badges coloridos).
- Campos de data com icone de calendario, fundo escuro com borda sutil.
- Texto auxiliar explicando que as datas sao baseadas no fechamento.
- Secao colapsavel com chevron e contador de meios de pagamento.

### Acessibilidade
- Campos de data devem ser acessiveis via leitor de tela com labels "De" e "Ate" associados ao nome do cartao.
- Contraste adequado nos textos e campos.

## Restricoes Tecnicas de Alto Nivel

- Integracao com o modelo de PaymentMethod existente (tipo CREDIT_CARD e PIX, campo closingDay).
- O calculo do "Real" filtrado deve ser feito no backend para garantir consistencia.
- As datas de periodo devem ser persistidas por orcamento (cada mes tem seu proprio range por meio de pagamento).
- Performance: o calculo filtrado nao deve adicionar latencia perceptivel ao carregamento do orcamento.

## Fora de Escopo

- Configuracao de periodo para meios de pagamento do tipo CASH.
- Historico de alteracoes de datas.
- Notificacoes ou alertas sobre datas proximas ao fechamento.
- Configuracao global de ranges (cada orcamento mensal tem seus proprios ranges).
- Sub-cartoes: o range e definido no nivel do cartao principal, nao por sub-cartao.
