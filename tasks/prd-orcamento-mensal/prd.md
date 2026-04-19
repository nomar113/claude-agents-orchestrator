# PRD: Tela de Orcamento Mensal Editavel

## Visao Geral

O app ControlAI possui uma tela de planejamento orcamentario (`/budget`) que atualmente funciona apenas como visualizacao. O backend ja oferece CRUD completo com 11 endpoints (budgets, items e incomes), mas o frontend nao permite ao usuario adicionar, editar ou remover itens de gasto, investimento ou receita. Alem disso, a interface visual esta desalinhada com o design de referencia no Paper (artboard "Orcamento Mensal").

Esta feature visa alinhar a tela ao design do Paper e tornar todas as funcionalidades de planejamento orcamentario acessiveis ao usuario, incluindo modo de edicao inline, duplicacao de mes e campo de icone/emoji nas categorias.

## Objetivos

- **Paridade visual com o design Paper**: Implementar o layout, cores, tipografia e componentes conforme o artboard "Orcamento Mensal".
- **CRUD completo no frontend**: Permitir adicionar, editar e remover itens de gasto, investimento e receita diretamente na tela.
- **Modo edicao inline**: Botao "Editar" transforma a tela em modo editavel; botao muda para "Salvar".
- **Duplicacao de mes**: Permitir copiar o orcamento de um mes para outro mes escolhido pelo usuario.
- **Icone por categoria**: Adicionar campo de emoji/icone na entidade de categoria (backend) para exibicao visual no frontend.
- **Feedback visual claro**: Barras de progresso por item, cores dinamicas para diferencas (verde = sobra, vermelho = estourou).

## Historias de Usuario

- Como usuario, eu quero ver meu orcamento mensal com comparacao planejado vs real para entender minha situacao financeira do mes.
- Como usuario, eu quero clicar em "Editar" para entrar em modo de edicao e adicionar ou remover categorias de gasto e investimento no meu orcamento.
- Como usuario, eu quero editar o valor planejado de cada categoria inline para ajustar meu orcamento rapidamente.
- Como usuario, eu quero adicionar, editar e remover fontes de receita (label + valor) para manter meu orcamento atualizado.
- Como usuario, eu quero duplicar meu orcamento para outro mes para nao precisar recriar tudo do zero a cada mes.
- Como usuario, eu quero ver barras de progresso e cores (verde/vermelho) por categoria para identificar rapidamente onde estou dentro ou fora do planejado.
- Como usuario, eu quero ver um icone/emoji em cada categoria para facilitar a identificacao visual.

## Funcionalidades Principais

### F1: Redesign Visual — Summary Card

O card de resumo "Planejado vs Real" deve exibir:

- **RF-01**: Badge de porcentagem com cor dinamica (verde <=80%, amarelo >80%, vermelho >100%).
- **RF-02**: Valores de "Planejado" e "Real" lado a lado com barra de progresso entre eles.
- **RF-03**: Linha inferior com tres metricas: Receitas, Saldo e Investido (novo campo).
- **RF-04**: Calculo de "Investido" = soma dos valores planejados dos itens do tipo INVESTMENT.

### F2: Redesign Visual — Cards de Categoria

Cada item de gasto ou investimento deve ser exibido como card contendo:

- **RF-05**: Icone/emoji da categoria a esquerda.
- **RF-06**: Nome da categoria e diferenca colorida ("+R$ X" verde ou "-R$ X" vermelho) na linha superior.
- **RF-07**: Valores "Plan: R$ X" e "Real: R$ X" na linha inferior.
- **RF-08**: Barra de progresso individual (proporcao real/planejado) com cor dinamica.

### F3: Modo Edicao Inline

- **RF-09**: Botao "Editar" no rodape ativa modo edicao; muda para "Salvar" ao ativar.
- **RF-10**: Em modo edicao, os valores planejados dos itens ficam editaveis (input numerico).
- **RF-11**: Em modo edicao, botoes de adicionar (+) e remover (x) aparecem em cada secao (Gastos, Investimentos, Receitas).
- **RF-12**: Ao clicar "Salvar", todas as alteracoes sao enviadas ao backend e a tela volta ao modo visualizacao.

