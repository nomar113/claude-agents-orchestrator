# Tech Spec: Build Android do ControlAI no Ionic Appflow

## Resumo Executivo

A solução reaproveita 100% da configuração já existente no projeto Appflow do ControlAI (mesmo app, mesmo `appflow.yml`, mesmo `capacitor.config.ts`) e adiciona a plataforma Android como um segundo alvo de Native Build, em paralelo ao pipeline iOS já operacional. O trabalho tem três frentes: (1) corrigir uma lacuna no script `appflow:build` do `package.json`, que hoje só executa `npx cap copy` para `CI_PLATFORM=ios`, deixando o projeto nativo `android/` sem sincronização de assets web/plugins quando buildado; (2) gerar um novo keystore de assinatura Android e cadastrá-lo no Appflow como Signing Certificate, já que o projeto não possui nenhum hoje; (3) configurar um Destination do Appflow para a Google Play (trilha de testes internos), autenticado via service account, disparado após cada Native Build Android bem-sucedido.

Não há mudança de código de aplicação (React/Ionic) nem de schema/API — este é um trabalho de configuração de CI/CD e um ajuste pontual de script de build. O número de versão (`versionCode`) já está unificado com o iOS via `CI_BUILD_NUMBER` em `appflow.yml`, então nenhuma mudança é necessária nesse ponto; o trabalho é validar que essa configuração já existente funciona de fato quando o build Android for disparado pela primeira vez.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **`package.json` → script `appflow:build`** (modificado): hoje roda `npx trapeze run appflow.yml -y --$CI_PLATFORM && npm run build && [cap copy ios apenas se CI_PLATFORM=ios]`. Passa a espelhar o mesmo tratamento para `CI_PLATFORM=android`, garantindo que o diretório `android/` receba os assets web (`dist/`) e a config de plugins Capacitor antes do Gradle montar o artefato.
- **`appflow.yml`** (sem alteração): já mapeia `android.versionCode` para a variável compartilhada `$CI_BUILD_NUMBER`, a mesma usada pelo `ios.buildNumber`. É o mecanismo que garante o requisito de numeração consistente entre plataformas (FR3 do PRD).
- **Projeto nativo `android/`** (sem alteração de código): estrutura Capacitor/Gradle já existente e válida (`applicationId br.com.nomar.controlai`, `minSdk 24`, `targetSdk/compileSdk 36`). Nenhum ajuste de `build.gradle` é necessário — a assinatura de release é aplicada pelo próprio Appflow Native Build a partir do Signing Certificate selecionado na UI, não por um `signingConfig` declarado no repositório (mesmo padrão presumivelmente já usado no pipeline iOS).
- **Appflow — Signing Certificate (Android)** (novo, configurado via dashboard): keystore `.jks` gerado uma única vez e cadastrado em Build → Signing Certificates, associado ao app ControlAI.
- **Appflow — Destination Google Play** (novo, configurado via dashboard): credencial de service account (JSON) do Google Play Console, apontando para `br.com.nomar.controlai`, trilha `internal`.
- **Fluxo de dados**: push/trigger na branch principal → Appflow dispara Native Build Android → `appflow:build` roda (`trapeze` aplica `versionCode`, `npm run build`, `cap copy android`) → Gradle monta e assina o AAB com o Signing Certificate → artefato disponível para download no Appflow → Destination envia o AAB para a trilha de testes internos da Google Play.

## Design de Implementação

### Interfaces Principais

Não há serviços de aplicação expostos — a "interface" relevante aqui é o contrato do script de build consumido pelo Appflow via variáveis de ambiente de CI. Mudança proposta em `package.json`:

```json
"appflow:build": "if [ \"$CI_PLATFORM\" != \"web\" ]; then npx trapeze run appflow.yml -y --$CI_PLATFORM; fi && npm run build && if [ \"$CI_PLATFORM\" = \"ios\" ]; then npx cap copy ios; elif [ \"$CI_PLATFORM\" = \"android\" ]; then npx cap copy android; fi"
```

