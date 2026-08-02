# PRD — Login e Autenticação (ControlAI)

## Visao Geral

Hoje o ControlAI (backend `controlai` e app `controlai-frontend`) não possui nenhum mecanismo de autenticação: a API é totalmente aberta e qualquer pessoa com acesso à URL consegue ler e alterar dados financeiros sensíveis (cartões, compras, faturas, orçamentos). Além disso, o app foi construído para um único conjunto de dados, o que impede que outras pessoas o utilizem.

Esta funcionalidade introduz **contas de usuário com login**, protegendo todos os dados por autenticação e preparando o produto para múltiplos usuários. Cada usuário passa a ter seus próprios dados, com a possibilidade de **compartilhar dados com outra conta** (conceito de grupo/família) — atendendo ao caso real do casal que gerencia as finanças em conjunto, cada um com seu próprio login.

O valor é duplo: **segurança** (dados financeiros deixam de ficar expostos) e **escalabilidade de produto** (o app passa a suportar qualquer número de usuários com dados isolados).

## Objetivos

- **Proteção total da API**: 100% dos endpoints de dados exigem autenticação; requisições não autenticadas são rejeitadas.
- **Cadastro e login funcionais** por dois métodos: e-mail/senha e conta Google.
- **Sessão persistente**: após o primeiro login, o usuário permanece autenticado sem precisar digitar a senha novamente, com desbloqueio por biometria (Face ID/Touch ID) ao abrir o app.
- **Isolamento de dados**: um usuário nunca vê dados de outro, exceto quando houver compartilhamento explícito.
- **Compartilhamento entre contas**: dois usuários (ex.: casal) conseguem visualizar e gerenciar o mesmo conjunto de dados.
- **Continuidade**: os dados existentes do casal permanecem acessíveis para ambos após a migração, sem perda de informação.

Métricas de sucesso:

- 0 endpoints de dados acessíveis sem token válido (verificável por teste automatizado).
- Login com sucesso nos dois métodos em iOS (Capacitor) e web.
- Casal acessando os mesmos dados a partir de duas contas distintas.

## Historias de Usuario

**Persona primária — Ramon (administrador das finanças do casal):**

- Como usuário existente, quero criar minha conta e manter acesso a todos os dados já cadastrados, para não perder o histórico financeiro.
- Como usuário, quero entrar com e-mail e senha ou com minha conta Google, para escolher o método mais conveniente.
- Como usuário, quero permanecer logado e desbloquear o app com Face ID, para acessar minhas finanças rapidamente e com segurança.
- Como usuário, quero convidar minha esposa para compartilhar meus dados, para que ambos gerenciem as finanças do casal.

**Persona secundária — Esposa (co-gestora das finanças):**

- Como usuária convidada, quero criar minha própria conta e aceitar o compartilhamento, para ver e editar os mesmos cartões, compras e orçamentos que meu marido.

**Persona terciária — Novo usuário:**

- Como novo usuário, quero me cadastrar e começar com dados vazios e isolados, para usar o app com privacidade.

**Fluxos de manutenção de conta:**

- Como usuário, quero recuperar minha senha por e-mail quando esquecê-la, para não perder acesso à conta.
- Como usuário logado, quero alterar minha senha, para manter minha conta segura.
- Como usuário, quero sair da conta (logout), para usar o app em outro dispositivo ou trocar de conta.

**Casos extremos:**

- Usuário que se cadastrou com Google tenta entrar com e-mail/senha (e vice-versa) usando o mesmo e-mail.
- Dispositivo sem biometria configurada ou biometria falha repetidamente.
- Sessão revogada/expirada no servidor enquanto o app está aberto.

## Funcionalidades Principais

### 1. Cadastro de usuário

Permite criar conta nova com nome, e-mail e senha, ou diretamente com a conta Google. Importante porque abre o app para múltiplos usuários.

- **RF-1.1**: O sistema deve permitir cadastro com nome, e-mail e senha.
- **RF-1.2**: O sistema deve permitir cadastro/login com conta Google em um único fluxo (se a conta não existe, é criada).
- **RF-1.3**: O sistema deve rejeitar cadastro com e-mail já utilizado, informando o usuário.
- **RF-1.4**: O sistema deve exigir senha com no mínimo 8 caracteres.
- **RF-1.5**: Um mesmo e-mail deve corresponder a uma única conta, independentemente do método de login usado.

### 2. Login e proteção da API

Autentica o usuário e bloqueia todo acesso não autenticado aos dados.

- **RF-2.1**: O sistema deve permitir login com e-mail/senha e com Google.
- **RF-2.2**: Todos os endpoints de dados da API devem exigir autenticação; requisições sem credencial válida devem ser rejeitadas com erro apropriado.
- **RF-2.3**: Mensagens de erro de login não devem revelar se o e-mail existe na base.
- **RF-2.4**: O app deve redirecionar para a tela de login qualquer acesso não autenticado.

