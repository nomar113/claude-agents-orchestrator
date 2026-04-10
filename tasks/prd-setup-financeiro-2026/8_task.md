# Tarefa 8.0: Frontend — Componente CategoryChips + integracao no ManualEntryPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente reutilizavel `CategoryChips` que carrega categorias do backend e exibe como chips selecionaveis. Integrar no `ManualEntryPage` substituindo o array hardcoded CATEGORIES.

<skills>
### Conformidade com Skills Padroes

- **`ionic-design`**: Usar IonChip ou botoes estilizados como chips.
- **`clean-code`**: Componente reutilizavel com props claras.
</skills>

<requirements>
- Componente `CategoryChips` com props: `selectedId: number | null`, `onSelect: (id: number) => void`
- Carrega categorias via `categoryService.listCategories()` no mount
- Exibe chips com visual identico ao atual do ManualEntryPage (classe `me-chip` / `me-chip-active`)
- Estado de loading enquanto busca categorias
- No ManualEntryPage: trocar `category: string` por `categoryId: number` no estado
- No ManualEntryPage: remover array CATEGORIES hardcoded
- No ManualEntryPage: usar CategoryChips no lugar dos chips manuais
- Atualizar chamada `createManualNotification` para enviar `categoryId` em vez de `category`
</requirements>

## Subtarefas

- [ ] 8.1 Criar `src/components/CategoryChips.tsx`
- [ ] 8.2 Criar `src/components/CategoryChips.css` (se necessario, ou reutilizar estilos me-chip)
- [ ] 8.3 Atualizar `ManualEntryPage.tsx` — remover CATEGORIES, usar CategoryChips, enviar categoryId
- [ ] 8.4 Escrever testes unitarios

## Detalhes de Implementacao

O `ManualEntryPage.tsx` atualmente tem (linhas 10-13):
```typescript
const CATEGORIES = [
  'Farmacia', 'Mercado', 'Restaurante', 'Lazer', 'Transporte',
  'Comida', 'Saude', 'Pet', 'Casa', 'Assinaturas', 'Outros',
];
```

E renderiza chips manualmente (linhas 172-183). Substituir por `<CategoryChips />`.

A chamada `createManualNotification` deve enviar `categoryId` (number) em vez de `category` (string).

## Criterios de Sucesso

- CategoryChips carrega e exibe categorias do backend
- ManualEntryPage usa CategoryChips em vez de array hardcoded
- Selecao de categoria funciona e envia `categoryId` ao backend
- Visual identico ao atual (chips com classe me-chip)
- Build passa sem erros

## Testes da Tarefa

- [ ] Teste unitario: CategoryChips renderiza categorias carregadas
- [ ] Teste unitario: CategoryChips chama onSelect ao clicar
- [ ] Teste unitario: ManualEntryPage envia categoryId na submissao
- [ ] Verificacao manual: visual dos chips identico ao anterior

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/ManualEntryPage.tsx` — Sera modificado (remover CATEGORIES, usar CategoryChips)
- `controlai-frontend/src/pages/ManualEntryPage.css` — Estilos me-chip existentes
- `controlai-frontend/src/services/categoryService.ts` — Servico HTTP (task 6)
- `controlai-frontend/src/types/category.ts` — Tipos (task 6)
