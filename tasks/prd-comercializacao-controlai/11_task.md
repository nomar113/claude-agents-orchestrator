# Tarefa 11.0: Testes E2E de ponta a ponta

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Cobrir com testes E2E (Playwright) os fluxos críticos de negócio desta funcionalidade, validando a integração real entre backend e frontend após todas as tarefas anteriores estarem concluídas: bloqueio de acesso sem assinatura, acesso liberado para grandfathered, e ausência do cadastro público. Depende de todas as tarefas de 2.0 a 9.0 estarem concluídas.

<skills>
### Conformidade com Skills Padrões

- `ionic-design` / `frontend-design` — nenhuma implementação de UI nova nesta tarefa, apenas testes sobre o que já existe.
</skills>

<requirements>
- Tech Spec `Abordagem de Testes > Testes de E2E`: usuário sem assinatura ativa vê a tela de bloqueio ao logar; usuário grandfathered acessa normalmente; rota `/register` não existe mais.
- PRD `Histórias de Usuário`: cobrir o fluxo de liberação automática de acesso e o fluxo de usuário existente mantendo acesso gratuito.
</requirements>

## Subtarefas

- [ ] 11.1 Cenário E2E: usuário grandfathered (grupo com `plan = GRANDFATHERED`) loga e acessa normalmente as telas principais do app (`/tab1`, etc.).
- [ ] 11.2 Cenário E2E: usuário com assinatura `CANCELLED`/sem assinatura loga e é redirecionado para a `SubscriptionRequiredPage`, sem conseguir acessar nenhuma tela protegida.
- [ ] 11.3 Cenário E2E: simular (via chamada direta ao backend de teste, ou fixture) um webhook `compra_aprovada` e verificar que o usuário criado consegue, após definir senha via link recebido, logar e acessar o app normalmente.
- [ ] 11.4 Cenário E2E: confirmar que a rota `/register` não está mais acessível/funcional no app.
- [ ] 11.5 Rodar a suíte completa (`npm run test.e2e.pw`) localmente e documentar os resultados.

## Detalhes de Implementação

Ver Tech Spec `Abordagem de Testes > Testes de E2E`. Usar a infraestrutura de testes E2E já existente no `controlai-frontend` (Playwright configurado em `@playwright/test`).

## Critérios de Sucesso

- Todos os cenários E2E listados passam de forma consistente (sem flakiness).
- A suíte E2E cobre tanto o caminho feliz (grandfathered e novo assinante) quanto o caminho de bloqueio (sem assinatura).

## Testes da Tarefa

- [ ] Suíte E2E Playwright cobrindo os 4 cenários acima, integrada ao pipeline de CI existente (se houver).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Novos specs Playwright em `controlai-frontend` (diretório de testes E2E existente).
- Depende de: Tarefas 2.0 a 9.0 (todas concluídas e integradas).
