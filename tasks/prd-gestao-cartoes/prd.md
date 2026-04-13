# PRD: Gestao de Cartoes e Meios de Pagamento

## Visao Geral

O ControlAI e um aplicativo de financas pessoais utilizado por um casal (Ramon e Aline) para controlar despesas de cartao de credito, substituindo uma planilha Google Sheets. Atualmente, o frontend exibe cartoes mockados (NUBANK PLATINUM, Inter, C6 Bank) que nao refletem a realidade do casal.

Esta funcionalidade visa permitir o cadastro, edicao e gerenciamento dos cartoes de credito e meios de pagamento reais utilizados pelo casal, associando cada um a seu titular e possibilitando que cada despesa seja vinculada ao cartao ou meio de pagamento correto. Sem isso, o sistema nao consegue reproduzir o controle que a planilha oferece: saber exatamente quanto foi gasto em cada cartao, por qual pessoa, em cada mes.

Os cartoes e meios de pagamento reais sao:

- **Smiles Infinite** (cartao principal, maior volume de gastos)
  - Fisico titular — finais 6668 (Ramon)
  - Fisico dependente — finais 9687 (Aline)
  - Carteira digital — Apple Pay (token proprio)
  - Virtual — para compras online
- **Latam** - assinaturas e despesas fixas
- **Nubank Ramon** - conta de telefone
- **Nubank Aline**
- **Neon Aline** - assinatura Apple Cloud
- **Pix** - transferencias instantaneas
- **Dinheiro** - pagamentos em especie

## Objetivos

- **Eliminar dados mockados**: substituir os cartoes hardcoded no frontend por dados reais vindos do backend, permitindo que o casal veja seus cartoes verdadeiros no app.
- **Reproduzir o controle da planilha**: permitir que cada despesa seja associada a um cartao/meio de pagamento especifico, com os ultimos 4 digitos quando aplicavel, exatamente como a planilha faz.
- **Visibilidade por cartao**: possibilitar a visualizacao do total gasto por cartao em cada mes, informacao que a planilha ja fornece e que o app precisa replicar.
- **Gestao autonoma**: permitir que o casal cadastre, edite e desative cartoes sem depender de alteracoes no codigo.

Metricas de sucesso:

- 100% das despesas registradas estao associadas a um cartao ou meio de pagamento
- O casal consegue visualizar o total mensal por cartao, equivalente a planilha
- Zero cartoes hardcoded no frontend

## Historias de Usuario

- Como **Ramon**, eu quero cadastrar meus cartoes reais (Smiles Infinite 6668, Latam, Nubank) para que o app mostre os cartoes que eu realmente uso, nao cartoes fictcios.
- Como **Aline**, eu quero ver meus cartoes (Smiles Infinite 9687, Nubank Aline, Neon Aline) separados dos cartoes do Ramon para que eu saiba exatamente quanto estou gastando em cada um.
- Como **usuario**, eu quero selecionar o cartao ao registrar uma despesa para que cada gasto fique vinculado ao meio de pagamento correto, assim como faco na planilha.
- Como **usuario**, eu quero ver o total gasto em cada cartao no mes para que eu saiba quanto vai vir na fatura de cada um.
- Como **usuario**, eu quero poder adicionar um novo cartao caso contrate um, sem precisar alterar o codigo do aplicativo.
- Como **usuario**, eu quero desativar um cartao que cancelei, sem perder o historico de despesas ja registradas nele.
- Como **usuario**, eu quero registrar despesas feitas via Pix ou Dinheiro para que todas as saidas financeiras estejam no mesmo lugar.
- Como **usuario**, eu quero identificar rapidamente de quem e cada cartao (titular) para evitar confusao ao registrar despesas.
- Como **Ramon**, eu quero cadastrar meus dois plasticos do Smiles Infinite (6668 e 9687) dentro do mesmo cartao para que a fatura total seja consolidada, mas eu consiga ver quanto foi gasto em cada um.
- Como **usuario**, eu quero cadastrar um cartao virtual permanente dentro do meu cartao principal para rastrear compras online feitas com ele.
- Como **usuario**, eu quero marcar que um sub-cartao e de carteira digital (Apple Pay, Google Pay) para saber quando uma despesa foi feita por aproximacao via celular.
- Como **usuario**, eu quero adicionar um cartao de dependente dentro do cartao principal para que a fatura do dependente apareca consolidada junto ao titular.
- Como **usuario**, eu quero gerar e desativar cartoes virtuais temporarios para compras especificas sem afetar o cartao principal.

## Funcionalidades Principais

### 1. Cadastro de Cartoes e Meios de Pagamento

Permitir criar cartoes de credito e outros meios de pagamento com as informacoes essenciais.

