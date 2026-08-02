# Tarefa 1.0: Migration — Indice Composto (amount, purchased_at)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar uma migration Flyway que adiciona um indice composto na tabela `payment_notifications` nas colunas `(amount, purchased_at)`. Este indice e pre-requisito para que a query de sugestoes tenha performance adequada (<500ms).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Criar migration Flyway com nomenclatura sequencial correta (`V{N}__add_index_amount_purchased_at_to_payment_notifications.sql`)
- O indice deve ser composto: `amount` primeiro (equality), `purchased_at` segundo (range)
- Nome do indice: `idx_pn_amount_purchased_at`
- A migration deve ser idempotente se possivel
</requirements>

## Subtarefas

- [ ] 1.1 Verificar o numero sequencial da proxima migration Flyway em `src/main/resources/db/migration/`
- [ ] 1.2 Criar o arquivo de migration com o SQL do indice composto
- [ ] 1.3 Rodar a migration localmente e verificar que o indice foi criado
- [ ] 1.4 Rodar build e testes existentes para garantir que nada quebrou

## Detalhes de Implementacao

Consultar a secao "Migration" da `techspec.md` para o SQL exato do indice.

**SQL esperado:**
```sql
CREATE INDEX idx_pn_amount_purchased_at
    ON payment_notifications (amount, purchased_at);
```

## Criterios de Sucesso

- Migration executada sem erros
- Indice `idx_pn_amount_purchased_at` existe na tabela `payment_notifications`
- Build e testes existentes continuam passando

## Testes da Tarefa

- [ ] Verificar que a migration executa sem erros no banco local
- [ ] Verificar que o indice aparece com `SHOW INDEX FROM payment_notifications`
- [ ] Build (`./gradlew build`) passa sem erros

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/resources/db/migration/` — pasta de migrations Flyway (backend controlai)
