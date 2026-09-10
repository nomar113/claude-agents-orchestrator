# Review: Task 7.0 - Desativar cadastro público no backend

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementação atende integralmente aos critérios de sucesso da Tarefa 7.0: `POST /auth/register` foi mantido mapeado (evitando um 404 genérico para builds antigos do app) mas passou a sempre responder `410 Gone` com uma mensagem explicando que a conta agora nasce da assinatura, sem depender mais de `RegisterUserUseCase`. O onboarding automático via webhook (Tarefa 5.0) continua intacto, pois `HandleKiwifyWebhookUseCase` usa `CreateUserWithPersonalGroupGateway` diretamente, sem qualquer dependência do endpoint REST removido — confirmei isso lendo o próprio use case, não apenas o resumo da task. Não sobrou nenhuma referência órfã (`RegisterRequest`, `registerUserUseCase`) no código. Rodei `./gradlew test` de forma independente contra o MySQL local e confirmei os mesmos números reportados: 615 testes, 0 falhas, 0 erros. A decisão de não anotar springdoc manualmente é coerente com o padrão real do projeto (verifiquei que nenhum outro controller usa `@Operation`/`@Tag`; `OpenApiConfig.kt` só define metadados globais da API). O único ponto que fica como observação não bloqueante é que `RegisterUserUseCase` ficou efetivamente órfão em produção (só é exercitado pelo seu próprio teste unitário) e que a representação do endpoint no doc OpenAPI auto-gerado (efeito do retorno `Nothing`) não foi verificada empiricamente.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/auth/entrypoint/rest/AuthController.kt` | OK | 0 |
| `application/auth/entrypoint/rest/request/AuthRequests.kt` | OK | 0 |
| `domain/auth/usecase/RegisterUserUseCase.kt` (não modificado) | Observação | 1 (minor) |
| `domain/auth/gateway/CreateUserWithPersonalGroupGateway.kt` (não modificado) | OK | 0 |
| `domain/billing/usecase/HandleKiwifyWebhookUseCase.kt` (não modificado, verificado) | OK | 0 |
| `application/auth/RegisterEndpointIntegrationTest.kt` (novo) | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`RegisterUserUseCase` ficou órfão em produção.**
   `src/main/kotlin/br/com/nomar/controlai/domain/auth/usecase/RegisterUserUseCase.kt`
   Após a remoção da chamada no `AuthController`, esta classe deixou de ter qualquer caller em código de produção — o único lugar que ainda a referencia é seu próprio teste unitário (`AuthUseCasesTest.kt`). A subtarefa 7.2 pedia para mantê-la "intacta... pois é reaproveitada pela Tarefa 5.0", mas na prática `HandleKiwifyWebhookUseCase` reaproveita apenas o `CreateUserWithPersonalGroupGateway` diretamente (confirmado lendo `HandleKiwifyWebhookUseCase.onboardNewCustomer`, linha 157-167), não o use case. Isso não é uma falha da implementação desta task — ela seguiu a letra da subtarefa 7.2 — mas é um resquício de código morto que vale registrar para uma limpeza futura: ou remover `RegisterUserUseCase` (e seu teste dedicado) em uma task de housekeeping, ou documentar explicitamente por que ele é mantido (ex.: possível criação manual de conta via ferramenta administrativa futura). Não bloqueia esta task porque ela cumpriu exatamente o que a subtarefa 7.2 pedia.
   *Sugestão*: abrir um item de backlog para decidir o destino de `RegisterUserUseCase`, em vez de deixá-lo goiabando sem justificativa registrada em código.

2. **Efeito do retorno `Nothing` no doc OpenAPI auto-gerado não foi verificado empiricamente.**
   `application/auth/entrypoint/rest/AuthController.kt:41-46`
   A alegação de que a mudança de assinatura do método (`fun register(): Nothing`, sem `@RequestBody`, sem `AuthResponse`) "já reflete corretamente a nova realidade no doc auto-gerado" é plausível — `Nothing` compila para `Void` em bytecode, e o `swagger-core`/springdoc trata `Void` como ausência de corpo de resposta, o que é um padrão comum em Kotlin/Spring — mas não encontrei nenhum teste que efetivamente bata em `/v3/api-docs` para confirmar isso, e não consegui subir a aplicação completa localmente para checar na prática (faltam variáveis de ambiente como `JWT_SECRET` fora do perfil de teste). Tentei validar via um teste de integração descartável batendo em `/v3/api-docs` sob `@SpringBootTest`/`@AutoConfigureMockMvc`, mas o endpoint retornou `404` nesse contexto de teste (aparentemente springdoc não é totalmente autoconfigurado nesse slice específico — um comportamento pré-existente, não introduzido por esta task). Não é um bloqueador dado o baixo risco técnico, mas registro como item a confirmar manualmente (ex.: em ambiente de staging) antes de considerar a subtarefa 7.3 100% fechada.

## Destaques Positivos

- Decisão de manter o mapeamento `@PostMapping("/register")` retornando `410 Gone` (em vez de removê-lo e deixar um `404` genérico) é a escolha correta para builds antigos do app mobile — comentário no código explica claramente o racional.
- Comentário em `HandleKiwifyWebhookUseCase.onboardNewCustomer` já deixava explícito, antes mesmo desta task, que o gateway é "the same gateway `RegisterUserUseCase` relies on" — facilitou confirmar a independência entre os dois fluxos.
- Limpeza correta de imports órfãos (`RegisterRequest`, `EmailAlreadyUsedException`, `RegisterUserUseCase`) no `AuthController`; `grep` em todo o projeto não encontrou nenhuma referência remanescente a `RegisterRequest` ou a um campo `registerUserUseCase`.
- Teste de integração novo é enxuto e cobre os três cenários relevantes: `410` com corpo válido, `410` com corpo vazio, e ausência de criação de usuário no banco (com `@AfterEach` de limpeza).
- Boa decisão pragmática de não duplicar cobertura de regressão: `KiwifyWebhookControllerIntegrationTest` já teria testes como `compra_aprovada for a brand-new email creates the account, activates the subscription...`, que exercitam exatamente o caminho de criação de conta via webhook, sem depender do endpoint removido — e o comentário no novo teste referencia essa suíte explicitamente, deixando o raciocínio rastreável.
- Decisão de não adicionar anotações springdoc manuais é bem fundamentada e não é um "atalho" — é consistente com o restante da base (nenhum outro controller do projeto usa `@Operation`/`@Tag`).
- Suíte completa reexecutada de forma independente por mim confirma exatamente os números reportados: 615 testes, 0 falhas, 0 erros.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| Logging | N/A (sem alteração de logging nesta task) |
| Testes | OK (com observação sobre cobertura de doc OpenAPI não verificada) |

## Recomendacoes

1. Abrir um item de backlog para decidir o destino de `RegisterUserUseCase` (remover ou documentar o motivo de mantê-lo), já que hoje ele não tem caller de produção.
2. Quando houver ambiente disponível com as variáveis necessárias (`JWT_SECRET`, etc.), confirmar manualmente que `/v3/api-docs` gera corretamente a entrada de `POST /auth/register` sem erro, fechando de vez a subtarefa 7.3 com evidência empírica.
3. Nenhuma ação obrigatória antes de mergear — os dois pontos acima são follow-ups, não bloqueios.

## Veredito

Aprovado com observações. Os critérios de sucesso da Tarefa 7.0 e os requisitos do Tech Spec (`Design de Implementação > Endpoints de API`) estão atendidos: o endpoint público de cadastro foi efetivamente desativado (`410 Gone`), o onboarding automático via Kiwify (Tarefa 5.0) permanece funcional e testado, não há código morto acessível via API nem referências quebradas, e a suíte de testes está 100% verde (confirmado de forma independente). As duas observações levantadas (órfão de `RegisterUserUseCase` e verificação empírica pendente do doc OpenAPI) são de baixo risco e não impedem o avanço da task; recomenda-se apenas registrá-las como follow-up.
