# Review: Task 2.0 - Gateway + Provider + Repository Method para Busca de Sugestoes

**Revisor**: AI Code Reviewer
**Data**: 2026-05-22
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementacao cobre corretamente os requisitos da task: gateway com `fun interface`, provider com conversao de tipos de data, repository com query nativa filtrando por valor exato, janela temporal +-1h, exclusao de deletadas/canceladas, e ordenacao por proximidade temporal. A compilacao passa com sucesso. Porem, ha desvios de design em relacao a tech spec e o tipo de teste implementado diverge do que a task solicitava.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/.../gateway/FindInvoiceSuggestionsGateway.kt` | OK | 0 |
| `application/.../application/FindInvoiceSuggestionsProvider.kt` | Problemas | 2 |
| `application/.../repository/PaymentNotificationRepository.kt` | OK | 0 |
| `test/.../FindInvoiceSuggestionsProviderTest.kt` | Problemas | 2 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**[M1] Provider assume responsabilidade do UseCase (desvio de arquitetura)**
- **Arquivo**: `FindInvoiceSuggestionsProvider.kt`, linhas 16-33
- **Descricao**: O Provider busca o invoice pelo `purchaseInvoiceRepository`, extrai o `total`, calcula a janela temporal e chama o repository. Segundo a tech spec, essa orquestracao (buscar invoice, validar existencia) deveria ser responsabilidade do `FindInvoiceSuggestionsUseCase` (task 3). O gateway recebe apenas `invoiceId` e faz tudo internamente, o que mistura orquestracao com acesso a dados.
- **Impacto**: Quando a task 3 (UseCase) for implementada, havera duplicacao de logica — o UseCase tambem buscara o invoice. Alem disso, o Provider injeta `PurchaseInvoiceRepository`, criando uma dependencia cross-domain (invoice repository dentro do modulo de payment_notification).
- **Sugestao**: Considerar refatorar o gateway para receber os parametros ja resolvidos (`amount`, `startDate`, `endDate`, `invoiceDate`) em vez do `invoiceId`. A assinatura ficaria:
```kotlin
fun interface FindInvoiceSuggestionsGateway {
    fun execute(
        amount: BigDecimal,
        startDate: LocalDateTime,
        endDate: LocalDateTime,
        invoiceDate: LocalDateTime,
    ): Result<List<PaymentNotification>>
}
```
Dessa forma, o UseCase fica responsavel por buscar o invoice e montar os parametros, e o Provider fica responsavel apenas por delegar ao repository. Isso respeita a separacao de responsabilidades da tech spec.
- **Nota**: Se a decisao foi intencional para simplificar a integracao futura, e aceitavel manter assim desde que a task 3 nao duplique a logica. Documentar a decisao.

**[M2] Testes sao de integracao (`@SpringBootTest`), nao unitarios como a task solicitou**
- **Arquivo**: `FindInvoiceSuggestionsProviderTest.kt`, linha 20
- **Descricao**: A task explicitamente pede "testes unitarios para o provider (mock do repository)" na subtarefa 2.4 e na secao de testes. A implementacao usa `@SpringBootTest` com `@Autowired`, o que configura testes de integracao que dependem de banco de dados real.
- **Impacto**: Os testes nao executam sem um banco de dados local configurado (conforme mencionado no contexto da task). Isso significa que efetivamente nao ha testes executaveis validando o comportamento do provider.
- **Sugestao**: Criar testes unitarios com mocks (Mockito/MockK) para o provider. Exemplo:
```kotlin
@ExtendWith(MockitoExtension::class)
class FindInvoiceSuggestionsProviderTest {
    @Mock lateinit var purchaseInvoiceRepository: PurchaseInvoiceRepository
    @Mock lateinit var paymentNotificationRepository: PaymentNotificationRepository
    @InjectMocks lateinit var provider: FindInvoiceSuggestionsProvider