### 3. Sessão persistente com Face ID

Mantém o usuário logado entre usos do app, protegendo a abertura com biometria.

- **RF-3.1**: Após login, a sessão deve permanecer válida sem novo login manual, sendo renovada automaticamente.
- **RF-3.2**: Ao abrir o app com sessão ativa, o sistema deve exigir desbloqueio por Face ID/Touch ID antes de exibir dados.
- **RF-3.3**: Em dispositivos sem biometria disponível (ex.: web), o app deve permitir acesso direto com a sessão válida.
- **RF-3.4**: Se a biometria falhar ou for cancelada, o app deve oferecer login por senha como alternativa.
- **RF-3.5**: Sessões revogadas ou expiradas devem levar o usuário à tela de login.

### 4. Isolamento e compartilhamento de dados

Cada conta enxerga apenas seus dados; contas podem compartilhar dados entre si (grupo/família).

- **RF-4.1**: Todos os dados (cartões, compras, faturas, categorias, orçamentos, notificações) devem pertencer a um usuário ou grupo, e só podem ser lidos/alterados por quem tem acesso.
- **RF-4.2**: Um usuário deve poder convidar outro (por e-mail) para compartilhar seus dados.
- **RF-4.3**: O convidado deve poder aceitar ou recusar o convite; ao aceitar, ambos passam a ver e gerenciar o mesmo conjunto de dados.
- **RF-4.4**: O compartilhamento deve poder ser desfeito por qualquer um dos participantes.
- **RF-4.5**: Os dados existentes hoje na base devem ser migrados para a conta do Ramon e ficar acessíveis à conta da esposa via compartilhamento, sem perda de dados.

### 5. Manutenção de conta

Fluxos de autoatendimento para senha e sessão.

- **RF-5.1**: O sistema deve oferecer "esqueci minha senha" com envio de link/código de redefinição por e-mail, com validade limitada.
- **RF-5.2**: O usuário logado deve poder alterar sua senha informando a senha atual.
- **RF-5.3**: O usuário deve poder fazer logout, encerrando a sessão no dispositivo.
- **RF-5.4**: Contas criadas apenas com Google devem poder definir uma senha via fluxo de redefinição.

## Experiencia do Usuario

- **Tela de login** como porta de entrada do app: campos de e-mail/senha, botão "Entrar com Google", links para cadastro e recuperação de senha.
- **Tela de cadastro** simples (nome, e-mail, senha) com validação inline dos campos.
- **Desbloqueio biométrico** imediato ao abrir o app logado — sem telas intermediárias quando a biometria funciona.
- **Convite de compartilhamento** acessível a partir de uma tela de perfil/conta, onde também ficam alterar senha e logout.
- Feedback claro de erros (credenciais inválidas, e-mail em uso, convite pendente) em português.
- Visual consistente com o restante do app (Ionic, padrões iOS).
- **Acessibilidade**: labels em todos os campos, navegação por leitor de tela, contraste adequado, área de toque mínima nos botões.

## Restricoes Tecnicas de Alto Nivel

- **Integração com Google** para login social, funcionando no iOS (app Capacitor) e na web.
- **Envio de e-mail transacional** (recuperação de senha e convites) — nova dependência externa a definir na Tech Spec.
- **Biometria via recursos nativos do iOS** (Face ID/Touch ID) através do Capacitor.
- **Dados sensíveis**: senhas nunca armazenadas em texto plano; credenciais/tokens armazenados de forma segura no dispositivo; dados financeiros trafegam apenas autenticados e sob HTTPS.
- **Compatibilidade**: a migração dos dados existentes é obrigatória e não pode causar perda de dados nem downtime prolongado.
- O backend permanece em Kotlin/Spring Boot e o frontend em Ionic/React — a solução deve se integrar às stacks atuais.

## Fora de Escopo

- Verificação obrigatória de e-mail no cadastro.
- Autenticação de dois fatores (2FA).
- Outros provedores sociais além do Google (Apple, Facebook etc.) — observação: a Apple pode exigir "Sign in with Apple" para publicação na App Store quando há login social; fica registrado como consideração futura.
- Grupos com mais de 2 participantes ou papéis/permissões diferenciados dentro do grupo (todos com acesso total).
- Compartilhamento parcial (escolher quais dados compartilhar) — o compartilhamento é do conjunto completo de dados.
- Gestão de múltiplos dispositivos/sessões (listar e revogar sessões individualmente).
- Exclusão de conta pelo próprio usuário (LGPD self-service) — consideração futura.
- Painel administrativo de usuários.
