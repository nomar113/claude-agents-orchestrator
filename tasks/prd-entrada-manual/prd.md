# PRD: Entrada Manual de Despesas

## Visao Geral

O ControlAI e um aplicativo mobile-first de financas pessoais usado por um casal (Ramon e Aline) para controlar gastos de cartao de credito. Atualmente, o app suporta apenas entrada de dados via leitura de QR Code de notas fiscais brasileiras. No entanto, aproximadamente 95% dos lancamentos do casal sao manuais -- corridas de Uber, restaurantes, assinaturas, gastos com pet, entre outros -- que nao possuem nota fiscal com QR Code.

Sem a entrada manual, o app nao consegue substituir a planilha do Google Sheets que o casal usa hoje. Esta e a funcionalidade mais critica para o uso diario: ela transforma o ControlAI de uma ferramenta parcial em a ferramenta principal de controle financeiro do casal.

A planilha atual possui os seguintes campos por lancamento: DATA (data da compra), DESCRICAO (estabelecimento ou descricao), PARCELAS (ex: 1/12, 3/10), VALOR (valor em reais), CARTAO (nome do cartao -- Smiles Infinite, Latam, Nubank Ramon, etc.), FINAL CARTAO (ultimos 4 digitos), CATEGORIA (17+ categorias como Comida, Gastos Gerais, Transporte, etc.) e um flag de verificado (TRUE/FALSE).

## Objetivos

1. **Permitir registro completo de despesas manuais** com todos os campos equivalentes a planilha atual, garantindo paridade funcional.

2. **Reduzir o tempo de registro** de uma despesa manual para menos de 30 segundos, tornando o app mais rapido que a planilha.

3. **Atingir adocao total** -- o casal deve conseguir registrar 100% dos gastos pelo app, eliminando a necessidade da planilha.

4. **Manter consistencia de dados** -- os lancamentos manuais devem ser armazenados no mesmo formato que os lancamentos via QR Code, permitindo visualizacao e relatorios unificados.

5. **Metricas de sucesso:**
   - Percentual de despesas registradas no app vs. planilha (meta: 100% no app em 30 dias)
   - Tempo medio de registro de uma despesa manual (meta: < 30 segundos)
   - Frequencia de uso diario (meta: pelo menos 1 registro/dia por usuario)

## Historias de Usuario

**Como Ramon ou Aline**, eu quero registrar rapidamente uma despesa manual (ex: Uber, restaurante, assinatura) pelo celular **para que** eu nao precise abrir a planilha do Google Sheets.

**Como Ramon ou Aline**, eu quero selecionar o cartao de credito utilizado a partir de uma lista pre-cadastrada **para que** eu nao precise digitar o nome e os ultimos 4 digitos toda vez.

**Como Ramon ou Aline**, eu quero categorizar cada despesa (Comida, Transporte, Gastos Gerais, etc.) **para que** eu consiga acompanhar meus gastos por categoria, assim como faco na planilha.

**Como Ramon ou Aline**, eu quero informar parcelas (ex: 3/10) quando a compra for parcelada **para que** eu tenha controle preciso do saldo devedor e das parcelas futuras.

**Como Ramon ou Aline**, eu quero que a data padrao seja "hoje" mas poder alterar para datas passadas **para que** eu consiga registrar gastos que esqueci de lancar no dia.

**Como Ramon ou Aline**, eu quero que o campo de descricao sugira descricoes ja utilizadas anteriormente **para que** gastos recorrentes (ex: "Uber", "iFood", "Petlove") sejam mais rapidos de registrar.

**Como Ramon ou Aline**, eu quero acessar o formulario de entrada manual com no maximo 1 toque a partir da tela principal **para que** o registro seja o mais rapido possivel.

**Como Ramon ou Aline**, eu quero marcar um lancamento como "verificado" ou "nao verificado" **para que** eu possa conferir os lancamentos na fatura do cartao posteriormente.

## Funcionalidades Principais

### F1. Formulario de Entrada Manual

O formulario e o nucleo desta feature. Deve conter todos os campos necessarios para paridade com a planilha, com foco em velocidade de preenchimento.

**Campos do formulario:**

- **Data**: seletor de data, padrao "hoje". Obrigatorio.
- **Descricao**: campo de texto livre com autocomplete baseado em descricoes anteriores. Obrigatorio.
- **Valor**: campo numerico em reais (R$), com teclado numerico. Obrigatorio.
- **Cartao**: seletor a partir da lista de cartoes pre-cadastrados do usuario (nome + ultimos 4 digitos). Obrigatorio.
- **Parcelas**: campo opcional no formato X/Y (parcela atual / total de parcelas). Quando nao informado, assume compra a vista (1/1).
- **Categoria**: seletor a partir da lista de categorias disponiveis. Obrigatorio.
- **Verificado**: toggle, padrao FALSE.

**Requisitos funcionais:**

- RF1.1: O formulario deve abrir com foco no campo Descricao (Data ja preenchida com hoje).
- RF1.2: O teclado numerico deve abrir automaticamente ao focar no campo Valor.
- RF1.3: Ao salvar, o formulario deve limpar os campos e estar pronto para um novo lancamento, mantendo o cartao e a categoria selecionados anteriormente (para lancamentos em sequencia).
- RF1.4: Deve exibir feedback visual de sucesso ao salvar (toast ou animacao breve).
- RF1.5: Validacao inline -- campos obrigatorios devem ser validados antes do envio.

