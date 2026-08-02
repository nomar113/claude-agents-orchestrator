# PRD — Gráfico de Pétalas (Distribuição de Gastos)

## Visão Geral

O **Gráfico de Pétalas** é um widget visual na **tela inicial (Tab1)** do ControlAI que apresenta a distribuição do consumo do orçamento mensal por categoria em formato de flor. Cada pétala representa uma categoria de gasto e cresce proporcionalmente ao percentual do limite (orçamento) já consumido no mês corrente. Categorias que estouraram o limite são destacadas visualmente.

O objetivo é dar ao casal usuário uma **visão imediata e emocionalmente legível** do quanto cada categoria já consumiu do orçamento, substituindo a leitura linha-a-linha de uma tabela ou planilha por um padrão visual reconhecível em segundos. O widget vive na tela inicial justamente para ser o primeiro toque diário do usuário sobre suas finanças do mês.

Problema que resolve: hoje o usuário precisa abrir telas específicas de orçamento, somar mentalmente vários cartões e cruzar categorias para entender se está dentro ou fora do planejado. O gráfico unifica essa leitura em uma única visualização agregada.

## Objetivos

- **Reduzir o tempo até a leitura do estado do orçamento** — usuário entende a saúde do mês em menos de 5 segundos ao abrir o app.
- **Tornar visíveis as categorias com estouro** — toda categoria acima de 100% do limite deve ser imediatamente perceptível sem leitura de números.
- **Aumentar o engajamento com a Tab1** — o gráfico é o componente de destaque visual da tela inicial.
- **Encurtar o caminho para a ação corretiva** — do gráfico ao detalhamento de gastos da categoria em no máximo um toque.

Métricas a acompanhar:

- % de sessões na Tab1 que incluem interação com o gráfico (toque em pétala ou em "Ver gastos detalhados").
- Tempo médio entre abertura do app e primeira interação com o gráfico.
- Taxa de uso semanal do widget (DAU/WAU do componente).

## Histórias de Usuário

- Como **usuário do casal**, quero ver de relance quanto cada categoria já consumiu do orçamento do mês, para identificar imediatamente onde estou estourando, sem precisar abrir telas de detalhamento.
- Como **usuário do casal**, quero tocar em uma pétala para ver os gastos daquela categoria, para entender a origem do consumo e decidir se preciso ajustar o comportamento no restante do mês.
- Como **usuário do casal**, quero um botão "Ver gastos detalhados" abaixo do gráfico para acessar a lista completa de gastos do mês, para revisar movimentações sem precisar tocar categoria por categoria.
- Como **usuário do casal**, quando uma categoria estoura o limite, quero que ela seja visualmente destacada (cor de alerta), para que eu identifique o problema sem precisar ler todos os percentuais.
- Como **usuário do casal** que ainda não lançou gastos no mês, quero ver um estado vazio claro em vez de um gráfico vazio confuso, para entender que o mês ainda não tem movimentação.

## Funcionalidades Principais

### 1. Renderização do gráfico de pétalas

- **O que faz:** desenha uma flor com uma pétala por categoria de gasto que tenha **orçamento definido E gasto > 0** no mês corrente.
- **Por que importa:** é o coração visual do widget e o que entrega o "entendimento em segundos".
- **Como funciona em alto nível:** cada pétala tem cor própria (alinhada à legenda) e tamanho proporcional ao % do limite consumido pela categoria.

**Requisitos funcionais:**

1.1. O gráfico deve renderizar uma pétala por categoria de gasto que possua orçamento mensal configurado E gasto > 0 no mês corrente.
1.2. Categorias sem orçamento mensal configurado **não devem aparecer** no gráfico, mesmo que tenham gastos.
1.3. Categorias com orçamento configurado mas sem nenhum gasto no mês **não devem aparecer** no gráfico.
1.4. Cada pétala deve exibir o percentual numérico de consumo do limite (ex.: 87%, 112%).
1.5. O título "DISTRIBUIÇÃO" deve aparecer no topo do widget.
1.6. Um indicador "Limite = 100%" deve estar visível no topo do gráfico, marcando a referência do círculo de 100%.
1.7. Uma legenda com o nome e a cor de cada categoria exibida deve estar visível abaixo do gráfico.

### 2. Cálculo de percentuais e período

- **O que faz:** define o número exibido em cada pétala e o seu tamanho relativo.
- **Por que importa:** o significado do gráfico depende inteiramente desse cálculo estar correto.

**Requisitos funcionais:**

2.1. O percentual exibido em cada pétala deve ser calculado como `(gasto da categoria no mês ÷ limite da categoria no mês) × 100`, arredondado para inteiro.
2.2. O período considerado por padrão deve ser o **mês corrente** (do dia 1 até o dia atual, inclusive).
2.3. O cálculo deve agregar gastos de **todos os cartões vinculados ao casal**, conforme o comportamento atual do app (sem filtro de cartão selecionado).
2.4. O cálculo deve usar a mesma fonte de gastos já considerada nas demais visões de orçamento do app, garantindo consistência entre o gráfico e o restante do app.

### 3. Destaque visual para estouro de limite

- **O que faz:** sinaliza visualmente quando uma categoria ultrapassou o limite.
- **Por que importa:** é o principal gatilho de ação corretiva do usuário.

**Requisitos funcionais:**

