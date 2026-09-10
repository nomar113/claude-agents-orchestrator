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

- [ ] 2.1 No dashboard do Appflow, adicionar a plataforma Android ao app ControlAI (se ainda não listada) e selecionar uma build stack compatível com `compileSdk 36` / `targetSdk 36` (ver risco documentado na Tech Spec).
- [ ] 2.2 Disparar um Native Build Android (Build Type: Debug) a partir da branch principal.
- [ ] 2.3 Acompanhar o log de build no Appflow até a conclusão (sucesso ou falha).
- [ ] 2.4 Se o build falhar por incompatibilidade de build stack (SDK/Gradle/JDK), documentar o erro exato e ajustar a build stack selecionada ou abrir chamado com a Ionic, conforme necessário.
- [ ] 2.5 Baixar o artefato de debug gerado e confirmar que ele instala em um dispositivo/emulador Android (validação manual básica de instalação, não de funcionalidade).

## Detalhes de Implementacao

Ver Tech Spec, seções "Pontos de Integração" (build stack Android) e "Riscos Conhecidos" (compatibilidade de `compileSdk 36` com a build stack do Appflow).

## Criterios de Sucesso

- Native Build Android (Debug) conclui com sucesso no Appflow, usando o script `appflow:build` corrigido na Tarefa 1.0.
- O artefato de debug gerado instala corretamente em um dispositivo/emulador Android.
- Log de build acessível e legível diretamente no Appflow, sem necessidade de debug local (atende ao FR4 do PRD).

## Testes da Tarefa

- [ ] Testes de unidade: não aplicável.
- [ ] Testes de integração: Native Build Android (Debug) disparado no Appflow, validado via log de sucesso.
- [ ] Testes E2E: instalação manual do APK/AAB de debug gerado em um dispositivo ou emulador Android, confirmando que o app abre.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código novo — configuração feita no dashboard do Appflow.
- `controlai-frontend/android/variables.gradle` (referência, para conferência de `compileSdkVersion`/`targetSdkVersion`).
