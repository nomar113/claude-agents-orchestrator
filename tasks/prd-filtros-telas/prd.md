# PRD - Filtros para Telas do ControlAI

## Visao Geral

O ControlAI atualmente exibe listas de compras, notificacoes e notas fiscais sem opcoes de filtragem. O usuario precisa rolar manualmente para encontrar transacoes especificas e nao consegue visualizar dados de meses anteriores ou filtrar por categoria de gasto.

Esta funcionalidade adiciona filtros de mes e categoria nas telas principais (Tab1 - Home e Tab2 - Notas Fiscais), permitindo ao usuario analisar seus gastos de forma segmentada e localizar transacoes rapidamente. Na Tab2, o usuario tambem podera selecionar um range de datas customizado.

## Objetivos

- Permitir ao usuario visualizar dados de qualquer mes (nao apenas o corrente) nas telas Tab1 e Tab2.
- Reduzir o tempo para localizar uma transacao especifica atraves de filtros por categoria.
- Oferecer analise por periodo customizado (range de datas) na tela de Notas Fiscais.
- Manter consistencia visual e de interacao entre as telas que possuem filtros.
- Cada tela deve lembrar seu ultimo filtro selecionado durante a sessao do app.

## Historias de Usuario

- Como usuario, eu quero selecionar um mes especifico na tela Home para que eu veja os cards de resumo, orcamento e lista de compras daquele mes.
- Como usuario, eu quero filtrar as ultimas compras por categoria para que eu analise rapidamente quanto gastei em cada tipo de despesa.
- Como usuario, eu quero selecionar um mes na tela de Notas Fiscais para que eu veja apenas as notas daquele periodo.
- Como usuario, eu quero definir um range de datas customizado na tela de Notas Fiscais para que eu analise gastos entre duas datas especificas (ex: 15/jan a 15/fev).
- Como usuario, eu quero filtrar notas fiscais por categoria para que eu encontre rapidamente compras de um tipo especifico (ex: Supermercado).
- Como usuario, eu quero que ao voltar para uma tela, os filtros que selecionei anteriormente ainda estejam ativos na mesma sessao.
- Como usuario, eu quero limpar todos os filtros de uma vez para voltar a visualizacao padrao.

## Funcionalidades Principais

### F1 - Seletor de Mes (Tab1 e Tab2)

Componente de navegacao por mes posicionado no topo da tela, permitindo navegar mes a mes com setas (anterior/proximo) e exibindo o mes/ano selecionado. Inicia no mes corrente.

**Requisitos Funcionais:**
- RF-1.1: O seletor de mes deve exibir o nome do mes e ano (ex: "Maio 2026").
- RF-1.2: O usuario deve poder navegar para o mes anterior e proximo atraves de botoes de seta.
- RF-1.3: Na Tab1, alterar o mes deve atualizar: cards de resumo (CardStack), resumo de orcamento (BudgetSummaryCard), lista de ultimas compras e projecao de parcelas.
- RF-1.4: Na Tab2, alterar o mes deve atualizar: total de notas fiscais e lista de notas.
- RF-1.5: O mes padrao ao abrir a tela pela primeira vez deve ser o mes corrente.
- RF-1.6: O componente deve ser reutilizavel entre Tab1 e Tab2.

### F2 - Filtro por Categoria (Tab1 e Tab2)

Barra de chips horizontais com scroll, posicionada abaixo do seletor de mes, listando as categorias disponiveis nos dados carregados. Permite selecao unica ou "Todas".

**Requisitos Funcionais:**
- RF-2.1: A barra deve exibir um chip "Todas" (selecionado por padrao) seguido das categorias presentes nos dados carregados.
- RF-2.2: Ao selecionar uma categoria, a lista deve ser filtrada para mostrar apenas itens daquela categoria.
- RF-2.3: Ao selecionar "Todas", o filtro de categoria deve ser removido.
- RF-2.4: A barra deve ter scroll horizontal quando houver mais categorias do que cabem na tela.
- RF-2.5: A filtragem por categoria deve ser aplicada localmente no frontend sobre os dados ja carregados.
- RF-2.6: O total exibido no card de resumo deve refletir os itens filtrados.
- RF-2.7: Quando nenhum item corresponder ao filtro, exibir estado vazio apropriado.

