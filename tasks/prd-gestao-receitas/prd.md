# PRD: Gestao de Receitas

## Visao Geral

O ControlAI e um aplicativo de financas pessoais que substitui uma planilha do Google Sheets utilizada pelo casal Ramon e Aline para controlar seus gastos mensais. Atualmente, o app registra apenas despesas (compras via fatura de cartao e notificacoes de pagamento), mas nao possui nenhum conceito de receita/renda.

Na planilha original, cada aba de planejamento mensal (PL) possui uma secao de RECEITAS com as seguintes linhas:

- **Mes anterior**: saldo remanescente do mes anterior (carry-over)
- **Ramon Adiantamento**: adiantamento salarial do Ramon
- **Aline Salario Adiantamento**: adiantamento salarial da Aline
- **Ramon Salario**: salario do Ramon
- **Aline Salario**: salario da Aline
- **TOTAL RECEITAS**: soma de todas as receitas do mes

Para referencia, em JAN/2026 o total de receitas foi R$21.662,45 contra R$16.446,12 em despesas.

Sem o registro de receitas, o app so consegue mostrar quanto foi gasto, mas nao consegue responder a pergunta fundamental: "estamos dentro do orcamento este mes?". Esta funcionalidade e o alicerce para calcular o saldo mensal (receitas - despesas), avaliar a saude financeira do casal e habilitar futuras funcionalidades de planejamento orcamentario.

## Objetivos

1. **Registrar todas as fontes de renda mensal** do casal, espelhando a secao RECEITAS da planilha original
2. **Calcular e exibir o saldo mensal** (total receitas - total despesas) para cada mes
3. **Transportar saldo do mes anterior** automaticamente, mantendo a continuidade financeira entre meses
4. **Permitir edicao rapida das receitas mensais**, ja que os salarios podem variar (bonus, horas extras, descontos)
5. **Fornecer visibilidade da saude financeira** — o usuario deve saber em segundos se o mes esta positivo ou negativo

Metricas de sucesso:
- 100% dos meses ativos possuem receitas cadastradas
- O saldo mensal e calculado corretamente e exibido no dashboard
- Tempo para registrar/editar receitas de um mes: menos de 30 segundos

## Historias de Usuario

### Usuarios primarios: Ramon e Aline

1. **Como Ramon**, eu quero registrar meu salario e adiantamento mensal para que o app calcule se estamos dentro do orcamento.

2. **Como Aline**, eu quero registrar meu salario e adiantamento mensal para que eu saiba quanto sobra apos os gastos.

3. **Como usuario**, eu quero ver o saldo do mes (receitas - despesas) para entender rapidamente se estamos no positivo ou negativo.

4. **Como usuario**, eu quero que o saldo do mes anterior seja transportado automaticamente para o mes seguinte, assim como funciona na planilha, para manter a continuidade do controle financeiro.

5. **Como usuario**, eu quero editar o valor de uma receita ja cadastrada (ex: salario veio diferente do esperado) para manter os dados precisos.

6. **Como usuario**, eu quero adicionar uma receita extra eventual (ex: restituicao IR, freelance, venda de item) para que o saldo do mes reflita toda a renda recebida.

7. **Como usuario**, eu quero ver o historico de receitas mes a mes para identificar tendencias na renda familiar.

## Funcionalidades Principais

### F1. Cadastro de Receitas Mensais

Permite registrar receitas associadas a um mes/ano especifico. Cada receita possui:
- Descricao (ex: "Ramon Salario", "Aline Adiantamento")
- Valor (em R$)
- Mes/ano de referencia
- Pessoa associada (Ramon ou Aline) — opcional, para receitas que nao sao de uma pessoa especifica

**Por que e importante**: E a funcionalidade central que preenche a lacuna entre o que a planilha fazia e o que o app faz hoje.

**Requisitos funcionais**:
1. O usuario pode criar uma ou mais receitas para um mes/ano
2. O usuario pode editar o valor e a descricao de uma receita existente
3. O usuario pode excluir uma receita
4. Receitas sao organizadas por mes/ano de referencia
5. O sistema deve exibir o total de receitas do mes

### F2. Categorias de Receita Pre-definidas

O sistema deve oferecer categorias pre-definidas que espelham a planilha original:
- Mes anterior (carry-over)
- Adiantamento salarial
- Salario
- Outros (para receitas eventuais)

**Por que e importante**: Agiliza o cadastro e mantem consistencia com o modelo mental que o casal ja usa na planilha.

**Requisitos funcionais**:
1. Ao criar uma receita, o usuario pode selecionar uma categoria pre-definida
2. A categoria "Outros" permite descricao livre
3. As categorias pre-definidas preenchem automaticamente a descricao sugerida

### F3. Saldo do Mes Anterior (Carry-over)

O saldo remanescente do mes anterior (receitas - despesas) deve ser transportado como uma receita do tipo "Mes anterior" no mes seguinte.

