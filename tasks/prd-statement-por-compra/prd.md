# PRD: Statement por Compra — Fonte Única de Verdade para Gasto do Mês

## Visão Geral

O ControlAí hoje trata "quanto uma compra conta em cada mês" de duas formas diferentes: compras parceladas geram registros individuais de parcela (`installment`), enquanto compras à vista, Pix ou dinheiro não geram nenhum registro equivalente — seu valor é lido diretamente do valor bruto da compra (`amount`) sempre que alguma tela precisa somar "gasto do mês". Essa duplicidade de modelo obriga cada nova tela, endpoint ou relatório a lembrar de tratar os dois casos separadamente (uma lógica condicional do tipo "se for parcelada, use a parcela; senão, use o total"), e isso já falhou de forma repetida: o card "Total Filtrado" da tela Início e a lista de detalhe por categoria mostraram o valor total de uma compra parcelada em vez da parcela do mês, mesmo depois de essa mesma regra já ter sido corrigida em outras telas do mesmo app.

Esta funcionalidade elimina a causa estrutural do problema: **toda compra, de qualquer meio de pagamento, passa a gerar um ou mais "statements"** — o mesmo conceito de parcela já usado hoje, generalizado para cobrir também compras à vista, Pix e dinheiro (que passam a ter exatamente 1 statement). A partir daí, toda tela, relatório ou endpoint que precisa saber "quanto foi gasto neste mês" lê exclusivamente da tabela de statements, nunca do valor bruto da compra original. Isso beneficia diretamente quem usa o ControlAí para substituir uma planilha manual de controle de gastos do casal, ao garantir que o valor mostrado em qualquer tela do app — hoje ou em qualquer tela futura — sempre reflita o comprometimento real daquele mês específico, sem depender de cada desenvolvedor lembrar de replicar a mesma regra condicional em cada novo lugar.

## Objetivos

- 100% das telas e endpoints que exibem ou somam "gasto do mês" refletem o valor do statement (parcela) daquele mês, nunca o valor total/bruto da compra original — mensurável por auditoria de código e por teste de contrato (ver Funcionalidade 4).
- Zero divergência entre o valor mostrado em uma listagem item a item e o valor mostrado em qualquer card agregado/total na mesma tela ou tela relacionada.
- Todo o histórico de compras já cadastradas (à vista, Pix, dinheiro e parceladas) é migrado para o novo modelo, sem perda de dado e sem necessidade de tratamento especial para dados "antigos" versus "novos" em nenhuma tela.
- Nenhuma superfície do produto (tela ativa ou código ainda não conectado a uma tela) permanece lendo o valor bruto da compra para fins de "gasto do mês" após a conclusão desta funcionalidade.

## Histórias de Usuário

- Como usuário que controla os gastos do casal, quero que uma compra parcelada, à vista, no Pix ou em dinheiro sempre apareça, em qualquer resumo mensal do app, pelo valor que efetivamente compromete aquele mês — para que eu nunca veja um total inflado ou subestimado em nenhuma tela.
- Como usuário, ao abrir a tela Início e ver o total do mês, quero que esse total bata exatamente com a soma dos itens individuais listados logo abaixo, para confiar no número sem precisar conferir item a item.
- Como usuário, quero que uma compra à vista feita no cartão de crédito perto do fechamento da fatura seja contabilizada no mês da fatura correta (não necessariamente o mês calendário da compra), da mesma forma que já acontece com a primeira parcela de uma compra parcelada.
- Como usuário, quero que uma compra em Pix ou dinheiro seja sempre contabilizada no mês calendário em que foi feita, já que não existe fatura de cartão envolvida.
- Como usuário, quero que compras que já registrei antes desta mudança continuem aparecendo corretamente em todos os meses, sem precisar recadastrar nada.

## Funcionalidades Principais

### 1. Statement como unidade universal de "gasto do mês"
Toda compra registrada no ControlAí — independentemente do meio de pagamento ou de ser parcelada — passa a ter pelo menos um statement associado. Uma compra parcelada em N vezes gera N statements (como já acontece hoje com as parcelas); uma compra à vista, Pix ou em dinheiro gera exatamente 1 statement.

**Requisitos funcionais:**
1.1. Toda compra registrada (por notificação de SMS/banco ou cadastro manual) gera pelo menos um statement no momento do registro, sem exigir ação adicional do usuário.
1.2. Um statement tem valor, data de referência (mês/planejamento a que pertence) e status próprios, sejam quais forem o meio de pagamento e o número de parcelas da compra de origem.
1.3. A soma dos valores dos statements de uma compra é sempre igual ao valor total da compra.

### 2. Regras de associação do statement ao planejamento/mês
A definição de "a qual mês/planejamento um statement pertence" segue uma regra única, consistente para todos os meios de pagamento.

**Requisitos funcionais:**
2.1. Para compras (parceladas ou à vista) feitas em cartão de crédito com dia de fechamento cadastrado, o statement segue o ciclo de fatura do cartão: a compra à vista gera 1 statement no ciclo aberto na data da compra, na mesma lógica hoje aplicada à primeira parcela de uma compra parcelada.
2.2. Para compras em Pix ou dinheiro (sem cartão associado), o statement é sempre associado ao mês calendário da data da compra.
2.3. Para cartão de crédito sem dia de fechamento cadastrado, aplica-se o mesmo comportamento de fallback já existente para compras parceladas (mês calendário da compra).
2.4. Quando os statements de uma compra recém-registrada apontam para planejamentos mensais que ainda não existem, esses planejamentos são criados automaticamente, reaproveitando o comportamento já existente para compras parceladas.

