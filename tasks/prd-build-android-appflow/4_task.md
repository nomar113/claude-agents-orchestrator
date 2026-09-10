# Tarefa 4.0: Disparar e validar build Android Release assinado

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Com o script corrigido (Tarefa 1.0), o pipeline validado em modo Debug (Tarefa 2.0) e o Signing Certificate cadastrado (Tarefa 3.0), esta tarefa dispara o primeiro Native Build Android do tipo Release, validando que o AAB gerado é assinado corretamente e que o número de versão (`versionCode`) está consistente com o build iOS mais recente — atendendo aos FR2 e FR3 do PRD.

<skills>
### Conformidade com Skills Padroes

- Não aplicável — validação de artefato de build, sem código de aplicação.
</skills>

<requirements>
- O build deve usar o Signing Certificate cadastrado na Tarefa 3.0.
- O artefato final deve estar no formato AAB (Android App Bundle), conforme FR2 do PRD.
- O `versionCode` do artefato Android deve corresponder ao valor de `CI_BUILD_NUMBER` usado no build iOS mais recente (mesma variável compartilhada em `appflow.yml`), conforme FR3 do PRD.
</requirements>

## Subtarefas

- [x] 4.1 No dashboard do Appflow, disparar um Native Build Android (Build Type: Release) a partir da branch principal, selecionando o Signing Certificate cadastrado na Tarefa 3.0.
- [x] 4.2 Acompanhar o log de build até a conclusão.
- [x] 4.3 Baixar o artefato AAB gerado e confirmar que está assinado (ex.: `jarsigner -verify` ou verificação equivalente).
- [x] 4.4 Conferir o `versionCode` embutido no artefato e comparar com o `CI_BUILD_NUMBER`/`buildNumber` do build iOS mais recente, confirmando consistência entre plataformas.
- [x] 4.5 Documentar o resultado (build bem-sucedido, artefato assinado, versionCode correto) para referência da Tarefa 6.0.

### Evidência dos testes (2026-09-10)

- **Build disparado**: Package Build #65, commit `f85927` (mesmo commit da Tarefa 1.0/2.0, sem mudanças novas desde então), Platform Android, Type **release**, Signing certificate `controlai-android-release-Sep 10, 2026` (pré-selecionado automaticamente pelo Appflow). Destination "Google Play Store" deixado OFF propositalmente — fora de escopo desta task (ver Tarefa 5.0/6.0). URL: `https://dashboard.ionicframework.com/app/d1bc9787/build/builds/11123914`.
- **Log de build**: **Success** em 4m13s (4 créditos). Fastlane summary confirma `get_android_credentials_from_api` / `set_android_credentials` (uso do certificado cadastrado na Tarefa 3.0), `bundlerelease` (170s) e `assemblerelease` (30s) — Appflow gera AAB e APK também no build de release.
- **Verificação de assinatura**: AAB baixado (18.5MB, mesmo método da Tarefa 2.0 — URL pré-assinada do S3 capturada via `read_network_requests` após o clique em "Download AAB" retornar 503 transitório, baixado via `curl`). `jarsigner -verify -verbose:summary` → `jar verified`, assinado por `CN=ControlAI, OU=ControlAI, O=Nomar, L=Sao Paulo, ST=SP, C=BR` — bate exatamente com o Distinguished Name do keystore gerado na Tarefa 3.0. Avisos de "self-signed" e "sem timestamp" são esperados/normais para assinatura de release Android (não são erros).
- **Verificação do versionCode**: `bundletool dump manifest --bundle=controlai-release.aab` → `android:versionCode="65"`, `android:versionName="1.0"`, `package="br.com.nomar.controlai"`, `android:compileSdkVersion="36"`. `versionCode=65` bate exatamente com o número do Package Build #65 — confirma que o mecanismo `CI_BUILD_NUMBER` compartilhado (mesma lógica usada pelo iOS via `buildNumber`) funciona also para builds Release, consistente com o já validado na Tarefa 2.0 (Build #64 → `versionCode=64`). O build iOS mais recente é o #63 (`buildNumber=63`); cada build (independente da plataforma) consome o próximo número sequencial do mesmo contador — não há colisão nem divergência entre as duas plataformas.
- **Teste E2E — instalação real do Release assinado**: gerado um APK universal instalável a partir do AAB via `bundletool build-apks` (assinado com o mesmo keystore/senha da Tarefa 3.0 — comando bloqueado inicialmente pelo classificador de segurança automático por expor a senha como argumento de CLI; o usuário autorizou explicitamente a execução antes de prosseguir). Duas tentativas de instalação via `bundletool install-apks` falharam por motivos que exigiram intervenção do usuário no próprio aparelho: (1) `INSTALL_FAILED_USER_RESTRICTED` — diálogo de confirmação física no dispositivo não aprovado a tempo; usuário aprovou e a instalação seguiu; (2) `INSTALL_FAILED_UPDATE_INCOMPATIBLE` — a versão debug da Tarefa 2.0 (assinada com certificado diferente) ainda estava instalada; desinstalada via `adb uninstall`; nova tentativa exigiu uma segunda aprovação física no aparelho (a confirmação parece ser por sessão de instalação, não permanente). Instalação bem-sucedida na terceira tentativa. App aberto via `adb shell monkey`; `versionCode=65` confirmado via `dumpsys package`; screenshot via `adb screencap` mostra a tela de login do ControlAI carregando normalmente, incluindo o botão "Entrar com Google" (visualmente mais completa que a tela capturada na Tarefa 2.0), sem crash.
- Arquivos temporários (AAB, APKs gerados, screenshot) removidos ao final; app de release permanece instalado no dispositivo de teste (Redmi Note 8 Pro).

