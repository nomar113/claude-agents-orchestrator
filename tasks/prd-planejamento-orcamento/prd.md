# PRD: Planejamento e Orcamento Mensal

## Visao Geral

O ControlAI e um aplicativo de financas pessoais usado por Ramon e Aline para controlar gastos do casal. Atualmente, o planejamento orcamentario mensal e feito em abas "PL" de uma planilha do Google Sheets (ex: PL JAN/2026, PL FEV/2026), onde o casal define expectativas de gastos por categoria, acompanha valores reais e visualiza diferencas.

Esta funcionalidade reproduz no app a capacidade de planejamento e orcamento mensal da planilha, permitindo que o casal defina metas de gastos por categoria, acompanhe receitas, e visualize o progresso do orcamento em tempo real -- eliminando a necessidade de manter a planilha em paralelo.

O problema central e que a planilha exige atualizacao manual, nao se integra com os dados de despesas ja existentes no app, e nao oferece uma experiencia mobile adequada para consultas rapidas do dia a dia.

## Objetivos

- **Paridade com a planilha**: Cobrir 100% das funcionalidades das abas "PL" do Google Sheets, incluindo planejamento de gastos, investimentos, receitas e totais por meio de pagamento.
- **Calculo automatico**: O valor "Real" de cada categoria deve ser calculado automaticamente a partir das despesas registradas no app para o mes correspondente, eliminando entrada manual duplicada.
- **Visibilidade rapida**: O casal deve conseguir abrir o app e em menos de 3 segundos entender quanto ja gastou vs. quanto planejou para o mes atual.
- **Historico mensal**: Manter o historico de planejamentos de meses anteriores para comparacao e evolucao.
- **Reducao de atrito**: Tornar desnecessario o uso da planilha para planejamento orcamentario, consolidando tudo no app.

## Historias de Usuario

- Como **Ramon ou Aline**, eu quero criar um planejamento mensal definindo valores esperados por categoria de gasto, para que possamos ter um orcamento claro para o mes.
- Como **Ramon ou Aline**, eu quero ver automaticamente quanto ja foi gasto em cada categoria (valor real), para que eu nao precise somar manualmente.
- Como **Ramon ou Aline**, eu quero ver a diferenca entre o valor planejado e o real de cada categoria, para identificar rapidamente onde estamos gastando mais ou menos do que o previsto.
- Como **Ramon ou Aline**, eu quero ver o percentual total gasto em relacao ao total planejado (ex: 89.47%), para ter uma visao geral do mes.
- Como **Ramon ou Aline**, eu quero registrar as receitas do mes (salarios, adiantamentos, saldo do mes anterior), para saber quanto temos disponivel.
- Como **Ramon ou Aline**, eu quero definir expectativas de investimento e acompanhar o valor real investido, para manter a disciplina de poupanca.
- Como **Ramon ou Aline**, eu quero ver os totais por meio de pagamento (Smiles Infinite, Latam, Nubank Aline, Nubank Ramon, Pix, Dinheiro), para entender a distribuicao dos gastos entre cartoes e metodos.
- Como **Ramon ou Aline**, eu quero copiar o planejamento de um mes anterior como base para o proximo mes, para nao precisar preencher tudo do zero.
- Como **Ramon ou Aline**, eu quero navegar entre os planejamentos de meses diferentes, para comparar a evolucao.

## Funcionalidades Principais

### 1. Gerenciamento de Planejamento Mensal

Permite criar, visualizar, editar e excluir um planejamento para um mes/ano especifico. Cada mes possui um unico planejamento.

- O usuario seleciona mes/ano e cria o planejamento
- Pode duplicar o planejamento de um mes anterior como ponto de partida
- Navegacao entre meses via seletor (anterior/proximo ou lista)

### 2. Planejamento de Gastos por Categoria

Reproduz a secao "PLANEJAMENTO GASTOS" da planilha. Para cada categoria, apresenta tres colunas:

- **Expectativa**: valor orcado, definido manualmente pelo usuario
- **Real**: valor efetivamente gasto, calculado automaticamente a partir das despesas do mes que pertencem aquela categoria
- **Diferenca**: expectativa menos real, calculada automaticamente

Categorias previstas (configuravel): Comida, Gastos Gerais, Carro, Seguro Carro, PetLove, Light, Bodytech, Venvanse, Daforin, Assinaturas, Telefonia, Condominio, Gas, Banho Cachorros, Psicologa, Viagem, Transporte, IPTU, IPVA, Taxa Incendio.

Exibe no rodape: total planejado, total real, total da diferenca e percentual gasto/expectativa.

### 3. Planejamento de Investimentos

Reproduz a secao "PLANEJAMENTO INVESTIMENTOS" da planilha. Permite definir valores de expectativa e registrar valores reais para investimentos do mes, com calculo automatico da diferenca.

