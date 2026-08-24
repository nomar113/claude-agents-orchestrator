# Resumo de Tarefas de Implementacao de Padronizacao de Datas e Timezone (controlai + controlai-frontend)

## Tarefas

- [x] 1.0 Backend — Configuracao central de timezone UTC
- [x] 2.0 Backend — Padronizacao de tipos de data nas entidades JPA + migration
- [x] 3.0 Backend — Correcao do PaymentNotificationTextParser
- [x] 4.0 Backend — Padronizacao de DTOs de request/response
- [x] 5.0 Frontend — Modulo unico de utilitarios de data (src/utils/date.ts)
- [ ] 6.0 Frontend — Migracao dos componentes consumidores + correcao dos bugs conhecidos
- [ ] 7.0 Testes E2E (Playwright) + validacao de independencia de timezone ponta a ponta

## Dependencias entre Tarefas

| Tarefa | Depende de | Motivo |
|---|---|---|
| 1.0 | — | Base de tudo: fixa UTC em Jackson/Hibernate/JDBC antes de qualquer mudanca de tipo. |
| 2.0 | 1.0 | Padronizar tipos (`Instant`/`LocalDate`) so faz sentido com o timezone da aplicacao ja fixado em UTC. |
| 3.0 | 1.0, 2.0 | O parser passa a alimentar `PaymentNotification.purchasedAt`, cujo tipo so fica definitivo apos a Tarefa 2.0. |
| 4.0 | 2.0, 3.0 | DTOs refletem os tipos das entidades (2.0) e os dados corretamente convertidos pelo parser (3.0). |
| 5.0 | — | Modulo isolado e testavel de forma independente (dayjs + plugins), sem depender de mudancas de backend. Pode ser desenvolvido em paralelo as tarefas 1.0-4.0, mas o formato ISO assumido deve ser validado contra o contrato final da Tarefa 4.0 antes da integracao. |
| 6.0 | 4.0, 5.0 | Precisa do novo contrato de API (4.0) e do modulo de utilitarios (5.0) para migrar os componentes e corrigir os bugs conhecidos. |
| 7.0 | 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 | E2E valida o fluxo completo (SMS → backend → frontend) apos backend e frontend estarem migrados e implantados juntos (breaking change coordenada). |

**Ordem de execucao recomendada:** 1.0 → 2.0 → 3.0 → 4.0 → (5.0 pode iniciar em paralelo a partir de 1.0) → 6.0 → 7.0.
