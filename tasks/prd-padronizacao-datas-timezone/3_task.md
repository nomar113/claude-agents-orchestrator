# Tarefa 3.0: Backend — Correcao do PaymentNotificationTextParser

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Corrigir o `PaymentNotificationTextParser` para declarar explicitamente que o horario extraido do SMS bancario esta em `America/Sao_Paulo` antes de converter para `Instant` (UTC). Esta e a correcao raiz de um dos dois bugs conhecidos: hoje a conversao depende implicitamente do timezone do host, podendo gerar deslocamento de horario para compras registradas automaticamente via SMS.

**Depende das Tarefas 1.0 e 2.0** — a configuracao central de UTC (1.0) e o tipo `Instant` em `PaymentNotification.purchasedAt` (2.0) devem estar em vigor antes desta correcao.

<skills>
### Conformidade com Skills Padroes

- `clean-code`: torna explicita uma premissa (`America/Sao_Paulo`) que hoje e implicita e fragil.
</skills>

<requirements>
- Como usuario, quando uma compra e criada automaticamente a partir de um SMS do banco, o horario exibido deve corresponder ao horario real da compra (horario de Brasilia), independentemente de onde o backend esta rodando (PRD, Historias de Usuario).
- O timezone usado para interpretar timestamps extraidos do SMS deve ser explicito, nao implicito no ambiente (PRD requisito 2).
</requirements>

## Subtarefas

- [x] 3.1 Alterar `PaymentNotificationTextParser` para parsear o texto do SMS como `LocalDateTime` "naive" e converter explicitamente via `.atZone(ZoneId.of("America/Sao_Paulo")).toInstant()`.
- [x] 3.2 Adicionar log em nivel `WARN` caso o texto do SMS nao case com o formato de data/hora esperado (conforme "Monitoramento e Observabilidade" da techspec.md).
- [x] 3.3 Escrever testes de unidade e integracao (ver secao de Testes).

## Detalhes de Implementacao

Ver bloco de codigo Kotlin em "Interfaces Principais" da `techspec.md` (trecho `fun parse(smsText: String): Instant`) e a secao "Fluxo de dados" para o caminho completo SMS → `Instant` UTC.

## Criterios de Sucesso

- Um horario extraido do SMS as 14:00 (horario de Brasilia) produz sempre o mesmo `Instant` (17:00 UTC), independentemente do timezone configurado no host onde o parser roda.
- Bug de deslocamento de horario em compras via SMS eliminado (PRD requisito 12, parcialmente — a parte de parcelas vencidas e tratada na Tarefa 6.0).

## Testes da Tarefa

- [x] Testes de unidade: `PaymentNotificationTextParser` verificando conversao correta SMS → `Instant` (conforme "Abordagem de Testes" da techspec.md), incluindo casos de virada de dia (SMS proximo a meia-noite em `America/Sao_Paulo`).
- [x] Testes de integracao: fluxo completo de recebimento de mensagem da fila SQS `payments-notifications` ate persistencia do `Instant` correto.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `.../payments_notification/.../PaymentNotificationTextParser.kt`
