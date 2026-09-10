# Review: Task 10.0 - Landing page estática de vendas

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 10_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementação entrega um site estático puro (HTML/CSS/JS, sem framework, sem build step) em um repositório novo e separado (`/Volumes/SSD480GB/projects/controlai-landing`), cumprindo a decisão de arquitetura da Tech Spec de desacoplar a landing page do bundle Ionic/Capacitor do `controlai-frontend`. Confirmei que o repositório não tem nenhum commit ainda (`git log` retorna "No commits yet on main") e que não há qualquer referência cruzada com o app mobile — é um projeto isolado por completo.

O conteúdo cobre hero, seções de funcionalidades (cartões do casal, faturas, compras parceladas, orçamento por categoria, sub-cartões), preço (R$ 77/ano) e prova social/garantia, com copy em pt-BR direto e sem jargão técnico, alinhado à seção `Experiência do Usuário` do PRD. Os 3 CTAs de compra apontam para o link real da Kiwify (`https://pay.kiwify.com.br/iDYf9MZ`, Tarefa 1.0) e os 3 links "já tenho conta" recebem a `LOGIN_URL` central via `js/main.js` — verifiquei ambos por `grep` e o número bate exatamente com o que foi reportado.

O trabalho de acessibilidade é o ponto mais forte da entrega: skip link, landmarks semânticos (`header`/`main`/`section`/`footer`), hierarquia única de headings por seção com `aria-labelledby` corretamente casado a cada `id` de heading, `aria-hidden` em todo elemento puramente decorativo (ícones SVG, mockup do hero), `:focus-visible` visível, `prefers-reduced-motion` respeitado, e todas as imagens `<img>` com `alt` descritivo. Recalculei manualmente o contraste do link corrigido em `.trust-item a` (`#1849b8` sobre `--paper-2` `#efe7d6`) e obtive uma razão de ~5,85:1, acima do mínimo de 4,5:1 do WCAG AA para texto normal — a correção relatada é real e suficiente, não apenas uma alegação.

Dois pontos, ambos não bloqueantes, merecem correção antes de considerar o projeto "fechado": (1) o link de checkout Kiwify — o dado mais crítico para receita do arquivo — está hardcoded 3 vezes no HTML, enquanto o link de login (ainda placeholder) foi corretamente centralizado em uma constante JS; o padrão deveria ser o inverso ou, ao menos, consistente. (2) `js/main.js` tem comentários e um identificador em português, violando o padrão do projeto de código em inglês. Nenhum dos dois compromete o funcionamento atual da página.

A decisão de usar um placeholder configurável para `LOGIN_URL` (não existe versão web publicada ainda) e a decisão de já usar o link real e ativo do checkout Kiwify são ambas razoáveis dado o contexto: foram tomadas por pergunta direta ao usuário antes de codar, estão documentadas como pendência explícita em `README.md` (seção "Antes de publicar"), e o `README.md` até alerta sobre o risco de cliques acidentais gerarem cobrança real — um cuidado que vale destacar.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `index.html` | OK | 0 |
| `css/styles.css` | OK | 0 |
| `js/main.js` | Problemas | 2 (major) |
| `README.md` | OK | 0 |
| `.gitignore` | OK | 0 |
| `assets/favicon-64.png`, `apple-touch-icon.png`, `logo-256.png` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

