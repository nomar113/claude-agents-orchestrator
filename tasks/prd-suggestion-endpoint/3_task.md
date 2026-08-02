# Tarefa 3.0: UseCase FindInvoiceSuggestionsUseCase

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o use case que orquestra a busca de sugestoes: valida que o invoice existe, delega ao gateway e retorna o resultado. Este e o ponto central de logica de negocio da feature.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar classe `FindInvoiceSuggestionsUseCase` anotada com `@Component`
- Injetar `PurchaseInvoiceRepository` e `FindInvoiceSuggestionsGateway`
- Buscar invoice por ID; se nao encontrado, lancar `NoSuchElementException`
- Chamar gateway e retornar resultado
- Testes unitarios cobrindo: invoice nao encontrado, gateway retorna lista, gateway retorna lista vazia
</requirements>

## Subtarefas

- [x] 3.1 Criar classe `FindInvoiceSuggestionsUseCase` seguindo assinatura da techspec
- [x] 3.2 Escrever testes unitarios: invoice nao encontrado retorna erro
- [x] 3.3 Escrever testes unitarios: gateway retorna lista com resultados
- [x] 3.4 Escrever testes unitarios: gateway retorna lista vazia
- [x] 3.5 Rodar build e testes

## Detalhes de Implementacao

Consultar a secao "Interfaces Principais" da `techspec.md` para a assinatura exata do use case.

## Criterios de Sucesso

- UseCase criado com injecao de dependencias correta
- Invoice inexistente resulta em erro apropriado
- Gateway chamado com parametros corretos
- 100% dos cenarios de teste cobertos

## Testes da Tarefa

- [x] Teste unitario: invoice nao encontrado → `NoSuchElementException`
- [x] Teste unitario: gateway retorna lista com 3 sugestoes → retorna lista com 3 itens
- [x] Teste unitario: gateway retorna lista vazia → retorna lista vazia
- [x] Build (`./gradlew compileKotlin`) passa sem erros (testes de integracao pre-existentes falham por razoes nao relacionadas)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/purchase_invoice/entrypoint/database/repository/PurchaseInvoiceRepository.kt`
- Gateway criado na tarefa 2.0
