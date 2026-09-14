# Tarefa 7.0: Acompanhamento das submissões até aprovação

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Acompanhar o status das submissões feitas nas Tarefas 5.0 (App Store) e 6.0 (Google Play) até a aprovação e publicação efetiva em ambas as lojas, registrando e corrigindo motivos de rejeição, se houver.

<skills>
### Conformidade com Skills Padrões

- Nenhuma skill de código se aplica diretamente — tarefa de acompanhamento operacional.
</skills>

<requirements>
- PRD `Objetivos`: ter o ControlAI publicado e aprovado simultaneamente na App Store e na Google Play.
- PRD `Funcionalidades Principais > 3. Processo de submissão`, requisitos 9–10: status de cada submissão acompanhável até a publicação; em caso de rejeição, registro do motivo para correção e reenvio.
</requirements>

## Subtarefas

- [ ] 7.1 Monitorar diariamente o status da submissão no App Store Connect até sair do estado "Em Revisão".
- [ ] 7.2 Monitorar diariamente o status da submissão no Google Play Console até sair do estado "Em revisão".
- [ ] 7.3 Em caso de rejeição em qualquer uma das lojas: registrar o motivo exato informado pelo revisor, identificar a correção necessária (ficha, build ou comportamento do app) e reenviar.
- [ ] 7.4 Após aprovação em ambas as lojas, confirmar que o app está publicamente pesquisável e instalável (busca real na App Store e na Google Play).
- [ ] 7.5 Confirmar que o fluxo completo funciona ponta a ponta a partir da instalação pública: busca → instalação → login/criação de conta → redirecionamento à landing/checkout externo quando sem assinatura ativa (PRD comercialização).

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento`, etapa 8, e `Monitoramento e Observabilidade` (status nativo dos dashboards das lojas, sem instrumentação customizada).

## Critérios de Sucesso

- ControlAI aprovado e publicado simultaneamente na App Store e na Google Play.
- Qualquer rejeição foi documentada com motivo e correção aplicada antes do reenvio.
- Fluxo de descoberta → instalação → login → gate de assinatura validado ponta a ponta em produção.

## Testes da Tarefa

- [ ] Teste manual: busca pelo nome "ControlAI" (ou termo correlato) em ambas as lojas retorna o app publicado.
- [ ] Teste manual: instalação do app a partir da loja (não de um artefato manual) e execução do fluxo completo de login/gate de assinatura.
- [ ] Registro documentado de qualquer rejeição e da correção aplicada (se aplicável).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — acompanhamento operacional nos dashboards das lojas.
- Depende de: Tarefa 5.0 (submissão App Store) e Tarefa 6.0 (submissão Google Play).
