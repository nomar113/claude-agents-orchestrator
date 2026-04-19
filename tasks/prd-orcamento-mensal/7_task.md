# Tarefa 7.0: Frontend — Botoes de Acao + Redesign Secoes

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o layout final do rodape com botoes "Duplicar Mes" (outline) e "Editar" (primary/gradiente) conforme design Paper. Redesign dos headers de secao (Gastos por Categoria, Investimentos, Receitas, Meios de Pagamento) com estilo Paper. Redesign da secao Meios de Pagamento com badges coloridas (NU, SM, LT, PIX). Ajustes finais de CSS para paridade completa com o Paper.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo padrao de implementacao
- `task-review` — Review automatico apos conclusao
- `executar-qa` — QA completo apos esta task (ultima da feature)
</skills>

<requirements>
- Botoes de acao no rodape conforme Paper: "Duplicar Mes" (outline) e "Editar" (primary)
- Em modo edicao: "Duplicar Mes" muda para "Cancelar", "Editar" muda para "Salvar"
- Headers de secao com icone chevron e contador de itens
- Secao Meios de Pagamento com badges coloridas por metodo
</requirements>

## Subtarefas

- [ ] 7.1 Implementar barra de botoes de acao no rodape (fixed bottom, 2 botoes lado a lado)
- [ ] 7.2 Botao "Duplicar Mes": estilo outline (`background: #4F8BFF1A`, `border: 1px solid #4F8BFF33`), icone de copiar
- [ ] 7.3 Botao "Editar": estilo primary (gradiente `oklab(65.5% -0.025 -0.182)` → `oklab(56.9% -0.021 -0.180)`), icone de editar
- [ ] 7.4 Em modo edicao: botao esquerdo vira "Cancelar" (descarta modo edicao), botao direito vira "Salvar"
- [ ] 7.5 Redesign headers de secao: titulo em uppercase, chevron de collapse, total/contador a direita
- [ ] 7.6 Redesign secao Meios de Pagamento: badges coloridas (28x28, border-radius 8px) com iniciais do metodo
- [ ] 7.7 Remover botoes provisorios das Tasks 4 e 6, usar os definitivos
- [ ] 7.8 Ajustes finais de CSS: espacamentos, margens, padding conforme Paper
- [ ] 7.9 Validacao visual completa contra o artboard Paper
- [ ] 7.10 Escrever e executar testes

## Detalhes de Implementacao

Consultar secao "Design de referencia" da techspec.md para tokens de design.

**Design tokens do Paper (botoes de acao):**
- Container: margin `24px 20px 40px`, display flex, gap `12px`
- Botao outline: `flex: 1`, border-radius `14px`, padding `14px`, background `#4F8BFF1A`, border `1px solid #4F8BFF33`
- Botao primary: `flex: 1`, border-radius `14px`, padding `14px`, gradiente conforme techspec
- Texto botao: IBM Plex Sans 18px, branco
- Icones: SVG 16x16 antes do texto

**Headers de secao Paper:**
- "GASTOS POR CATEGORIA" em uppercase, 18px semibold
- Chevron de collapse a esquerda do titulo
- "12 itens" ou "R$ 1.500" a direita, 16px, cor neutra

**Badges de meios de pagamento:**
- Container 28x28, border-radius 8px
- Cores variam por metodo (NU=roxo, SM=verde, LT=vermelho, PIX=verde-agua)
- Texto: iniciais em 10-12px, branco, centralizado

## Criterios de Sucesso

- Botoes no rodape identicos ao Paper (outline + primary)
- Transicao Editar↔Salvar e Duplicar↔Cancelar funciona
- Headers de secao com estilo uppercase e contadores
- Meios de pagamento com badges coloridas
- Paridade visual completa com artboard Paper "Orcamento Mensal"

## Testes da Tarefa

- [ ] Teste unitario: Botoes de acao renderizam corretamente em modo visualizacao
- [ ] Teste unitario: Botoes mudam label em modo edicao (Editar→Salvar, Duplicar→Cancelar)
- [ ] Teste unitario: Headers de secao exibem titulo e contador/total
- [ ] Teste E2E (Playwright): Fluxo completo — abrir /budget → navegar meses → entrar modo edicao → adicionar item → editar valor → remover item → adicionar receita → sair modo edicao
- [ ] Teste E2E (Playwright): Duplicar mes → verificar dados no mes destino

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Projeto:** `/Volumes/SSD480GB/projects/controlai-frontend`

- `src/pages/BudgetPage.tsx` (modificar — botoes definitivos, headers, meios de pagamento)
- `src/pages/BudgetPage.css` (modificar — estilos finais)
- **Design:** Paper artboard "Orcamento Mensal" (ID 158-0)
  - "Action Buttons" (1CP-0), "Button" outline (1CQ-0), "Button" primary (1CV-0)
  - "Section: Gastos Header" (16D-0), "Section: Investimentos Header" (1A8-0)
  - "Section: Receitas Header" (1B2-0), "Section: Meios Pagamento Header" (1BK-0)
  - "Meios Pagamento Card" (1BQ-0)
