# Tarefa 5.0: Recalculo de periodos na duplicacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Ao duplicar um orcamento para outro mes, os periods devem ser recalculados para o mes destino com base no closingDay de cada cartao, nao copiados do mes origem.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao com testes e verificacoes.
- `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- Ao duplicar budget, recalcular periods para o yearMonth destino
- Usar a mesma logica de calculo da Task 2 (closingDay para CREDIT_CARD, dia 1 a ultimo para PIX)
- Nao copiar as datas do mes origem
- Considerar novos meios de pagamento que possam ter sido adicionados desde o budget original
</requirements>

## Subtarefas

- [ ] 5.1 Modificar `DuplicateBudgetProvider` para chamar logica de geracao de periods com o mes destino
- [ ] 5.2 Reutilizar o servico/utility de calculo de datas criado na Task 2
- [ ] 5.3 Escrever testes

## Detalhes de Implementacao

Reutilizar a logica de calculo de datas criada na Task 2. A duplicacao deve buscar todos os PaymentMethods ativos e gerar periods frescos para o mes destino.

## Criterios de Sucesso

- Duplicar budget de abril para maio gera periods com datas de maio
- Novos meios de pagamento adicionados apos o budget original sao incluidos
- Meios de pagamento deletados nao sao incluidos

## Testes da Tarefa

- [ ] Teste de integracao: duplicar budget e verificar que periods tem datas do mes destino
- [ ] Teste de integracao: duplicar com novo payment method adicionado — verificar inclusao
- [ ] Teste de integracao: duplicar com payment method deletado — verificar exclusao

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/main/kotlin/br/com/nomar/controlai/application/budget/application/DuplicateBudgetProvider.kt`
- Servico/utility de calculo de datas criado na Task 2