### F2. Autocomplete de Descricao

Para gastos recorrentes, o autocomplete reduz drasticamente o tempo de digitacao.

- RF2.1: Ao digitar no campo Descricao, sugerir descricoes ja utilizadas que contenham o texto digitado.
- RF2.2: A lista de sugestoes deve ser ordenada por frequencia de uso (mais usadas primeiro).
- RF2.3: Ao selecionar uma sugestao, preencher automaticamente a Categoria mais usada para aquela descricao (o usuario pode alterar).

### F3. Gerenciamento de Cartoes

Os cartoes sao um dado relativamente estatico que precisa ser configurado uma vez e reutilizado.

- RF3.1: O usuario deve poder cadastrar cartoes com: nome do cartao (ex: "Smiles Infinite") e ultimos 4 digitos.
- RF3.2: O usuario deve poder editar e excluir cartoes cadastrados.
- RF3.3: Deve haver cartoes pre-cadastrados iniciais baseados nos cartoes conhecidos do casal (Smiles Infinite, Latam, Nubank Ramon, Nubank Aline, etc.) para facilitar o onboarding.

### F4. Lista de Categorias

- RF4.1: As categorias devem incluir no minimo: Comida, Gastos Gerais, Transporte, Saude, Lazer, Pet, Casa, Educacao, Roupas, Beleza, Presentes, Viagem, Assinaturas, Mercado, Farmacia, Combustivel, Outros.
- RF4.2: As categorias devem ser exibidas com icones visuais para identificacao rapida.
- RF4.3: Categorias mais usadas devem aparecer primeiro no seletor.

### F5. Acesso Rapido

- RF5.1: Deve haver um botao de acao flutuante (FAB) ou equivalente na tela principal para abrir o formulario de entrada manual com 1 toque.
- RF5.2: O formulario pode ser uma tela dedicada ou um bottom sheet -- o importante e ser rapido de acessar e preencher.

## Experiencia do Usuario

**Persona primaria:** Ramon e Aline -- casal que registra despesas diariamente, geralmente no celular logo apos a compra (na fila do caixa, no Uber, etc.). Precisam de velocidade acima de tudo.

**Fluxo principal:**

1. Usuario abre o app e ve a tela principal (lista de despesas recentes).
2. Toca no botao de adicionar despesa (FAB ou equivalente).
3. Formulario abre com Data = hoje e foco no campo Descricao.
4. Digita "Ub..." e seleciona "Uber" do autocomplete. Categoria "Transporte" e preenchida automaticamente.
5. Toca em Valor, digita "23.50".
6. Seleciona o cartao (ex: "Nubank Ramon - 4321").
7. Toca em Salvar. Toast de sucesso aparece. Formulario limpa para novo lancamento.

**Tempo total estimado: 15-25 segundos.**

**Consideracoes de UX:**

- O formulario deve ser otimizado para uso com uma mao (thumb-zone friendly).
- Campos mais usados (Descricao, Valor) devem estar no topo.
- O seletor de cartao e categoria deve usar chips ou bottom sheet, evitando dropdowns que exigem scroll excessivo.
- O feedback de salvamento deve ser sutil mas claro -- nao deve bloquear o fluxo.
- Em caso de erro de conexao, o lancamento deve ser salvo localmente e sincronizado quando houver conexao (offline-first).

## Restricoes Tecnicas de Alto Nivel

- **Backend existente**: o backend em Kotlin/Spring Boot ja possui modelos para lancamentos vindos de QR Code. Os lancamentos manuais devem ser compativeis com o modelo existente ou ser uma extensao dele.
- **Frontend existente**: o frontend usa React com Ionic e Capacitor (mobile-first). O formulario deve seguir os padroes de UI ja estabelecidos no app.
- **Offline-first**: como o app e mobile e sera usado em situacoes com conexao instavel (ex: dentro de lojas), os lancamentos devem ser persistidos localmente antes de sincronizar com o backend.
- **Dados sensiveis**: valores financeiros e nomes de cartao sao dados sensiveis. A comunicacao deve ser via HTTPS e os dados locais devem seguir as boas praticas de armazenamento seguro do Capacitor.
- **Integracao com dados existentes**: os lancamentos manuais devem aparecer na mesma listagem e nos mesmos relatorios que os lancamentos via QR Code, sem distincao visual (exceto um indicador de origem, se necessario).

## Fora de Escopo

- **Importacao em lote da planilha**: migrar dados historicos do Google Sheets para o app nao faz parte deste escopo.
- **Lancamentos recorrentes automaticos**: agendar lancamentos que se repetem mensalmente (ex: Netflix, Spotify) e uma evolucao futura, nao parte desta entrega.
- **Edicao e exclusao de lancamentos existentes**: esta feature foca na criacao. Edicao e exclusao serao tratadas em um PRD separado.
- **Notificacoes e lembretes**: lembretes para registrar gastos ou alertas de limite de gasto nao fazem parte deste escopo.
- **Relatorios e dashboards**: visualizacao de gastos por categoria, por cartao ou por periodo e uma feature separada.
- **Multi-moeda**: todos os lancamentos sao em BRL (Real). Suporte a outras moedas nao esta no escopo.
- **Compartilhamento entre usuarios**: embora Ramon e Aline compartilhem os dados, o controle de acesso multi-usuario nao faz parte deste escopo (ambos usam a mesma conta).