### F3 - Range de Datas (Tab2)

Na tela de Notas Fiscais, alem do seletor de mes, o usuario pode alternar para um modo de selecao por range de datas, definindo data inicio e data fim.

**Requisitos Funcionais:**
- RF-3.1: O usuario deve poder alternar entre modo "Mes" e modo "Periodo" na Tab2.
- RF-3.2: No modo "Periodo", dois campos de data devem ser exibidos: data inicio e data fim.
- RF-3.3: A data inicio nao pode ser posterior a data fim.
- RF-3.4: Ao definir o range, a lista de notas e o total devem ser atualizados para refletir apenas o periodo selecionado.
- RF-3.5: O modo padrao deve ser "Mes".

### F4 - Persistencia de Filtros por Tela

Cada tela mantem o estado dos seus filtros durante a sessao do app. Ao navegar para outra tela e voltar, os filtros selecionados anteriormente sao restaurados.

**Requisitos Funcionais:**
- RF-4.1: Ao sair de uma tela e retornar na mesma sessao, os filtros devem estar no ultimo estado selecionado.
- RF-4.2: Ao fechar e reabrir o app, os filtros devem resetar para o padrao (mes corrente, categoria "Todas").
- RF-4.3: A persistencia deve funcionar independentemente entre telas (filtro da Tab1 nao afeta Tab2).

### F5 - Acao de Limpar Filtros

Botao ou acao que reseta todos os filtros da tela para o estado padrao.

**Requisitos Funcionais:**
- RF-5.1: Deve existir uma acao visivel para limpar todos os filtros quando algum filtro estiver ativo.
- RF-5.2: Limpar filtros deve restaurar: mes para o corrente, categoria para "Todas", modo para "Mes" (Tab2).

## Experiencia do Usuario

### Layout dos Filtros

O seletor de mes fica posicionado logo abaixo do header da tela, seguindo o mesmo padrao visual do BudgetPage (setas laterais + label central). A barra de chips de categoria fica imediatamente abaixo do seletor de mes, com scroll horizontal.

### Fluxo de Interacao

1. Usuario abre Tab1 → ve dados do mes corrente, chip "Todas" selecionado.
2. Toca na seta esquerda do seletor → dados atualizam para o mes anterior.
3. Toca no chip "Supermercado" → lista filtra para mostrar apenas compras dessa categoria, total atualiza.
4. Navega para Tab2 → Tab2 mostra seus proprios filtros independentes.
5. Volta para Tab1 → filtros da Tab1 (mes anterior + Supermercado) ainda estao ativos.

### Consideracoes de UI/UX

- Chips devem ter feedback visual claro de selecao (cor de destaque).
- Transicao suave ao filtrar/atualizar dados (sem flash de tela).
- Loading state ao trocar de mes (dados vem do backend).
- Estado vazio amigavel quando filtros nao retornam resultados.
- O seletor de mes e a barra de categorias devem ser sticky (fixos no topo ao rolar).

### Acessibilidade

- Chips de categoria devem ter role e aria-labels apropriados.
- Seletor de mes deve ser navegavel por teclado.
- Estados de selecao devem ter contraste suficiente (WCAG AA).

## Restricoes Tecnicas de Alto Nivel

- Os endpoints `GET /payments/notifications` e `GET /purchases/invoices` atualmente nao suportam filtragem por mes ou categoria — sera necessario adicionar query params no backend.
- O endpoint `GET /payment-methods/summary` ja aceita parametro `month` e pode ser reutilizado.
- O filtro por categoria deve ser aplicado no frontend (dados ja carregados) para evitar round-trips desnecessarios ao backend.
- O range de datas (Tab2) exige suporte a `startDate`/`endDate` no backend.
- A persistencia de filtros deve usar estado em memoria (React state/context), nao localStorage.

## Fora de Escopo

- Filtro por titular (Ramon/Aline) — iteracao futura.
- Filtro por cartao/meio de pagamento — iteracao futura.
- Filtro por faixa de valor (min/max) — iteracao futura.
- Busca por texto (merchantName/description) — iteracao futura.
- Filtros na BudgetPage (ja possui seletor de mes funcional).
- Filtros na PaymentMethodsPage (ja possui agrupamento por titular).
- Persistencia de filtros entre sessoes (localStorage/AsyncStorage).
