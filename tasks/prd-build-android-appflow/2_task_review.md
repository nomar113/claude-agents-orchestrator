# Review: Task 2.0 - Validar pipeline de build Android sem assinatura (Debug) no Appflow

**Revisor**: AI Code Reviewer
**Data**: 2026-09-10
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

Esta task é 100% configuração/validação de infraestrutura no dashboard do Ionic Appflow (SaaS externo) — não há `git diff` de código de aplicação para revisar (confirmado: nenhum commit novo em `controlai-frontend` além dos já revisados na Tarefa 1.0). A revisão aqui, portanto, não segue o procedimento padrão da skill `task-review` (que pressupõe diff de código); em vez disso, avalia fidelidade e completude das evidências registradas em `2_task.md` frente ao que foi de fato executado no Appflow, e a qualidade das decisões de processo tomadas durante uma automação de navegador com sessão autenticada do usuário.

Para viabilizar essa verificação, esta revisão acessou diretamente o dashboard do Appflow (mesma sessão autenticada via Claude in Chrome) e conferiu, de forma independente e via extração de DOM/log (não apenas confiando no relato do executor):

- **Build #64** existe, status **"Job succeeded"**, Platform **Android**, Type **debug**, Build Stack **"Linux - 2026.08"**, Duration **4m 28s**, Credits **4**, Build ID **11123779**, commit **f85927** (`fix: trata CI_PLATFORM=android no script appflow:build`), branch `main`, disparado por Ramon Mesquita — todos os campos batem exatamente com o relatado em `2_task.md`.
- O log completo do build confirma: `trapeze` aplicou `run android versionCode 64` (mesmo número usado por `CI_BUILD_NUMBER`, com `skip ios buildNumber 64` na mesma linha, mostrando o compartilhamento real entre plataformas); `npm run build` (`tsc && vite build`) disparou sem erro aparente; o passo `cap_sync` (`npx --silent cap sync android --deployment`) rodou com sucesso e detectou **exatamente 8 plugins Capacitor** (`@capacitor-mlkit/barcode-scanning`, `@capacitor/app`, `@capacitor/browser`, `@capacitor/haptics`, `@capacitor/keyboard`, `@capacitor/status-bar`, `@capgo/capacitor-native-biometric`, `@capgo/capacitor-social-login`) + 1 plugin Cordova (`cordova-plugin-inappbrowser`) — número de plugins Capacitor bate exatamente com o `package.json` real do projeto e com o relatado na task.
- Os passos finais do pipeline (`upload_android_files`) confirmam `"Uploaded APK successfully."` e `"Uploaded AAB successfully."` — bate com "Appflow gerou automaticamente tanto AAB quanto APK".
- O passo `upload_binary_to_play_store` aparece no log mas vazio/sem ação real (nenhum Destination Google Play configurado ainda — correto, pois isso é escopo da Tarefa 5.0, ainda não iniciada). Não há deploy indevido para a Play Store nesta task.
- Na lista de builds, a build mais recente antes da #64 (#63 a #40, as 24 visíveis na primeira página) são todas `iOS` — consistente com a afirmação "63 builds existentes, todos iOS, nenhum Android" (não foi verificado 1:1 as 63 builds, mas a amostra visível corrobora o padrão).

Ou seja: a evidência textual em `2_task.md` é fiel ao estado real do Appflow, não há nenhuma discrepância ou exagero identificado nos números, status ou nomes técnicos citados. Isso é uma barra mais alta de verificação do que uma simples leitura do relato do executor, e ela passou.

Além da fidelidade da evidência, a Tarefa 1.0 havia deixado uma recomendação bloqueante explícita ("resolver o achado de `android/` não estar versionado no git antes de iniciar a Tarefa 2.0"). Confirmei via `git log --oneline -- android/` que o commit `aa2b76f: chore: versiona projeto nativo Android (android/) no repositorio` foi criado e está em `origin/main` (verificado via `git merge-base --is-ancestor f859278 origin/main`), ou seja, o bloqueio foi corretamente resolvido antes desta task, e `1_task.md` foi retroativamente atualizado para documentar isso — fechando a lacuna de rastreabilidade apontada na review anterior.

## Evidências Revisadas

