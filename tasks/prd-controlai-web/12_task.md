# Tarefa 12.0: Validação final de deploy em produção

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Fechar o ciclo de implementação validando o ControlAI Web completo (shell desktop, todas as telas responsivas, acessibilidade, fluxo de NFC-e manual) publicado em produção, com o domínio final e a configuração de CORS definitiva, executando um smoke test ponta a ponta contra a API de produção real.

<skills>
### Conformidade com Skills Padroes

- `kotlin-springboot` — validação da configuração final de CORS em produção.
- `ionic-design` — validação visual final do build web publicado.
</skills>

<requirements>
- Tech Spec `Sequenciamento de Desenvolvimento`: última etapa, após shell, todas as telas responsivas, acessibilidade e E2E desktop/mobile.
- PRD `Objetivos`: paridade funcional completa e consistência de dados entre web e mobile devem ser verificadas com dados reais (não apenas ambiente de teste).
- Confirmar que nenhuma credencial/URL de teste ficou hardcoded no build de produção.
</requirements>

## Subtarefas

- [ ] 12.1 Confirmar o domínio final de produção do ControlAI Web (promovendo de preview para produção na Vercel/Netlify, se ainda não feito).
- [ ] 12.2 Atualizar `CORS_ALLOWED_ORIGIN_PATTERNS` no backend de produção com o domínio final (revisando a configuração provisória da Tarefa 2.0).
- [ ] 12.3 Rodar a suíte E2E Playwright (Tarefas 10.0 e 11.0) apontando para a URL de produção e a API de produção.
- [ ] 12.4 Executar smoke test manual cobrindo o fluxo completo do PRD: login com conta real → dashboard → cartões/sub-cartões compartilhados → fatura → registrar/editar/cancelar compra manual → orçamento.
- [ ] 12.5 Confirmar consistência de dados entre web e mobile: uma alteração feita na web (ex.: nova compra) aparece no app mobile do mesmo usuário sem sincronização manual, e vice-versa.

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento` (etapa final) e `Monitoramento e Observabilidade`.

## Critérios de Sucesso

- ControlAI Web publicado em produção, acessível pelo domínio final, sem erros de CORS.
- Smoke test manual do fluxo completo do PRD passa sem erros.
- Alteração feita na web reflete no app mobile do mesmo usuário (e vice-versa) sem ação manual, confirmando RF-8 do PRD.

## Testes da Tarefa

- [ ] Testes E2E Playwright (desktop + mobile) executados contra produção, passando.
- [ ] Smoke test manual documentado (passo a passo executado e resultado).
- [ ] Teste manual de consistência cross-plataforma (alteração na web refletindo no mobile e vice-versa).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Configuração de produção do projeto Vercel/Netlify (fora do repositório)
- `controlai/application.yml` / variável de ambiente `CORS_ALLOWED_ORIGIN_PATTERNS` em produção
- Depende de: todas as tarefas anteriores (1.0 a 11.0)