### 4. Registro de Receitas

Reproduz a secao "RECEITAS" da planilha. Permite registrar as fontes de renda do mes:

- Mes anterior (saldo transferido)
- Ramon Adiantamento
- Aline Salario Adiantamento
- Ramon Salario
- Aline Salario

Exibe o total de receitas do mes.

### 5. Totais por Meio de Pagamento

Reproduz a secao "TOTAIS POR MEIO DE PAGAMENTO" da planilha. Agrega automaticamente os gastos do mes por meio de pagamento:

- Smiles Infinite
- Latam
- Nubank Aline
- Nubank Ramon
- Pix
- Dinheiro

Os valores devem ser calculados a partir das despesas registradas no app.

### 6. Dashboard Resumo do Mes

Tela principal do planejamento que apresenta uma visao consolidada:

- Total de receitas
- Total planejado vs. total gasto (com percentual)
- Total investido vs. planejado
- Indicadores visuais de progresso (ex: barra de progresso, cores verde/amarelo/vermelho)

## Experiencia do Usuario

### Personas

- **Ramon**: Responsavel principal pelas financas. Usa o app diariamente para registrar e acompanhar gastos. Acessa pelo celular (Android).
- **Aline**: Acompanha os gastos e contribui com registros. Acessa pelo celular (iOS).

### Fluxos Principais

1. **Criar planejamento do mes**: Usuario acessa a area de planejamento, seleciona o mes, opcionalmente duplica de um mes anterior, e preenche os valores de expectativa por categoria, receitas e investimentos.
2. **Consultar progresso**: Usuario abre o app, acessa o planejamento do mes atual e visualiza o dashboard com totais, percentuais e indicadores visuais. Pode expandir para ver detalhes por categoria.
3. **Ajustar planejamento**: Usuario edita valores de expectativa ou receitas a qualquer momento do mes conforme necessidade.
4. **Comparar meses**: Usuario navega entre meses para comparar planejamentos e resultados.

### Consideracoes de UI/UX

- A tela de planejamento deve ser otimizada para mobile, com scroll vertical e secoes colapsaveis (Gastos, Investimentos, Receitas, Meios de Pagamento)
- Valores monetarios formatados em BRL (R$ 1.234,56)
- Cores para indicar status: verde (abaixo do orcamento), amarelo (proximo do limite, >80%), vermelho (acima do orcamento)
- A diferenca negativa (gastou mais que o planejado) deve ser visualmente destacada
- O percentual gasto/expectativa deve ter destaque visual no topo da tela
- Edicao inline dos valores de expectativa (tap para editar, sem navegar para outra tela)

## Restricoes Tecnicas de Alto Nivel

- **Backend existente**: O backend e Kotlin/Spring Boot. A funcionalidade deve se integrar com o modelo de dados existente de despesas (purchases/invoices) e meios de pagamento.
- **Frontend existente**: O frontend e React/Ionic/Capacitor. A funcionalidade deve seguir os padroes de componentes e navegacao ja estabelecidos no app.
- **Calculo do valor real**: O valor "Real" por categoria depende de as despesas registradas no app estarem corretamente categorizadas. A funcionalidade assume que existe (ou sera criado) um vinculo entre despesas e categorias de planejamento.
- **Meio de pagamento**: O calculo de totais por meio de pagamento depende de as despesas registradas possuirem informacao de meio de pagamento (ja existe no modelo `PurchasePayment`).
- **Dados sensiveis**: Valores financeiros sao dados pessoais sensiveis. O app ja possui autenticacao; esta funcionalidade deve respeitar o mesmo modelo de seguranca.
- **Performance**: O calculo de totais e agregacoes deve ser performatico mesmo com centenas de despesas por mes. Considerar pre-calculo ou cache quando necessario.

## Fora de Escopo

- **Alertas e notificacoes**: Notificacoes push quando uma categoria ultrapassar o orcamento ficam para uma versao futura.
- **Orcamento compartilhado com permissoes diferentes**: Ambos os usuarios tem acesso total ao mesmo planejamento. Nao ha controle de permissoes por usuario.
- **Integracao bancaria automatica (Open Finance)**: Os dados de despesas continuam sendo registrados manualmente ou via importacao de notas fiscais ja existente.
- **Relatorios e graficos avancados**: Graficos de evolucao ao longo de varios meses, comparativos anuais e exportacao para PDF/Excel ficam para versoes futuras.
- **Metas de economia**: Funcionalidade de definir metas de economia por categoria ou geral nao faz parte deste escopo.
- **Categorias dinamicas criadas pelo usuario**: As categorias de planejamento serao as previstas pela planilha. A possibilidade de criar categorias customizadas fica para versao futura.
- **Planejamento anual consolidado**: Esta funcionalidade cobre apenas o planejamento mensal individual. Visao anual consolidada fica para versao futura.
