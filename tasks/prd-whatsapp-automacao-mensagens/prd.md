# PRD — Automação de Mensagens Agendadas no WhatsApp

## Visão Geral

Ferramenta pessoal de automação que permite ao usuário agendar e disparar mensagens recorrentes no WhatsApp de forma simples, sem código e sem depender de lembretes manuais. O sistema resolve o problema de **esquecer mensagens importantes** (cumprimentos diários, lembretes de saúde de pets, parabéns de aniversário) e a **fricção de configurar agendamentos complexos** (ex: relativos ao nascer do sol ou a datas dinâmicas de contatos).

O público é o **uso pessoal individual** — uma pessoa que gerencia sua própria conta de WhatsApp e quer transformar rotinas de mensagem em automações confiáveis através de uma interface web local.

## Objetivos

- Reduzir a zero o esquecimento de mensagens recorrentes que hoje dependem da memória do usuário.
- Permitir criar um agendamento completo (gatilho + destinatário + mensagem) em até **3 passos** no dashboard.
- Suportar **100% dos três cenários-âncora** descritos nas histórias de usuário sem necessidade de scripts ou integrações externas.
- Garantir **0 mensagens disparadas por engano** através de pré-visualização e confirmação para envios em massa.
- Manter a configuração legível e editável: qualquer agendamento ativo pode ser pausado ou alterado em menos de 30 segundos.

## Histórias de Usuário

- **Como** usuário pessoal, **eu quero** enviar "Bom dia" para a Irene **todos os dias 2 horas após o nascer do sol** **para que** ela receba o cumprimento sempre com a luz da manhã, mesmo no inverno e no verão.
- **Como** dono de um gato, **eu quero** receber/enviar um lembrete **mensal** sobre a injeção do gato no veterinário **para que** eu nunca perca uma dose.
- **Como** organizador da família, **eu quero** disparar **uma mensagem de feliz aniversário por ano** para cada pessoa da minha lista de aniversariantes **para que** ninguém seja esquecido na data correta.
- **Como** usuário cuidadoso, **eu quero** pré-visualizar a mensagem antes de salvar o agendamento **para que** eu não envie um texto com variáveis quebradas.
- **Como** usuário que viaja, **eu quero** pausar temporariamente um agendamento sem perder sua configuração **para que** eu possa retomá-lo depois.
- **Como** novo usuário, **eu quero** importar meus contatos de um arquivo CSV ou da agenda do WhatsApp **para que** eu não precise digitar números manualmente.

## Funcionalidades Principais

### 1. Gestão de Contatos e Listas

- **FR1**: O sistema deve permitir cadastrar contatos individuais com no mínimo: nome, número de WhatsApp, data de nascimento (opcional) e variáveis customizadas (opcional).
- **FR2**: O sistema deve permitir importar contatos em massa via arquivo CSV.
- **FR3**: O sistema deve permitir importar contatos a partir da agenda da conta WhatsApp conectada.
- **FR4**: O sistema deve permitir organizar contatos em **listas** nomeadas (ex: "Aniversariantes", "Família", "Clientes Pet").
- **FR5**: O sistema deve permitir editar e remover contatos e listas a qualquer momento, sem afetar agendamentos já disparados.

### 2. Tipos de Agendamento

- **FR6**: O sistema deve suportar agendamento **recorrente por data/hora fixa** com granularidade diária, semanal, mensal e anual (ex: "todo dia 15 às 9h", "toda segunda às 8h").
- **FR7**: O sistema deve suportar agendamento **relativo a eventos solares**, com deslocamento configurável antes ou depois (ex: "2h após o nascer do sol", "30min antes do pôr do sol").
- **FR8**: Agendamentos solares devem usar a **localização configurada pelo usuário** (cidade/coordenadas) para calcular o horário correto a cada dia.
- **FR9**: O sistema deve suportar agendamento **baseado em datas dinâmicas de contatos**, com aniversário como gatilho nativo (ex: "no dia do aniversário de cada contato da lista X, às 9h").
- **FR10**: O sistema deve suportar agendamento **one-time** para uma data e hora específicas no futuro.
- **FR11**: Todos os agendamentos devem respeitar o fuso horário configurado pelo usuário.
- **FR12**: O sistema deve permitir definir uma **data de término** (ou número de ocorrências) para agendamentos recorrentes, opcionalmente.

### 3. Composição de Mensagens

- **FR13**: O sistema deve permitir compor mensagens de **texto simples**.
- **FR14**: O sistema deve suportar **templates com variáveis** que são substituídas no momento do envio (ex: `{nome}`, `{idade}`, `{data}`).
- **FR15**: O sistema deve permitir anexar **imagens, GIFs, vídeos e áudios** à mensagem agendada.
- **FR16**: O sistema deve permitir anexar **documentos** (PDF, planilhas, etc.) à mensagem agendada.
- **FR17**: A composição de mensagem deve oferecer **pré-visualização renderizada** mostrando o texto final com variáveis substituídas e mídia anexada antes do salvamento.

