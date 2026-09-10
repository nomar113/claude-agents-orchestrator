# Tarefa 3.0: Gerar e cadastrar o keystore Android como Signing Certificate no Appflow

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

O ControlAI não possui hoje nenhum keystore Android. Esta tarefa gera um novo keystore de assinatura de release (`.jks`), com validade longa (~10.000 dias, conforme prática padrão do ecossistema Android/Ionic), e o cadastra no Appflow como Signing Certificate do app, para uso nos builds Android do tipo Release.

<skills>
### Conformidade com Skills Padroes

- Não aplicável — tarefa de geração de credencial e configuração de dashboard, sem código de aplicação.
</skills>

<requirements>
- O keystore gerado deve usar RSA, chave de 2048 bits, validade de longo prazo.
- As senhas do keystore e da chave (alias) devem ser armazenadas com segurança (gerenciador de senhas), nunca commitadas no repositório.
- O keystore em si (arquivo `.jks`) não deve ser commitado no repositório — cadastro é feito diretamente no dashboard do Appflow.
- O certificado deve ser associado ao app ControlAI e ao `applicationId` `br.com.nomar.controlai` (mesmo já usado em `capacitor.config.ts`).
</requirements>

## Subtarefas

- [ ] 3.1 Gerar o keystore com `keytool` (ex.: `keytool -genkey -v -keystore controlai-release.jks -alias controlai -keyalg RSA -keysize 2048 -validity 10000`), definindo senha do keystore e da chave.
- [ ] 3.2 Guardar o arquivo `.jks` e as senhas em local seguro (gerenciador de senhas/cofre), fora do repositório de código.
- [ ] 3.3 No dashboard do Appflow, ir em Build → Signing Certificates → Add Profile, cadastrar o keystore, alias, senha do keystore e senha da chave para o app ControlAI (plataforma Android).
- [ ] 3.4 Confirmar no Appflow que o certificado foi validado com sucesso (sem erro de senha/alias incorreto).

## Detalhes de Implementacao

Ver Tech Spec, seções "Arquitetura do Sistema > Visão Geral dos Componentes" (Appflow — Signing Certificate Android) e "Restrições Técnicas de Alto Nível" do PRD.

## Criterios de Sucesso

- Keystore Android gerado e validado com sucesso no Appflow como Signing Certificate.
- Nenhuma credencial de assinatura commitada no repositório de código.
- Certificado disponível para seleção em builds Android do tipo Release (validado na Tarefa 4.0).

## Testes da Tarefa

- [ ] Testes de unidade: não aplicável.
- [ ] Testes de integração: cadastro do certificado no Appflow concluído sem erro de validação (mensagem de sucesso do próprio dashboard).
- [ ] Testes E2E: não aplicável nesta tarefa (uso efetivo do certificado validado na Tarefa 4.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — keystore e credenciais vivem fora do repositório (cofre de senhas + Appflow dashboard).
- `controlai-frontend/capacitor.config.ts` (referência, `appId` usado para conferência).