**Por que e importante:** Sem essa base cadastral, nao ha como associar despesas a cartoes reais nem exibir informacoes corretas no dashboard.

**Requisitos funcionais:**

1.1. Cadastrar um cartao de credito (cartao principal) com: nome (ex: "Smiles Infinite"), titular (Ramon ou Aline), bandeira (opcional) e dia de fechamento da fatura.

1.2. Cadastrar um meio de pagamento que nao e cartao de credito (Pix, Dinheiro) com: nome e titular.

1.3. Cada cartao/meio de pagamento deve ter um tipo que o classifique: cartao de credito, pix ou dinheiro.

1.4. Permitir edicao dos dados de um cartao existente.

1.5. Permitir desativar um cartao (soft delete), mantendo o historico de despesas associadas.

1.6. Listar todos os cartoes e meios de pagamento, com filtro por titular.

### 1A. Sub-cartoes (Cartoes Vinculados)

Cada cartao principal pode conter multiplos sub-cartoes, cada um com seus proprios ultimos 4 digitos. Isso reflete a realidade de que um mesmo cartao de credito pode ter diversas variantes fisicas e digitais.

**Por que e importante:** Um unico cartao de credito (ex: Smiles Infinite) pode gerar multiplos "plasticos" e versoes digitais — cartao fisico titular, cartao de dependente, cartao virtual para compras online, cartao virtual temporario e cartoes tokenizados em carteiras digitais. Para reproduzir fielmente o controle da planilha, e necessario identificar em qual variante especifica cada despesa foi feita, ja que cada uma tem seus proprios ultimos 4 digitos na fatura.

**Tipos de sub-cartao:**

- **Fisico titular** — o cartao plastico principal do titular
- **Fisico dependente** — cartao adicional emitido para outra pessoa (ex: Aline como dependente no Smiles de Ramon)
- **Virtual** — cartao virtual permanente gerado pelo app do banco para compras online
- **Virtual temporario** — cartao virtual de uso unico ou com validade curta
- **Carteira digital** — cartao tokenizado em Apple Pay, Google Pay, Samsung Pay ou outra carteira digital

**Requisitos funcionais:**

1A.1. Cada sub-cartao deve ter: ultimos 4 digitos (obrigatorio), tipo (fisico titular, fisico dependente, virtual, virtual temporario, carteira digital), apelido (opcional, ex: "Virtual Compras Online") e status ativo/inativo.

1A.2. Sub-cartoes do tipo "carteira digital" devem permitir selecionar a plataforma: Apple Pay, Google Pay, Samsung Pay ou Outra.

1A.3. Sub-cartoes do tipo "fisico dependente" devem permitir informar o nome do dependente.

1A.4. Ao registrar uma despesa, o usuario seleciona o cartao principal e, opcionalmente, o sub-cartao especifico (pelos ultimos 4 digitos). Se nao selecionar um sub-cartao, a despesa fica associada apenas ao cartao principal.

1A.5. A fatura total do cartao principal e a soma de todos os seus sub-cartoes.

1A.6. Permitir adicionar, editar e desativar sub-cartoes sem afetar o cartao principal.

1A.7. Sub-cartoes desativados mantem o historico de despesas associadas (soft delete).

### 2. Associacao de Titular

Cada cartao ou meio de pagamento pertence a um titular (Ramon ou Aline).

**Por que e importante:** O casal precisa saber quanto cada pessoa esta gastando e em qual cartao, informacao fundamental para o controle financeiro conjunto.

**Requisitos funcionais:**

2.1. Todo cartao deve ter um titular obrigatorio.

2.2. O titular deve ser selecionavel ao cadastrar ou editar um cartao.

2.3. O dashboard deve permitir filtrar a visualizacao por titular.

### 3. Vinculacao de Despesas a Cartoes

Ao registrar uma despesa, o usuario deve selecionar em qual cartao ou meio de pagamento ela foi feita.

**Por que e importante:** Esta e a funcionalidade central que replica o comportamento da planilha - saber em qual cartao cada gasto foi feito para calcular o total da fatura.

**Requisitos funcionais:**

3.1. O formulario de registro de despesa deve incluir um campo obrigatorio para selecionar o cartao/meio de pagamento.

3.2. A lista de cartoes no seletor deve mostrar apenas cartoes ativos, agrupados por titular.

3.3. Deve ser possivel alterar o cartao de uma despesa ja registrada.

3.4. Apos selecionar o cartao principal, o usuario pode opcionalmente selecionar um sub-cartao especifico (identificado pelos ultimos 4 digitos e tipo). Isso permite rastrear em qual variante do cartao a despesa foi feita.