**Por que e importante**: Na planilha, o casal sempre considerava o saldo acumulado. Sem isso, cada mes seria isolado e o controle financeiro perderia continuidade.

**Requisitos funcionais**:
1. O sistema calcula automaticamente o saldo do mes anterior (total receitas - total despesas)
2. O valor calculado e sugerido como receita "Mes anterior" ao configurar um novo mes
3. O usuario pode aceitar o valor sugerido ou ajustar manualmente (para cobrir discrepancias)
4. Se o saldo do mes anterior for negativo, o carry-over deve ser exibido como valor negativo

### F4. Calculo e Exibicao do Saldo Mensal

O app deve calcular e exibir de forma proeminente:
- Total de receitas do mes
- Total de despesas do mes (ja existente)
- Saldo do mes (receitas - despesas)

**Por que e importante**: Esta e a informacao mais valiosa para o casal — saber se estao gastando mais do que ganham.

**Requisitos funcionais**:
1. O saldo mensal e calculado como: total receitas - total despesas
2. O saldo e exibido com destaque visual (verde para positivo, vermelho para negativo)
3. O calculo e atualizado em tempo real quando receitas ou despesas sao modificadas
4. O saldo deve ser visivel na tela principal/dashboard do mes

### F5. Tela de Gestao de Receitas

Uma tela dedicada para visualizar e gerenciar as receitas de um mes especifico.

**Por que e importante**: Centraliza a gestao de receitas em um unico lugar, facilitando o cadastro e a conferencia.

**Requisitos funcionais**:
1. Lista todas as receitas do mes selecionado
2. Exibe o total de receitas no topo ou rodape da lista
3. Permite adicionar nova receita via botao de acao
4. Permite editar uma receita ao tocar nela
5. Permite excluir uma receita com confirmacao
6. Navegacao entre meses (anterior/proximo)

## Experiencia do Usuario

### Personas

- **Ramon**: usuario principal e tecnico. Registra as receitas no inicio de cada mes. Quer rapidez e praticidade.
- **Aline**: usuario frequente. Consulta o saldo para decisoes de compra. Quer clareza visual e simplicidade.

### Fluxos principais

**Fluxo 1 — Configurar receitas do mes**:
1. Usuario acessa a tela de receitas do mes atual
2. O sistema sugere as receitas recorrentes (salarios e adiantamentos) com base no mes anterior
3. Usuario confirma ou ajusta os valores
4. O carry-over do mes anterior e exibido automaticamente
5. Total de receitas e saldo sao atualizados em tempo real

**Fluxo 2 — Consultar saldo mensal**:
1. Usuario abre o app
2. Na tela principal, ve o saldo do mes atual (receitas - despesas) em destaque
3. Se quiser detalhes, toca para ver o breakdown de receitas e despesas

**Fluxo 3 — Adicionar receita extra**:
1. Usuario acessa a tela de receitas
2. Toca em "Adicionar receita"
3. Seleciona categoria "Outros", digita descricao e valor
4. Salva e ve o total atualizado

### Consideracoes de UI/UX

- A interface deve seguir o padrao visual ja existente no app (Ionic/React)
- O saldo mensal deve ter destaque visual claro (cor verde/vermelha, tamanho de fonte maior)
- O cadastro de receitas deve ser rapido — idealmente 2-3 toques para receitas recorrentes
- A tela deve funcionar bem em dispositivos moveis (mobile-first, Capacitor)

## Restricoes Tecnicas de Alto Nivel

- O backend deve seguir a arquitetura existente do projeto ControlAI (Kotlin/Spring Boot)
- O frontend deve usar React com Ionic e Capacitor, mantendo compatibilidade com o app existente
- Os dados de receitas devem ser persistidos no mesmo banco de dados utilizado pelo sistema
- A API de receitas deve seguir o padrao REST ja utilizado pelos demais endpoints
- Os valores monetarios devem ser tratados com precisao adequada (sem erros de ponto flutuante)
- Beneficios como VA/VR nao fazem parte do escopo e nao devem ser rastreados neste sistema

## Fora de Escopo

- **Importacao automatica de receitas** (ex: via integracao bancaria ou Open Finance) — sera considerada no futuro
- **Rastreamento de beneficios (VA/VR)** — esses valores sao gastos em cartoes separados e nao fazem parte do controle financeiro do casal
- **Receitas recorrentes automaticas** — o sistema nao criara receitas automaticamente a cada mes; o usuario deve confirmar os valores manualmente (salarios podem variar)
- **Previsao de receitas futuras** — projecoes e estimativas ficam para uma funcionalidade futura
- **Divisao de receitas por conta bancaria** — o sistema trata receitas de forma agregada, sem vincular a contas especificas
- **Relatorios avancados de renda** — graficos e analises detalhadas de evolucao salarial serao funcionalidades futuras
- **Multi-moeda** — o sistema opera exclusivamente em BRL (R$)