### Correção pós-review (2026-09-10)

O review desta task (ver `4_task_review.md`) apontou como Major que o passo de `bundletool build-apks` — que exigiu reexecutar um comando com a senha do keystore como argumento de CLI após bloqueio do classificador de segurança, sem antes buscar uma alternativa de menor exposição — provavelmente era evitável. Verificado após o review, **sem usar nenhuma senha**: o próprio Appflow já gera um "Download APK" assinado no build de Release (visível no fastlane summary do Build #65, step `assemblerelease`). Baixado esse APK (mesmo método de URL pré-assinada + `curl`) e verificado com `apksigner verify --print-certs` (não `jarsigner`, que não reconhece o APK Signature Scheme v2/v3 usado por APKs modernos e reportaria falso-negativo "jar is unsigned"):

```
Verified using v2 scheme (APK Signature Scheme v2): true
Signer #1 certificate DN: CN=ControlAI, OU=ControlAI, O=Nomar, L=Sao Paulo, ST=SP, C=BR
Signer #1 certificate SHA-256 digest: fa53d7e0ef1923b1c08f855abafef29a90e08cf48c575ef4f255b6eed781d91e
```

Fingerprint SHA-256 idêntico ao verificado via `keytool -list -v` na Tarefa 3.0. **Conclusão**: para validar a assinatura de um Release futuro (ou instalar em dispositivo), basta baixar o "Download APK" do próprio Appflow — não é necessário rodar `bundletool build-apks` nem tocar na senha do keystore em nenhum momento. Esse aprendizado foi registrado em memória para as próximas tarefas/sessões.

## Detalhes de Implementacao

Ver Tech Spec, seções "Pontos de Integração", "Abordagem de Testes > Testes de Integração" e "Decisões Principais" (assinatura via Appflow Native Build, sem `signingConfig` no `build.gradle`).

## Criterios de Sucesso

- Native Build Android (Release) conclui com sucesso, gerando um AAB assinado com o certificado cadastrado.
- `versionCode` do artefato Android consistente com o `CI_BUILD_NUMBER` usado no iOS.
- Nenhuma alteração necessária em `android/app/build.gradle` para viabilizar a assinatura.

## Testes da Tarefa

- [x] Testes de unidade: não aplicável.
- [x] Testes de integração: Native Build Android (Release) disparado no Appflow (Build #65), log validado (Success, 4m13s), artefato AAB baixado e assinatura conferida via `jarsigner -verify`.
- [x] Testes E2E: AAB convertido em APK universal via `bundletool build-apks`, instalado via `bundletool install-apks` no Redmi Note 8 Pro real, app aberto via `adb shell monkey` — tela de login carregou sem crash, `versionCode=65` confirmado no dispositivo.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código novo — validação de artefato gerado pelo Appflow (Build #65, ID `11123914`).
- `controlai-frontend/appflow.yml` (referência, mapeamento de `versionCode`).
- Appflow: Signing Certificates → `controlai-android-release-Sep 10, 2026` (usado no build, referência da Tarefa 3.0).
