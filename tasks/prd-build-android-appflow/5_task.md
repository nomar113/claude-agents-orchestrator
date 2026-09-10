# Tarefa 5.0: Configurar Destination Google Play (trilha de testes internos)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Esta tarefa configura o envio automático do artefato Android para a Google Play, na trilha de testes internos, atendendo aos FR5 e FR6 do PRD (atualizado). Isso envolve garantir que o app já existe na Google Play Console, criar uma service account no Google Cloud com permissão de upload, e cadastrar essa credencial como Destination no Appflow.

<skills>
### Conformidade com Skills Padroes

- Não aplicável — configuração de credenciais e dashboard (Google Cloud/Play Console + Appflow), sem código de aplicação.
</skills>

<requirements>
- O app `br.com.nomar.controlai` deve existir na Google Play Console antes de configurar o Destination (pré-requisito de conta, não criado por este pipeline — ver Restrições Técnicas do PRD).
- A service account deve ter permissão de upload restrita ao necessário para a trilha de testes internos (não deve ter permissão de promover a produção).
- A credencial JSON da service account não deve ser commitada no repositório — cadastro apenas no dashboard do Appflow.
- O Destination deve apontar exclusivamente para a trilha `internal` (testes internos), nunca para produção, conforme FR6 do PRD.
</requirements>

## Subtarefas

- [ ] 5.1 Confirmar que o app `br.com.nomar.controlai` já existe na Google Play Console (criar manualmente, se necessário, mesmo sem ficha pública completa).
- [ ] 5.2 No Google Cloud Console (projeto vinculado à Play Console), habilitar a Google Play Developer API e criar uma service account com papel de upload de release.
- [ ] 5.3 Gerar e baixar a chave JSON da service account, e vincular a service account ao app no Google Play Console (Configurações → Acesso à API).
- [ ] 5.4 No dashboard do Appflow, configurar o Destination Android para Google Play (`appflow destination create-android` via CLI, ou equivalente na UI), informando `package-name br.com.nomar.controlai`, trilha `internal`, e a chave JSON como credencial.
- [ ] 5.5 Guardar a chave JSON em local seguro (cofre de senhas), fora do repositório.

## Detalhes de Implementacao

Ver Tech Spec, seções "Arquitetura do Sistema > Visão Geral dos Componentes" (Appflow — Destination Google Play) e "Pontos de Integração" (Google Play Console — Service Account).

## Criterios de Sucesso

- Destination Android configurado no Appflow, apontando para a trilha de testes internos da Google Play Console.
- Service account com permissões mínimas necessárias (sem acesso a produção).
- Nenhuma credencial commitada no repositório.

## Testes da Tarefa

- [ ] Testes de unidade: não aplicável.
- [ ] Testes de integração: Destination configurado no Appflow sem erro de validação de credencial (teste de conexão, se disponível na UI do Appflow).
- [ ] Testes E2E: validado em conjunto com a Tarefa 6.0 (disparo real do deploy end-to-end).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — configuração feita no Google Cloud Console, Google Play Console e dashboard do Appflow.
