# PRD: Comercialização do ControlAI (Landing Page + Assinatura Kiwify)

## Visão Geral

O ControlAI hoje é usado gratuitamente por seus usuários atuais (Ramon e família) como substituto de planilha de controle financeiro pessoal/do casal. Esta funcionalidade transforma o ControlAI em um produto comercial: uma página de vendas pública e uma assinatura recorrente processada pela Kiwify, inspiradas no modelo de referência do concorrente MultiCap (`planilha.multicap.com.br`).

O problema resolvido é de negócio, não técnico: hoje não existe nenhum mecanismo para que terceiros conheçam, comprem e paguem pelo ControlAI. Esta funcionalidade cria a porta de entrada comercial (marketing + cobrança) para o produto que já existe.

## Objetivos

- Disponibilizar uma página de vendas pública do ControlAI, acessível sem login, que explique a proposta de valor e direcione para a compra.
- Disponibilizar um produto de assinatura anual na Kiwify, no valor de R$ 77/ano, com um item adicional (order bump) de upgrade para um plano vitalício do ControlAI.
- Garantir que todo novo assinante tenha seu acesso ao app liberado automaticamente após confirmação de pagamento, e revogado automaticamente em caso de cancelamento/estorno, sem intervenção manual.
- Meta numérica de conversão/receita: a definir após o lançamento (não há meta fixa nesta primeira versão — o objetivo inicial é validar que existe demanda paga).

## Histórias de Usuário

- Como visitante que busca controlar as finanças pessoais/do casal, quero entender o que o ControlAI faz e quanto custa, para decidir se assino.
- Como visitante convencido, quero contratar a assinatura anual (e, opcionalmente, o upgrade vitalício) pagando com cartão, boleto ou Pix, para começar a usar o ControlAI.
- Como assinante, quero que meu acesso ao app seja liberado automaticamente assim que meu pagamento for aprovado, sem precisar contatar suporte.
- Como assinante que se arrepende da compra, quero poder solicitar reembolso dentro de 7 dias, conforme meus direitos como consumidor.
- Como usuário atual do ControlAI (conta já existente antes do lançamento comercial), quero continuar tendo acesso gratuito e vitalício, sem precisar assinar.
- Como dono do produto, quero saber quando uma assinatura é criada, renovada, cancelada ou estornada, para manter o acesso dos usuários sempre consistente com o status de pagamento.

## Funcionalidades Principais

### 1. Landing page de vendas
O que faz: página pública com proposta de valor do ControlAI (controle de cartões do casal, faturas, compras parceladas, orçamento por categoria, sub-cartões), prova social e chamada para ação de compra.
Por que importa: é o único canal de descoberta e conversão do produto pago.
Requisitos funcionais:
1. A página deve ser acessível publicamente, sem exigir login.
2. A página deve exibir o preço da assinatura (R$ 77/ano) e a proposta de valor central do ControlAI.
3. A página deve conter ao menos uma chamada para ação que leve ao checkout de pagamento.
4. A página deve conter um link para usuários existentes fazerem login diretamente (sem passar pelo checkout).

### 2. Produto de assinatura na Kiwify
O que faz: produto de assinatura recorrente anual (R$ 77/ano) cadastrado na Kiwify, com um order bump de upgrade para plano vitalício do ControlAI.
Por que importa: é o mecanismo real de cobrança — sem ele não existe receita.
Requisitos funcionais:
5. Deve existir um produto de assinatura anual no valor de R$ 77/ano na Kiwify.
6. O checkout deve oferecer um order bump de upgrade para um plano vitalício do ControlAI (pagamento único, sem renovação).
7. O checkout deve aceitar cartão, boleto e Pix, replicando as opções de pagamento do modelo de referência.
8. A política de reembolso deve seguir o mínimo legal de 7 dias corridos (direito de arrependimento), sem período de teste gratuito adicional.

### 3. Liberação e revogação automática de acesso
O que faz: sincroniza o status de pagamento da Kiwify com o acesso do usuário ao ControlAI.
Por que importa: sem isso, a liberação de acesso dependeria de trabalho manual, o que não escala e gera atraso na experiência do comprador.
Requisitos funcionais:
9. Uma compra aprovada na Kiwify deve resultar em acesso liberado ao ControlAI para o comprador.
10. Um cancelamento, reembolso ou estorno na Kiwify deve resultar em revogação do acesso pago do usuário correspondente.
11. Contas de usuários que já utilizavam o ControlAI antes do lançamento comercial devem manter acesso gratuito e vitalício, independentemente de assinatura.

## Experiência do Usuário

- Persona primária: pessoas físicas (indivíduos ou casais) no Brasil que hoje controlam finanças em planilha ou de forma manual e buscam uma alternativa mais simples via app.
- Persona secundária: usuários atuais do ControlAI (grandfathered), que não interagem com a cobrança.
- Fluxo principal: visitante acessa a landing page → entende a proposta → clica em comprar → é redirecionado ao checkout da Kiwify → paga → recebe acesso ao ControlAI (login/criação de conta).
- Fluxo de usuário existente: usuário atual acessa a landing page → clica em "já tenho conta" → vai direto para o login do app, sem passar pelo checkout.
- A comunicação (copy da landing page, e-mails transacionais de compra) deve ser em português, tom direto e alinhado ao público de finanças pessoais.
- Requisito de acessibilidade: a landing page deve seguir práticas básicas de acessibilidade web (contraste adequado, textos alternativos em imagens, navegação por teclado).

## Restrições Técnicas de Alto Nível

- A cobrança é integralmente processada pela Kiwify (gateway de pagamento, emissão de nota/recibo, antifraude); o ControlAI não deve armazenar dados de cartão.
- É necessário algum mecanismo de comunicação entre a Kiwify e o backend do ControlAI para refletir o status de pagamento no acesso do usuário (ex.: webhooks) — o desenho técnico dessa integração pertence à Tech Spec.
- O app mobile (iOS/Android) não deve conter nenhum link ou menção ao checkout de pagamento externo dentro do próprio app, para não violar as diretrizes de compra de conteúdo digital das lojas de aplicativo (ver PRD de publicação nas lojas). A venda ocorre inteiramente fora do app.
- Deve haver conformidade com a LGPD para os dados pessoais coletados na landing page e no checkout (nome, e-mail, CPF, telefone).

## Fora de Escopo

- Build e publicação do app nas lojas (App Store e Google Play) — coberto pelos PRDs "Build Android no Appflow" e "Publicação nas lojas do ControlAI".
- Versão web do ControlAI — coberta pelo PRD "ControlAI Web".
- Meios de pagamento próprios ou gateway de pagamento alternativo à Kiwify.
- Programa de afiliados, cupons de desconto ou campanhas de marketing pago (tráfego pago, SEO).
- Definição de metas numéricas de receita/conversão — a ser tratada em uma iteração futura, após dados iniciais de lançamento.
- Suporte a múltiplos planos de preço (ex.: mensal, trimestral) — nesta primeira versão existe apenas o plano anual + upgrade vitalício.
