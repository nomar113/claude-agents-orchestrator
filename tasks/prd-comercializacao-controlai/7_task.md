# Tarefa 7.0: Desativar cadastro público no backend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Remover a possibilidade de qualquer pessoa criar uma conta gratuita diretamente via `POST /auth/register`, já que a partir desta funcionalidade toda conta nova deve nascer de uma compra aprovada na Kiwify (Tarefa 5.0) ou já existir como grandfathered. Depende conceitualmente das Tarefas 4.0/5.0 estarem no ar (para não deixar o sistema sem nenhuma forma de criar conta nova), mas pode ser implementada em paralelo e ativada por último.

<skills>
### Conformidade com Skills Padrões

- `kotlin-springboot` — remoção de endpoint seguindo o padrão de resposta HTTP já usado no projeto (`ResponseStatusException`).
</skills>

<requirements>
- Decisão da clarificação de techspec: desativar registro público no app (backend + frontend).
- Tech Spec `Design de Implementação > Endpoints de API`: `POST /auth/register` é removido ou passa a responder `410 Gone`.
</requirements>

## Subtarefas

- [ ] 7.1 Decidir e implementar a forma de desativação: remover o mapeamento `@PostMapping("/register")` do `AuthController` ou mantê-lo retornando `410 Gone` com mensagem explicando que contas são criadas via assinatura (ver PRD para o texto/tom adequado).
- [ ] 7.2 Manter `RegisterUserUseCase` e `CreateUserWithPersonalGroupGateway` intactos internamente (são reaproveitados pela Tarefa 5.0), apenas removendo a exposição pública via REST.
- [ ] 7.3 Atualizar a documentação OpenAPI/Swagger (`springdoc`) para refletir a remoção do endpoint.

## Detalhes de Implementação

Ver Tech Spec `Design de Implementação > Endpoints de API`. Esta tarefa é deliberadamente pequena e isolada para minimizar o risco de quebrar o fluxo de onboarding automático da Tarefa 5.0, que depende do mesmo gateway internamente.

## Critérios de Sucesso

- `POST /auth/register` não cria mais contas livremente (removido ou `410 Gone`).
- O onboarding automático via webhook (Tarefa 5.0) continua funcionando normalmente, pois usa o gateway diretamente, não o endpoint REST.

## Testes da Tarefa

- [ ] Teste de integração confirmando que `POST /auth/register` não cria mais um usuário (retorna `404`/`410`, conforme decisão de 7.1).
- [ ] Teste de regressão confirmando que o fluxo de onboarding automático (Tarefa 5.0) continua criando contas normalmente após esta mudança.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/auth/entrypoint/rest/AuthController.kt` (modificado)
- Depende de: Tarefa 5.0 (para não deixar o onboarding quebrado ao remover o endpoint público)