3.1. Categorias com percentual maior que 100% devem ter sua pétala **renderizada além do círculo de referência de 100%**, ocupando mais espaço que as demais.
3.2. Categorias com percentual maior que 100% devem usar uma **cor/estilo de alerta** distinto das demais pétalas, identificável sem leitura do número.
3.3. O número exibido deve refletir o percentual real (ex.: "112%"), mesmo acima de 100%, sem ser truncado.
3.4. O destaque visual deve estar acessível também a usuários com daltonismo (não pode depender exclusivamente da cor — formato/tamanho da pétala já provê redundância).

### 4. Interação por toque na pétala

- **O que faz:** permite navegar do "todo" para os gastos específicos da categoria tocada.
- **Por que importa:** encurta o caminho da leitura para a ação.

**Requisitos funcionais:**

4.1. Ao tocar em uma pétala, o usuário deve ser levado ao detalhamento daquela categoria (lista de gastos do mês corrente filtrada pela categoria tocada).
4.2. A área de toque de cada pétala deve respeitar o tamanho mínimo de área tocável recomendado para mobile.
4.3. Tocar na legenda da categoria deve ter o mesmo efeito que tocar na pétala correspondente.

### 5. Botão "Ver gastos detalhados"

- **O que faz:** dá acesso à lista completa de gastos do período, sem pré-filtro de categoria.
- **Por que importa:** atende ao usuário que quer auditar todo o mês, não apenas uma categoria.

**Requisitos funcionais:**

5.1. Um botão "Ver gastos detalhados" deve estar visível na parte inferior do widget.
5.2. Ao acionar o botão, o usuário deve ser levado à **lista completa de gastos do período (mês corrente)**, agrupada por categoria.
5.3. O botão deve estar sempre visível, inclusive no estado vazio (item 6), permitindo o usuário acessar a lista mesmo sem dados no gráfico.

### 6. Estado vazio (sem gastos no período)

- **O que faz:** comunica que não há dados ainda para o mês.
- **Por que importa:** evita confundir o usuário com um gráfico vazio sem explicação.

**Requisitos funcionais:**

6.1. Quando não houver nenhum gasto registrado no mês corrente em categorias com orçamento, o widget deve exibir um **estado vazio textual ou ilustrado** no lugar do gráfico.
6.2. O estado vazio deve manter visíveis o título "DISTRIBUIÇÃO" e o botão "Ver gastos detalhados".
6.3. A mensagem do estado vazio deve indicar claramente que ainda não há gastos no mês.

## Experiência do Usuário

**Jornada principal:**

1. Usuário abre o app e cai na Tab1.
2. Percorre visualmente o gráfico de pétalas (1-5 segundos) e identifica se há categorias estouradas pelo tamanho/cor das pétalas.
3. Se identificar uma categoria preocupante, toca na pétala correspondente e chega ao detalhamento da categoria.
4. Alternativamente, se quiser revisar o mês inteiro, toca em "Ver gastos detalhados" e chega à lista completa.

**Considerações de UI/UX:**

- O widget é o **componente de destaque visual da Tab1** e deve ter prioridade hierárquica na composição da tela.
- As cores das pétalas devem ser distintas o suficiente para serem reconhecíveis na legenda e replicáveis em telas pequenas.
- Pétalas com estouro precisam de redundância visual (cor + tamanho) para acessibilidade.
- O número de cada pétala deve permanecer legível mesmo em pétalas pequenas (ex.: 24%) — fonte com peso e contraste apropriados sobre o fundo escuro.
- Tap targets devem respeitar o mínimo recomendado para mobile, mesmo em pétalas pequenas.

**Requisitos de acessibilidade:**

- Cada pétala deve ter rótulo acessível para leitores de tela no formato `"{Categoria}: {percentual}% do limite"`.
- Categorias estouradas devem ter rótulo acessível adicional indicando o estouro (ex.: `"acima do limite"`).
- O botão "Ver gastos detalhados" deve ter rótulo acessível explícito.
- O destaque de estouro não pode depender exclusivamente de cor.

## Restrições Técnicas de Alto Nível

- **Dependência de orçamento mensal configurado:** o gráfico só funciona para categorias com orçamento definido. A funcionalidade de configuração de orçamento mensal é pré-requisito.
- **Dependência da fonte agregada de gastos do casal:** o cálculo precisa consumir a mesma agregação de gastos já usada nas demais visões do app, para evitar divergência de números.
- **Performance em mobile:** a renderização do gráfico deve ser fluida na Tab1, sem causar perceptível atraso na abertura da tela inicial.
- **Consistência com o restante do app:** os percentuais e categorias mostrados no gráfico devem coincidir com o que é exibido na tela de orçamento mensal para o mesmo período.

## Fora de Escopo

- **Edição de orçamento direto do gráfico** — alterar o limite de uma categoria continua sendo feito na tela de orçamento mensal.
- **Comparação histórica** — não há comparação com meses anteriores, médias ou tendências dentro do gráfico.
- **Seletor de período** — não há seleção de mês anterior, intervalo customizado ou período do orçamento alternativo. O gráfico mostra sempre o mês corrente.
- **Filtro por cartão** — não há opção de filtrar o gráfico por cartão individual; sempre agrega todos os cartões do casal.
- **Visualizações alternativas** — não há opção de alternar para outro tipo de gráfico (barras, pizza, etc.).
- **Exportação ou compartilhamento** — não há exportação de imagem do gráfico.
- **Notificações ou alertas push** — alertas automáticos sobre estouro de categoria estão fora do escopo desta funcionalidade.
- **Categorias sem orçamento** — não são representadas no gráfico nem listadas separadamente. Definição de orçamento permanece em fluxo próprio.
- **Sub-categorias** — o gráfico opera apenas no nível de categoria principal.