1. **`index.html:36,61,203` — link de checkout Kiwify duplicado 3x em vez de centralizado, ao contrário do padrão já adotado para `LOGIN_URL`.**
   O link `https://pay.kiwify.com.br/iDYf9MZ` (o dado mais crítico do arquivo, pois qualquer erro nele afeta receita diretamente) está copiado literalmente em 3 lugares do HTML (header, hero, price-card). Enquanto isso, `LOGIN_URL` — hoje só um placeholder — foi corretamente centralizada em `js/main.js` e aplicada via `.js-login-link`. Isso inverte a prioridade: o link ainda-não-real está mais bem protegido contra inconsistência do que o link que já move dinheiro de verdade. Se um dia o ID do produto/checkout mudar na Kiwify, é fácil atualizar 2 das 3 ocorrências e deixar uma desatualizada sem perceber, silenciosamente.

   Sugestão: aplicar o mesmo padrão já usado para o login —
   ```js
   const KIWIFY_CHECKOUT_URL = "https://pay.kiwify.com.br/iDYf9MZ";

   document.querySelectorAll(".js-buy-link").forEach((link) => {
     link.setAttribute("href", KIWIFY_CHECKOUT_URL);
   });
   ```
   e trocar `href="https://pay.kiwify.com.br/iDYf9MZ"` pelos 3 `<a class="btn ... js-buy-link">` no HTML.

2. **`js/main.js:1-3,10` — comentários e identificador em português, violando o padrão de código em inglês do projeto.**
   O checklist de padrões (`references/code-standards.md`) exige "All code in English (variables, functions, classes, comments)". Em `js/main.js`, os comentários (`// URL de login do ControlAI...`, `// TODO: nao existe versao web publicada ainda...`) e a variável `anoAtual` (linha 10) estão em português. É um arquivo pequeno (13 linhas) e a correção é trivial — o copy visível ao usuário no `index.html` deve continuar em pt-BR (é conteúdo, não código), mas o próprio JavaScript deveria seguir o padrão do restante dos repositórios do projeto.

   Sugestão:
   ```js
   // ControlAI login URL (existing app/web).
   // TODO: no web version is published yet — replace with app.controlai.com.br/login
   // (or equivalent) before publishing this landing page. See Subtask 10.1.
   const LOGIN_URL = "#login-em-breve";

   document.querySelectorAll(".js-login-link").forEach((link) => {
     link.setAttribute("href", LOGIN_URL);
   });

   const currentYearElement = document.getElementById("ano-atual");
   if (currentYearElement) {
     currentYearElement.textContent = String(new Date().getFullYear());
   }
   ```

### Problemas Minor

1. **`index.html:36,63,205` — `rel="noopener"` sem `target="_blank"` correspondente.** Nenhum dos 3 CTAs de compra abre em nova aba, então `rel="noopener"` hoje não tem efeito nenhum (nem positivo nem negativo). Ou remove o atributo, ou (talvez preferível para não tirar o visitante do funil de compra) mantém same-tab e remove o `rel`.
2. **`index.html:32` vs `74,233` — `rel="nofollow"` aplicado só no link "já tenho conta" do header, não nos outros dois.** Como o `href` real hoje é sempre um placeholder de fragmento (`#login-em-breve`), isso não tem efeito prático, mas fica inconsistente entre as 3 ocorrências do mesmo link.
3. **Meta tags sociais ausentes.** Não há `og:title`, `og:description`, `og:image` nem `twitter:card`. Para uma landing de vendas com forte expectativa de compartilhamento via WhatsApp/redes sociais, a prévia do link ficará genérica (sem imagem, título/descrição do próprio navegador).
4. **`index.html:7` — meta description com ~166 caracteres**, acima do limite prático de ~155-160 recomendado para não ser cortada em resultados de busca. Não bloqueante, apenas SEO.
5. **Navegação principal (`.site-nav`) totalmente oculta abaixo de 800px, sem alternativa (ex.: menu hambúrguer).** O CTA de compra continua visível (confirmado), mas os atalhos para `#funcionalidades`/`#preco`/`#garantia` somem no mobile — aceitável para uma página de rolagem única, mas vale considerar para uma iteração futura de UX.
6. **`index.html:212` — emoji `🛡️` usado inline no texto de garantia sem tratamento de acessibilidade.** Leitores de tela podem anunciar o nome do emoji antes do texto ("escudo, Garantia incondicional..."), um ruído pequeno mas evitável.
7. **Ausência de qualquer verificação automatizada (lint de HTML, link checker, etc.).** Aceitável dado que a arquitetura deliberadamente não usa build step nem framework (decisão da Tech Spec), mas um `npm run validate` leve (ex.: `html-validate` ou `htmlhint` via `npx`, sem virar dependência de build) poderia pegar erros de marcação futuros sem contradizer a decisão de "sem framework".