    @Test
    fun `should return matching notifications`() {
        val invoice = PurchaseInvoiceModel(id = 1L, date = OffsetDateTime.now(), ...)
        whenever(purchaseInvoiceRepository.findById(1L)).thenReturn(Optional.of(invoice))
        whenever(paymentNotificationRepository.findSuggestionsByAmountAndDateRange(any(), any(), any(), any()))
            .thenReturn(listOf(/* mock notifications */))

        val result = provider.execute(1L)
        assertTrue(result.isSuccess)
    }
}
```

### Problemas Minor

**[m1] Redundancia da clausula `deleted_at IS NULL` na query nativa**
- **Arquivo**: `PaymentNotificationRepository.kt`, linha 109
- **Descricao**: A entidade `PaymentNotification` ja possui `@SQLRestriction("deleted_at IS NULL")`. Porem, `@SQLRestriction` aplica-se apenas a queries JPQL/HQL geradas pelo Hibernate, e NAO a queries nativas. Portanto, a clausula explicita na query nativa esta correta e necessaria. Nao e redundante — e defensivo.
- **Veredito**: Sem acao necessaria. Manter como esta.

**[m2] `toLocalDateTime()` sem timezone explicito**
- **Arquivo**: `FindInvoiceSuggestionsProvider.kt`, linha 23
- **Descricao**: `invoice.date.toLocalDateTime()` converte `OffsetDateTime` para `LocalDateTime` descartando a informacao de timezone. O resultado depende do offset presente no `OffsetDateTime` original (ex: `-03:00`). A task e a tech spec mencionam esse risco. Embora funcione corretamente quando o servidor e o offset do invoice estao na mesma timezone, em cenarios com timezones diferentes poderia gerar janelas temporais incorretas.
- **Sugestao**: Considerar usar conversao explicita com timezone do sistema:
```kotlin
val invoiceDateLocal = invoice.date
    .atZoneSameInstant(ZoneId.systemDefault())
    .toLocalDateTime()
```

## Destaques Positivos

1. **Padrao `fun interface` seguido corretamente** — consistente com os 30+ gateways existentes no projeto.
2. **Query nativa bem construida** — filtra por valor exato, janela temporal, exclui deletadas e canceladas, e ordena por proximidade temporal usando `ABS(TIMESTAMPDIFF(SECOND, ...))`.
3. **Omissao intencional da clausula NOT IN** — corretamente omitida conforme especificado na task, ja que a tabela de associacao ainda nao existe.
4. **Tratamento de erros com `runCatching` e `Result`** — consistente com o padrao do projeto (ex: `CancelPaymentNotificationProvider`).
5. **Validacao de `invoice.total` nullable** — o provider verifica se o total e null antes de prosseguir, evitando NPE.
6. **Compilacao limpa** — `compileKotlin` e `compileTestKotlin` passam sem warnings.
7. **Cenarios de teste abrangentes** — os 6 testes cobrem match dentro da janela, exclusao fora da janela, exclusao por valor diferente, exclusao de canceladas, lista vazia, e invoice inexistente.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| Arquitetura (Gateway/Provider) | Problemas |
| Naming Conventions | OK |
| Testes | Problemas |

## Recomendacoes

1. **[Prioridade Alta]** Criar testes unitarios com mocks para o provider, conforme solicitado na task. Os testes de integracao podem ser mantidos como bonus, mas nao substituem os unitarios.
2. **[Prioridade Media]** Avaliar se a responsabilidade de buscar o invoice deve permanecer no Provider ou ser movida para o UseCase (task 3). Se mantida no Provider, ajustar a task 3 para nao duplicar a logica.
3. **[Prioridade Baixa]** Considerar conversao de timezone explicita no `toLocalDateTime()` para robustez futura.

## Veredito

A implementacao atende os requisitos funcionais da task — a query esta correta, os filtros sao adequados, e o padrao de gateway/provider e seguido. Os dois problemas major sao: (1) o Provider esta assumindo responsabilidades que a tech spec atribui ao UseCase, o que pode causar duplicacao na task 3; e (2) os testes sao de integracao e nao executam localmente, quando a task pedia testes unitarios com mocks. Recomendo corrigir pelo menos o item de testes unitarios antes de prosseguir, ja que validacao automatizada do comportamento e essencial. O desvio de arquitetura pode ser resolvido na task 3 com um ajuste na assinatura do gateway.
