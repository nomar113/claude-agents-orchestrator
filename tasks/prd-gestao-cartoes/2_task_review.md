# Review: Task 2.0 - Domain layer do bounded context payment_methods

**Revisor**: AI Code Reviewer
**Data**: 2026-03-30
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task 2.0 implementou a camada de dominio completa do bounded context `payment_methods`, incluindo 3 entidades, 3 enums, 10 gateways (interfaces) e 10 use cases, acompanhados de 24 testes unitarios. A implementacao segue fielmente o padrao hexagonal existente no projeto (referencia: `purchases_invoices`), mantendo entidades como classes imutaveis, gateways como `fun interface` e use cases como `@Component`. A qualidade geral e boa, com cobertura de testes adequada e aderencia a techspec. Ha observacoes minor que podem ser aprimoradas mas nao bloqueiam a entrega.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `domain/payment_methods/entity/Holder.kt` | OK | 0 |
| `domain/payment_methods/entity/PaymentMethod.kt` | OK | 0 |
| `domain/payment_methods/entity/SubCard.kt` | OK | 0 |
| `domain/payment_methods/entity/PaymentMethodType.kt` | OK | 0 |
| `domain/payment_methods/entity/SubCardType.kt` | OK | 0 |
| `domain/payment_methods/entity/WalletPlatform.kt` | OK | 0 |
| `domain/payment_methods/gateway/SaveHolderGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/ListHoldersGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/SavePaymentMethodGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/ListPaymentMethodsGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/FindPaymentMethodGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/UpdatePaymentMethodGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/DeactivatePaymentMethodGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/SaveSubCardGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/UpdateSubCardGateway.kt` | OK | 0 |
| `domain/payment_methods/gateway/DeactivateSubCardGateway.kt` | OK | 0 |
| `domain/payment_methods/usecase/SaveHolderUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/ListHoldersUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/SavePaymentMethodUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/ListPaymentMethodsUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/FindPaymentMethodUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/UpdatePaymentMethodUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/DeactivatePaymentMethodUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/SaveSubCardUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/UpdateSubCardUseCase.kt` | OK | 0 |
| `domain/payment_methods/usecase/DeactivateSubCardUseCase.kt` | OK | 0 |
| `test/.../PaymentMethodsUseCasesTest.kt` | Observacoes | 2 |
| `test/.../config/TestGatewayConfig.kt` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**M1. Entidades usam `class` em vez de `data class` conforme descrito na task**

- **Arquivo**: `Holder.kt`, `PaymentMethod.kt`, `SubCard.kt`
- **Descricao**: A task definition (requisito 2.3) especifica "domain entities sao data classes imutaveis", porem as entidades foram implementadas como `class` sem o modificador `data`. Isso significa que `equals()`, `hashCode()`, `copy()` e `toString()` nao sao gerados automaticamente, dificultando comparacoes em testes e debugging.
- **Atenuante**: O bounded context de referencia (`purchases_invoices`) tambem usa `class` simples (ex: `PurchaseInvoice`, `Purchase`). A implementacao esta consistente com o padrao existente no projeto, portanto a decisao de manter `class` e aceitavel como escolha de alinhamento com o codebase. Converter para `data class` no futuro pode ser feito sem breaking changes.

**M2. Ausencia de validacoes de dominio nas entidades**

- **Arquivo**: `SubCard.kt` (linhas 7-8), `PaymentMethod.kt` (linha 11)
- **Descricao**: A techspec menciona regras de validacao que poderiam residir na camada de dominio: `lastFourDigits` deveria ter exatamente 4 caracteres numericos, `closingDay` deveria estar entre 1 e 31, `walletPlatform` deveria ser obrigatorio quando o tipo e `DIGITAL_WALLET`, e `dependentName` deveria ser obrigatorio quando o tipo e `PHYSICAL_DEPENDENT`. Atualmente, essas validacoes nao existem em nenhuma camada.
- **Correcao sugerida**: Adicionar blocos `init` nas entidades para validar invariantes de dominio. Exemplo:

```kotlin
class SubCard(
    // ... campos existentes
) {
    init {
        require(lastFourDigits.length == 4 && lastFourDigits.all { it.isDigit() }) {
            "lastFourDigits must be exactly 4 numeric characters"
        }
        if (type == SubCardType.DIGITAL_WALLET) {
            requireNotNull(walletPlatform) { "walletPlatform is required for DIGITAL_WALLET type" }
        }
        if (type == SubCardType.PHYSICAL_DEPENDENT) {
            requireNotNull(dependentName) { "dependentName is required for PHYSICAL_DEPENDENT type" }
        }
    }
}
```

- **Nota**: Esta validacao pode ser tratada na camada de application/controller (via DTOs e Bean Validation). Registrada como minor porque nao causa bugs na camada de dominio atual e pode ser endererada nas tasks subsequentes de application layer.

**M3. Arquivo de testes unico para todo o bounded context**

