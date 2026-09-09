# Tarefa 10.0: Landing page estática de vendas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar o site estático (separado do `controlai-frontend`) com a proposta de valor do ControlAI, preço da assinatura e chamada para ação para o checkout da Kiwify criado na Tarefa 1.0. Inspirado no modelo de referência do concorrente MultiCap. Pode ser desenvolvida em paralelo às tarefas de backend, mas só pode ser publicada com o link real do checkout (Tarefa 1.0) disponível.

<skills>
### Conformidade com Skills Padrões

- `frontend-design` — qualidade visual e de UX da landing page, evitando estética genérica de IA.
</skills>

<requirements>
- RF-1 a RF-4 do PRD: página pública sem login, preço e proposta de valor visíveis, CTA para o checkout, link para login de usuários existentes.
- Tech Spec `Arquitetura do Sistema`: site estático separado, desacoplado do bundle Ionic/Capacitor, sem qualquer referência circular com o app mobile.
- Requisito de acessibilidade do PRD: contraste adequado, textos alternativos em imagens, navegação por teclado.
</requirements>

## Subtarefas

- [ ] 10.1 Definir e confirmar com o usuário a estrutura de hospedagem/domínio do site estático (fora do escopo de código desta tarefa, mas necessário antes da publicação).
- [ ] 10.2 Construir a página com: hero com proposta de valor, seções de funcionalidades (cartões do casal, faturas, compras parceladas, orçamento por categoria, sub-cartões), preço (R$ 77/ano), CTA para o checkout Kiwify (link da Tarefa 1.0), e link "já tenho conta" apontando para o login do app/web.
- [ ] 10.3 Aplicar práticas básicas de acessibilidade (contraste, `alt` em imagens, navegação por teclado, marcação semântica).
- [ ] 10.4 Validar responsividade (mobile e desktop, já que visitantes podem chegar por qualquer dispositivo).
- [ ] 10.5 Revisar o copy em português, tom direto, alinhado ao público de finanças pessoais (PRD `Experiência do Usuário`).

## Detalhes de Implementação

Ver PRD `Funcionalidades Principais > 1. Landing page de vendas` e `Experiência do Usuário`. Ver Tech Spec `Arquitetura do Sistema` para a decisão de site estático separado. Usar como referência de conteúdo (não copiar texto/imagens protegidos) a landing do MultiCap já analisada durante a criação do PRD.

## Critérios de Sucesso

- Página acessível publicamente sem exigir login, com preço e proposta de valor visíveis.
- CTA de compra leva diretamente ao checkout Kiwify real (Tarefa 1.0).
- Link "já tenho conta" leva ao login do ControlAI, sem passar pelo checkout.
- Página passa em uma checagem básica de acessibilidade (ex.: Lighthouse ou axe).

## Testes da Tarefa

- [ ] Teste manual/E2E de navegação: CTA de compra abre o checkout Kiwify correto; link de login leva à tela de login do app/web.
- [ ] Checagem de acessibilidade (Lighthouse/axe) sem erros críticos.
- [ ] Teste de responsividade em pelo menos um breakpoint mobile e um desktop.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Novo projeto/repositório da landing page estática (local a definir com o usuário).
- Depende de: Tarefa 1.0 (link real do checkout).
