# Tarefa 2.0: Validar pipeline de build Android sem assinatura (Debug) no Appflow

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Antes de introduzir a complexidade de keystore e assinatura de release, é preciso validar que o pipeline Android compila de ponta a ponta no Appflow — build stack compatível, dependências resolvidas, script `appflow:build` (corrigido na Tarefa 1.0) funcionando em ambiente real de CI. Esta tarefa configura e dispara um Native Build Android do tipo Debug no dashboard do Appflow, sem depender de Signing Certificate.

<skills>
### Conformidade com Skills Padroes

- Não aplicável — tarefa de configuração de CI/CD no dashboard do Appflow, sem alteração de código de aplicação.
</skills>

<requirements>
- A Tarefa 1.0 deve estar concluída e mergeada na branch principal antes de disparar este build (o Appflow builda a partir do repositório remoto).
- O build deve ser do tipo Debug (não requer certificado de assinatura).
- Deve ser possível acompanhar o log completo do build no próprio Appflow, sem necessidade de reprodução local.
</requirements>

## Subtarefas

- [x] 2.1 No dashboard do Appflow, adicionar a plataforma Android ao app ControlAI (se ainda não listada) e selecionar uma build stack compatível com `compileSdk 36` / `targetSdk 36` (ver risco documentado na Tech Spec).
- [x] 2.2 Disparar um Native Build Android (Build Type: Debug) a partir da branch principal.
- [x] 2.3 Acompanhar o log de build no Appflow até a conclusão (sucesso ou falha).
- [x] 2.4 Se o build falhar por incompatibilidade de build stack (SDK/Gradle/JDK), documentar o erro exato e ajustar a build stack selecionada ou abrir chamado com a Ionic, conforme necessário. (Não se aplicou — build stack "Linux - 2026.08" já suporta Android SDK 27-37, cobrindo `compileSdk 36`.)
- [x] 2.5 Baixar o artefato de debug gerado e confirmar que ele instala em um dispositivo/emulador Android (validação manual básica de instalação, não de funcionalidade).

### Evidência dos testes (2026-09-10)

- **Plataforma/build stack**: ao selecionar "Android" no formulário de novo build, o Appflow ofereceu automaticamente a stack "Linux - 2026.08" (Latest), com Android SDK 27-37 — compatível com `compileSdk 36`/`targetSdk 36` do projeto. Nenhum ajuste necessário.
- **Build disparado**: Package Build #64, commit `f85927` (branch `main`), Platform Android, Type debug, via dashboard do Appflow (Claude in Chrome, sessão já autenticada do usuário). URL: `https://dashboard.ionicframework.com/app/d1bc9787/build/builds/11123779`.
- **Log de build**: concluído com status **Success** em 4m28s (4 créditos). Confirma em produção que a correção da Tarefa 1.0 funciona: `trapeze` aplicou `versionCode 64` (mesmo número que seria usado no iOS via `CI_BUILD_NUMBER`), `npm run build` rodou sem erro, e `npx cap copy android` + `cap sync android` executaram corretamente, detectando os 8 plugins Capacitor do projeto (incluindo MLKit barcode-scanning, biometric, social login) + 1 plugin Cordova (`cordova-plugin-inappbrowser`).
- **Artefato**: Appflow gerou automaticamente tanto AAB quanto APK. Build ID `11123779`.
- **Instalação real em dispositivo**: APK de debug baixado (33.5MB, via URL pré-assinada S3 do próprio Appflow) e instalado via `adb install` em um Redmi Note 8 Pro físico (Android 11, SDK 30) conectado à máquina. Uma versão anterior já instalada (versionCode 1, sideload manual anterior, assinatura diferente) precisou ser desinstalada primeiro (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). Após reinstalar, o app foi aberto via `adb shell monkey` e a tela de login do ControlAI carregou corretamente (screenshot capturado via `adb screencap`, sem crash). `versionCode=64` confirmado via `dumpsys package`.
- Nenhuma falha de build/deploy ocorreu nesta execução, então o critério "falhas devem ser visíveis no Appflow" (FR4) não pôde ser exercitado negativamente aqui — será reforçado na Tarefa 6.0 com um cenário de falha controlada.

## Detalhes de Implementacao

Ver Tech Spec, seções "Pontos de Integração" (build stack Android) e "Riscos Conhecidos" (compatibilidade de `compileSdk 36` com a build stack do Appflow).

## Criterios de Sucesso

- Native Build Android (Debug) conclui com sucesso no Appflow, usando o script `appflow:build` corrigido na Tarefa 1.0.
- O artefato de debug gerado instala corretamente em um dispositivo/emulador Android.
- Log de build acessível e legível diretamente no Appflow, sem necessidade de debug local (atende ao FR4 do PRD).

## Testes da Tarefa

- [x] Testes de unidade: não aplicável.
- [x] Testes de integração: Native Build Android (Debug) disparado no Appflow (Build #64), validado via log de sucesso completo.
- [x] Testes E2E: APK instalado via `adb install` em dispositivo físico (Redmi Note 8 Pro, Android 11) e aberto via `adb shell monkey` — tela de login do ControlAI carregou sem crash.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código novo — configuração feita no dashboard do Appflow (Build #64, ID `11123779`).
- `controlai-frontend/android/variables.gradle` (referência, para conferência de `compileSdkVersion`/`targetSdkVersion`).
- `controlai-frontend/android/app/build.gradle` e `AndroidManifest.xml` (atualizados em runtime pelo `trapeze` durante o build, não commitados — `versionCode` é aplicado a cada build, não persistido no repo).