`cap copy` (em vez de `cap sync`) é mantido por consistência com o branch iOS já existente — não instala novos plugins nativos automaticamente, mas copia web assets e config. Caso o app precise de um plugin nativo novo no futuro, isso já seria um problema pré-existente no branch iOS e não é escopo deste PRD.

### Modelos de Dados

Não aplicável — não há entidades de domínio, banco de dados ou schemas envolvidos nesta funcionalidade.

### Endpoints de API

Não aplicável — não há API de aplicação exposta. A "API" relevante é a do Google Play Developer (consumida internamente pelo Destination do Appflow via service account), que não requer código no repositório.

## Pontos de Integração

- **Ionic Appflow (Native Builds)**: build stack Android deve ser selecionado no dashboard (Node/JDK/Android SDK compatíveis com Capacitor 8 / compileSdk 36); autenticação já existente via GitHub integration do Appflow.
- **Google Play Console — Service Account**: credencial JSON gerada no Google Cloud Console (projeto vinculado à conta Play Console), com papel de "Release manager" ou equivalente, permissão de upload restrita à trilha de testes internos. Cadastrada como Destination credential no Appflow, não commitada no repositório.
- **Pré-requisito externo (fora do controle deste pipeline)**: o app `br.com.nomar.controlai` precisa já existir na Google Play Console (criado manualmente uma vez, mesmo sem ficha pública completa) — a API de upload da Play Console não cria apps novos.
- Tratamento de erro: falhas de build (compilação/assinatura) e falhas de deploy (rejeição da Play Console, ex. versionCode duplicado ou service account sem permissão) ficam visíveis nos logs de Build e de Deploy do próprio Appflow — não há necessidade de logging customizado no app.

## Abordagem de Testes

### Testes Unidade
Não aplicável — não há lógica de aplicação nova. A mudança no script `appflow:build` é um script de shell trivial, sem cobertura de teste unitário isolado.

### Testes de Integração
- Validar localmente, antes de disparar o build real no Appflow, a sintaxe do script simulando `CI_PLATFORM=android`:
  ```bash
  CI_PLATFORM=android npm run appflow:build
  ```
  Confirmar que `npx cap copy android` roda sem erro e que `android/app/src/main/assets/public` é atualizado com o conteúdo de `dist/`.
- Disparar um Native Build Android manual no Appflow (Build Type: Debug) antes de configurar assinatura de release, para validar que o pipeline compila sem depender ainda do keystore.
- Disparar um Native Build Android (Build Type: Release) com o Signing Certificate cadastrado, validando que o AAB gerado é baixável e assinado corretamente (`jarsigner -verify` ou equivalente, se necessário confirmar localmente).

### Testes de E2E
Não aplicável — funcionalidade é infraestrutura de build/deploy, sem fluxo de usuário final testável via Playwright.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Corrigir o script `appflow:build`** (`package.json`) para tratar `CI_PLATFORM=android` — é pré-requisito para qualquer build Android funcionar corretamente, independente de assinatura.
2. **Validar build Android sem assinatura (Debug)** no Appflow, confirmando que o pipeline compila de ponta a ponta antes de introduzir a complexidade de credenciais.
3. **Gerar o keystore Android** (`keytool`) e cadastrá-lo como Signing Certificate no Appflow.
4. **Disparar build Android Release assinado** no Appflow e validar o AAB gerado.
5. **Criar a service account no Google Cloud/Play Console** e configurar o Destination Android no Appflow apontando para a trilha de testes internos.
6. **Disparar o fluxo completo** (build → deploy automático) e confirmar que o artefato aparece na trilha de testes internos da Google Play Console.

### Dependências Técnicas

- Acesso de administrador ao projeto ControlAI no dashboard do Appflow (para cadastrar certificate e destination).
- Acesso ao Google Play Console do app `br.com.nomar.controlai` (para criar a service account e habilitar a API do Play Developer no Google Cloud).
- App já existente na Google Play Console (pré-requisito de conta, não técnico deste repositório).

## Monitoramento e Observabilidade