## Destaques Positivos

- Decoupling real confirmado: repositório git próprio, zero arquivo compartilhado ou referência ao `controlai-frontend`/Capacitor/Ionic — a decisão da Tech Spec foi seguida à risca, não apenas de nome.
- Trabalho de acessibilidade consistente e verificável no próprio código, não só alegado: skip link funcional, `aria-labelledby` de cada `section` corretamente casado com o `id` do heading correspondente, `aria-hidden` em 100% dos elementos decorativos (ícones SVG e mockup do hero), `:focus-visible` visível em todos os controles, `prefers-reduced-motion` respeitado.
- A correção de contraste relatada (`.trust-item a` de `var(--blue-2)` para `#1849b8`) foi validada de forma independente nesta revisão via cálculo de luminância relativa — razão de contraste ~5,85:1, acima do mínimo de 4,5:1 exigido pelo WCAG AA, confirmando que não é apenas uma alegação do axe-core.
- Todos os elementos interativos são `<a>` nativos, sem nenhum `div`/`span` clicável via JS — garante navegação e ativação por teclado "de graça", sem reimplementar semântica de foco.
- A decisão de usar `LOGIN_URL` como constante única já é um bom hábito de engenharia (mesmo sendo hoje um placeholder) — só faltou aplicar a mesma disciplina ao link real de checkout (ver Problema Major #1).
- Nenhum script de analytics/tracking na página — reduz a superfície de dados pessoais coletados diretamente pela landing, coerente com a postura do PRD de que toda cobrança/dado sensível fica do lado da Kiwify.
- Reaproveitamento pragmático do ícone do app (`sips`) nas resoluções corretas — confirmei os 3 arquivos: `favicon-64.png` 64×64, `apple-touch-icon.png` 180×180 (tamanho padrão esperado pela Apple), `logo-256.png` 256×256.
- `README.md` documenta claramente as pendências reais de pré-publicação (login real, domínio/hospedagem, troca da página de vendas no painel da Kiwify) e até alerta sobre o risco de cliques acidentais no CTA gerarem cobrança real durante testes — evidência de cuidado, não just de completude burocrática.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo (idioma do codigo) | Problemas (ver Major #2) |
| HTML Semantico | OK |
| CSS | OK |
| Acessibilidade (WCAG AA) | OK |
| Arquitetura (desacoplamento da Tech Spec) | OK |
| Testes (manuais/E2E + axe, ja executados nesta sessao) | OK |

## Recomendacoes

1. Centralizar o link de checkout Kiwify em uma constante JS (`KIWIFY_CHECKOUT_URL`), espelhando o padrão já usado para `LOGIN_URL`, para eliminar o risco de uma futura atualização esquecer uma das 3 ocorrências no HTML (Major #1).
2. Traduzir para inglês os comentários e o identificador `anoAtual` em `js/main.js`, mantendo o copy do `index.html` em pt-BR (Major #2).
3. Antes da publicação real do site, garantir que a substituição de `LOGIN_URL` fique rastreada como tarefa/dependência explícita vinculada ao PRD `controlai-web` (ou equivalente), e não dependente apenas de alguém lembrar de ler o checklist do `README.md`.
4. Adicionar tags Open Graph/Twitter Card (`og:title`, `og:description`, `og:image`, `twitter:card`) antes da publicação, dado o alto potencial de compartilhamento de uma landing de vendas via WhatsApp/redes sociais.
5. (Opcional, não bloqueante) Normalizar o uso de `rel="nofollow"`/`rel="noopener"` nos links de CTA e login, e considerar navegação alternativa para `<800px` no lugar da `.site-nav` totalmente oculta.

## Veredito

A Tarefa 10.0 cumpre os critérios de sucesso definidos: página pública sem login, preço e proposta de valor visíveis, os 3 CTAs de compra levam ao checkout Kiwify real da Tarefa 1.0 (verificado por busca no código, não apenas no relato), e a checagem de acessibilidade (axe-core, 0 violações) foi validada de forma independente nesta revisão via recálculo manual de contraste no ponto que havia sido corrigido. A decisão de arquitetura da Tech Spec — site estático totalmente desacoplado do bundle Ionic/Capacitor — foi seguida de forma real e verificável, incluindo um repositório git próprio ainda sem nenhum commit.

O único critério de sucesso que não está 100% satisfeito hoje — "link 'já tenho conta' leva ao login do ControlAI" — depende de uma versão web que ainda não existe; a decisão de usar um placeholder documentado (`LOGIN_URL`) foi tomada com o usuário antes de codar e está corretamente registrada como bloqueador de pré-publicação no `README.md`, não como algo esquecido. Isso é aceitável para fechar esta task, mas é o item que mais precisa de acompanhamento antes de este site ir ao ar de verdade.

Está **APROVADO COM OBSERVACOES**. Os 2 problemas Major (link de checkout duplicado em vez de centralizado, e idioma do código em `js/main.js`) são pequenos, rápidos de corrigir, e não bloqueiam o funcionamento atual da página — mas recomendo corrigi-los antes do commit inicial deste repositório novo, já que é mais barato agora do que depois de já haver histórico de commits em cima do padrão atual.

## Follow-up (pós-review)

Aplicadas as correções recomendadas antes do primeiro commit deste repositório:

- **Major 1 (resolvido)**: o link de checkout Kiwify agora é centralizado em `const CHECKOUT_URL` em `js/main.js`, aplicado via `.js-checkout-link` aos 3 CTAs de compra (header, hero, price-card) — mesmo padrão já usado para `LOGIN_URL`. O `href` estático original permanece no HTML como fallback para o caso (improvável, dado que não há build step) de o JS não carregar.
- **Major 2 (resolvido)**: comentários e o identificador `anoAtual` em `js/main.js` traduzidos para inglês (`currentYear`), seguindo a sugestão do review. O copy visível ao usuário em `index.html` permanece em pt-BR (conteúdo, não código).
- **Minor 1 (resolvido)**: removido `rel="noopener"` dos 3 CTAs de compra — nenhum abre em nova aba (`target="_blank"` ausente), então o atributo não tinha efeito.
- **Minor 2 (resolvido)**: removido `rel="nofollow"` do link "já tenho conta" do header, alinhando as 3 ocorrências (nenhuma tem efeito prático hoje, já que o `href` real é sempre um placeholder de fragmento).
- **Minor 3 (resolvido)**: adicionadas tags `og:title`/`og:description`/`og:image` e `twitter:card`/`twitter:title`/`twitter:description`/`twitter:image`, com nota `TODO` para tornar `og:image` absoluta quando o domínio final for definido (ver `README.md`).
- **Minor 4 (resolvido)**: meta description reduzida para ~128 caracteres (antes ~166).
- **Minor 6 (resolvido)**: emoji `🛡️` do texto de garantia agora envolto em `<span aria-hidden="true">`, evitando que leitores de tela anunciem o nome do emoji antes do texto.
- **Minor 5 e 7 (não aplicados, decisão consciente)**: navegação alternativa para `<800px` (menu hambúrguer) e lint automatizado de HTML ficam como possível iteração futura — não bloqueiam esta task e o próprio review os classificou como "aceitável"/"opcional".

Revalidado após as correções via Chrome (Claude in Chrome): axe-core 4.9.1 (wcag2a + wcag2aa) continua em 0 violações/20 checks aprovados; os 3 `.js-checkout-link` resolvem para `https://pay.kiwify.com.br/iDYf9MZ` e os 3 `.js-login-link` para `LOGIN_URL`, confirmados via `querySelectorAll` no console do navegador.
