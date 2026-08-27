# Tarefa 8.0: Validacao manual end-to-end (smoke test) e rollout

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Validar manualmente, contra a SEFAZ-RJ real, que o fluxo completo (endpoint Kotlin -> `nfce-extraction-service` implantado na VPS -> SEFAZ) funciona antes de qualquer liberacao ampla. A Tech Spec e o PRD explicitamente desaconselham automatizar essa validacao via Playwright em CI (risco de o proprio pipeline ser bloqueado pelo anti-bot), entao esta tarefa e um checklist de smoke test manual, executado uma vez por quem fizer o rollout.

<skills>
### Conformidade com Skills Padroes

Nao aplicavel — tarefa operacional/manual, sem codigo novo.
</skills>

<requirements>
- `nfce-extraction-service` implantado na VPS de Sao Paulo (Docker, Tarefa 4.0), acessivel apenas internamente pelo backend Kotlin.
- Backend Kotlin com o endpoint `POST /purchases/invoice/extraction` (Tarefa 7.0) apontando para o servico implantado.
- Executar o smoke test manual com pelo menos 3 a 5 notas RJ reais, cobrindo:
  - Ao menos 1 nota valida com sucesso completo (extracao + retorno dos campos corretos).
  - Ao menos 1 cenario de bloqueio tratado corretamente (se reproduzivel) ou revisao do log de um bloqueio historico.
  - Confirmacao do comportamento de timeout tratado corretamente (nota invalida/inexistente ou reducao temporaria do timeout para forcar o cenario).
- Registrar os resultados do smoke test (sucesso/bloqueio/timeout) e a duracao de cada chamada, usando os logs estruturados das Tarefas 4.0/5.0.
- Confirmar que nenhum dado pessoal ou HTML da nota aparece nos logs gerados durante o smoke test.
</requirements>

## Subtarefas

- [ ] 8.1 Confirmar que o `nfce-extraction-service` esta rodando na VPS e acessivel apenas pela rede interna (nao exposto publicamente).
- [ ] 8.2 Confirmar as variaveis de ambiente/segredo compartilhado (`X-Internal-Key`) configuradas de forma consistente entre o backend Kotlin e o `nfce-extraction-service` em producao.
- [ ] 8.3 Escanear/enviar 3 a 5 URLs de notas RJ reais via `POST /purchases/invoice/extraction` e registrar o resultado de cada uma.
- [ ] 8.4 Validar o caso de bloqueio (reproduzido ou revisado via log historico) e o caso de timeout, confirmando os status HTTP `422`/`504` esperados (Tech Spec, tabela de mapeamento de erro).
- [ ] 8.5 Revisar os logs gerados (Kotlin e Node) durante o smoke test, confirmando ausencia de HTML/dados pessoais.
- [ ] 8.6 Documentar o resultado do smoke test (taxa de sucesso observada, ocorrencias) para servir de baseline da metrica principal do PRD.

## Detalhes de Implementacao

Ver Tech Spec, secoes "Abordagem de Testes" > "Testes de E2E" (checklist de smoke test manual) e "Riscos Conhecidos" (taxa real de sucesso desconhecida ate validacao em producao, mitigada por rollout gradual). Ver PRD, secao "Objetivos" (metrica principal: % de scans com sucesso).

## Criterios de Sucesso

- Pelo menos 1 nota RJ real e lida com sucesso de ponta a ponta via o novo endpoint.
- Os cenarios de bloqueio e timeout, quando observados, retornam ao chamador os status HTTP e mensagens definidos na Tech Spec.
- Nenhum HTML ou dado pessoal da nota aparece nos logs revisados.
- Resultado do smoke test documentado como baseline antes do rollout amplo.

## Testes da Tarefa

- [ ] Testes de unidade: nao aplicavel (cobertos pelas Tarefas 1.0 a 7.0).
- [ ] Testes de integracao: nao aplicavel (cobertos pelas Tarefas 1.0 a 7.0).
- [ ] Testes E2E: checklist de smoke test manual contra a SEFAZ-RJ real, conforme requisitos acima — **este e o entregavel principal da tarefa**.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `nfce-extraction-service/` implantado na VPS (sem alteracao de codigo nesta tarefa)
- Logs de producao (Kotlin: SLF4J; Node: `pino`) gerados durante o smoke test
- Registro/checklist do smoke test (ex: anexado a este arquivo de tarefa ou a um documento de rollout, conforme preferencia do time)
