# Tarefa 2.0: Ícone de launcher Android

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Gerar e adicionar os arquivos de ícone de launcher Android (mipmaps em todas as densidades, incluindo ícone adaptativo) em `controlai-frontend/android/app/src/main/res/`, hoje vazio apesar de `AndroidManifest.xml` referenciar `@mipmap/ic_launcher`. Sem esse ícone não é possível gerar um build de release Android apresentável para publicação.

<skills>
### Conformidade com Skills Padrões

- `ionic-design` — consistência visual do ícone gerado com a identidade já usada no ícone iOS.
</skills>

<requirements>
- Tech Spec `Riscos Conhecidos`: launcher icon do Android ausente bloqueia build de release apresentável.
- Tech Spec `Sequenciamento de Desenvolvimento`, etapa 3: deve ser resolvido antes da exportação de screenshots e da submissão Android.
- PRD `Restrições Técnicas de Alto Nível`: depende dos artefatos de build gerados pelo Appflow.
</requirements>

## Subtarefas

- [ ] 2.1 Obter a arte-fonte do ícone já usada em `controlai-frontend/ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png` (ou uma versão de resolução equivalente/maior).
- [ ] 2.2 Gerar os mipmaps Android (`mipmap-mdpi` a `mipmap-xxxhdpi`, incluindo `ic_launcher.png`, `ic_launcher_round.png` e a versão adaptativa `ic_launcher_foreground`/`ic_launcher_background`) a partir da arte-fonte.
- [ ] 2.3 Adicionar os arquivos gerados em `controlai-frontend/android/app/src/main/res/`, seguindo a estrutura padrão de um projeto Capacitor/Android.
- [ ] 2.4 Validar localmente que um build Android (Debug) exibe o ícone corretamente no launcher do dispositivo/emulador.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema` (ícone Android) e `Dependências Técnicas`. Não requer nenhuma alteração de código de aplicação — apenas assets de imagem na estrutura de recursos nativos do Android.

## Critérios de Sucesso

- `controlai-frontend/android/app/src/main/res/` contém os mipmaps do ícone em todas as densidades exigidas.
- Um build Android local/Appflow exibe o ícone correto no launcher.
- Ícone visualmente consistente com o ícone já usado no iOS.

## Testes da Tarefa

- [ ] Teste manual: build Android (Debug) instalado em emulador/dispositivo exibe o ícone correto no launcher.
- [ ] Teste manual: ícone adaptativo renderiza corretamente em diferentes formatos de máscara (círculo, quadrado arredondado) do Android.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/android/app/src/main/res/mipmap-*/` (novo).
- Referência: `controlai-frontend/ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png`.
- Referência: `controlai-frontend/android/app/src/main/AndroidManifest.xml` (já referencia `@mipmap/ic_launcher`).
- Depende de: build Android já funcional (PRD "Build Android no Appflow", concluído).