### 3. Fonte única de leitura para "gasto do mês"
Todo lugar do produto que hoje soma ou exibe "quanto foi gasto neste mês" — orçamento por categoria, resumo por meio de pagamento, listagem principal de compras, gráficos de distribuição, card de total filtrado, e qualquer tela futura equivalente — passa a ler exclusivamente os statements do mês em questão, nunca o valor bruto da compra original.

**Requisitos funcionais:**
3.1. Nenhuma tela, endpoint ou relatório do produto calcula "gasto do mês" somando o valor bruto de uma compra; todos usam o(s) statement(s) daquele mês como única fonte.
3.2. Onde hoje existe lógica condicional para decidir entre "valor da parcela" e "valor total" dependendo do meio de pagamento ou do número de parcelas, essa lógica é eliminada — não deve mais haver distinção a fazer, porque toda compra tem statement.
3.3. Componentes e endpoints hoje não conectados a nenhuma tela ativa do produto, mas que ainda leem o valor bruto da compra para fins de resumo mensal, são removidos do produto (não são migrados para o novo modelo).

### 4. Garantia de não regressão
O produto passa a ter um mecanismo de verificação que impede que uma tela, endpoint ou relatório futuro reintroduza a leitura do valor bruto da compra para fins de "gasto do mês".

**Requisitos funcionais:**
4.1. Existe um mecanismo de verificação automatizada, executado como parte do processo de desenvolvimento, capaz de detectar quando um novo ponto do produto soma ou exibe "gasto do mês" usando o valor bruto da compra em vez do statement.
4.2. Esse mecanismo cobre, no mínimo, todo endpoint e toda tela que hoje exibem valores agregados ou individuais de "gasto do mês" (listados no requisito 3.1), e é aplicado a qualquer novo ponto equivalente introduzido no futuro.

### 5. Migração de dados existentes
Todas as compras já cadastradas no sistema — parceladas ou não, de qualquer meio de pagamento — são reprocessadas para gerar seus statements segundo as regras desta funcionalidade.

**Requisitos funcionais:**
5.1. Toda compra existente no sistema, incluindo as já pagas/em meses passados, recebe seu(s) statement(s) segundo as regras de associação definidas na Funcionalidade 2.
5.2. A migração não altera o valor total nem o meio de pagamento de nenhuma compra original — apenas cria os statements e sua associação a planejamento/mês.
5.3. Após a migração, os totais de "gasto do mês" de todos os planejamentos mensais existentes (passados e futuros) refletem exclusivamente os statements gerados, sem depender mais do valor bruto da compra em nenhuma leitura.

## Experiência do Usuário

- **Personas**: usuário principal é quem administra os gastos do casal usando o ControlAí como substituto de planilha manual — já familiarizado com o app e com a lógica de fechamento de fatura usada na tela de orçamento e na listagem de compras.
- **Fluxo principal**: usuário registra ou recebe (via notificação do banco) uma compra de qualquer tipo (à vista, Pix, dinheiro ou parcelada) → o(s) statement(s) correspondente(s) são gerados e associados ao(s) planejamento(s) corretos → em qualquer tela do app onde o usuário vê "gasto do mês" (Início, orçamento por categoria, gráfico de distribuição, detalhe da compra), o valor exibido é sempre consistente entre si, refletindo exatamente o statement daquele mês.
- **Consistência**: o padrão visual de "item individual com valor e status próprios", já usado hoje na tela de detalhe de compra e na listagem principal para parcelas, se estende de forma transparente para compras à vista/Pix/dinheiro — que hoje já aparecem como item único e continuam aparecendo da mesma forma, sem mudança visual perceptível para o usuário nesses casos.
- **Acessibilidade**: nenhum requisito novo além dos já vigentes nas telas afetadas (informação de status/posição não deve depender apenas de cor).

## Restrições Técnicas de Alto Nível

- Não há integração externa nova; a origem dos dados de compra continua sendo os canais já existentes (notificação de SMS/banco e cadastro manual).
- A migração de dados existentes deve ser executada sem perda de dado: nenhuma compra pode ser removida ou ter seu valor total alterado durante o reprocessamento.
- A remoção de componentes/endpoints órfãos (Funcionalidade 3.3) deve ser verificada previamente quanto à ausência de consumidores ativos (nenhuma tela do produto ou integração externa conhecida os utiliza) antes da remoção.
- O campo de dia de fechamento (`closing_day`) do cadastro de cartão continua sendo informado manualmente pelo usuário; não há integração automática com o banco para descobri-lo.
- Nenhuma informação financeira sensível nova é introduzida além do que já é tratado hoje (valor, cartão, categoria).

## Fora de Escopo

- Edição manual do valor ou data de um statement individual já gerado.
- Parcelamento via PIX ou qualquer meio "carnê"/PIX parcelado.
- Integração automática com o banco para descobrir o dia de fechamento do cartão.
- Alterações no fluxo de cancelamento de compra/statement já existente.
- Redesenho visual das telas — a experiência reaproveita os padrões já definidos no design existente do produto.
- Decisão sobre reintroduzir, no futuro, funcionalidades hoje órfãs que dependiam dos endpoints removidos na Funcionalidade 3.3 (ex.: uma futura tela de "fatura por cartão"); se isso vier a ser desejado, será tratado como uma nova funcionalidade que já nasce lendo statements.
