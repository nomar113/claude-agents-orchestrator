# PRD: Dashboard Mensal com Dados Reais

## Visao Geral

O dashboard atual do ControlAi exibe dados mockados (receita fixa de R$5.200, saldo de R$2.847,52, orcamento de 45%) e cartoes fictícios (Nubank Platinum, Inter, C6 Bank) que nao correspondem a realidade financeira do casal Ramon e Aline. Para que o app substitua a planilha Google Sheets, o dashboard precisa apresentar dados reais e consolidados do mes, permitindo uma visao rapida da saude financeira do casal.

Na planilha, cada aba mensal permite ver o total gasto, e a aba de planejamento (PL) mostra receitas vs gastos, totais por categoria e por cartao. O dashboard deve consolidar essas informacoes em uma unica tela, com navegacao entre meses.

## Objetivos

- Substituir 100% dos dados mockados do dashboard por dados reais do banco de dados
- Exibir resumo financeiro mensal completo em menos de 3 segundos de carregamento
- Permitir navegacao entre meses para comparacao de periodos
- Apresentar indicadores visuais de saude financeira (% do orcamento utilizado)
- Mostrar os cartoes reais do casal com totais de gastos por cartao no mes

## Historias de Usuario

- Como Ramon, eu quero ver o total de gastos do mes atual ao abrir o app para que eu saiba rapidamente quanto ja gastamos
- Como Ramon, eu quero ver quanto cada cartao acumula no mes para que eu saiba o valor de cada fatura
- Como Aline, eu quero ver meus gastos separados dos do Ramon para que eu saiba minha parcela nos gastos do casal
- Como Ramon, eu quero ver o percentual do orcamento ja utilizado para que eu saiba se estamos dentro do planejado
- Como Ramon, eu quero navegar entre meses anteriores para que eu possa comparar gastos entre periodos
- Como Ramon, eu quero ver o saldo do mes (receitas - gastos) para que eu saiba se estamos no positivo ou negativo
- Como Aline, eu quero ver os gastos agrupados por categoria para que eu identifique onde estamos gastando mais

## Funcionalidades Principais

### RF01 - Resumo Financeiro do Mes

O dashboard deve exibir um card de resumo contendo:
- Total de gastos do mes
- Total de receitas do mes
- Saldo (receitas - gastos)
- Percentual do orcamento utilizado (baseado no planejamento cadastrado)
- Indicador visual (cor verde/amarelo/vermelho) baseado no % do orcamento

### RF02 - Cartoes Reais com Totais

Substituir os cards mockados pelos cartoes reais cadastrados no sistema. Cada card deve mostrar:
- Nome do cartao e bandeira
- Ultimos 4 digitos
- Titular (Ramon ou Aline)
- Total de gastos no mes para aquele cartao
- Incluir Pix e Dinheiro como meios de pagamento com seus respectivos totais

### RF03 - Gastos por Categoria

Exibir uma visualizacao dos gastos agrupados por categoria:
- Nome da categoria
- Valor total gasto na categoria no mes
- Percentual que a categoria representa do total
- Ordenacao por valor (maior para menor)

### RF04 - Gastos por Pessoa

Exibir totais separados por titular:
- Total de gastos do Ramon
- Total de gastos da Aline
- Total de gastos compartilhados (se aplicavel)

### RF05 - Navegacao entre Meses

- Permitir navegar para meses anteriores e posteriores
- Exibir o mes/ano selecionado de forma clara
- Atualizar todos os dados do dashboard ao trocar de mes
- Manter o mes atual como padrao ao abrir o app

### RF06 - Lista de Compras Recentes

Manter a lista de compras recentes ja existente, mas filtrada pelo mes selecionado:
- Nome do estabelecimento com icone da categoria
- Data e hora
- Valor
- Cartao utilizado
- Quantidade de itens (quando disponivel via nota fiscal)

### RF07 - Indicador de Tendencia

Exibir uma comparacao simples com o mes anterior:
- Total do mes atual vs total do mes anterior
- Indicador de aumento ou reducao (seta + percentual)

## Experiencia do Usuario

O dashboard e a primeira tela que o usuario ve ao abrir o app. Deve comunicar a saude financeira do mes em menos de 5 segundos de leitura visual.

**Fluxo principal:**
1. Usuario abre o app → ve o resumo do mes atual com total, saldo e % orcamento
2. Rola para baixo → ve os cartoes reais com totais e gastos por categoria
3. Swipe lateral no topo ou toque em setas → navega entre meses
4. Toque em uma categoria → (futuro) filtra a lista de gastos por categoria

**Consideracoes de UX:**
- Cards de resumo devem usar cores para indicar status: verde (< 80% orcamento), amarelo (80-100%), vermelho (> 100%)
- Os cartoes devem manter a estetica de card stack ja existente, substituindo os dados mockados
- Skeleton loading ja existente deve ser mantido durante carregamento
- O dashboard deve funcionar offline com dados em cache quando possivel

**Acessibilidade:**
- Valores monetarios devem ser legiveis em tamanho adequado
- Cores de status devem ter alternativa textual (nao depender apenas de cor)
- Labels descritivos para leitores de tela

## Restricoes Tecnicas de Alto Nivel

- Depende do PRD de Modelo de Dados estar implementado (categorias, cartoes, titulares)
- Depende do PRD de Gestao de Receitas para exibir saldo e % orcamento
- Depende do PRD de Planejamento/Orcamento para indicadores de saude financeira
- O backend deve fornecer endpoints de agregacao para evitar calculos pesados no frontend
- O dashboard deve carregar em menos de 3 segundos em conexao 4G
- Dados sensiveis (valores financeiros) nao devem ser cacheados em texto plano

## Fora de Escopo

- Graficos elaborados (charts de pizza, barras, linhas) — serao considerados em versao futura
- Notificacoes push sobre gastos
- Metas de economia ou investimento
- Comparativo entre multiplos meses simultaneamente
- Exportacao de dados do dashboard
- Previsao de gastos futuros baseada em historico
- Tela de detalhes ao clicar em uma categoria (sera feature futura)