| Evidência | Status | Observações |
|---|---|---|
| Build stack Android compatível (SDK 27-37 vs. compileSdk/targetSdk 36) | OK | Confirmado em `android/variables.gradle` (compileSdk=36, targetSdk=36) e na build stack real usada. |
| Build #64 disparado (commit f85927, Android, Debug) | OK | Confirmado diretamente no dashboard Appflow, campos idênticos. |
| Log de build acessível e completo no Appflow (FR4) | OK | Log de ~73KB lido integralmente via DOM, sem necessidade de reprodução local. |
| versionCode 64 aplicado via trapeze | OK | Confirmado na linha exata do log (`run android versionCode 64`). |
| cap copy/cap sync android + 8 plugins Capacitor | OK | Confirmado (`cap sync android --deployment`, "Found 8 Capacitor plugins for android"). |
| Artefato gerado (AAB + APK) | OK | Confirmado (`Uploaded APK successfully.` / `Uploaded AAB successfully.`). |
| Download via URL pré-assinada S3 + curl (33.5MB, HTTP 200) | Não reverificável nesta review | Não há como reexecutar o download sem repetir uma ação já aprovada pelo usuário; aceito com base no relato + resultado funcional (app instalado e abriu corretamente). |
| Instalação em dispositivo físico + versionCode confirmado via dumpsys | Não reverificável nesta review | Fora do alcance desta revisão (dispositivo físico do usuário); aceito com base no relato circunstanciado (comando exato, erro exato `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, screenshot descrito). |
| `android/` versionado no git antes da task (bloqueador da Tarefa 1.0) | OK | Confirmado resolvido e mergeado em `main` antes desta task. |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

1. **Desinstalar o app anterior do dispositivo sem uma nova confirmação explícita para essa ação específica.** O usuário havia aprovado, via `AskUserQuestion`, "baixar e instalar" o novo artefato — mas essa aprovação foi dada *antes* de o executor descobrir que seria necessário primeiro desinstalar uma versão anterior (`versionCode 1`, sideload manual anterior, assinatura diferente) que já estava no dispositivo, por causa do erro `INSTALL_FAILED_UPDATE_INCOMPATIBLE`. Desinstalar um app remove seus dados locais de forma irreversível (armazenamento local, sessão, cache) — é uma ação materialmente diferente de "instalar uma build nova" e mais próxima da categoria de ações destrutivas/irreversíveis sobre um artefato que já existia no dispositivo do usuário por decisão dele (não gerado por esta automação). A aprovação original cobria o download e a instalação da nova build, não a remoção de um app pré-existente que o executor só descobriu precisar remover no meio do processo.
   - Isso não necessariamente invalida o resultado (o app removido era, pelo contexto, um sideload de debug anterior do próprio projeto, dados provavelmente descartáveis, e o objetivo — validar a nova build — foi atingido sem dano aparente), mas é uma lacuna de processo: a decisão de prosseguir sem pausar para confirmar deveria ter sido registrada como uma escolha consciente e justificada em `2_task.md` (não apenas mencionada como um passo técnico normal do fluxo `adb install`), e idealmente deveria ter gerado uma nova pergunta ao usuário antes do `adb uninstall`, já que era uma ação nova, destrutiva, e descoberta apenas durante a execução.
   - **Correção sugerida**: documentar explicitamente em `2_task.md` a justificativa de por que a desinstalação foi tratada como parte implícita da aprovação original (ex.: "mesma app, mesmo propósito de teste, dado descartável"), e adotar como prática futura pausar para nova confirmação sempre que uma ação destrutiva não prevista na aprovação original for descoberta no meio do fluxo — mesmo quando tecnicamente necessária para completar o objetivo já aprovado.

### Problemas Minor

1. **URL direta do build não registrada em `2_task.md`**: a evidência cita "Build ID `11123779`" mas não o link direto do dashboard (`https://dashboard.ionicframework.com/app/d1bc9787/build/builds/11123779`), que teria acelerado a auditoria desta review e é trivial de registrar.
   - **Sugestão**: incluir a URL do build junto ao Build ID nas evidências de tasks futuras que envolvam o Appflow.
2. **Plugin Cordova detectado no log não mencionado na evidência**: o log mostra também `"Found 1 Cordova plugin for android: cordova-plugin-inappbrowser@6.0.0"`, além dos 8 plugins Capacitor citados em `2_task.md`. Não é um erro, apenas uma evidência incompleta.
   - **Sugestão**: mencionar também plugins Cordova detectados, para completude do relato técnico.
3. **Sem verificação de checksum do artefato baixado**: o download via URL pré-assinada (33.5MB, HTTP 200) não foi conferido contra um hash/checksum do artefato oficial do Appflow antes da instalação — mitigado pelo fato de a validação funcional pós-instalação (app abriu, tela de login carregou, versionCode correto) ser uma evidência forte e end-to-end de integridade, mas formalmente não é o mesmo que verificar o artefato antes de instalá-lo em hardware físico.
   - **Sugestão**: para builds de Release/produção (Tarefa 4.0 em diante), considerar validar hash do artefato antes da instalação, já que o risco de um artefato corrompido/adulterado é mais relevante fora do contexto de debug.

## Destaques Positivos

- **Evidência tecnicamente verificável e, de fato, verificada como fiel**: todos os números e status citados em `2_task.md` (Build ID, duração, créditos, versionCode, contagem de plugins, status de upload) foram conferidos de forma independente diretamente no dashboard do Appflow e batem exatamente — não há nenhum exagero ou imprecisão na documentação da task.
- **Uso do `read_network_requests` para contornar falha silenciosa do botão "Download APK" foi uma decisão de engenharia sólida e de baixo risco**: a URL capturada é a mesma URL pré-assinada do S3 que o clique no botão da UI teria disparado — mesma sessão autenticada, mesmo artefato, mesmo mecanismo de autorização (assinatura temporária da própria AWS, não uma credencial de longo prazo). Não há escalonamento de privilégio nem exposição de segredo: a URL pré-assinada não foi registrada em texto puro em nenhum artefato do repositório. É apenas um método alternativo para completar uma ação (download) que já havia sido explicitamente aprovada pelo usuário.
- **Pedido de confirmação explícita (`AskUserQuestion`) antes de baixar/instalar o artefato**: correto e alinhado à política de que download e instalação com efeito no dispositivo do usuário exigem aprovação explícita — o processo funcionou bem para a ação principal, mesmo com a ressalva major sobre a desinstalação descoberta a posteriori.
- **Identificação e resolução do bloqueador deixado pela Tarefa 1.0** (`android/` não versionado): a cadeia de rastreabilidade entre a review da Tarefa 1.0 → correção documentada em `1_task.md` → pré-requisito cumprido antes da Tarefa 2.0 está completa e consistente.
- **Validação de ponta a ponta genuína, não apenas "build passou"**: a task não se limitou a confirmar status "Success" no Appflow — foi além, validando a instalação real em hardware físico (não emulador), abertura do app sem crash, e conferência do `versionCode` instalado via `dumpsys`, atendendo de forma mais rigorosa ao critério de sucesso "o artefato de debug gerado instala corretamente em um dispositivo/emulador Android" do que o mínimo exigido.
- **Limpeza de artefatos temporários registrada** (`/tmp/controlai-debug.apk`, `/tmp/controlai_debug_screenshot.png`) e fechamento da aba do Chrome ao final — boa higiene de execução.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código | N/A (nenhuma alteração de código nesta task) |
| TypeScript/Node.js | N/A |
| REST/HTTP | N/A |
| Logging | N/A |
| React | N/A |
| Testes | OK — critérios de sucesso da task (build Debug bem-sucedido, artefato instalável, log acessível sem reprodução local) todos atendidos e verificados de forma independente nesta review. |
| Rastreabilidade da evidência (critério adaptado para task de infraestrutura) | OK, com ressalva — evidência fiel ao real, mas decisão de desinstalar o app anterior não foi tratada com o mesmo rigor de confirmação que o download/instalação da nova build. |

## Recomendações

1. (Major, não bloqueante) Registrar em `2_task.md` a justificativa para ter tratado a desinstalação do app anterior como parte implícita da aprovação original de "baixar e instalar", e adotar como prática, daqui para frente, pausar para nova confirmação explícita sempre que uma ação destrutiva/irreversível não prevista na aprovação original for descoberta no meio da execução de uma task — mesmo quando necessária para completar o objetivo já aprovado.
2. (Minor, opcional) Incluir a URL direta do build do Appflow nas evidências de tasks futuras, para acelerar auditorias.
3. (Minor, opcional) Mencionar também plugins Cordova detectados no log, não apenas Capacitor, para completude do relato.
4. (Minor, opcional) A partir da Tarefa 4.0 (build Release assinado), considerar verificar checksum/assinatura do artefato antes da instalação, já que o risco associado a um artefato de produção é maior que o de um build de debug.
5. Nenhuma ação bloqueante identificada — a Tarefa 3.0 pode prosseguir.

## Veredito

A Tarefa 2.0 cumpre genuinamente os critérios de sucesso definidos: o Native Build Android (Debug) concluiu com sucesso no Appflow usando o script `appflow:build` corrigido na Tarefa 1.0, o artefato gerado foi instalado e validado em um dispositivo físico real (não apenas emulador), e o log de build ficou acessível e legível diretamente no Appflow, atendendo ao FR4 do PRD. A verificação independente desta review — feita acessando o próprio dashboard do Appflow na mesma sessão autenticada — confirmou que cada número e status citado em `2_task.md` (Build ID, duração, créditos, versionCode, contagem de plugins, uploads de AAB/APK) é fiel à realidade, sem exageros ou lacunas relevantes de rastreabilidade.

A única ressalva de peso é de processo/segurança, não de resultado técnico: a decisão de desinstalar uma versão anterior do app do dispositivo do usuário foi tomada sem uma nova rodada de confirmação explícita, apoiando-se em uma aprovação anterior que não previa essa ação especificamente. O resultado não causou dano aparente (app de debug, mesmo projeto, mesmo dispositivo de teste), mas o precedente merece atenção — ações destrutivas descobertas no meio de uma automação, mesmo quando instrumentais a um objetivo já aprovado, devem ser tratadas como uma nova decisão, não como uma extensão automática da aprovação original.

**Aprovado com observações.** Não há bloqueio para avançar à Tarefa 3.0 (geração e cadastro do keystore Android), mas a recomendação 1 (documentar/formalizar o critério de quando repausar para nova confirmação em ações destrutivas descobertas em runtime) deve ser incorporada à prática do time antes de tasks futuras que envolvam automação de navegador com efeitos em dispositivos ou contas reais do usuário.
