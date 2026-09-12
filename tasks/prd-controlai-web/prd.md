# PRD: ControlAI Web

## Visão Geral

O ControlAI existe hoje apenas como app mobile (Capacitor, iOS e Android). Parte do público que hoje controla finanças em planilha está acostumado a fazer isso no computador, e exigir a instalação de um app mobile é uma barreira de adoção para esse público. Esta funcionalidade cria uma versão web do ControlAI, acessível por navegador, com paridade completa de funcionalidades em relação ao app mobile.

## Objetivos

- Permitir que qualquer usuário do ControlAI gerencie suas finanças completamente pelo navegador, sem precisar instalar o app mobile.
- Atingir paridade funcional completa com o app mobile: as mesmas informações e ações disponíveis no app devem estar disponíveis na web.
- Manter os dados do usuário consistentes entre web e mobile (a mesma conta, os mesmos dados, em ambas as plataformas).

## Histórias de Usuário

- Como usuário que prefere usar computador, quero acessar o ControlAI pelo navegador com meu login existente, para gerenciar minhas finanças sem instalar um app.
- Como usuário que já usa o app mobile, quero que qualquer alteração feita na web (ex.: um novo lançamento) apareça também no app mobile, e vice-versa.
- Como usuário, quero visualizar meus cartões, faturas, compras parceladas, sub-cartões e orçamento na web, da mesma forma que vejo no app.
- Como usuário que registra compras a partir de notas fiscais (NFC-e), quero ter uma forma de fazer isso pela web, mesmo sem câmera de celular em mãos.
- Como novo assinante vindo da landing page comercial, quero poder começar a usar o ControlAI direto pela web, sem precisar instalar nada primeiro.

## Funcionalidades Principais

### 1. Autenticação web
O que faz: permite login na versão web com a mesma conta usada no app mobile.
Por que importa: é pré-requisito para qualquer uso da versão web, e garante que não existam contas paralelas.
Requisitos funcionais:
1. O usuário deve conseguir entrar na versão web com as mesmas credenciais já usadas no app mobile.
2. Um usuário autenticado na web deve enxergar os mesmos dados (cartões, faturas, lançamentos) que enxerga no app mobile.

### 2. Paridade de funcionalidades com o app mobile
O que faz: reproduz na web todas as telas e ações hoje disponíveis no app mobile do ControlAI.
Por que importa: é o requisito central desta funcionalidade — uma versão web incompleta não substitui o app para o público-alvo.
Requisitos funcionais:
3. A versão web deve permitir visualizar e gerenciar cartões e sub-cartões, incluindo cartões compartilhados entre o casal.
4. A versão web deve permitir visualizar faturas, incluindo o detalhamento por compra e por período de fechamento.
5. A versão web deve permitir registrar, editar e cancelar compras, incluindo compras parceladas.
6. A versão web deve permitir visualizar e planejar o orçamento mensal por categoria.
7. A versão web deve oferecer um fluxo equivalente ao de leitura de NFC-e do app mobile para registro automático de compras, ainda que o mecanismo de captura seja diferente (ex.: upload de imagem/QR code em vez de câmera do celular).

### 3. Consistência de dados entre web e mobile
O que faz: garante que web e mobile operam sobre a mesma base de dados do usuário, em tempo real.
Por que importa: sem isso, o usuário teria duas versões divergentes das próprias finanças, o que quebra a confiança no produto.
Requisitos funcionais:
8. Uma alteração feita na web deve refletir no app mobile do mesmo usuário, e vice-versa, sem exigir sincronização manual.

## Experiência do Usuário

- Persona primária: mesmo público do ControlAI mobile (indivíduos/casais controlando finanças pessoais), agora em contexto desktop.
- Persona secundária: novos assinantes vindos da landing page comercial que preferem começar pela web antes de instalar o app.
- Fluxo principal: usuário acessa a URL do ControlAI Web → faz login → navega pelas mesmas seções do app mobile (dashboard, cartões, faturas, orçamento) adaptadas ao formato desktop.
- Consideração de UX: o layout deve ser desenhado para tela larga (desktop/notebook), não apenas uma cópia redimensionada da UI mobile.
- Requisitos de acessibilidade: navegação completa por teclado, contraste adequado de texto e componentes, e compatibilidade com leitores de tela nas telas principais (dashboard, cartões, faturas).

## Restrições Técnicas de Alto Nível

- Deve reutilizar o backend/API já existente do ControlAI, sem duplicar regras de negócio já implementadas para o mobile.
- A leitura de NFC-e por câmera, hoje disponível no mobile, depende de hardware não presente no desktop; é necessário um fluxo alternativo equivalente (ex.: upload de arquivo/imagem), sujeito às mesmas limitações já conhecidas de bloqueio do WAF da SEFAZ na leitura de notas.
- Deve seguir os mesmos requisitos de proteção de dados (LGPD) já aplicáveis ao app mobile, por lidar com os mesmos dados financeiros sensíveis.

## Fora de Escopo

- Aplicativos nativos adicionais (ex.: desktop empacotado) — o escopo aqui é uma aplicação web acessível via navegador.
- Funcionalidades exclusivas da web sem equivalente no mobile (ex.: exportações avançadas, dashboards adicionais) — podem ser propostas em iteração futura, mas não fazem parte da paridade inicial.
- Landing page comercial e checkout de assinatura — cobertos pelo PRD "Comercialização do ControlAI"; a versão web aqui descrita é a área logada do produto, não a página de vendas.
- Suporte offline na versão web.
