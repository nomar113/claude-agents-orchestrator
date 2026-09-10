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

- [x] 10.1 Definir e confirmar com o usuário a estrutura de hospedagem/domínio do site estático (fora do escopo de código desta tarefa, mas necessário antes da publicação). — Confirmado com o usuário: novo projeto irmão `/Volumes/SSD480GB/projects/controlai-landing`, repositório git próprio, HTML/CSS/JS puro (sem framework), sem dependência do bundle Ionic/Capacitor. Domínio/hospedagem final (Vercel/Netlify/subdomínio) permanece em aberto — ver `README.md` do novo projeto, seção "Antes de publicar".
- [x] 10.2 Construir a página com: hero com proposta de valor, seções de funcionalidades (cartões do casal, faturas, compras parceladas, orçamento por categoria, sub-cartões), preço (R$ 77/ano), CTA para o checkout Kiwify (link da Tarefa 1.0), e link "já tenho conta" apontando para o login do app/web. — Implementado em `controlai-landing/index.html`. CTA de compra usa o link real e ativo da Kiwify (`https://pay.kiwify.com.br/iDYf9MZ`, Tarefa 1.0). O link "já tenho conta" usa um placeholder configurável (`LOGIN_URL` em `js/main.js`), pois ainda não existe versão web publicada do ControlAI (confirmado com o usuário) — documentado como pendência em `README.md`.
- [x] 10.3 Aplicar práticas básicas de acessibilidade (contraste, `alt` em imagens, navegação por teclado, marcação semântica). — Skip link, `header`/`main`/`section`/`footer` semânticos, hierarquia única de headings por seção, `alt` descritivo no logo, ícones decorativos com `aria-hidden`, `:focus-visible` visível em todos os controles, todos os elementos interativos são `<a>` nativos (sem `div` clicável).
- [x] 10.4 Validar responsividade (mobile e desktop, já que visitantes podem chegar por qualquer dispositivo). — Validado via Chrome (Claude in Chrome) em 1440px (desktop) e 390px (mobile, iPhone-width via iframe para contornar limitação de resize do ambiente de teste): grids colapsam para coluna única, nav principal oculta em telas estreitas mantendo o CTA de compra sempre visível no header, cards de preço/hero empilham corretamente, sem overflow horizontal.
- [x] 10.5 Revisar o copy em português, tom direto, alinhado ao público de finanças pessoais (PRD `Experiência do Usuário`). — Copy revisado em pt-BR, tom direto (“Chega de planilha de casal”, “Um preço. Tudo incluído.”), linguagem do dia a dia financeiro do casal, sem jargão técnico.

## Detalhes de Implementação

Ver PRD `Funcionalidades Principais > 1. Landing page de vendas` e `Experiência do Usuário`. Ver Tech Spec `Arquitetura do Sistema` para a decisão de site estático separado. Usar como referência de conteúdo (não copiar texto/imagens protegidos) a landing do MultiCap já analisada durante a criação do PRD.

## Critérios de Sucesso

- Página acessível publicamente sem exigir login, com preço e proposta de valor visíveis.
- CTA de compra leva diretamente ao checkout Kiwify real (Tarefa 1.0).
- Link "já tenho conta" leva ao login do ControlAI, sem passar pelo checkout.
- Página passa em uma checagem básica de acessibilidade (ex.: Lighthouse ou axe).

## Testes da Tarefa

- [x] Teste manual/E2E de navegação: CTA de compra abre o checkout Kiwify correto; link de login leva à tela de login do app/web. — Validado via Chrome: os 3 CTAs de compra (header, hero, preço) apontam para `https://pay.kiwify.com.br/iDYf9MZ`; os 3 links "já tenho conta" (header, hero, seção de confiança) recebem a `LOGIN_URL` central via `js/main.js`. Sem tela de login real para apontar ainda (ver Subtarefa 10.1/10.2) — comportamento documentado como pendência pré-publicação.
- [x] Checagem de acessibilidade (Lighthouse/axe) sem erros críticos. — axe-core 4.9.1 executado no navegador (regras `wcag2a`+`wcag2aa`): 0 violações, 20 checks aprovados. Uma violação de contraste encontrada e corrigida durante a validação (link "entre direto por aqui" na seção de confiança).
- [x] Teste de responsividade em pelo menos um breakpoint mobile e um desktop. — Validado em 1440px e 390px (ver Subtarefa 10.4).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Novo projeto/repositório da landing page estática (local a definir com o usuário).
- Depende de: Tarefa 1.0 (link real do checkout).
