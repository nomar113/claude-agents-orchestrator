# Tarefa 6.0: Validar fluxo completo build → deploy automático e observabilidade

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Última tarefa do pipeline: validar o fluxo completo, de ponta a ponta — build Android Release assinado seguido do envio automático para a trilha de testes internos da Google Play — e garantir que falhas (de build ou de deploy) fiquem visíveis no Appflow sem necessidade de reprodução manual local (FR4 e FR7 do PRD). Também confirma que o pipeline iOS existente não sofreu nenhuma regressão com as mudanças desta funcionalidade.

<skills>
### Conformidade com Skills Padroes

- Não aplicável — validação de pipeline de CI/CD, sem código de aplicação.
</skills>

<requirements>
- O deploy automático deve ser disparado a partir de um Native Build Android (Release) bem-sucedido, usando o Destination configurado na Tarefa 5.0.
- O artefato deve chegar à trilha de testes internos da Google Play Console, sem promoção automática a produção.
- Falhas de build e de deploy devem aparecer nos logs do Appflow.
- O pipeline iOS existente (build/deploy) deve continuar funcionando sem alterações de comportamento.
</requirements>

## Subtarefas

- [ ] 6.1 Disparar um Native Build Android (Release) configurado para acionar o Destination automaticamente ao final do build.
- [ ] 6.2 Acompanhar build e deploy até a conclusão, confirmando sucesso em ambas as etapas no Appflow.
- [ ] 6.3 Confirmar na Google Play Console que o novo artefato aparece na trilha de testes internos, com o `versionCode` esperado.
- [ ] 6.4 Configurar notificação (e-mail ou equivalente já usado pelo iOS) para falhas de build/deploy Android no Appflow.
- [ ] 6.5 Simular um cenário de falha controlada (ex.: disparar deploy com credencial temporariamente inválida, se seguro fazê-lo em ambiente de teste) para confirmar que o erro fica visível no Appflow sem necessidade de debug local; reverter a credencial em seguida.
- [ ] 6.6 Disparar (ou revisar o último) build iOS para confirmar que nenhuma regressão foi introduzida pelas mudanças no script `appflow:build` compartilhado.

## Detalhes de Implementacao

Ver Tech Spec, seções "Sequenciamento de Desenvolvimento" (passo 6), "Monitoramento e Observabilidade" e "Riscos Conhecidos".

## Criterios de Sucesso

- Fluxo build → deploy automático Android funciona de ponta a ponta sem intervenção manual.
- Artefato visível na trilha de testes internos da Google Play Console.
- Falhas de build/deploy são rastreáveis diretamente no Appflow.
- Pipeline iOS existente permanece funcional, sem regressão.

## Testes da Tarefa

- [ ] Testes de unidade: não aplicável.
- [ ] Testes de integração: execução real do fluxo build → deploy Android no Appflow, com verificação do artefato na Play Console.
- [ ] Testes E2E: cenário de falha controlada validando visibilidade do erro no Appflow; confirmação de que o build iOS mais recente continua bem-sucedido (regressão).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código novo — validação end-to-end do pipeline configurado nas Tarefas 1.0 a 5.0.
- `controlai-frontend/package.json` (referência, script modificado na Tarefa 1.0).
