# Tarefa 8.0: Mecanismo anti-regressao no frontend (script de varredura)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Complementa a Tarefa 6.0 (ArchUnit no backend) com a metade frontend do mecanismo anti-regressao exigido pelo PRD (Funcionalidade 4). Como o projeto nao tem regra de lint custom hoje, esta tarefa cria um script que varre `src/` por padroes proibidos de uso de valor bruto (`.amount` fora de uma allowlist de arquivos) e o integra ao processo de build/CI, para que qualquer novo ponto que reintroduza a leitura do valor bruto quebre o build.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices`: nao aplicavel diretamente (script de tooling, nao componente React), mas o script nao deve introduzir dependencia de runtime no bundle da aplicacao.
</skills>

<requirements>
- PRD 4.1 (mecanismo automatizado, executado como parte do processo de desenvolvimento).
- PRD 4.2 (cobre no minimo toda tela hoje listada no requisito 3.1, e qualquer tela futura equivalente).
- Ver Tech Spec, secao "Script check-raw-amount-usage" em Visao Geral dos Componentes e "Decisoes Principais" ("ArchUnit no backend + script grep no frontend").
</requirements>

## Subtarefas

- [ ] 8.1 Criar `scripts/check-raw-amount-usage.mjs` (ou equivalente) que varre `src/**/*.{ts,tsx}` procurando padroes proibidos (ex.: `.amount` usado fora de uma allowlist de arquivos/linhas conhecidas).
- [ ] 8.2 Definir e documentar no proprio script a allowlist inicial (ex.: exibicao do valor bruto na tela de detalhe da propria compra, `PurchaseDetail.tsx`).
- [ ] 8.3 Adicionar o script como etapa do `npm run build` (ou de um script `npm run check:amount` chamado pelo CI), falhando o processo se algo fora da allowlist for encontrado.
- [ ] 8.4 Auditar o frontend (apos a Tarefa 7.0) e confirmar que o script passa limpo no estado atual do codigo.
- [ ] 8.5 Testar manualmente que o script falha se um uso indevido de `.amount` for introduzido temporariamente (revertido antes do commit final).

## Detalhes de Implementacao

Ver Tech Spec, secao "Arquivos relevantes e dependentes" (frontend): `scripts/check-raw-amount-usage.mjs` (ou similar) + wiring em `package.json`/CI.

## Criterios de Sucesso

- `npm run build` (ou o script de CI equivalente) falha se um componente fora da allowlist somar/exibir `.amount` bruto para fins de "gasto do mes".
- A allowlist esta documentada no proprio script, com justificativa por item.
- O script roda em menos de alguns segundos (varredura textual simples, sem impacto perceptivel no tempo de build).

## Testes da Tarefa

- [ ] Teste manual/scriptado: script falha ao detectar um uso proibido introduzido de proposito; passa limpo no estado atual do codigo apos a Tarefa 7.0.
- [ ] Verificacao de integracao ao pipeline: confirmar que o script roda como parte do `npm run build` ou de um step de CI dedicado.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `scripts/check-raw-amount-usage.mjs` (novo)
- `package.json` (wiring do script no `build`/CI)