### F4: CRUD de Itens (Gastos e Investimentos)

- **RF-13**: Adicionar item: seletor de categoria + tipo (Gasto ou Investimento) + valor planejado.
- **RF-14**: Editar item: alterar valor planejado inline.
- **RF-15**: Remover item: botao de remover visivel no modo edicao, com confirmacao.
- **RF-16**: Validacao: nao permitir adicionar a mesma categoria duas vezes no mesmo budget.

### F5: CRUD de Receitas

- **RF-17**: Adicionar receita: campos label (texto livre) e valor.
- **RF-18**: Editar receita: label e valor editaveis inline no modo edicao.
- **RF-19**: Remover receita: botao de remover visivel no modo edicao, com confirmacao.

### F6: Duplicar Mes

- **RF-20**: Botao "Duplicar Mes" no rodape abre seletor de mes destino.
- **RF-21**: O seletor exibe meses futuros e indica quais ja possuem orcamento.
- **RF-22**: Ao confirmar, chama endpoint POST /budgets/{id}/duplicate?targetMonth=YYYY-MM.
- **RF-23**: Exibe toast de sucesso/erro apos a duplicacao.
- **RF-24**: Se o mes destino ja tiver orcamento, exibir alerta de confirmacao para sobrescrever.

### F7: Icone/Emoji por Categoria

- **RF-25**: Adicionar campo `icon` (varchar) na tabela `categories` do backend.
- **RF-26**: Exibir o icone da categoria nos cards de gasto e investimento.
- **RF-27**: Usar emoji padrao generico quando a categoria nao tiver icone definido.

## Experiencia do Usuario

### Fluxo Principal — Visualizacao

1. Usuario acessa /budget.
2. Tela carrega o orcamento do mes atual (ou exibe "Criar Planejamento" se nao existir).
3. Navega entre meses com setas.
4. Visualiza summary card, gastos, investimentos, receitas e meios de pagamento.

### Fluxo de Edicao

1. Usuario clica em "Editar" no rodape.
2. Tela entra em modo edicao: valores planejados viram inputs, botoes +/x aparecem.
3. Usuario adiciona/edita/remove itens e receitas.
4. Clica "Salvar" para persistir ou "Cancelar" para descartar.

### Fluxo de Duplicacao

1. Usuario clica em "Duplicar Mes".
2. Seletor de mes aparece (modal ou action sheet).
3. Usuario escolhe mes destino e confirma.
4. Toast confirma sucesso ou erro.

### Consideracoes de UX

- Inputs numericos devem usar mascara de moeda (R$).
- Confirmacao antes de remover itens (alert nativo do Ionic).
- Loading state durante operacoes de rede.
- Feedback visual (toast) para todas as acoes de CRUD.
- Secoes colapsaveis devem manter estado ao alternar modo edicao.

## Restricoes Tecnicas de Alto Nivel

- **Backend**: 11 endpoints ja implementados e funcionais. Unica alteracao necessaria: adicionar campo `icon` na tabela `categories` (migracao Flyway).
- **Frontend**: Ionic/React. Deve consumir os endpoints existentes sem alteracao de contrato.
- **Design de referencia**: Artboard "Orcamento Mensal" no Paper (arquivo ControlAI, ID 158-0). Cores, fontes e layout devem seguir o design.
- **Fontes**: IBM Plex Sans (principal) e IBM Plex Mono (valores numericos), conforme design.
- **Tema**: Dark mode (fundo escuro conforme design Paper).

## Fora de Escopo

- Graficos historicos de evolucao orcamentaria (comparacao entre meses).
- Notificacoes push de estouro de orcamento.
- Orcamento recorrente automatico (auto-duplicacao mensal).
- Relatorio exportavel (PDF/CSV) do orcamento.
- Edicao do campo de icone/emoji da categoria pelo usuario (sera preenchido por logica interna baseada no CNAE para invoices — escopo futuro).
- Alteracoes na tela de meios de pagamento (somente leitura conforme design).
