# Review: Task 2.0 - Criar componente `PeriodEditModal`

**Revisor**: AI Code Reviewer
**Data**: 2026-07-20
**Arquivo da task**: 2_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A implementacao entrega o componente `PeriodEditModal` com todos os requisitos funcionais da task: `IonModal` bottom-sheet com os breakpoints corretos, dois `IonDatetime` em `pt-BR`, validacao de datas, save via `updateBudgetPeriods`, toast de danger em erro e callback `onConfirmed` no sucesso. Os 5 testes unitarios cobrem todos os criterios de sucesso listados na task e passam sem falhas. TypeScript e ESLint tambem passam limpos. A implementacao e coesa, curta (105 linhas) e segue os padroes do projeto. Ha apenas pontos menores a observar.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/PeriodEditModal.tsx` | Problemas | 3 |
| `src/components/PeriodEditModal.test.tsx` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**MINOR-1** — `keepContentsMounted` ausente no `IonModal`
**Arquivo**: `src/components/PeriodEditModal.tsx`, linha 49
**Descricao**: A Tech Spec (secao "Pontos de Integracao") instrui o uso de `keepContentsMounted` no `IonDatetime` para evitar que o componente seja desmontado a cada abertura/fechamento do modal, o que pode causar um flash visual no calendário. O atributo nao foi incluido.
**Correcao sugerida**:
```tsx
<IonDatetime
  presentation="date"
  locale="pt-BR"
  keepContentsMounted={true}
  value={localStart}
  ...
/>
```

---

**MINOR-2** — Ausencia de atributos de acessibilidade no modal
**Arquivo**: `src/components/PeriodEditModal.tsx`, linhas 49-103
**Descricao**: O PRD (secao "Acessibilidade") exige label acessivel descrevendo o periodo completo. O `IonModal` nao possui `htmlAttributes={{ 'aria-labelledby': '...' }}` e o titulo `<h3>` nao tem `id` correspondente, diferentemente do padrao adotado em `CategoryDetailSheet.tsx` (linha 194 que usa `aria-labelledby: 'cds-title'`). Os botoes de acao tambem nao possuem `aria-label`.
**Correcao sugerida**:
```tsx
<IonModal
  ...
  htmlAttributes={{ 'aria-labelledby': 'period-edit-title' }}
>
  <IonContent>
    <div className="period-edit-content">
      <h3 id="period-edit-title" className="period-edit-title">Editar Período</h3>
      ...
      <button
        className="period-edit-save"
        aria-label="Salvar período"
        ...
      >
        Salvar
      </button>
    </div>
  </IonContent>
</IonModal>
```

---

**MINOR-3** — `onConfirmed` chamado antes de `onDismiss` pode causar double-render
**Arquivo**: `src/components/PeriodEditModal.tsx`, linhas 39-40
**Descricao**: No sucesso do save, `onConfirmed()` e chamado imediatamente antes de `onDismiss()`. Se `onConfirmed` disparar um reload de estado no componente pai, o `PeriodEditModal` ainda estara montado e visivel por um breve instante com dados potencialmente desatualizados. O padrao mais seguro e fechar primeiro e depois notificar o pai, ou agrupar em uma unica callback que o pai controla.
**Correcao sugerida** (ordem invertida):
```tsx
onDismiss();
onConfirmed();
```
Ou, preferivelmente, delegar ao pai via callback unica `onSaved` que encapsula dismiss + reload.

## Destaques Positivos

- **Logica de sincronizacao de estado no `useEffect`** (linhas 23-28): o reset de `localStart`/`localEnd` ao abrir o modal (`if (isOpen)`) e elegante e evita que valores antigos persistam entre aberturas — sem necessidade de `key` prop.
- **Guard duplo no `handleSave`** (linha 33): `if (isInvalid || saving) return` protege tanto contra datas invalidas quanto contra cliques duplos durante o request, sem necessidade de estado adicional.
- **`void` no handler do `onClick`** (linha 92): `onClick={() => void handleSave()}` lida corretamente com a promise de forma idiomatica, evitando o warning do ESLint para promises nao tratadas em event handlers.
- **Testes bem estruturados**: cada teste e focado em exatamente um criterio de sucesso, os mocks sao minimais e o uso de `data-testid` torna os seletores robustos contra mudancas de UI.
- **Separacao clara de responsabilidades**: o componente nao gerencia estado de visibilidade (`isOpen` e controlado pelo pai), seguindo o padrao do projeto.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript | OK |
| React | OK |
| Ionic/Mobile | Problemas |
| Acessibilidade | Problemas |
| Testes | OK |

## Recomendacoes

1. Adicionar `keepContentsMounted={true}` em ambos os `IonDatetime` para evitar flash visual ao reabrir o modal (MINOR-1).
2. Adicionar `htmlAttributes={{ 'aria-labelledby': 'period-edit-title' }}` no `IonModal` e `id="period-edit-title"` no `<h3>`, seguindo o padrao de `CategoryDetailSheet` (MINOR-2).
3. Avaliar inverter a ordem `onDismiss()` / `onConfirmed()` para reduzir o risco de double-render transitorio no componente pai (MINOR-3).

## Veredito

A task esta **APROVADA COM OBSERVACOES**. Os requisitos funcionais estao todos implementados e verificados, os checks de qualidade (typecheck, testes, lint) passam limpos. Os tres pontos levantados sao melhorias de qualidade (acessibilidade e comportamento Ionic) que nao bloqueiam a entrega, mas devem ser endereçados antes da integracao com `BudgetPeriodCard` na task seguinte para que o componente atenda ao PRD em sua totalidade.
