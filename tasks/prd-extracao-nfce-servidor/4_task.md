# Tarefa 4.0: Dockerizacao e logging estruturado do microservico

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Empacotar o `nfce-extraction-service` em uma imagem Docker pronta para rodar na VPS de Sao Paulo (mesma maquina do backend Kotlin), com log estruturado leve via `pino`, e validar localmente que o container sobe corretamente e responde ao healthcheck. O deploy efetivo na VPS e a exposicao apenas na rede interna ficam documentados aqui, mas a execucao do deploy em si e uma acao operacional fora do escopo de codigo desta tarefa.

<skills>
### Conformidade com Skills Padroes

Nao ha skill dedicada a Docker/deploy no repositorio. Nenhuma skill padrao do orquestrador se aplica diretamente alem das boas praticas gerais de codigo limpo.
</skills>

<requirements>
- `Dockerfile` multi-stage (build TypeScript -> imagem final enxuta) incluindo as dependencias do Chromium exigidas pelo Playwright.
- Imagem final deve iniciar o servidor (Tarefa 3.0) e responder a `GET /health`.
- Substituir os `console.log`/logs ad-hoc por logging estruturado com `pino`: um log por extracao contendo status final (`READY/BLOCKED/TIMEOUT/NAVIGATION_ERROR`) e duracao, **sem** logar HTML da pagina ou dados pessoais da nota (CPF/CNPJ do consumidor, endereco).
- Documentar (`README.md` ou `DEPLOY.md` do `nfce-extraction-service`) as variaveis de ambiente de producao, requisito de RAM (~1-2GB para o Chromium de longa duracao) e a orientacao de rede (porta acessivel somente internamente na VPS, nunca exposta publicamente).
- Validar localmente: build da imagem + `docker run` + chamada a `GET /health` respondendo `200`.
</requirements>

## Subtarefas

- [ ] 4.1 Escrever o `Dockerfile` multi-stage do `nfce-extraction-service`, incluindo dependencias de sistema do Chromium/Playwright.
- [ ] 4.2 Adicionar `pino` e substituir logs ad-hoc por logging estruturado (status + duracao por extracao, sem HTML/dados pessoais).
- [ ] 4.3 Adicionar `.dockerignore` (excluir `node_modules`, fixtures de teste, etc.) para manter a imagem enxuta.
- [ ] 4.4 Documentar variaveis de ambiente, requisito de RAM e orientacao de rede interna em `README.md`/`DEPLOY.md`.
- [ ] 4.5 Build local da imagem (`docker build`) e execucao (`docker run`), validando `GET /health` via `curl`.
- [ ] 4.6 Validar manualmente que os logs de uma extracao de teste (contra fixture local) nao contem HTML nem dados pessoais.

## Detalhes de Implementacao

Ver Tech Spec, secoes "Monitoramento e Observabilidade" (Node: `pino`, status final e duracao, sem persistir HTML) e "Dependencias Tecnicas" (Docker na VPS, RAM ~1-2GB, segredo compartilhado entre servicos) e "Sequenciamento de Desenvolvimento" > item 2 (dockerizacao e smoke test).

## Criterios de Sucesso

- A imagem builda sem erros e o container sobe com `docker run`.
- `GET /health` responde `200` a partir do container rodando localmente.
- Os logs gerados durante uma extracao de teste contem status e duracao, mas nenhum HTML ou dado pessoal da nota.

## Testes da Tarefa

- [ ] Teste manual/scriptado de build + run local do container, validando `GET /health`.
- [ ] Teste de integracao: reexecutar a suite de `supertest` da Tarefa 3.0 dentro do container (ou validar que a mesma suite passa com a imagem buildada), garantindo paridade de comportamento.
- [ ] Testes E2E: nao aplicavel nesta tarefa (deploy real na VPS e smoke test contra SEFAZ real ficam na Tarefa 8.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `nfce-extraction-service/Dockerfile` (novo)
- `nfce-extraction-service/.dockerignore` (novo)
- `nfce-extraction-service/src/logger.ts` (novo, configuracao do `pino`)
- `nfce-extraction-service/README.md`/`DEPLOY.md` (novo/atualizado)
