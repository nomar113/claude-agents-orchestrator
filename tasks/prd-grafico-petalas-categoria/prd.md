# PRD — Gráfico de Pétalas por Categoria (Tela "Por Categoria" + Detalhe de Categoria)

## Visão Geral

Esta funcionalidade entrega a **visão detalhada de gastos por categoria** do ControlAI, composta por duas superfícies:

1. **Tela "Por categoria"** — uma tela dedicada que apresenta o mês selecionado com: total gasto, quantidade de categorias com movimento, alerta de categorias acima do limite, o **gráfico de pétalas** de distribuição e uma **lista de categorias** com percentual de consumo do limite e barra de progresso.
2. **Bottom sheet de categoria (pétala selecionada)** — um painel de detalhe aberto ao tocar em uma pétala ou em uma linha da lista, mostrando o consumo da categoria (gasto vs. limite), o valor do estouro quando houver, e a lista de compras da categoria no mês, com ordenações e filtro por cartão.

Ela complementa o widget de distribuição da Tab1 (PRD `prd-grafico-petalas-distribuicao`): o widget dá a leitura de relance na tela inicial; esta funcionalidade é o destino do aprofundamento — responde "quanto gastei, onde, e em quê exatamente" sem que o usuário precise cruzar telas ou somar valores mentalmente.

**Problema que resolve:** hoje, após perceber que uma categoria está alta, o usuário não tem um caminho único para auditar a categoria — precisa navegar pela lista geral de compras e filtrar manualmente. Esta funcionalidade fecha o ciclo *percepção → diagnóstico → compra específica* em no máximo dois toques.

## Objetivos

- **Fechar o funil de diagnóstico**: do widget da Tab1 (ou do Orçamento Mensal) até a compra individual que causou o estouro em até 2 toques.
- **Dar visibilidade retroativa**: permitir revisar a distribuição de qualquer mês anterior, não apenas o corrente.
- **Quantificar o estouro**: o usuário deve ver **em reais** quanto uma categoria ultrapassou o limite, não apenas o percentual.

Métricas a acompanhar:

- % de sessões da tela "Por categoria" que abrem o bottom sheet de pelo menos uma categoria.
- % de acessos à tela vindos do widget da Tab1 vs. do Orçamento Mensal.
- Taxa de uso da navegação para meses anteriores.

## Histórias de Usuário

- Como **usuário do casal**, quero abrir uma tela dedicada de gastos por categoria a partir do widget da Tab1, para analisar o mês com mais detalhe do que o widget permite.
- Como **usuário do casal**, quero ver o total gasto no mês e quantas categorias estão acima do limite logo no topo da tela, para dimensionar o problema antes de investigar categoria a categoria.
- Como **usuário do casal**, quero tocar em uma pétala (ou linha da lista) e ver as compras daquela categoria no mês, para identificar exatamente quais compras causaram o consumo.
- Como **usuário do casal**, quando uma categoria estourou, quero ver o valor do estouro em reais (ex.: "Estourou em R$ 96,12"), para saber o tamanho do ajuste necessário.
- Como **usuário do casal**, quero ordenar a lista de categorias por % do limite ou por valor gasto, para alternar entre a leitura de risco (percentual) e a de magnitude (reais).
- Como **usuário do casal**, quero navegar para meses anteriores, para comparar meu comportamento e revisar fechamentos passados.
- Como **usuário do casal**, dentro do detalhe da categoria, quero ordenar as compras por mais recentes ou maiores valores e filtrar por cartão, para localizar rapidamente uma compra específica.

## Funcionalidades Principais

### 1. Tela "Por categoria" — cabeçalho e resumo do mês

- **O que faz:** apresenta o contexto do mês selecionado: título, período, total gasto e indicadores de alerta.
- **Por que importa:** dimensiona a situação do mês antes do detalhamento.

**Requisitos funcionais:**

1.1. O cabeçalho deve exibir o título "Por categoria", o mês/ano selecionado (ex.: "JUNHO · 2026") e um botão de voltar.
1.2. Um card de resumo deve exibir o **total gasto no mês** (soma de todas as compras do casal no período, em todas as categorias com orçamento) e a **quantidade de categorias** com gasto no período.
1.3. Quando houver categorias acima do limite, o card de resumo deve exibir um badge de alerta com a contagem (ex.: "2 acima do limite").
1.4. O total e os indicadores devem refletir o mês selecionado, atualizando ao navegar entre meses.

