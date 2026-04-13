# Review: Task 7 - Frontend -- Tela de gerenciamento de categorias

**Revisor**: AI Code Reviewer
**Data**: 2026-04-11
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementacao da CategoriesPage segue fielmente o padrao visual e estrutural da PaymentMethodsPage, com CRUD completo de categorias, tratamento de erros 409, toasts, empty state e loading skeleton. A qualidade geral e boa, com codigo limpo e bem organizado. Ha um problema major (teste faltante exigido pela task) e alguns problemas menores que nao bloqueiam a entrega.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| src/pages/CategoriesPage.tsx | Problemas | 3 |
| src/pages/CategoriesPage.css | OK | 0 |
| src/pages/CategoriesPage.test.tsx | Problemas | 1 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1. Teste unitario de exclusao com 409 ausente**
- **Arquivo**: `src/pages/CategoriesPage.test.tsx`
- **Descricao**: A task define 4 testes obrigatorios. O terceiro -- "Teste unitario: exclusao bloqueada exibe mensagem de erro" -- nao foi implementado. Os testes existentes cobrem: listagem, empty state, criacao com service, e criacao duplicada (409). Falta o cenario de exclusao com erro 409 que deve exibir o toast "Categoria vinculada a compras. Remova os vinculos antes de excluir."
- **Correcao sugerida**:
```typescript
it('shows error toast when deleting a linked category (409)', async () => {
  vi.mocked(catService.listCategories).mockResolvedValue([
    { id: 1, name: 'Mercado' },
  ]);
  vi.mocked(catService.deleteCategory).mockRejectedValue(
    new Error('HTTP 409: Conflict'),
  );

  render(<CategoriesPage />);

  await waitFor(() => {
    expect(screen.getByText('Mercado')).toBeDefined();
  });

  // Click delete button
  const dangerBtns = document.querySelectorAll('.cat-danger');
  await userEvent.click(dangerBtns[0] as HTMLElement);

  // Confirm deletion
  const confirmBtn = screen.getByText('Excluir');
  await userEvent.click(confirmBtn);

  await waitFor(() => {
    expect(
      screen.getByText('Categoria vinculada a compras. Remova os vinculos antes de excluir.'),
    ).toBeDefined();
  });
});
```

### Problemas Minor

**m1. Non-null assertion na chamada de updateCategory**
- **Arquivo**: `src/pages/CategoriesPage.tsx`, linha 72
- **Descricao**: O uso de `editingId!` (non-null assertion) e fragil. Se por algum bug `editingId` for null, o erro seria silencioso ou propagado de forma confusa.
- **Correcao sugerida**: Adicionar early return ou guard clause:
```typescript
if (formMode === 'edit') {
  if (editingId === null) return;
  await catService.updateCategory(editingId, { name });
  showToast('success', 'Categoria atualizada!');
}
```

**m2. Rota /categories nao registrada no App.tsx**
- **Arquivo**: `src/App.tsx`
- **Descricao**: A pagina CategoriesPage foi criada mas nao ha `<Route>` correspondente em `src/App.tsx`. Possivelmente isso sera feito em outra task (integracao de navegacao), mas vale registrar para nao ser esquecido.

**m3. Linhas em branco dentro de funcoes**
- **Arquivo**: `src/pages/CategoriesPage.tsx`, linhas 64-65, 66-67
- **Descricao**: A funcao `handleSave` possui linhas em branco internas (entre `if (!name) return;` e `try {`). O padrao de codigo do projeto orienta "No blank lines within methods/functions". O mesmo padrao e encontrado na referencia PaymentMethodsPage, entao e um padrao ja estabelecido no projeto -- mencionado apenas como observacao.

## Destaques Positivos

1. **Consistencia visual com PaymentMethodsPage**: A estrutura do componente (header, loading, empty state, list, overlay form, confirm dialog) segue exatamente o mesmo padrao da referencia, facilitando manutencao.

2. **Tratamento adequado de erros 409**: Tanto na criacao (nome duplicado com erro inline) quanto na exclusao (categoria vinculada com toast), os cenarios de conflito sao tratados com mensagens claras para o usuario.

3. **Reutilizacao do ConfirmDialog**: Uso correto do componente existente para confirmacao de exclusao, sem reinventar a roda.

4. **CSS bem organizado e responsivo**: Os estilos usam safe-area-inset, animacoes suaves no toast, e padroes consistentes com o design system do app (cores, border-radius, gradientes).

5. **Tipagem TypeScript correta**: Uso de tipos do `category.ts`, sem uso de `any`, e tipagem adequada dos estados com generics.

6. **Service layer bem utilizada**: Import do `categoryService` com namespace `catService` (consistente com `pmService` na referencia) e uso correto de todas as operacoes CRUD.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| React | OK |
| Testes | Problemas |

## Recomendacoes

1. **[Major]** Adicionar o teste unitario de exclusao com erro 409 conforme exigido pela task (M1).
2. **[Minor]** Substituir o non-null assertion `editingId!` por um guard clause explicito (m1).
3. **[Info]** Garantir que a rota `/categories` seja registrada no App.tsx na task de integracao de navegacao (m2).

## Veredito

A implementacao atende aos requisitos funcionais da task com boa qualidade. O unico ponto major e a ausencia de um teste exigido explicitamente pela task (exclusao bloqueada com 409). Apos adicionar esse teste, a task estara pronta para ser considerada concluida. Os problemas minor sao observacoes que podem ser enderecaradas opcionalmente.

**Proximo passo**: Implementar o teste de exclusao com 409 (M1) e marcar a task como concluida.
