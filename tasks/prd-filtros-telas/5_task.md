# Tarefa 5.0: Frontend - Componente CategoryFilterBar reutilizavel

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar um componente `CategoryFilterBar` que exibe uma barra horizontal de chips de categoria com scroll. Inclui chip "Todas" como padrao. Permite selecao unica de categoria para filtragem local dos dados.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-2.1: Chip "Todas" selecionado por padrao, seguido das categorias presentes nos dados.
- RF-2.2: Selecionar uma categoria filtra a lista.
- RF-2.3: Selecionar "Todas" remove o filtro.
- RF-2.4: Scroll horizontal quando categorias excedem largura da tela.
- Props: `categories` (lista de nomes unicos), `selected` (string | null), `onSelect` (callback).
- Chips com feedback visual claro de selecao (cor de destaque).
- Acessibilidade: role e aria-labels nos chips.
</requirements>

## Subtarefas

- [ ] 5.1 Criar componente `CategoryFilterBar.tsx` em `src/components/`.
- [ ] 5.2 Implementar props: `categories: string[]`, `selected: string | null`, `onSelect: (cat: string | null) => void`.
- [ ] 5.3 Renderizar chip "Todas" + chips dinamicos das categorias recebidas.
- [ ] 5.4 Implementar scroll horizontal com CSS (`overflow-x: auto`, `flex-wrap: nowrap`).
- [ ] 5.5 Estilizar chips com estado ativo/inativo (cores de destaque para selecionado).
- [ ] 5.6 Escrever testes unitarios.

## Detalhes de Implementacao

O componente e controlado: recebe `selected` e chama `onSelect`. A lista de categorias e derivada dos dados carregados pelo consumidor (Tab1/Tab2). O consumidor extrai categorias unicas dos dados e passa como prop.

**Estilo sugerido:** Chips com `border-radius`, `padding`, cor de fundo diferente quando ativo. Barra com `display: flex`, `gap`, `overflow-x: auto`, `-webkit-overflow-scrolling: touch`.

## Criterios de Sucesso

- Renderiza chip "Todas" + N chips de categoria.
- Chip "Todas" selecionado por padrao (quando `selected` e null).
- Click em "Supermercado" chama `onSelect("Supermercado")`.
- Click em "Todas" chama `onSelect(null)`.
- Scroll horizontal funciona com 10+ categorias.
- Chip selecionado tem visual distinto do nao selecionado.

## Testes da Tarefa

- [ ] Teste unitario: renderiza "Todas" + categorias recebidas.
- [ ] Teste unitario: "Todas" aparece como selecionado quando `selected` e null.
- [ ] Teste unitario: click em categoria chama `onSelect` com nome da categoria.
- [ ] Teste unitario: click em "Todas" chama `onSelect(null)`.
- [ ] Teste unitario: categorias vazias renderiza apenas "Todas".
- [ ] Teste unitario: aria-labels presentes nos chips.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/pages/Tab1.css` (referencia de estilos existentes)
