# Tarefa 5.0: Testes de Integracao Backend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar testes de integracao completos para o endpoint `GET /purchases/invoices/{id}/suggestions` usando `@SpringBootTest` + `@AutoConfigureMockMvc` + `JdbcTemplate`. Os testes devem validar o fluxo completo end-to-end no backend, inserindo dados reais no banco e verificando a resposta HTTP.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar `SuggestionControllerIntegrationTest` usando `@SpringBootTest` + `@AutoConfigureMockMvc`
- Usar `JdbcTemplate` para inserir dados de teste diretamente no banco
- Cobrir todos os cenarios listados na techspec
- Cada teste deve ser independente (setup e cleanup proprio)
</requirements>

## Subtarefas

- [x] 5.1 Criar classe de teste com setup de dados via `JdbcTemplate`
- [x] 5.2 Teste: match exato (valor igual, dentro da janela temporal) → retorna sugestao
- [x] 5.3 Teste: sem match por valor diferente → retorna lista vazia
- [x] 5.4 Teste: sem match por fora da janela temporal → retorna lista vazia
- [x] 5.5 Teste: notification cancelada (`cancelled_at IS NOT NULL`) → excluida dos resultados
- [x] 5.6 Teste: notification deletada (`deleted_at IS NOT NULL`) → excluida dos resultados
- [x] 5.7 Teste: ordenacao por proximidade temporal (menor delta primeiro)
- [x] 5.8 Teste: invoice inexistente → retorna 404
- [x] 5.9 Teste: match exato mas sem notifications candidatas → retorna lista vazia 200
- [x] 5.10 Rodar todos os testes e verificar que passam

## Detalhes de Implementacao

Consultar a secao "Testes de Integracao" da `techspec.md` para a lista de cenarios. Seguir o padrao de testes de integracao ja existentes no projeto.

## Criterios de Sucesso

- Todos os cenarios de teste passando
- Testes sao independentes (nao dependem de ordem de execucao)
- Dados de teste sao limpos apos cada teste
- Build completo (`./gradlew build`) passa

## Testes da Tarefa

- [x] Todos os testes de integracao listados acima passando
- [x] Build (`./gradlew build`) passa sem erros (falhas pre-existentes em Budget/PurchaseCategory, nao relacionadas)
- [ ] Nenhum teste existente quebrado

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Controller, UseCase, Gateway, Provider e Repository criados nas tarefas 1-4
- Testes de integracao existentes no projeto como referencia de padrao