3.5. O seletor de sub-cartao deve exibir icones identificando o tipo (fisico, virtual, carteira digital) para facilitar a selecao rapida.

### 4. Visualizacao de Totais por Cartao

Exibir o total gasto por cartao/meio de pagamento no mes corrente.

**Por que e importante:** A planilha mostra o total por meio de pagamento no planejamento mensal. O app precisa oferecer essa mesma visibilidade para que o casal saiba quanto vira em cada fatura.

**Requisitos funcionais:**

4.1. O dashboard deve exibir os cartoes reais do usuario (substituindo os mockados) com o total de despesas do mes.

4.2. Exibir o total gasto por cartao no mes, com destaque para o cartao com maior gasto.

4.3. Permitir navegar para ver o detalhamento das despesas de um cartao especifico.

## Experiencia do Usuario

**Personas:**

- **Ramon** - responsavel pela maioria dos gastos, usa principalmente o Smiles Infinite 6668. Registra despesas diariamente. Quer ver rapidamente quanto ja gastou no cartao principal.
- **Aline** - usa Smiles Infinite 9687, Nubank Aline e Neon Aline. Precisa ver seus cartoes separados dos de Ramon.

**Fluxo principal - Dashboard:**

1. Ao abrir o app, o usuario ve seus cartoes reais no lugar dos cartoes mockados atuais.
2. Cada cartao exibe nome, ultimos 4 digitos (quando aplicavel), titular e total do mes.
3. O cartao com maior gasto fica em destaque (posicao frontal, como o layout atual).
4. O usuario pode tocar em um cartao para ver as despesas daquele cartao no mes.

**Fluxo principal - Registro de despesa:**

1. No formulario de nova despesa, o usuario seleciona o cartao/meio de pagamento em um seletor.
2. Os cartoes aparecem agrupados por titular para facilitar a selecao.
3. O ultimo cartao utilizado pode ser pre-selecionado para agilizar o registro.

**Fluxo de gestao de cartoes:**

1. Em uma tela de configuracoes, o usuario acessa a lista de cartoes.
2. Pode adicionar novo cartao, editar existente ou desativar.
3. Interface simples com formulario direto, sem complexidade desnecessaria.

**Fluxo de gestao de sub-cartoes:**

1. Na tela de criacao/edicao do cartao principal, o usuario ve a secao "Cartoes vinculados".
2. Pode adicionar sub-cartoes informando: ultimos 4 digitos, tipo (fisico titular, fisico dependente, virtual, virtual temporario, carteira digital) e apelido opcional.
3. Para sub-cartoes de carteira digital, seleciona a plataforma (Apple Pay, Google Pay, Samsung Pay).
4. Para sub-cartoes de dependente, informa o nome do dependente.
5. Pode desativar sub-cartoes individualmente sem afetar o cartao principal ou outros sub-cartoes.

**Consideracoes de UX:**

- Manter a estetica atual do card stack no dashboard, apenas alimentando com dados reais.
- O seletor de cartao no registro de despesa deve ser rapido (poucos toques) ja que o casal tem menos de 10 meios de pagamento.
- Indicar visualmente o titular de cada cartao (cor, icone ou label).

## Restricoes Tecnicas de Alto Nivel

- O backend e Kotlin/Spring Boot e o frontend e React/Ionic/Capacitor. A solucao deve seguir os padroes ja existentes no projeto.
- Os cartoes devem ser persistidos no banco de dados do backend, servidos via API REST e consumidos pelo frontend. Nao deve haver mais dados hardcoded.
- A associacao entre despesa e cartao deve ser obrigatoria para novas despesas. Despesas ja existentes sem cartao associado devem continuar funcionando (compatibilidade retroativa).
- Os dados de cartao sao sensiveis: armazenar apenas os ultimos 4 digitos, nunca o numero completo.
- O sistema deve funcionar offline-first para consulta (Capacitor), sincronizando quando houver conexao.

## Fora de Escopo

- **Integracao com bancos ou Open Finance** - nao ha integracao automatica com instituicoes financeiras. Todos os dados sao inseridos manualmente.
- **Controle de limite de credito** - o gerenciamento de limites e analise de credito disponivel ficam para uma versao futura.
- **Multiplas contas ou familias** - o sistema e exclusivo para o casal Ramon e Aline. Nao ha necessidade de multi-tenancy.
- **Notificacoes de vencimento de fatura** - alertas e lembretes de pagamento estao fora deste escopo.
- **Geracao automatica de cartao virtual** - o app nao gera cartoes virtuais; apenas permite cadastrar os dados (ultimos 4 digitos) de cartoes virtuais ja gerados pelo banco.
- **Importacao automatica de faturas** - a leitura automatica de faturas (PDF, OFX) e escopo de outra funcionalidade.
