# PRD: Publicação do ControlAI na App Store e Google Play

## Visão Geral

O ControlAI atualmente não está publicado em nenhuma loja de aplicativos — é instalado manualmente pelos usuários atuais. Esta funcionalidade cobre tudo o que é necessário para que o ControlAI se torne publicamente disponível e instalável pela App Store (iOS) e pela Google Play (Android), como um app gratuito para download (a monetização acontece fora do app, conforme o PRD de comercialização).

## Objetivos

- Ter o ControlAI publicado e aprovado simultaneamente na App Store e na Google Play.
- Garantir que a ficha de loja (nome, descrição, ícone, screenshots, política de privacidade) represente corretamente o produto e atenda às exigências de cada loja.
- Passar pela revisão de ambas as lojas sem rejeição por motivos evitáveis (ex.: menção a pagamento externo dentro do app, política de privacidade ausente, dados de teste inválidos para o revisor).

## Histórias de Usuário

- Como pessoa interessada no ControlAI, quero encontrá-lo pesquisando na App Store ou na Google Play, para instalá-lo sem precisar de um link direto.
- Como revisor da loja, quero conseguir logar em uma conta de teste válida do ControlAI, para avaliar o app e aprovar sua publicação.
- Como usuário, quero encontrar uma política de privacidade pública e acessível a partir da ficha da loja, para entender como meus dados financeiros são tratados.
- Como dono do produto, quero que o app publicado nas lojas não mencione nem direcione para o checkout de pagamento externo, para não colocar a aprovação do app em risco.

## Funcionalidades Principais

### 1. Ficha de loja (App Store e Google Play)
O que faz: conjunto de informações públicas exibidas na página do app em cada loja.
Por que importa: é o que converte uma busca em instalação, e é pré-requisito obrigatório de cada loja para publicar.
Requisitos funcionais:
1. Deve existir nome, descrição curta e longa, ícone e categoria definidos para o ControlAI em ambas as lojas.
2. Devem existir screenshots representativos das principais telas do app (dashboard, cartões, faturas, orçamento) em ambas as lojas.
3. Deve existir uma política de privacidade pública e acessível por URL, referenciada na ficha de loja de ambas as plataformas.
4. A classificação etária/indicativa do app deve ser preenchida corretamente em ambas as lojas.

### 2. Conformidade com as diretrizes de cada loja
O que faz: garante que o app publicado respeita as regras de conteúdo e monetização de cada loja.
Por que importa: é a causa mais comum de rejeição em apps com funcionalidade financeira e assinatura.
Requisitos funcionais:
5. O app publicado não deve conter nenhum link, texto ou fluxo que direcione o usuário ao checkout de pagamento externo (Kiwify) a partir de dentro do app.
6. Deve ser disponibilizada uma conta de demonstração (ou fluxo alternativo aprovado pela loja) para que o time de revisão consiga acessar as telas internas do app sem precisar de dados financeiros reais.
7. O app deve declarar corretamente, nos formulários de privacidade de cada loja (ex.: App Privacy da Apple, Data Safety do Google), quais dados são coletados e para quê.

### 3. Processo de submissão e acompanhamento
O que faz: envio do artefato (build iOS já existente via Appflow; build Android conforme PRD "Build Android no Appflow") para revisão em cada loja.
Por que importa: é a etapa final que efetivamente torna o app público.
Requisitos funcionais:
8. Deve ser possível submeter uma nova versão do app para revisão em ambas as lojas a partir dos artefatos gerados pelo Appflow.
9. O status de cada submissão (em revisão, aprovado, rejeitado) deve ser acompanhável até a publicação efetiva.
10. Em caso de rejeição, deve haver um registro do motivo, para correção e reenvio.

## Experiência do Usuário

- Persona: mesmo público do PRD de comercialização (indivíduos/casais buscando controle financeiro), agora descobrindo o app organicamente pela busca nas lojas.
- Fluxo principal: usuário busca "ControlAI" (ou termo correlato) na loja → visualiza a ficha → instala → abre o app → faz login ou cria conta → é direcionado à landing page/checkout externo caso não tenha assinatura ativa (fluxo detalhado no PRD de comercialização).
- Requisito de acessibilidade: screenshots e descrição devem ser compreensíveis e legíveis (texto com contraste adequado), já que muitos usuários decidem instalar com base apenas nessas informações.

## Restrições Técnicas de Alto Nível

- Depende de contas ativas e em situação regular no App Store Connect (Apple) e no Google Play Console.
- Depende dos artefatos de build gerados pelo Appflow (iOS já existente; Android conforme PRD "Build Android no Appflow").
- Sujeito às políticas de revisão da Apple (guideline 3.1.1 sobre compras externas) e do Google (política de assinaturas e de apps financeiros), que podem exigir ajustes de conteúdo sem aviso prévio.
- Dados sensíveis (financeiros) exigem atenção redobrada ao preenchimento correto dos formulários de privacidade de cada loja, sob risco de rejeição ou remoção posterior.

## Fora de Escopo

- Criação da landing page e do produto de assinatura — coberto pelo PRD "Comercialização do ControlAI".
- Pipeline de build Android em si — coberto pelo PRD "Build Android no Appflow".
- Estratégia de ASO (App Store Optimization), tradução para outros idiomas ou marketing pago para aquisição via loja.
- Programas de beta público (TestFlight, Google Play Beta) — podem ser considerados em iteração futura.
