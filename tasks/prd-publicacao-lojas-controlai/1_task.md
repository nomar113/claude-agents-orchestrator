# Tarefa 1.0: Seed da conta de revisor das lojas (backend)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar, via migração Flyway, uma conta fixa de revisor (usuário + grupo + assinatura ativa + dados de exemplo não sensíveis) no backend do ControlAI, para ser usada como credencial de acesso pelo time de revisão da Apple e do Google durante a análise de publicação — já que o cadastro público está desativado (PRD "Comercialização do ControlAI").

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — convenções de migração Flyway e camada de persistência do backend.
- `clean-code` — a migração deve seguir o mesmo padrão de dado já usado no grandfathering (`V39`), sem introduzir lógica de aplicação nova.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 2. Conformidade com as diretrizes de cada loja`, requisito 6: deve existir uma conta de demonstração para o time de revisão acessar as telas internas sem dados financeiros reais.
- Tech Spec `Arquitetura do Sistema` e `Modelos de Dados`: migração `V40`, reaproveitando as tabelas já existentes de `users`/`groups`/`subscriptions` do bounded context `billing`.
</requirements>

## Subtarefas

- [x] 1.1 Criar a migração `V40__seed_store_reviewer_account.sql`: grupo dedicado, usuário com e-mail e senha fixos (hash bcrypt gerado previamente), e uma linha em `subscriptions` com `status = ACTIVE`.
- [x] 1.2 Popular dados de exemplo não sensíveis para o grupo do revisor (1 cartão fictício, 1–2 compras), suficientes para navegar pelas telas de dashboard, cartões, faturas e orçamento sem estados vazios.
- [x] 1.3 Documentar as credenciais da conta seed em local seguro (não commitado em texto claro no repositório) para uso na Tarefa 5.0 e 6.0 (App Review Information / App content). — Credenciais entregues ao usuário fora do repositório (chat); não persistidas em nenhum arquivo.
- [x] 1.4 Validar, em ambiente de teste local, que a conta seed autentica normalmente e não recebe `402` do `SubscriptionGuardFilter`. — Validado via `StoreReviewerAccountSeedIntegrationTest` (GET /purchases retorna 200) e verificação isolada de que o hash BCrypt gravado bate com a senha real via `PasswordEncoder` do Spring.

## Detalhes de Implementação

Ver Tech Spec `Design de Implementação > Modelos de Dados` e `Sequenciamento de Desenvolvimento` (etapa 1). Reaproveitar o padrão de dado do backfill de grandfathering em `V39__create_billing_tables.sql`, sem lógica condicional nova no caminho de autorização.

## Critérios de Sucesso

- Conta de revisor existe no ambiente de produção, com assinatura `ACTIVE` e dados de exemplo navegáveis.
- Credenciais documentadas e prontas para uso nas Tarefas 5.0 e 6.0.
- Nenhuma alteração de comportamento para usuários reais (grupos existentes não são afetados pela migração).

## Testes da Tarefa

- [x] Teste de integração: migração `V40` aplicada em banco de teste (docker-compose MySQL) sem erros e sem afetar dados existentes. — `./gradlew test` completo (623 testes) passa após a migração.
- [x] Teste de integração: login com a conta seed retorna `200` em uma rota protegida (reaproveitando fixture de `SubscriptionGuardFilter` já testada no PRD comercialização). — `StoreReviewerAccountSeedIntegrationTest`.
- [ ] Teste manual: navegação completa pelas telas principais com a conta seed, confirmando ausência de estados vazios. — Não executado nesta tarefa: exige o app mobile/web rodando contra um backend com `V40` aplicada e `JWT_SECRET` de ambiente real (não disponível neste sandbox local). Coberto pela verificação de App Review Information nas Tarefas 5.0/6.0.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai/src/main/resources/db/migration/V40__seed_store_reviewer_account.sql` (novo).
- Referência: `controlai/src/main/resources/db/migration/V39__create_billing_tables.sql`.
- Referência: testes de integração existentes do `SubscriptionGuardFilter` (PRD comercialização).
