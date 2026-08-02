# Review: Task 2.0 - Backend - Filtro por mes, range de datas e paginacao no endpoint de Invoices

**Revisor**: AI Code Reviewer
**Data**: 2026-05-01
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task implementou com sucesso os filtros de mes, range de datas e paginacao no endpoint `GET /purchases/invoices`. A logica de resolucao de datas (precedencia startDate/endDate sobre month, default mes corrente) esta correta e bem testada. Os 9 testes de integracao cobrem todos os cenarios exigidos e passam com sucesso. Ha observacoes menores sobre tipagem do retorno e robustez de parametros.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| PurchaseInvoiceController.kt | Observacoes | 2 |
| PurchaseRepository.kt | OK | 0 |
| PurchaseInvoiceFilterIntegrationTest.kt | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1 - Retorno `Map<String, Any>` em vez de tipo seguro**
- **Arquivo**: `PurchaseInvoiceController.kt`, linha 54
- **Descricao**: O metodo `listInvoices()` retorna `Map<String, Any>`, perdendo type-safety. A Tech Spec define que o retorno deve ser `Page<PurchaseResponse>` (ou equivalente tipado). O `Map<String, Any>` funciona, mas impede que o compilador valide a estrutura da resposta e dificulta a geracao automatica de documentacao (Swagger/OpenAPI).
- **Correcao sugerida**: Criar um data class tipado para a resposta paginada:
```kotlin
data class PagedResponse<T>(
    val content: List<T>,
    val totalElements: Long,
    val totalPages: Int,
    val number: Int,
    val size: Int,
    val last: Boolean,
)
```
Ou utilizar o `PageImpl` do Spring Data para retornar `Page<PurchaseResponse>` diretamente, que ja serializa no formato esperado.

### Problemas Minor

**m1 - Parametros de data como String em vez de tipos do Spring**
- **Arquivo**: `PurchaseInvoiceController.kt`, linhas 49-51
- **Descricao**: Os parametros `month`, `startDate` e `endDate` sao recebidos como `String?` e parseados manualmente com try/catch. O Spring suporta `@DateTimeFormat` para fazer o parse automaticamente, delegando a validacao de formato ao framework.
- **Correcao sugerida**:
```kotlin
@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") startDate: LocalDate? = null,
@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") endDate: LocalDate? = null,
```
Para `month` (YearMonth), o Spring tambem suporta conversao automatica com um `Converter<String, YearMonth>` registrado. Isso eliminaria os blocos try/catch manuais em `resolveDateRange()`.

**m2 - Ausencia de validacao de limites em `page` e `size`**
- **Arquivo**: `PurchaseInvoiceController.kt`, linhas 52-53
- **Descricao**: Nao ha validacao de que `page >= 0` e `size > 0`. Um `size=0` causaria divisao por zero na linha 72 (protegido pela condicao `if (size > 0)`, mas retornaria `totalPages=0` para qualquer input). Um `size` negativo resultaria em comportamento inesperado no SQL LIMIT. Um `page` negativo geraria offset negativo.
- **Correcao sugerida**: Adicionar validacao com `@Min` ou early return:
```kotlin
@RequestParam(defaultValue = "0") @Min(0) page: Int,
@RequestParam(defaultValue = "50") @Min(1) @Max(100) size: Int,
```

## Destaques Positivos

1. **Resolucao de datas bem estruturada**: O metodo `resolveDateRange()` encapsula toda a logica de precedencia (startDate/endDate > month > mes corrente) de forma clara e coesa.

2. **endDate inclusivo tratado corretamente**: A conversao `end.plusDays(1).atStartOfDay()` garante que registros do dia final sejam incluidos, usando `<` na query SQL. Abordagem correta e consistente.

3. **Cobertura de testes abrangente**: Os 9 testes cobrem todos os cenarios exigidos pela task: filtragem por mes, range de datas, precedencia, default mes corrente, validacao 400, paginacao, soft delete e ordenacao DESC.

4. **Testes com setup limpo**: O `@BeforeEach` com cleanup das tabelas dependentes garante isolamento entre testes.

5. **Consistencia com o padrao existente**: A nova query segue o mesmo padrao das queries existentes no `PurchaseRepository` (native SQL, projection interface).

6. **Query count separada**: A `countInvoicesByDateRange` permite calcular paginacao de forma eficiente sem carregar todos os registros.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | Observacoes |
| REST/HTTP | Observacoes |
| Testes | OK |

## Recomendacoes

1. **[Major]** Substituir `Map<String, Any>` por um tipo seguro para a resposta paginada, alinhando com a Tech Spec que especifica `Page<PurchaseResponse>`.
2. **[Minor]** Considerar usar `@DateTimeFormat` do Spring para parse automatico dos parametros de data, reduzindo codigo manual de validacao.
3. **[Minor]** Adicionar validacao de limites para `page` e `size` com `@Min`/`@Max` para prevenir inputs invalidos.

## Veredito

A implementacao atende todos os requisitos funcionais da task e da Tech Spec. A logica de filtragem, paginacao e resolucao de datas esta correta e bem testada. O problema major (M1) sobre o tipo de retorno `Map<String, Any>` nao bloqueia o funcionamento, mas diverge da Tech Spec e reduz a seguranca de tipos. Recomenda-se corrigir em iteracao futura antes de integrar com o frontend. Os problemas minor sao melhorias de robustez que podem ser endereçadas oportunisticamente.

**Proximo passo**: Seguir para a proxima task do PRD (frontend ou outra task backend). Considerar resolver M1 quando for fazer a integracao frontend, pois o contrato da API sera consumido diretamente.