### 4. Controles de Segurança e Operação

- **FR18**: O sistema deve permitir **pausar e retomar** qualquer agendamento sem perder sua configuração.
- **FR19**: O sistema deve exibir **confirmação explícita** antes de salvar agendamentos cujo público destinatário ultrapasse um limite configurável (ex: lista com mais de 10 contatos).
- **FR20**: O sistema deve aplicar um **limite anti-spam** que impeça mais de N mensagens automáticas para o mesmo contato em uma janela de tempo configurável.
- **FR21**: O usuário deve poder editar ou cancelar um agendamento a qualquer momento antes da próxima execução.
- **FR22**: O sistema deve indicar visualmente o **próximo horário de disparo** calculado para cada agendamento ativo.

### 5. Conexão com o WhatsApp

- **FR23**: O sistema deve permitir conectar a conta WhatsApp do usuário via **escaneamento de QR Code** (WhatsApp Web).
- **FR24**: O sistema deve manter a sessão conectada e alertar o usuário caso a sessão expire ou seja desconectada.
- **FR25**: O sistema deve permitir desconectar e reconectar a conta WhatsApp pelo dashboard.

## Experiência do Usuário

**Persona Primária**: usuário pessoal não-técnico, familiarizado com WhatsApp e aplicativos web, que quer automatizar rotinas sem aprender a programar.

**Fluxos Principais**:

1. **Onboarding (primeira vez)**: conectar WhatsApp via QR Code → configurar localização e fuso horário → importar contatos (CSV ou agenda).
2. **Criar agendamento (3 passos)**:
   - Passo 1: escolher destinatário (contato individual ou lista).
   - Passo 2: escolher gatilho (data fixa / solar / aniversário / one-time) e parâmetros.
   - Passo 3: compor mensagem (texto + variáveis + mídia) e pré-visualizar.
3. **Gerenciar agendamentos**: ver lista de agendamentos ativos com próximo disparo, pausar/retomar, editar ou excluir.
4. **Reconectar WhatsApp**: tela dedicada com QR Code e status da sessão.

**Requisitos de UI/UX**:

- Dashboard web responsivo (desktop e mobile browser).
- Linguagem clara em português, sem jargão técnico.
- Cada tipo de gatilho deve ter um formulário visual dedicado (não um campo livre de cron).
- Pré-visualização da mensagem sempre visível antes do salvamento.
- Estado de cada agendamento (ativo, pausado, expirado) visível com cores e ícones distintos.

**Requisitos de Acessibilidade**:

- Navegação completa por teclado.
- Contraste WCAG AA mínimo em todos os textos e ícones.
- Labels semânticos em todos os campos de formulário.
- Mensagens de erro descritivas e associadas ao campo correspondente.

## Restrições Técnicas de Alto Nível

- **Canal de envio**: integração via WhatsApp Web (sessão pessoal por QR Code). A solução **não** usa a WhatsApp Business API oficial no MVP — isso implica em risco de bloqueio da conta em caso de uso abusivo e deve ser comunicado ao usuário no onboarding.
- **Eventos solares**: cálculo de nascer/pôr do sol requer **localização geográfica** do usuário (cidade ou coordenadas).
- **Fuso horário**: todo agendamento deve ser interpretado no fuso configurado pelo usuário; mudanças de horário de verão devem ser tratadas corretamente.
- **Privacidade**: contatos, mensagens e mídia ficam sob controle do usuário; não devem ser compartilhados com terceiros.
- **Confiabilidade**: o sistema precisa estar em execução no momento do disparo (não há fila externa garantindo entrega offline) — isso é uma limitação explícita do MVP.
- **Conformidade**: o usuário é responsável pelo conteúdo enviado; o sistema deve incluir aviso explícito sobre uso responsável e respeito a contatos que não desejam mensagens automatizadas.

## Fora de Escopo

- **Histórico e logs detalhados** de envios (status entregue/lido, reenvio automático em falhas, dashboard analítico).
- **Multi-usuário ou SaaS**: o sistema é monoinstância, para uso pessoal de uma pessoa.
- **App mobile nativo** (iOS/Android) — apenas dashboard web no MVP.
- **WhatsApp Business API oficial** (templates aprovados pela Meta, números comerciais).
- **Conversas bidirecionais / chatbot** — o sistema apenas envia mensagens agendadas; não interpreta nem responde a mensagens recebidas.
- **Integração com outros canais** (SMS, e-mail, Telegram, Instagram).
- **Gatilhos baseados em eventos externos** (webhooks, APIs, RSS, clima) — apenas data/hora, solar, aniversário e one-time no MVP.
- **Compartilhamento de agendamentos** entre múltiplas contas WhatsApp na mesma instalação.
- **Marketing em massa / segmentação avançada** — o foco é uso pessoal, não campanhas comerciais.