- Status de build (sucesso/falha) e logs de compilação já são nativamente expostos na aba Builds do Appflow — nenhuma instrumentação adicional necessária.
- Status de deploy (sucesso/falha do envio à Play Console) exposto na aba Deploys/Destinations do Appflow.
- Não há métricas Prometheus/Grafana aplicáveis — este é um pipeline de CI/CD, não um serviço em runtime.
- Recomenda-se habilitar notificação por e-mail do Appflow para falhas de build/deploy Android (mesmo mecanismo já usado, presumivelmente, para o iOS), atendendo ao FR4 e FR7 do PRD.

## Considerações Técnicas

### Decisões Principais

- **Reaproveitar `cap copy` em vez de migrar para `cap sync`**: mantém paridade e comportamento idêntico ao branch iOS já validado em produção, minimizando risco de regressão. Migrar ambos os branches para `cap sync` seria uma melhoria válida, mas está fora do escopo deste PRD (que pede paridade, não uma reescrita do script).
- **Assinatura via Appflow Native Build (UI) em vez de `signingConfig` no `build.gradle`**: evita commitar caminhos/segredos de keystore no repositório e segue o mesmo modelo operacional presumido para o iOS (certificados gerenciados no dashboard do Appflow, não no código).
- **Destination configurado apenas para a trilha de testes internos**: atende ao requisito de deploy automático do PRD atualizado sem promover artefatos a produção, mantendo a publicação pública como responsabilidade do PRD "Publicação nas lojas do ControlAI".

### Riscos Conhecidos

- **Build stack do Appflow para Android não confirmado**: é necessário verificar no dashboard se há uma build stack compatível com `compileSdk 36` disponível; caso não haja, pode ser necessário abrir chamado de suporte com a Ionic ou ajustar `compileSdk`/`targetSdk` no projeto — requer validação manual antes da primeira execução.
- **`versionName` do Android fixo em `"1.0"`**: `appflow.yml` só mapeia `versionCode`, não `versionName`. Isso não bloqueia builds nem viola requisitos deste PRD, mas fará com que a versão exibida na Play Console fique estática — vale registrar como melhoria futura (fora de escopo aqui).
- **Pré-requisito de app já existente na Google Play Console**: se o app `br.com.nomar.controlai` ainda não foi criado manualmente na Play Console, o Destination falhará ao tentar o primeiro upload — este passo manual único deve ser confirmado antes da Tarefa de configuração do Destination.
- **Modelo de assinatura do iOS não verificado diretamente**: a decisão de não alterar `build.gradle` assume que o iOS também usa certificados gerenciados via Appflow (não Fastlane customizado no repo). Se o iOS usa um fluxo customizado (ex. `ios/App/fastlane`), o padrão de referência muda — vale uma checagem rápida no dashboard do Appflow antes de iniciar a implementação.

### Conformidade com Skills Padrão

- `clean-code`: aplicável apenas à pequena edição do script `appflow:build` — manter a mudança mínima e legível (mesmo padrão do branch `ios` existente), sem introduzir abstração desnecessária para um script de duas linhas.
- Demais skills do projeto (`frontend-design`, `ionic-design`, `vercel-react-best-practices`, `shadcn`, `ui-ux-pro-max`, `web-design-guidelines`) não se aplicam — não há mudança de UI/componentes React nesta funcionalidade.

### Arquivos relevantes e dependentes

- `controlai-frontend/package.json` — script `appflow:build` (único arquivo de código modificado).
- `controlai-frontend/appflow.yml` — referência, sem alteração (já mapeia `versionCode`).
- `controlai-frontend/capacitor.config.ts` — referência, sem alteração (`appId br.com.nomar.controlai`).
- `controlai-frontend/android/app/build.gradle` — referência, sem alteração (namespace/applicationId/minSdk/targetSdk já corretos).
- `controlai-frontend/android/variables.gradle` — referência, sem alteração (`compileSdk`/`targetSdk 36`).
- Configuração externa ao repositório: Appflow dashboard (Signing Certificate Android, Destination Google Play) e Google Cloud/Play Console (service account) — não versionada em código.
