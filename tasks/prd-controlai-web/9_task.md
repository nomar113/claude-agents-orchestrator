# Tarefa 9.0: Acessibilidade WCAG 2.1 AA nas telas principais

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Revisar e ajustar navegação por teclado, ordem de foco, contraste e compatibilidade com leitores de tela nas telas principais indicadas pelo PRD — dashboard (`Tab1`), cartões (`PaymentMethodsPage`) e faturas (`PurchaseDetail`, `ByCategoryPage`) — visando conformidade com WCAG 2.1 AA. Depende das Tarefas 5.0 e 6.0 (layouts responsivos dessas telas já implementados).

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — os componentes Ionic já têm suporte ARIA razoável por padrão; esta tarefa valida e complementa onde necessário.
- `frontend-design` — aplica-se a ajustes de contraste/estados de foco visíveis.
</skills>

<requirements>
- PRD `Experiência do Usuário`: "navegação completa por teclado, contraste adequado de texto e componentes, e compatibilidade com leitores de tela nas telas principais (dashboard, cartões, faturas)".
- Tech Spec `Sequenciamento de Desenvolvimento`: acessibilidade é revisada após os layouts responsivos das telas principais estarem prontos (Tarefas 5.0 e 6.0).
- Nível alvo: WCAG 2.1 AA (decisão confirmada com o usuário na etapa de Tech Spec).
</requirements>

## Subtarefas

- [ ] 9.1 Auditar `Tab1`, `PaymentMethodsPage`, `PurchaseDetail` e `ByCategoryPage` com uma ferramenta automatizada de a11y (ex.: `axe-core`), documentando violações encontradas.
- [ ] 9.2 Corrigir problemas de navegação por teclado (ordem de tabulação lógica, elementos interativos alcançáveis e operáveis via teclado, incluindo modais/bottom sheets).
- [ ] 9.3 Corrigir problemas de contraste de texto/componentes identificados na auditoria, respeitando o tema escuro existente (`theme/variables.css`).
- [ ] 9.4 Adicionar/corrigir atributos ARIA e rótulos acessíveis onde a auditoria apontar ausência (ex.: ícones sem texto, botões sem `aria-label`).
- [ ] 9.5 Validar manualmente com um leitor de tela (ex.: VoiceOver ou NVDA) o fluxo: login → dashboard → cartão → fatura.

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento` (etapa 5) e PRD `Experiência do Usuário`.

## Critérios de Sucesso

- Auditoria automatizada (`axe-core`) não reporta violações de nível AA nas quatro telas revisadas.
- Todo fluxo crítico dessas telas é operável apenas via teclado.
- Contraste de texto/componentes atende AA (mínimo 4.5:1 para texto normal, 3:1 para texto grande/componentes).

## Testes da Tarefa

- [ ] Testes automatizados de acessibilidade (ex.: `vitest-axe` ou equivalente) adicionados para `Tab1`, `PaymentMethodsPage`, `PurchaseDetail`, `ByCategoryPage`, sem violações de nível AA.
- [ ] Teste manual de navegação por teclado documentando o percurso testado.
- [ ] Teste manual com leitor de tela documentando o percurso testado.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/Tab1.tsx`, `PaymentMethodsPage.tsx`, `PurchaseDetail.tsx`, `ByCategoryPage.tsx`
- `controlai-frontend/src/theme/variables.css`
- Depende de: Tarefas 5.0 e 6.0 (layouts responsivos dessas telas)
