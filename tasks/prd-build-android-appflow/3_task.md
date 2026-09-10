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

- [x] 3.1 Gerar o keystore com `keytool` (ex.: `keytool -genkey -v -keystore controlai-release.jks -alias controlai -keyalg RSA -keysize 2048 -validity 10000`), definindo senha do keystore e da chave.
- [x] 3.2 Guardar o arquivo `.jks` e as senhas em local seguro (gerenciador de senhas/cofre), fora do repositório de código.
- [x] 3.3 No dashboard do Appflow, ir em Build → Signing Certificates → Add Profile, cadastrar o keystore, alias, senha do keystore e senha da chave para o app ControlAI (plataforma Android).
- [x] 3.4 Confirmar no Appflow que o certificado foi validado com sucesso (sem erro de senha/alias incorreto).

### Evidência dos testes (2026-09-10)

- **Geração do keystore**: decisão de segurança tomada com o usuário antes de gerar — como o `keytool` interativo exigiria que o usuário rodasse o comando ele mesmo (senha nunca passando pelo executor) e o usuário optou por delegar a geração, o executor gerou duas senhas aleatórias fortes (28 caracteres alfanuméricos via `/dev/urandom`) e rodou `keytool -genkeypair -v -keystore ~/Documents/controlai-secrets/controlai-release.jks -alias controlai -keyalg RSA -keysize 2048 -validity 10000 -storepass ... -keypass ... -dname "CN=ControlAI, OU=ControlAI, O=Nomar, L=Sao Paulo, ST=SP, C=BR"`.
- **Achado técnico**: o `keytool` avisou que o formato PKCS12 (padrão atual) não suporta senha de keystore diferente da senha da chave — ignorou a segunda senha gerada e usou a primeira para ambas. As duas senhas foram exibidas ao usuário uma única vez nesta conversa para ele salvar no gerenciador de senhas; a senha não utilizada foi explicitamente descartada na comunicação; o arquivo temporário que continha as senhas em texto puro (`/tmp/.controlai_keystore_pw`) foi apagado (`shred -u`) logo após o uso.
- **Verificação do keystore**: `keytool -list -v` confirmou RSA 2048 bits, alias `controlai`, algoritmo `SHA384withRSA`, válido de 10/09/2026 até 26/01/2054 (~10.000 dias).
- **Local de armazenamento**: `~/Documents/controlai-secrets/controlai-release.jks` — fora do repositório git (pasta criada especificamente fora de qualquer working tree). O `.jks` em si não é considerado segredo suficiente sozinho (sem a senha é inútil), mas o ideal a médio prazo é o usuário mover esse arquivo para um cofre/gerenciador de senhas com suporte a anexos, não apenas mantê-lo na pasta Documents.
- **Cadastro no Appflow**: o executor preparou o formulário "Add signing certificate" (Build → Signing Certificates → Android) via Claude in Chrome — nome `controlai-android-release-Sep 10, 2026`, upload do arquivo `.jks` (copiado temporariamente para o scratchpad da sessão para permitir o upload via automação de navegador, e apagado do scratchpad logo em seguida), correção do campo "Key alias" (veio pré-preenchido com um valor incorreto, `controlai-certificate`, corrigido para `controlai` — o alias real usado na geração), e limpeza do campo "Key password" que apareceu pré-preenchido (provável autofill do Chrome, não inserido pelo executor). Os dois campos de senha (`Certificate password` e `Key password`) foram deixados vazios propositalmente — o usuário digitou a senha pessoalmente nos dois campos e confirmou o cadastro.
- **Validação no Appflow**: certificado `controlai-android-release-Sep 10, 2026` aparece na listagem de Signing Certificates, tipo `production`, plataforma `Android`, com data de expiração `Jan 26, 2054` — batendo exatamente com a validade do keystore gerado (`keytool -list -v`), confirmando que Appflow aceitou a senha/alias sem erro (atende ao critério de sucesso da task e ao FR2 do PRD, que exige artefato assinado).

## Detalhes de Implementacao

Ver Tech Spec, seções "Arquitetura do Sistema > Visão Geral dos Componentes" (Appflow — Signing Certificate Android) e "Restrições Técnicas de Alto Nível" do PRD.

## Criterios de Sucesso

- Keystore Android gerado e validado com sucesso no Appflow como Signing Certificate.
- Nenhuma credencial de assinatura commitada no repositório de código.
- Certificado disponível para seleção em builds Android do tipo Release (validado na Tarefa 4.0).

## Testes da Tarefa

- [x] Testes de unidade: não aplicável.
- [x] Testes de integração: cadastro do certificado no Appflow concluído sem erro de validação — certificado listado em Build → Signing Certificates com plataforma Android e expiração batendo com o keystore gerado.
- [x] Testes E2E: não aplicável nesta tarefa (uso efetivo do certificado num build Release será validado na Tarefa 4.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — keystore e credenciais vivem fora do repositório (cofre de senhas + Appflow dashboard).
- `controlai-frontend/capacitor.config.ts` (referência, `appId` usado para conferência).
- `~/Documents/controlai-secrets/controlai-release.jks` (fora do repositório; recomenda-se mover para um cofre/gerenciador de senhas com suporte a anexos).
- Appflow: Signing Certificates → `controlai-android-release-Sep 10, 2026` (Android, expira 26/01/2054).
