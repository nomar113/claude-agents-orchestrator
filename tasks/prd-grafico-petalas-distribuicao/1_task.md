# Tarefa 1.0: Utilitario de cores de categoria (`categoryColors.ts`)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o modulo utilitario puro `src/utils/categoryColors.ts` no projeto `controlai-frontend`, responsavel por atribuir cores deterministicas as categorias do grafico de petalas e fornecer a cor de alerta para categorias em estouro de limite. E a base de cores consumida por todas as tasks seguintes.

<skills>
### Conformidade com Skills Padroes

- `clean-code` — funcoes puras, pequenas e nomeadas (`getCategoryColor`, `getOverflowColor`); paleta como constante nomeada.
- `vercel-react-best-practices` — modulo puro sem dependencia de React, facilitando memoizacao no componente consumidor.
</skills>

<requirements>
- Paleta fixa com pelo menos 12 cores distintas, alinhada ao tema escuro do app (`#0D1028`–`#0E1832`).
- `getCategoryColor(categoryId: number, index: number): CategoryColor` deterministico: mesmo `categoryId` retorna sempre a mesma cor entre chamadas e re-renders (chave por `categoryId`, nao por nome — ver "Riscos Conhecidos" na techspec.md).
- `getOverflowColor(): CategoryColor` retorna `#FF6B6B` (alinhado ao restante do app).
- Interface `CategoryColor` com `base` (cor da petala) e `text` (cor do texto do percentual sobre a petala).
- Categorias alem da paleta caem em atribuicao ciclica (fallback deterministico).
</requirements>

## Subtarefas

- [x] 1.1 Criar `src/utils/categoryColors.ts` com a interface `CategoryColor`, a paleta fixa (12+ cores) e as funcoes `getCategoryColor` e `getOverflowColor`.
- [x] 1.2 Criar `src/utils/categoryColors.test.ts` cobrindo determinismo, quantidade de cores distintas e cor de overflow.
- [x] 1.3 Executar os testes e o typecheck do projeto.

## Detalhes de Implementacao

Ver secoes "Interfaces Principais" (bloco `utils/categoryColors.ts`) e "Decisoes Principais" (paleta fixa com fallback deterministico por `categoryId`) na `techspec.md`.

## Criterios de Sucesso

- Modulo compila sem erros de tipo e nao importa React nem servicos.
- `getCategoryColor` retorna o mesmo resultado para o mesmo `categoryId` em qualquer ordem de chamada.
- Todos os testes da tarefa passam.

## Testes da Tarefa

- [x] Testes de unidade (`categoryColors.test.ts`, Vitest):
  - `getCategoryColor` e deterministico para o mesmo `categoryId` em chamadas diferentes.
  - A paleta cobre pelo menos 12 cores distintas (sem colisao ate 12 categorias).
  - `getOverflowColor()` retorna `#FF6B6B`.
- [x] Testes de integracao: nao aplicavel (modulo puro, sem dependencias).
- [x] Testes E2E: nao aplicavel.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/utils/categoryColors.ts` (novo)
- `src/utils/categoryColors.test.ts` (novo)
- `src/components/BudgetCategoryCard.tsx` (referencia visual de paleta e tons de overflow)
- `src/theme/variables.css` (tokens de cor do tema)
