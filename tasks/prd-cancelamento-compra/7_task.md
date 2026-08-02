# Tarefa 7.0: Testes Backend

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Consolidar e garantir cobertura de testes para todas as funcionalidades backend implementadas nas tasks 1-6. Verificar que o conjunto completo de testes passa e cobre os cenarios criticos.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de testes do projeto (@SpringBootTest, JdbcTemplate).
</skills>

<requirements>
- Testes unitarios para ambos os providers de cancelamento
- Testes de integracao para ambos os endpoints PATCH /cancel
- Testes de integracao para queries de budget com compras canceladas
- Testes de integracao para query UNION com campo cancelledAt
- Todos os testes existentes devem continuar passando
- Cobertura dos cenarios de erro (404, 409, 422)
</requirements>

## Subtarefas

- [ ] 7.1 Escrever/revisar testes unitarios dos providers de cancelamento (sucesso + erros)
- [ ] 7.2 Escrever testes de integracao dos endpoints PATCH /cancel
- [ ] 7.3 Escrever testes de integracao para budget excluindo cancelados
- [ ] 7.4 Escrever testes de integracao para listagem UNION incluindo cancelados
- [ ] 7.5 Executar suite completa de testes e garantir 100% green

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Abordagem de Testes"

Usar `@SpringBootTest` com `JdbcTemplate` para setup de dados. Seguir padrao de testes existentes no projeto.

## Criterios de Sucesso

- Todos os testes novos passam
- Todos os testes existentes continuam passando
- Cenarios cobertos: cancelamento com sucesso, item nao encontrado, ja cancelado, ja excluido
- Budget totals corretamente excluem cancelados
- Listagem corretamente inclui cancelados com campo preenchido

## Testes da Tarefa

- [ ] Executar `./gradlew test` e verificar que todos passam
- [ ] Verificar cobertura dos cenarios criticos listados acima

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/test/kotlin/.../` (diretorio de testes)
- Testes existentes de deactivation como referencia de padrao
