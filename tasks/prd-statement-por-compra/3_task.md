# Tarefa 3.0: Executar a migracao one-off de dados existentes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Com o mecanismo de backfill pronto e testado (Tarefa 2.0), esta tarefa executa a migracao contra o historico real de dados: ativar a property `app.reconciliation.installments.run-full-backfill`, subir a aplicacao uma vez, confirmar via log que 100% das compras nao canceladas/deletadas ficaram com statement, e desligar a property de volta. Esta tarefa e o pre-requisito direto para a Tarefa 4.0 poder simplificar a leitura agregada com seguranca (ver Tech Spec, "Ordem de Construcao" item 2-3 e risco "Janela entre os passos 1 e 3").

<skills>
### Conformidade com Skills Padroes

- Nenhuma skill de codigo aplicavel — esta tarefa e operacional/de verificacao, nao de implementacao de feature nova.
</skills>

<requirements>
- PRD 5.1, 5.2, 5.3 (migracao sem perda de dado, sem alterar valor/meio de pagamento original, totais de planejamentos passados e futuros refletindo exclusivamente os statements apos a migracao).
- Ver Tech Spec, secao "Dependencias Tecnicas" (coordenacao manual de deploy) e "Monitoramento e Observabilidade".
</requirements>

## Subtarefas

- [x] 3.1 Rodar a aplicacao localmente/homologacao com a property ligada contra uma copia realista dos dados e validar os logs `"Installment reconciliation for group..."` para cada grupo.
- [x] 3.2 Escrever uma consulta de verificacao (SQL ou teste) confirmando 0 linhas em `payment_notifications` (nao canceladas/deletadas) sem nenhuma linha correspondente em `installments`.
- [x] 3.3 Confirmar que nenhum valor total ou meio de pagamento de compra original foi alterado (comparar `SUM(pn.amount)` antes/depois vs `SUM(i.amount)` agrupado por `parent_id`).
- [x] 3.4 Ativar a property em producao, subir a aplicacao, validar os logs de conclusao.
- [x] 3.5 Desligar a property (retorna ao default) e confirmar que o proximo boot nao reexecuta o backfill.

## Detalhes de Implementacao

Ver Tech Spec, secao "Dependencias Tecnicas": "requer coordenacao manual de deploy (subir com a property ligada, confirmar via log, redeploy com a property desligada)". Esta tarefa nao envolve mudanca de codigo alem do necessario para a consulta de verificacao do item 3.2, se implementada como teste automatizado.

## Criterios de Sucesso

- 100% das `payment_notifications` nao canceladas/deletadas (parceladas ou nao) possuem pelo menos 1 statement associado apos a execucao.
- Nenhuma compra foi removida; nenhum valor total ou meio de pagamento foi alterado (PRD 5.2).
- Os totais de "Real" dos planejamentos mensais existentes (passados e futuros) batem com a soma dos statements apos a migracao (PRD 5.3).
- A property esta desligada apos a confirmacao, e o boot subsequente nao reprocessa o historico.

## Testes da Tarefa

- [x] Teste de integracao/verificacao: consulta confirmando ausencia de `payment_notifications` orfas de statement pos-migracao.
- [x] Verificacao manual documentada: comparacao de totais antes/depois por grupo, anexada ao registro da execucao (log ou nota de deploy).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application/installments/application/InstallmentReconciliationRunner.kt` (execucao, sem mudanca de codigo)
- `src/main/resources/application.yml` (ou `application.properties`) — toggle da property
- Query/teste de verificacao de integridade pos-migracao (novo, local a definir junto ao time)
