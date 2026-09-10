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

- [ ] 4.1 No dashboard do Appflow, disparar um Native Build Android (Build Type: Release) a partir da branch principal, selecionando o Signing Certificate cadastrado na Tarefa 3.0.
- [ ] 4.2 Acompanhar o log de build até a conclusão.
- [ ] 4.3 Baixar o artefato AAB gerado e confirmar que está assinado (ex.: `jarsigner -verify` ou verificação equivalente).
- [ ] 4.4 Conferir o `versionCode` embutido no artefato e comparar com o `CI_BUILD_NUMBER`/`buildNumber` do build iOS mais recente, confirmando consistência entre plataformas.
- [ ] 4.5 Documentar o resultado (build bem-sucedido, artefato assinado, versionCode correto) para referência da Tarefa 6.0.

## Detalhes de Implementacao

Ver Tech Spec, seções "Pontos de Integração", "Abordagem de Testes > Testes de Integração" e "Decisões Principais" (assinatura via Appflow Native Build, sem `signingConfig` no `build.gradle`).

## Criterios de Sucesso

- Native Build Android (Release) conclui com sucesso, gerando um AAB assinado com o certificado cadastrado.
- `versionCode` do artefato Android consistente com o `CI_BUILD_NUMBER` usado no iOS.
- Nenhuma alteração necessária em `android/app/build.gradle` para viabilizar a assinatura.

## Testes da Tarefa

- [ ] Testes de unidade: não aplicável.
- [ ] Testes de integração: Native Build Android (Release) disparado no Appflow, log validado, artefato AAB baixado e assinatura conferida.
- [ ] Testes E2E: instalação do AAB (via `bundletool` gerando APKs de teste, ou upload em trilha de teste) em um dispositivo, confirmando que o app abre normalmente.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código novo — validação de artefato gerado pelo Appflow.
- `controlai-frontend/appflow.yml` (referência, mapeamento de `versionCode`).
