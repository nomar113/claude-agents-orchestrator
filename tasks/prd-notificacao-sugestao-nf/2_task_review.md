# Review: Task 2.0 - Backend — Provider de sugestões de NF

**Revisor**: AI Code Reviewer
**Data**: 2026-05-24
**Arquivo da task**: 2_task.md
**Status**: APROVADO

---

## Resumo

A implementação criou o `FindNotificationInvoiceSuggestionsProvider` de forma limpa e concisa, seguindo rigorosamente o padrão `runCatching` adotado no projeto. O provider realiza exatamente o que a tarefa exige: busca a notificação, delega a query de matching ao repository (implementado na Tarefa 1.0) e mapeia os resultados para `InvoiceSuggestionResponse`. A suíte de testes é abrangente, cobre todos os cenários obrigatórios e usa mocks corretamente. O código é de alta qualidade e está pronto para produção.

---

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `application/payments_notification/application/FindNotificationInvoiceSuggestionsProvider.kt` | OK | 0 |
| `test/.../payments_notification/FindNotificationInvoiceSuggestionsProviderTest.kt` | OK | 0 |

---

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**[MINOR-01]** Divergência de pacote entre local real e referência da task

- **Arquivo**: `FindNotificationInvoiceSuggestionsProvider.kt` — linha 1
- **Descrição**: O provider foi criado no subpacote `application` (caminho completo: `payments_notification/application/`), ao passo que a task e o arquivo de referência (`SearchNotificationsProvider.kt`) residem em `purchases_invoices/application/`. Não causa erro funcional, pois é o local correto para um provider de `payments_notification`, mas a task menciona como referência de path `provider/FindNotificationInvoiceSuggestionsProvider.kt` (usando `provider` em vez de `application`). A escolha do pacote `application` está alinhada com os demais providers do módulo e é a decisão correta; apenas o template da task usa nomenclatura inconsistente.
- **Impacto**: Nulo em runtime. Apenas inconsistência documental.

**[MINOR-02]** Teste de ordenação não valida a ordem com IDs fora de sequência (cobre apenas o caminho feliz da ordenação)

- **Arquivo**: `FindNotificationInvoiceSuggestionsProviderTest.kt` — linhas 80-101
- **Descrição**: O teste `should return mapped suggestions ordered by date proximity` injeta os invoices já na ordem correta de proximidade (`dateDeltaMinutes = 5, 30, 120`) e o mock do repository devolve a lista nessa mesma sequência. Isso significa que o teste não valida se o **provider** realmente ordena os resultados — ele valida apenas que o mapping está correto. A responsabilidade de ordenação, conforme a implementação, é delegada ao banco via `ORDER BY` na query nativa do repository. O teste está correto para esse design (o provider confia na ordenação do repository), mas um comentário explicando esse contrato tornaria a intenção mais clara para futuros mantenedores.
- **Sugestão**: Adicionar um cenário com os invoices intencionalmente fora de ordem no mock para documentar que a ordenação é responsabilidade do repositório, ou adicionar um comentário:

```kotlin
// Ordering is enforced by PurchaseInvoiceRepository.findByTotalAndNotAssociated
// via ORDER BY ABS(TIMESTAMPDIFF(...)) — provider trusts repository contract.
@Test
fun `should return mapped suggestions ordered by date proximity`() { ... }
```

---

## Destaques Positivos

- **Implementação minimalista e correta**: O provider tem apenas 25 linhas, sem nenhum código desnecessário. Delega responsabilidades corretamente — a query fica no repository, o mapeamento no DTO companion object.
- **Uso idiomático de `runCatching`**: Consistente com `AssociateInvoiceProvider`, `SearchNotificationsProvider` e demais providers do projeto. O `runCatching` captura exceções da camada de persistência sem a necessidade de try/catch explícito.
- **`orElseThrow` com mensagem descritiva**: A mensagem de erro `"PaymentNotification not found: $notificationId"` é informativa e facilita debugging.
- **Testes de qualidade**: Quatro cenários bem definidos, cada um com responsabilidade única. O uso de `mock()` sem `@ExtendWith` (Mockito inline) é moderno e elimina boilerplate de anotação.
- **Factories de teste bem estruturadas**: `createNotification()` e `createInvoice()` com parâmetros default tornam os testes legíveis e fáceis de adaptar.
- **Assertions completas no cenário de mapeamento**: O teste valida `id`, `total`, `cnpj`, `merchantName` e `totalItems` — cobertura satisfatória dos campos do DTO.
- **Cenário de exceção de repositório**: O quarto teste (`should return failure when repository throws exception`) cobre falhas inesperadas da camada de dados, o que vai além dos critérios mínimos da task.

---

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (Clean Code) | OK |
| Kotlin / Spring Boot | OK |
| Nomenclatura (camelCase, PascalCase) | OK |
| Funcoes com verbo e responsabilidade unica | OK |
| Maximos de linhas (metodo < 50, classe < 300) | OK |
| Sem magic numbers | OK |
| Sem comentarios desnecessarios | OK |
| Testes | OK |

---

## Recomendacoes

1. **(MINOR-02 — baixa prioridade)** Considerar adicionar um comentário ou cenário de teste inverso para documentar explicitamente que a ordenação dos resultados é contrato do repository, não do provider. Evita confusão futura quando outro desenvolvedor ler o teste e achar que a ausência de `sortedBy` no provider é um bug.

---

## Veredito

A implementação está aprovada sem ressalvas bloqueantes. O provider é simples, correto e consistente com os padrões estabelecidos no projeto. Os dois pontos minor identificados não afetam funcionalidade nem qualidade do código em produção — são observações de documentação/teste.

Pode-se prosseguir para a **Tarefa 3.0** (controller endpoints e extensão do `PaymentNotificationResponse`).
