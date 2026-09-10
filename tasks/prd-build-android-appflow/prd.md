# PRD: Build Android do ControlAI no Ionic Appflow

## Visão Geral

O ControlAI já possui build e deploy automatizados para iOS configurados no Ionic Appflow. O projeto frontend (Capacitor) já contém a estrutura nativa Android (`android/`) e o arquivo `appflow.yml` já prevê variáveis para a plataforma Android (`versionCode`), mas o pipeline de build Android em si ainda não está configurado/operacional no Appflow. Esta funcionalidade cria esse pipeline, para que builds Android possam ser gerados de forma confiável e repetível, com paridade em relação ao pipeline iOS existente.

## Objetivos

- Ter um pipeline de build Android no Appflow capaz de gerar um artefato instalável/publicável (AAB) a partir do código-fonte do ControlAI.
- Garantir que o processo de build Android seja tão confiável e repetível quanto o pipeline iOS já existente.
- Reduzir a zero a necessidade de gerar builds Android manualmente na máquina de um desenvolvedor.
- Enviar automaticamente o artefato Android gerado para a Google Play (trilha de testes internos), sem intervenção manual, após cada build bem-sucedido.

## Histórias de Usuário

- Como responsável técnico pelo ControlAI, quero disparar um build Android pelo Appflow, para obter um artefato assinado sem precisar montar o ambiente Android localmente.
- Como responsável técnico, quero que cada build Android tenha um número de versão consistente com o build iOS correspondente, para manter rastreabilidade entre as duas plataformas.
- Como responsável técnico, quero ser avisado quando um build Android falhar, para corrigir o problema antes de tentar publicar.

## Funcionalidades Principais

### 1. Pipeline de build Android configurado no Appflow
O que faz: configura o Appflow para compilar e assinar o app Android do ControlAI a partir do repositório já existente.
Por que importa: sem isso, não existe caminho automatizado para gerar o artefato Android necessário para publicação nas lojas.
Como funciona em alto nível: reaproveita a mesma origem de código e configuração (`capacitor.config.ts`, `appflow.yml`) já usada pelo pipeline iOS, adicionando a plataforma Android como um segundo alvo de build.
Requisitos funcionais:
1. Deve ser possível disparar, pelo Appflow, um build Android do ControlAI a partir da branch principal do repositório.
2. O build gerado deve produzir um artefato assinado, pronto para ser enviado à Google Play (formato AAB).
3. O número de versão do artefato Android gerado deve seguir a mesma lógica de numeração já usada pelo build iOS (`CI_BUILD_NUMBER` em `appflow.yml`).
4. Falhas de build devem ser visíveis/rastreáveis no próprio Appflow, sem necessidade de reprodução manual local para diagnóstico inicial.

### 2. Deploy automático para a Google Play (trilha de testes internos)
O que faz: após um build Android bem-sucedido no Appflow, envia automaticamente o artefato (AAB) para a Google Play Console, na trilha de testes internos.
Por que importa: elimina o passo manual de upload do artefato na Play Console, mantendo o fluxo Android tão automatizado quanto o iOS.
Como funciona em alto nível: configura um Destination do Appflow para a Google Play, autenticado via conta de serviço do Google Play Console, disparado a cada Native Build Android bem-sucedido (ou manualmente, quando necessário).
Requisitos funcionais:
5. Deve ser possível enviar automaticamente o artefato Android gerado pelo Appflow para a trilha de testes internos da Google Play Console.
6. O envio automático não deve promover o artefato para produção — apenas para a trilha de testes internos.
7. Falhas no envio à Google Play devem ser visíveis/rastreáveis no próprio Appflow.

## Experiência do Usuário

- Usuário desta funcionalidade: o próprio Ramon (responsável técnico/produto), não o usuário final do app.
- Fluxo principal: acessar o Appflow → selecionar o app ControlAI → disparar build para a plataforma Android → acompanhar o status do build → artefato é enviado automaticamente à trilha de testes internos da Google Play.
- Não há interface voltada ao usuário final nesta funcionalidade — é infraestrutura de entrega de software.

## Restrições Técnicas de Alto Nível

- Depende de credenciais de assinatura Android (keystore) configuradas com segurança no Appflow — como não existe keystore hoje, um novo deve ser gerado e cadastrado como Signing Certificate no Appflow.
- Deve reutilizar a mesma base de código Capacitor já existente (`br.com.nomar.controlai`), sem criar um segundo projeto ou repositório para Android.
- O pipeline Android deve conviver com o pipeline iOS já existente no mesmo projeto Appflow, sem quebrar ou alterar o comportamento atual de build/deploy do iOS.
- Depende de uma conta de serviço (service account) do Google Play Console com permissão de upload, configurada como credencial de Destination no Appflow.
- O app precisa já existir na Google Play Console (mesmo que sem ficha pública completa) para aceitar uploads automatizados de artefato — pré-requisito de conta, fora do controle deste pipeline.

## Fora de Escopo

- Promoção do artefato para trilhas além de testes internos (produção, testes fechados/abertos) — cobertura de ficha de loja e publicação pública fica a cargo do PRD "Publicação nas lojas do ControlAI".
- Testes automatizados de UI/integração como parte do pipeline de build.
- Distribuição via outros canais de teste (ex.: Firebase App Distribution) — pode ser considerada em iteração futura.
- Mudanças de funcionalidade do app em si — este PRD trata exclusivamente do pipeline de build e do envio à trilha de testes internos.