### 2. Gráfico de pétalas na tela

- **O que faz:** renderiza o mesmo gráfico de pétalas do widget da Tab1, aplicado ao mês selecionado.
- **Por que importa:** mantém a continuidade visual entre o widget e a tela de detalhe.

**Requisitos funcionais:**

2.1. O gráfico deve seguir as mesmas regras de renderização, cálculo e destaque de estouro definidas no PRD `prd-grafico-petalas-distribuicao` (requisitos 1.x, 2.1 e 3.x daquele documento), aplicadas ao **mês selecionado** em vez de fixo no mês corrente.
2.2. O bloco deve manter o título "DISTRIBUIÇÃO", o indicador "Limite = 100%" e a legenda de categorias com nome e cor.
2.3. Tocar em uma pétala ou em um item da legenda deve abrir o **bottom sheet de detalhe da categoria** (funcionalidade 4).

### 3. Lista de categorias com ordenação

- **O que faz:** lista todas as categorias exibidas no gráfico, com valores absolutos, percentual e barra de progresso.
- **Por que importa:** dá a leitura precisa (números) que o gráfico entrega apenas visualmente.

**Requisitos funcionais:**

3.1. Cada linha deve exibir: indicador de cor da categoria (mesma cor da pétala/legenda), nome, valor gasto e limite (ex.: "R$ 896,12 · de R$ 800,00"), percentual de consumo e barra de progresso proporcional.
3.2. Categorias acima de 100% devem exibir o badge "Estourou" e usar o estilo de alerta no percentual e na barra.
3.3. Um seletor de ordenação deve permitir alternar entre **"% do limite"** (padrão, decrescente) e **"valor gasto"** (decrescente).
3.4. Tocar em uma linha deve abrir o bottom sheet de detalhe da categoria (funcionalidade 4).
3.5. A lista deve conter exatamente as mesmas categorias exibidas no gráfico (orçamento configurado E gasto > 0 no mês selecionado).

### 4. Bottom sheet de detalhe da categoria (pétala selecionada)

- **O que faz:** painel sobreposto com o consumo da categoria e a lista de compras do mês.
- **Por que importa:** é o último passo do funil — liga o número agregado às compras individuais.

**Requisitos funcionais:**

4.1. O cabeçalho do sheet deve exibir: nome da categoria, quantidade de compras e período (ex.: "5 compras · Junho 2026") e botão de fechar.
4.2. Quando a categoria estourou o limite, o cabeçalho deve exibir o **valor do estouro em reais** (ex.: "Estourou em R$ 96,12").
4.3. Um card deve exibir gasto e limite lado a lado (ex.: "R$ 896,12 · R$ 800,00"), o percentual de consumo e uma barra de progresso, com estilo de alerta quando acima de 100%.
4.4. A lista de compras deve exibir, por item: descrição/estabelecimento, cartão utilizado com final (ex.: "Nubank Ramon · **** 4521") ou meio de pagamento (ex.: "Pix recorrente"), valor e data/hora.
4.5. Devem existir ordenações **"Recentes"** (padrão, data decrescente) e **"Maiores"** (valor decrescente).
4.6. Deve existir um filtro **"Cartão"** que restringe a lista às compras de um cartão específico do casal.
4.7. O sheet deve ser dispensável por botão de fechar e por gesto de arrastar para baixo.
4.8. O sheet deve abrir a partir de: pétala/legenda/linha da tela "Por categoria" e pétala/legenda/linha do gráfico da tela **Orçamento Mensal**.

### 5. Navegação entre meses

- **O que faz:** permite mudar o mês de referência de toda a tela.
- **Por que importa:** habilita revisão retroativa e comparação de comportamento.

**Requisitos funcionais:**

5.1. O usuário deve poder navegar para meses anteriores e retornar até, no máximo, o mês corrente (não há navegação para meses futuros).
5.2. Ao trocar o mês, resumo, gráfico e lista devem ser recalculados para o período selecionado.
5.3. O mês selecionado deve estar sempre visível no cabeçalho.
5.4. O percentual de meses passados deve considerar o mês fechado completo; o mês corrente considera do dia 1 até o dia atual.