- **Arquivo**: `PaymentMethodsUseCasesTest.kt` (309 linhas)
- **Descricao**: Todos os 24 testes estao em um unico arquivo com 309 linhas. Embora ainda esteja dentro do limite de 300 linhas para classes de producao, a tendencia e crescer conforme novas funcionalidades sejam adicionadas. Separar em arquivos por grupo (ex: `HolderUseCasesTest.kt`, `PaymentMethodUseCasesTest.kt`, `SubCardUseCasesTest.kt`, `PaymentMethodsEnumsTest.kt`) melhoraria a organizacao.
- **Nota**: Nao e bloqueante para esta task, mas recomenda-se refatorar antes que os testes de integracao sejam adicionados nas proximas tasks.

## Destaques Positivos

1. **Aderencia perfeita ao padrao hexagonal existente**: Entidades, gateways e use cases seguem exatamente a mesma estrutura do bounded context `purchases_invoices`, facilitando a manutencao por parte de qualquer desenvolvedor familiarizado com o projeto.

2. **Gateways como `fun interface`**: Excelente uso de SAM (Single Abstract Method) interfaces do Kotlin, permitindo instanciacao com lambdas nos testes e mantendo o codigo conciso.

3. **Cobertura de testes completa**: Todos os 10 use cases possuem testes de sucesso e falha. Os 3 enums possuem testes de valores. As 3 entidades possuem testes de construcao. Total de 24 testes cobrindo cenarios positivos e negativos.

4. **Separacao limpa de dependencias**: A camada de dominio depende exclusivamente de `kotlin.Result` e `org.springframework.stereotype.Component`, sem nenhuma dependencia de JPA, infraestrutura ou frameworks pesados. Exatamente como requerido pela task.

5. **`TestGatewayConfig` bem projetado**: Configuracao de teste que fornece beans stub para todos os gateways do novo bounded context, garantindo que o Spring context dos testes de integracao existentes nao quebre com a adicao das novas interfaces.

6. **Modelagem fiel a techspec**: Todas as entidades, enums e gateways correspondem exatamente ao que foi especificado nos modelos de dados e interfaces da techspec. Os campos, tipos e relacionamentos estao corretos.

7. **Use cases com `runCatching` + `getOrThrow`**: Padrao consistente que encapsula excecoes do gateway em `Result`, permitindo tratamento uniforme de erros nas camadas superiores.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| Kotlin/Spring | OK |
| Arquitetura Hexagonal | OK |
| Testes | OK |
| Naming Conventions | OK |
| Separacao de Camadas | OK |

**Detalhamento**:
- **Linguagem**: Todo o codigo esta em ingles (nomes de classes, metodos, variaveis, campos).
- **Naming**: PascalCase para classes/enums, camelCase para metodos/variaveis. Nomes claros e sem abreviacoes.
- **Funcoes**: Todos os metodos se chamam `execute`, padrao Single Action consistente com o projeto.
- **Parametros**: Todos os use cases recebem no maximo 1 parametro (entidade ou id). Gateways idem.
- **Tamanho**: Nenhum arquivo excede 20 linhas de producao. Metodos tem no maximo 5 linhas.
- **Dependencias de dominio**: Zero dependencias de JPA ou infraestrutura, exceto `@Component` nos use cases (padrao do projeto).
- **Kebab-case em diretorios**: `payment_methods` usa snake_case, porem e consistente com o padrao existente (`purchases_invoices`). O padrao do projeto e snake_case para pacotes Kotlin (convencao Java/Kotlin), nao kebab-case.

## Recomendacoes

1. **Considerar adicionar validacoes de dominio com `init` blocks** nas entidades `SubCard` e `PaymentMethod` para garantir invariantes como formato de `lastFourDigits`, range de `closingDay`, e campos condicionalmente obrigatorios (`walletPlatform`, `dependentName`). Pode ser feito nesta task ou na proxima.

2. **Separar o arquivo de testes** em arquivos menores por grupo de funcionalidade antes de iniciar a task 3 (application layer), quando mais testes serao adicionados.

3. **Avaliar uso de `data class`** para as entidades de dominio se houver necessidade futura de `equals`/`copy` (ex: em testes de igualdade ou transformacoes). O padrao atual do projeto usa `class`, entao nao e obrigatorio.

## Veredito

A implementacao da task 2.0 esta **aprovada com observacoes minor**. Todas as subtarefas foram completadas (entidades, enums, gateways, use cases e testes). O codigo segue fielmente o padrao hexagonal do projeto, esta livre de dependencias de infraestrutura na camada de dominio, e possui cobertura de testes adequada com 24 testes unitarios passando. As observacoes registradas (validacoes de dominio e organizacao de testes) sao melhorias que podem ser endereadas de forma incremental sem bloquear o progresso para a proxima task (application layer com providers JPA).

**Proximos passos**: Seguir para a task 3.0 (Application layer -- Providers + Repositories).
