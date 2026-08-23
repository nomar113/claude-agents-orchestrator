# Tarefa 7.0: Testes E2E (Playwright) + validacao de independencia de timezone ponta a ponta

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fechar a padronizacao com testes E2E cobrindo os dois fluxos de negocio criticos ponta a ponta (backend+frontend) e validar que o deploy coordenado (contrato de API muda junto) esta pronto para producao. Esta e a ultima tarefa da sequencia — valida a integracao completa de todas as tarefas anteriores.

**Depende de todas as tarefas anteriores (1.0 a 6.0)** — backend e frontend devem estar totalmente migrados antes da validacao E2E, pois o contrato de API e uma breaking change coordenada.

<skills>
### Conformidade com Skills Padroes

- Nenhuma skill de projeto adicional alem das ja aplicadas nas tarefas de implementacao (backend e frontend nao possuem skills especificas de E2E configuradas).
</skills>

<requirements>
- Zero divergencia entre horario real e horario exibido, em qualquer tela do app, em qualquer ambiente (PRD, Objetivos).
- Ausencia de deslocamento de horario em testes que cobrem virada de dia (PRD, Objetivos — item de sucesso mensuravel "b").
- A padronizacao deve ser aplicavel sem exigir indisponibilidade do sistema em producao (PRD, Restricoes Tecnicas de Alto Nivel).
</requirements>

## Subtarefas

- [ ] 7.1 Playwright: criacao de compra manual informando data/hora especifica → valor exibido no detalhe da compra deve ser identico ao informado.
- [ ] 7.2 Playwright: parcela com `dueDate` igual a data atual, exercitada perto da virada de dia, classificada corretamente como vencida/nao vencida.
- [ ] 7.3 Validar manualmente (ou via teste automatizado) que o fluxo de SMS → compra automatica → exibicao produz o horario correto de Brasilia em ambiente com timezone de host diferente (ex: rodando o backend com `TZ=UTC` explicitamente distinto do padrao anterior).
- [ ] 7.4 Revisar e confirmar plano de deploy coordenado backend+frontend (contrato de API muda junto — ver "Sequenciamento de Desenvolvimento", item 10, da techspec.md), incluindo ordem de aplicacao da migration Flyway antes do deploy do backend com os novos tipos de entidade.
- [ ] 7.5 Confirmar que os logs `WARN` adicionados nas Tarefas 3.0 e 4.0 (SMS fora do formato esperado; `purchasedAt` sem offset) estao visiveis e monitoraveis apos o deploy, para deteccao de clientes desatualizados.

## Detalhes de Implementacao

Ver secao "Testes de E2E" e "Sequenciamento de Desenvolvimento" (item 10, "Deploy coordenado") da `techspec.md`.

## Criterios de Sucesso

- Auditoria de codigo confirma um unico tipo de data por categoria semantica em cada camada, com timezone declarado explicitamente onde antes dependia de configuracao implicita (PRD, Objetivos — item de sucesso mensuravel "a").
- Os dois testes E2E (compra manual sem deslocamento; classificacao correta de parcela vencida perto da virada de dia) passam de forma consistente.
- Nenhum requisito funcional do PRD (1 a 12) permanece sem cobertura de teste em alguma das tarefas 1.0-7.0.

## Testes da Tarefa

- [ ] Testes E2E (Playwright): os dois fluxos descritos em 7.1 e 7.2, conforme "Abordagem de Testes" da techspec.md.
- [ ] Teste de integracao ponta a ponta: fluxo completo SMS → parser → persistencia → serializacao → frontend, validando ausencia de deslocamento em qualquer etapa.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Suite de testes Playwright existente no `controlai-frontend`
- Pipeline/checklist de deploy coordenado (backend+frontend)