### 6. Pontos de entrada

**Requisitos funcionais:**

6.1. O widget de distribuição da Tab1 deve dar acesso à tela "Por categoria" (mês corrente).
6.2. A tela "Orçamento Mensal" deve dar acesso à tela "Por categoria", preservando o mês que estiver selecionado no Orçamento Mensal.
6.3. O botão de voltar deve retornar à tela de origem.

### 7. Estados vazios

**Requisitos funcionais:**

7.1. Quando o mês selecionado não tiver nenhum gasto em categorias com orçamento, a tela deve exibir estado vazio no lugar do gráfico e da lista, mantendo cabeçalho e navegação de meses.
7.2. Quando o filtro de cartão no bottom sheet não retornar compras, o sheet deve exibir mensagem de "nenhuma compra" mantendo o filtro visível para ajuste.

## Experiência do Usuário

**Jornada principal:**

1. Usuário percebe no widget da Tab1 (ou no Orçamento Mensal) uma categoria estourada.
2. Acessa a tela "Por categoria" e vê o total do mês e o badge "N acima do limite".
3. Toca na pétala/linha da categoria estourada → bottom sheet abre com "Estourou em R$ X" e as compras.
4. Ordena por "Maiores" ou filtra por cartão e identifica a compra responsável.
5. Opcionalmente navega para o mês anterior para comparar.

**Considerações de UI/UX:**

- A tela usa o mesmo dark theme e linguagem visual do restante do app; cores das categorias devem ser idênticas entre pétala, legenda, lista e bottom sheet.
- O seletor de ordenação e o filtro de cartão devem indicar claramente o estado ativo.
- O bottom sheet deve cobrir parcialmente a tela, mantendo o contexto visível ao fundo.
- Barras de progresso e percentuais precisam de contraste suficiente sobre o fundo escuro, especialmente nos tons de alerta.

**Requisitos de acessibilidade:**

- Linhas da lista de categorias com rótulo acessível: `"{Categoria}: R$ {gasto} de R$ {limite}, {percentual}% do limite"` + `"acima do limite"` quando estourada.
- O bottom sheet deve anunciar seu título ao abrir e ser dispensável por leitor de tela.
- Estado de estouro nunca comunicado apenas por cor (badge textual + valor em reais já provêm redundância).
- Tap targets mínimos recomendados para mobile em pétalas, linhas, abas de ordenação e filtro.

## Restrições Técnicas de Alto Nível

- **Consistência de dados:** total, percentuais e listas devem usar a mesma fonte agregada de gastos do casal usada pelo widget da Tab1 e pelo Orçamento Mensal — os números devem coincidir entre as três superfícies para o mesmo período.
- **Dependências:** orçamento mensal por categoria configurado (pré-requisito) e o widget da Tab1 (PRD `prd-grafico-petalas-distribuicao`) como ponto de entrada.
- **Histórico:** a navegação por meses depende da disponibilidade dos gastos e limites históricos por categoria; meses sem dados seguem o estado vazio (7.1).
- **Performance:** abertura da tela e do bottom sheet sem atraso perceptível; a troca de mês deve dar feedback imediato de carregamento.

## Fora de Escopo

- **Edição de orçamento/limite** a partir desta tela ou do bottom sheet — permanece na tela de orçamento mensal.
- **Comparação histórica lado a lado** (gráficos de tendência, médias entre meses) — a navegação por meses é apenas sequencial.
- **Edição ou exclusão de compras** a partir do bottom sheet — tocar em uma compra não abre fluxo de edição nesta versão.
- **Filtro por cartão no nível da tela** — o filtro de cartão existe apenas dentro do bottom sheet; gráfico e lista sempre agregam todos os cartões do casal.
- **Exportação ou compartilhamento** de imagem/relatório.
- **Sub-categorias e sub-cartões** — a visão opera no nível de categoria principal e agrega sub-cartões ao cartão pai.
- **Notificações push** sobre estouro.
- **Seleção de intervalo customizado** — apenas mês fechado como unidade de período.
