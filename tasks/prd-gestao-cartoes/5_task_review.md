# Review: Task 5 - Backend -- Endpoint de resumo mensal por cartao

**Revisor**: AI Code Reviewer
**Data**: 2026-04-08
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A Task 5 implementa o endpoint `GET /payment-methods/summary?month=YYYY-MM` que retorna totais gastos por cartao/meio de pagamento no mes especificado, incluindo breakdown por sub-cartao. A implementacao segue corretamente a arquitetura hexagonal do projeto (Controller -> UseCase -> Gateway -> Provider), o formato de resposta esta conforme a techspec, e os testes de integracao cobrem os cenarios principais. Existem algumas observacoes menores sobre logica de calculo de totais e robustez da query que merecem atencao.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| PaymentMethodController.kt | OK | 0 |
| GetPaymentMethodsSummaryUseCase.kt | OK | 0 |
| GetPaymentMethodsSummaryGateway.kt | OK | 0 |
| GetPaymentMethodsSummaryProvider.kt | Problemas | 2 |
| PaymentMethodSummaryResponse.kt | OK | 0 |
| PaymentMethodSummary.kt | OK | 0 |
| SummaryIntegrationTest.kt | Problemas | 1 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1. Logica fragil para calculo de totalSpent em cartoes sem sub-cards**
- **Arquivo**: `GetPaymentMethodsSummaryProvider.kt`, linha 63
- **Descricao**: A logica que calcula `totalSpent` usa uma heuristica fragil: se a soma dos sub-cards for zero, usa o valor de `first["total"]` (que corresponde a uma linha da query sem sub-card). Isso pode falhar em cenarios onde um cartao tem sub-cards mas nenhum deles teve despesas no mes -- nesse caso `subCardTotals.sumOf { it.total }` sera zero e o codigo usara o valor da primeira row, que pode ser o total de despesas sem sub-card atribuido.

```kotlin
totalSpent = subCardTotals.sumOf { it.total }
    .let { if (it == BigDecimal.ZERO) (first["total"] as BigDecimal) else it },
```

- **Correcao sugerida**: Tratar explicitamente o caso de cartao com sub-cards (somar os totais dos sub-cards) versus cartao sem sub-cards (usar o total direto da query). Uma abordagem mais clara:

```kotlin
totalSpent = if (subCardTotals.isNotEmpty()) {
    subCardTotals.sumOf { it.total }
} else {
    first["total"] as BigDecimal
},
```

Isso evita o falso positivo quando sub-cards existem mas tiveram zero despesas (que resultaria em uma lista nao-vazia com totais zero, somando corretamente para zero).

### Problemas Minor

**m1. Query SQL nao considera despesas atribuidas ao cartao pai sem sub-card quando o cartao possui sub-cards**
- **Arquivo**: `GetPaymentMethodsSummaryProvider.kt`, linhas 34-36
- **Descricao**: A condicao de JOIN `(pn.sub_card_id = sc.id OR (pn.sub_card_id IS NULL AND sc.id IS NULL))` significa que despesas com `sub_card_id = NULL` so sao contabilizadas quando nao ha sub-cards no cartao. Se um cartao possui sub-cards e uma despesa foi registrada com `payment_method_id` preenchido mas `sub_card_id = NULL`, essa despesa nao aparece em nenhuma linha do resultado. Atualmente nao e um problema funcional (as despesas sao sempre vinculadas ao sub-card), mas pode causar discrepancias se futuramente houver despesas vinculadas apenas ao cartao pai.
- **Sugestao**: Documentar essa premissa no codigo ou considerar adicionar uma linha extra na query para capturar despesas "orfas" do cartao pai.

**m2. Ausencia de teste para cartao com sub-cards onde despesas estao no cartao pai (sub_card_id = NULL)**
- **Arquivo**: `SummaryIntegrationTest.kt`
- **Descricao**: Nao ha teste que valide o comportamento quando existem despesas com `payment_method_id` preenchido mas `sub_card_id = NULL` em um cartao que possui sub-cards cadastrados. Esse e um cenario de borda relevante para garantir que nenhuma despesa se perca no calculo.
- **Sugestao**: Adicionar um teste que insira despesas com `sub_card_id = NULL` em um cartao que possui sub-cards e valide o comportamento esperado.

**m3. Casting via `as Number` pode ser fragil dependendo do driver JDBC**
- **Arquivo**: `GetPaymentMethodsSummaryProvider.kt`, linhas 50, 52
- **Descricao**: O uso de `(it["sub_card_id"] as Number).toLong()` e seguro para a maioria dos drivers, mas o tipo exato retornado pode variar entre bancos (H2, MySQL). O COALESCE para 0 na query ajuda, porem o cast `as BigDecimal` na linha 53 e 63 pode falhar se o banco retornar um tipo numerico diferente para colunas com COALESCE/SUM.
- **Sugestao**: Considerar usar metodos mais robustos como `(row["total"] as Number).let { BigDecimal(it.toString()) }` para maior portabilidade, especialmente se os testes usam H2 e producao usa MySQL.

## Destaques Positivos

1. **Arquitetura consistente**: A implementacao segue fielmente o padrao hexagonal do projeto -- Gateway (interface funcional) no dominio, UseCase como orquestrador, Provider como implementacao, Response DTO no entrypoint. Isso demonstra dominio do padrao do projeto.

2. **Query SQL bem construida**: A query faz um unico acesso ao banco com JOINs eficientes, agrupando por cartao e sub-cartao. O uso de LEFT JOINs garante que cartoes sem despesas e sem sub-cards aparecam no resultado.

3. **Validacao de entrada no controller**: O parsing de `YearMonth` com tratamento de excecao retornando 400 e correto e segue boas praticas REST.

4. **Testes de integracao abrangentes**: Os 6 testes cobrem os cenarios principais -- totais corretos, cartao sem despesas, separacao por mes, soma de sub-cards, parametro ausente e formato invalido. Os testes usam dados reais via MockMvc e JDBC, validando o fluxo completo.

5. **Domain entities limpas**: `PaymentMethodSummary` e `SubCardTotal` sao classes simples e bem definidas, sem dependencias de framework.

6. **Response DTO com factory method**: O padrao `companion object { fun from() }` para conversao domain -> response e limpo e consistente com o resto do projeto.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring Boot | OK |
| REST/HTTP | OK |
| Arquitetura Hexagonal | OK |
| Testes | OK |

## Recomendacoes

1. **[Major]** Corrigir a logica de `totalSpent` no Provider para distinguir explicitamente entre cartao com sub-cards e cartao sem sub-cards, em vez de depender da comparacao com `BigDecimal.ZERO`.

2. **[Minor]** Adicionar teste de integracao para o cenario de despesa com `sub_card_id = NULL` em cartao que possui sub-cards, para documentar e proteger o comportamento esperado.

3. **[Minor]** Considerar extrair a query SQL para uma constante nomeada (`SUMMARY_QUERY`) no topo da classe Provider, facilitando leitura e manutencao.

## Veredito

A implementacao esta solida e atende aos requisitos da task. A arquitetura esta consistente com o projeto, os testes cobrem os cenarios principais, e o formato de resposta esta conforme a techspec. O unico problema major identificado (logica de totalSpent) nao causa bug nos cenarios atuais de uso, mas pode introduzir comportamento inesperado em cenarios de borda futuros. Recomendo aplicar a correcao sugerida no item M1 antes de prosseguir para as proximas tasks, pois e uma mudanca simples que elimina fragilidade. Os demais itens sao observacoes menores que podem ser tratados a criterio do desenvolvedor.
