# Tarefa 1.0: Backend — Campo icon na entidade Category

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar campo `icon` (emoji/texto) na tabela `categories` via migracao Flyway V19, propagar para entidade de dominio, model JPA, converter e response da API. Atualizar `GetBudgetSummaryProvider` para incluir `categoryIcon` no retorno do summary de budget. Isso desbloqueia o frontend para exibir icones por categoria.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- RF-25: Adicionar campo `icon` (varchar 10, nullable) na tabela `categories`
- RF-27: Quando categoria nao tiver icone, usar emoji padrao generico (tratado no frontend, mas backend deve retornar null)
- Atualizar `GetBudgetSummaryProvider` para retornar `categoryIcon` no `BudgetItemSummary`
- Atualizar `BudgetItemSummaryResponse` para incluir `categoryIcon`
</requirements>

## Subtarefas

- [ ] 1.1 Criar migracao Flyway `V19__add_icon_to_categories.sql` com `ALTER TABLE categories ADD COLUMN icon VARCHAR(10) DEFAULT NULL`
- [ ] 1.2 Atualizar `Category.kt` (dominio) adicionando campo `val icon: String? = null`
- [ ] 1.3 Atualizar `CategoryModel.kt` adicionando `@Column(name = "icon", length = 10, nullable = true) val icon: String? = null`
- [ ] 1.4 Atualizar `CategoryConverter.kt` para mapear campo `icon` entre model e entity
- [ ] 1.5 Atualizar `CategoryResponse.kt` para expor `icon: String?`
- [ ] 1.6 Atualizar `BudgetItemSummary.kt` (dominio) adicionando `val categoryIcon: String? = null`
- [ ] 1.7 Atualizar `BudgetItemSummaryResponse.kt` adicionando `categoryIcon: String?` e mapeando no `from()`
- [ ] 1.8 Atualizar `GetBudgetSummaryProvider.kt` para buscar `icon` da tabela `categories` junto com `name` e passar para `BudgetItemSummary`
- [ ] 1.9 Escrever e executar testes

## Detalhes de Implementacao

Consultar a secao "Modelos de Dados" e "Arquivos relevantes e dependentes > Backend" da techspec.md para detalhes de implementacao.

O `GetBudgetSummaryProvider` ja faz query em `categories` para buscar `name` — basta adicionar `icon` na mesma query SQL e propagar o valor.

## Criterios de Sucesso

- Migracao V19 aplica sem erros no banco
- `GET /categories` retorna campo `icon` (null para categorias sem icone)
- `GET /budgets?month=YYYY-MM` retorna `categoryIcon` em cada item do summary
- Testes unitarios e de integracao passam

## Testes da Tarefa

- [ ] Teste unitario: `CategoryConverterTest` — verificar mapeamento bidirecional do campo `icon`
- [ ] Teste de integracao: `CategoryControllerIntegrationTest` — verificar campo `icon` no response de `GET /categories`
- [ ] Teste de integracao: `BudgetControllerIntegrationTest` — verificar `categoryIcon` no response de `GET /budgets?month=YYYY-MM`

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai`

- `src/main/resources/db/migration/V19__add_icon_to_categories.sql` (novo)
- `src/main/kotlin/.../categories/entity/Category.kt`
- `src/main/kotlin/.../categories/entrypoint/database/model/CategoryModel.kt`
- `src/main/kotlin/.../categories/converter/CategoryConverter.kt`
- `src/main/kotlin/.../categories/entrypoint/rest/response/CategoryResponse.kt`
- `src/main/kotlin/.../domain/budget/entity/BudgetSummary.kt`
- `src/main/kotlin/.../budget/entrypoint/rest/response/BudgetSummaryResponse.kt`
- `src/main/kotlin/.../budget/application/GetBudgetSummaryProvider.kt`
