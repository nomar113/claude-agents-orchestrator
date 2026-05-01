# Tarefa 3.0: Frontend — Componente CategoryBottomSheet

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente `CategoryBottomSheet` usando IonModal com breakpoints (half-screen bottom sheet). O componente exibe a lista de todas as categorias cadastradas, permite selecionar uma ou remover a categoria atual ("Nenhuma"), e destaca visualmente a categoria selecionada.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Criar componente `CategoryBottomSheet` como IonModal com breakpoints (0, 0.5, 0.75)
- Receber props: `isOpen`, `selectedCategoryId`, `onSelect(categoryId: number | null)`, `onDismiss`
- Listar todas as categorias via `listCategories()` do `categoryService`
- Exibir icone da categoria quando disponivel, nome sempre
- Primeira opcao: "Nenhuma" para remover categoria (emite `onSelect(null)`)
- Destacar visualmente a categoria atualmente selecionada (checkmark ou cor de fundo)
- Exibir skeleton/loading enquanto categorias carregam
- Fechar automaticamente apos selecao (chamar `onDismiss`)
</requirements>

## Subtarefas

- [ ] 3.1 Criar arquivo `CategoryBottomSheet.tsx` em `src/components/`
- [ ] 3.2 Criar estilos `CategoryBottomSheet.css`
- [ ] 3.3 Implementar IonModal com breakpoints e lista de categorias
- [ ] 3.4 Implementar opcao "Nenhuma" como primeiro item
- [ ] 3.5 Implementar destaque visual da categoria selecionada
- [ ] 3.6 Implementar loading skeleton
- [ ] 3.7 Escrever testes unitarios do componente

## Detalhes de Implementacao

Consultar a secao **"Arquitetura do Sistema > Visao Geral dos Componentes"** da `techspec.md` para a descricao do componente.

**Padrao de referencia:** O componente `CategoryChips` (`src/components/CategoryChips.tsx`) mostra o padrao de listagem de categorias e selecao. O novo componente segue a mesma logica mas renderiza em um bottom sheet.

**Props interface:**
```typescript
type CategoryBottomSheetProps = {
  isOpen: boolean;
  selectedCategoryId: number | null;
  onSelect: (categoryId: number | null) => void;
  onDismiss: () => void;
};
```

## Criterios de Sucesso

- Componente renderiza como bottom sheet (IonModal com breakpoints)
- Lista todas as categorias com nome e icone
- Opcao "Nenhuma" disponivel e funcional
- Categoria selecionada destacada visualmente
- Skeleton exibido durante loading
- Fecha apos selecao
- Testes unitarios passam

## Testes da Tarefa

- [ ] Testes de unidade: renderiza lista de categorias mockadas
- [ ] Testes de unidade: destaca categoria selecionada
- [ ] Testes de unidade: emite `onSelect(id)` ao clicar em categoria
- [ ] Testes de unidade: emite `onSelect(null)` ao clicar em "Nenhuma"
- [ ] Testes de unidade: exibe skeleton enquanto carrega

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Criar:**
- `src/components/CategoryBottomSheet.tsx` (no projeto controlai-frontend)
- `src/components/CategoryBottomSheet.css` (no projeto controlai-frontend)
- `src/components/CategoryBottomSheet.test.tsx` (no projeto controlai-frontend)

**Referencia:**
- `src/components/CategoryChips.tsx` — padrao de listagem de categorias
- `src/services/categoryService.ts` — funcao `listCategories()`
- `src/types/category.ts` — tipo `Category`
