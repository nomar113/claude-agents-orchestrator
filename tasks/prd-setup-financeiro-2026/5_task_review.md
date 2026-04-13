# Review: Task 5 - Backend -- Vincular categorias as compras

**Revisor**: AI Code Reviewer
**Data**: 2026-04-11
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementacao vincula corretamente categorias as compras (payment_notifications e purchase_invoices) via FK `category_id`, com LEFT JOIN na UNION query para expor `categoryName` nos responses. A migracao Flyway esta bem estruturada, o campo antigo `category` (texto) foi preservado para retrocompatibilidade, e todos os testes (incluindo 4 novos testes de integracao em `PurchaseCategoryIntegrationTest` e 5 em `CategoryFkMigrationIntegrationTest`) passam com sucesso. A qualidade geral e boa, com algumas observacoes menores.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `PaymentNotification.kt` | OK | 0 |
| `PurchaseInvoiceModel.kt` | OK | 0 |
| `ManualPaymentNotificationRequest.kt` | OK | 0 |
| `PaymentNotificationController.kt` | OK | 0 |
| `PaymentNotificationResponse.kt` | OK | 0 |
| `PurchaseProjection.kt` | OK | 0 |
| `PurchaseRepository.kt` | Observacao | 1 |
| `Purchase.kt` (domain) | OK | 0 |
| `PurchaseResponse.kt` | OK | 0 |
| `ListPurchasesProvider.kt` | OK | 0 |
| `PurchaseInvoiceController.kt` | Observacao | 1 |
| `V14__add_category_id_to_purchases.sql` | OK | 0 |
| `PurchaseCategoryIntegrationTest.kt` (novo) | OK | 0 |
| `CategoryFkMigrationIntegrationTest.kt` (novo) | OK | 0 |
| `CategoryControllerIntegrationTest.kt` (corrigido) | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**MINOR-1: Duplicacao de mapeamento Projection -> Purchase entre ListPurchasesProvider e PurchaseInvoiceController**

- **Arquivo**: `PurchaseInvoiceController.kt` (linhas 46-57) e `ListPurchasesProvider.kt` (linhas 15-25)
- **Descricao**: O mapeamento de `PurchaseProjection` para `Purchase` esta duplicado em dois locais. Ambos fazem exatamente a mesma conversao campo a campo. Se um novo campo for adicionado ao `PurchaseProjection`, sera necessario atualizar ambos os locais, o que e propenso a erros.
- **Sugestao**: Extrair um metodo factory `Purchase.from(projection: PurchaseProjection)` na entidade `Purchase` ou criar um extension function:

```kotlin
// Em Purchase.kt
companion object {
    fun from(projection: PurchaseProjection) = Purchase(
        id = projection.getId(),
        date = projection.getDate(),
        total = projection.getTotal(),
        merchantName = projection.getMerchantName(),
        totalItems = projection.getTotalItems(),
        description = projection.getDescription(),
        categoryName = projection.getCategoryName(),
    )
}
```

**MINOR-2: UNION vs UNION ALL na query de compras**

- **Arquivo**: `PurchaseRepository.kt` (linha 18)
- **Descricao**: A query usa `UNION` (que elimina duplicatas) em vez de `UNION ALL`. Como as duas tabelas (`payment_notifications` e `purchase_invoices`) sao fontes de dados distintas e nunca terao linhas identicas, `UNION ALL` seria mais performatico por evitar o custo de deduplicacao.
- **Sugestao**: Trocar `UNION` por `UNION ALL` para ganho de performance.

## Destaques Positivos

1. **Migracao Flyway bem estruturada**: A `V14__add_category_id_to_purchases.sql` esta limpa, com FK constraints nomeadas (`fk_pn_category`, `fk_pi_category`) e campos nullable para retrocompatibilidade.

2. **Retrocompatibilidade preservada**: O campo `category: String?` foi mantido no model `PaymentNotification` e no response, permitindo que dados antigos continuem acessiveis. A coexistencia do campo texto com a FK e uma abordagem de migracao gradual correta.

3. **Cobertura de testes abrangente**: `PurchaseCategoryIntegrationTest` cobre os 4 cenarios exigidos pela task (criacao com categoryId, listagem com categoryName, listagem sem categoria, e validacao de campo obrigatorio). `CategoryFkMigrationIntegrationTest` valida a existencia das colunas, FK, nullable e retrocompatibilidade. Excelente cobertura.

4. **Correcao preventiva no CategoryControllerIntegrationTest**: A limpeza de FKs antes de deletar categorias no `@BeforeEach` previne falhas de integridade referencial entre testes -- boa pratica de isolamento de testes.

5. **LEFT JOIN correto**: O uso de LEFT JOIN garante que compras sem categoria vinculada continuem aparecendo na listagem com `categoryName = null`, sem quebrar a retrocompatibilidade.

6. **Validacao @NotNull no request**: O `categoryId` em `ManualPaymentNotificationRequest` usa `@NotNull` corretamente, garantindo que o frontend envie a categoria ao criar compras manuais.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| Naming Conventions | OK |
| Testes | OK |
| Migracao de Banco | OK |

## Recomendacoes

1. **Eliminar duplicacao do mapeamento Projection -> Purchase** (MINOR-1): Criar um factory method em `Purchase` para centralizar a conversao e evitar divergencia futura.
2. **Considerar UNION ALL** (MINOR-2): Avaliar a troca de `UNION` por `UNION ALL` nas queries nativas para ganho de performance.

## Veredito

**APROVADO COM OBSERVACOES**. A implementacao esta correta, completa, e bem testada. Todas as subtarefas foram cumpridas: modelos JPA atualizados, request migrado de `category: String` para `categoryId: Long`, UNION query com LEFT JOIN funcionando, responses atualizados, e testes de integracao cobrindo todos os cenarios exigidos. As duas observacoes menores (duplicacao de mapeamento e UNION vs UNION ALL) sao melhorias opcionais que nao bloqueiam a entrega. A task pode seguir para a proxima etapa.
