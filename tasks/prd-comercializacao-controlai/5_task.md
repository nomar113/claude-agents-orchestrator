# Tarefa 5.0: Onboarding automático de conta pós-compra

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Conectar o `HandleKiwifyWebhookUseCase` (Tarefa 4.0) à criação automática de conta: quando um evento `compra_aprovada` chega para um e-mail que ainda não existe no ControlAI, criar o usuário e o grupo pessoal (reaproveitando `CreateUserWithPersonalGroupGateway`) e enviar um e-mail para o comprador definir a senha, reaproveitando o token de "esqueci minha senha" já existente. Quando o e-mail já existe (conta grandfathered ou compra repetida), a assinatura é apenas vinculada ao grupo já existente, sem criar conta duplicada.

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — reaproveitamento de gateways existentes em vez de duplicar lógica de criação de usuário.
</skills>

<requirements>
- Decisão da clarificação de techspec: conta criada automaticamente no webhook (não por vínculo manual de e-mail).
- Tech Spec `Decisões Principais`: reaproveitar `CreateUserWithPersonalGroupGateway` e o token de "esqueci minha senha" — não duplicar fluxo de criação de conta ou de e-mail.
- Tech Spec `Riscos Conhecidos`: colisão de e-mail entre autocriação via webhook e conta já existente deve ser tratada buscando por e-mail antes de criar (mesmo padrão do `RegisterUserUseCase`).
</requirements>

## Subtarefas

- [ ] 5.1 No `HandleKiwifyWebhookUseCase`, para eventos `compra_aprovada`: buscar usuário por e-mail (`FindUserByEmailGateway`); se não existir, criar via `CreateUserWithPersonalGroupGateway` usando nome/e-mail vindos do payload da Kiwify.
- [ ] 5.2 Vincular/atualizar a `Subscription` ao `group_id` do usuário encontrado ou recém-criado (via `UpsertSubscriptionGateway` da Tarefa 3.0).
- [ ] 5.3 Para usuários recém-criados, gerar um token de definição de senha reaproveitando `CreatePasswordResetTokenGateway` e enviar e-mail via `EmailGateway`/`ResendEmailClient`, com um template "sua conta ControlAI foi criada — defina sua senha" (variação do template de reset de senha já existente).
- [ ] 5.4 Para usuários já existentes (grandfathered ou compra repetida), pular a criação de conta e o envio do e-mail de "defina sua senha" (enviar, no máximo, uma confirmação de renovação/ativação, se aplicável).

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema > Visão Geral dos Componentes` (reaproveitamento de `auth`) e `Pontos de Integração` (Resend). Referenciar `domain/auth/usecase/RegisterUserUseCase.kt` e `domain/auth/usecase/ForgotPasswordUseCase.kt` como padrões de reaproveitamento.

## Critérios de Sucesso

- Um evento `compra_aprovada` para um e-mail novo resulta em: usuário + grupo pessoal criados, assinatura vinculada, e e-mail de definição de senha enviado.
- Um evento `compra_aprovada` para um e-mail já existente (grandfathered) resulta apenas na atualização/confirmação da assinatura, sem criar conta duplicada nem violar a constraint `uk_users_email`.

## Testes da Tarefa

- [ ] Teste de unidade: e-mail novo → cria usuário + grupo + assinatura + dispara e-mail.
- [ ] Teste de unidade: e-mail já existente → não cria usuário duplicado, apenas atualiza a assinatura do grupo já existente.
- [ ] Teste de integração (H2) do fluxo completo webhook → banco, verificando que a constraint de e-mail único nunca é violada mesmo em compras repetidas.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/domain/billing/usecase/HandleKiwifyWebhookUseCase.kt` (modificado, da Tarefa 4.0)
- `src/main/kotlin/br/com/nomar/controlai/application/auth/application/ResendEmailClient.kt` (modificado — novo template)
- `src/main/kotlin/br/com/nomar/controlai/domain/auth/gateway/EmailGateway.kt` (possível novo método)
- Depende de: Tarefas 3.0 e 4.0
