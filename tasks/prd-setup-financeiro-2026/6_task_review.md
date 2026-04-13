# Review: Task 6 - Frontend -- Servico e tipos de categorias

**Revisor**: AI Code Reviewer
**Data**: 2026-04-11
**Arquivo da task**: 6_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task implementou corretamente o servico HTTP de categorias (`categoryService.ts`), os tipos TypeScript (`category.ts`), atualizou `ManualNotificationRequest` para usar `categoryId` em vez de `category`, adicionou `categoryId` ao `PaymentNotificationDetail`, integrou a ManualEntryPage com categorias do backend e criou 6 testes unitarios. Build e testes passam sem erros (21 testes, 0 falhas). A qualidade geral e boa, com aderencia aos padroes existentes do projeto. Ha observacoes menores sobre duplicacao de codigo e um ponto funcional sobre reset de estado no formulario.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/types/category.ts` | OK | 0 |
| `src/services/categoryService.ts` | Problemas | 1 |
| `src/services/categoryService.test.ts` | OK | 0 |
| `src/services/paymentMethodService.ts` | Problemas | 1 |
| `src/services/purchaseService.ts` | OK | 0 |
| `src/pages/ManualEntryPage.tsx` | Problemas | 2 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1 — Funcao `httpRequest` duplicada em 3 servicos**
- **Arquivos**: `categoryService.ts` (linhas 5-35), `paymentMethodService.ts` (linhas 16-46), `purchaseService.ts` (linhas 4-34)
- **Descricao**: A funcao `httpRequest` (35 linhas identicas) esta copiada integralmente nos 3 servicos. Isso viola o principio DRY e significa que qualquer correcao futura (ex.: adicionar autenticacao, retry, interceptors) precisara ser replicada em todos os arquivos.
- **Observacao**: Esse problema ja existia antes desta task (foi herdado de `paymentMethodService.ts`). Portanto, nao e um defeito introduzido, mas a task perdeu a oportunidade de refatorar. Classificado como major nao-bloqueante por ser divida tecnica pre-existente.
- **Correcao sugerida**: Extrair `httpRequest` para um modulo compartilhado:
```typescript
// src/services/httpClient.ts
export async function httpRequest<T>(
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH',
  path: string,
  body?: unknown,
): Promise<T> { /* ... */ }
```

### Problemas Minor

**m1 — `categoryId` nao e resetado apos submissao do formulario**
- **Arquivo**: `src/pages/ManualEntryPage.tsx`, linha 101-103
- **Descricao**: Apos salvar uma compra, `amount`, `merchantName` e `time` sao resetados, mas `categoryId` nao. Isso pode ser intencional (manter a categoria para entradas consecutivas da mesma categoria), mas e inconsistente com o reset dos outros campos. Se o usuario estiver cadastrando compras de categorias diferentes, tera que lembrar de trocar manualmente.
- **Correcao sugerida**: Adicionar `setCategoryId(null)` junto aos outros resets, ou documentar a decisao de manter:
```typescript
showToast('success', 'Compra salva com sucesso!');
setAmount('');
setMerchantName('');
setCategoryId(null);
setTime('');
```

**m2 — Interface `ManualNotificationRequest` definida no servico em vez do arquivo de tipos**
- **Arquivo**: `src/services/paymentMethodService.ts`, linhas 103-112
- **Descricao**: A interface `ManualNotificationRequest` esta definida diretamente no arquivo de servico, enquanto todas as outras interfaces de request (`CreatePaymentMethodRequest`, `UpdatePaymentMethodRequest`, etc.) estao em `src/types/paymentMethod.ts`. Isso quebra a consistencia de organizacao do projeto.
- **Observacao**: A task 6 especificava atualizar `ManualNotificationRequest` em `src/types/paymentMethod.ts`, mas a interface ja estava no servico antes da task. Nao e um defeito introduzido por esta task.
- **Correcao sugerida**: Mover `ManualNotificationRequest` para `src/types/paymentMethod.ts` junto com as demais interfaces de request.

**m3 — Ausencia de tratamento de estado vazio/loading para categorias**
- **Arquivo**: `src/pages/ManualEntryPage.tsx`, linhas 171-181
- **Descricao**: Se a API de categorias falhar ou retornar vazio, a secao de chips fica invisivel sem qualquer feedback ao usuario. Nao ha estado de loading nem mensagem de erro/fallback.
- **Correcao sugerida**: Adicionar um indicador de loading ou mensagem de fallback:
```tsx
{categories.length === 0 ? (
  <span className="me-empty-hint">Carregando categorias...</span>
) : (
  categories.map((cat) => (/* ... */))
)}
```

## Destaques Positivos

1. **Aderencia ao padrao existente**: O `categoryService.ts` segue fielmente a mesma estrutura e convencoes de `paymentMethodService.ts`, facilitando a manutencao.
2. **Tipos bem definidos**: As interfaces `Category`, `CreateCategoryRequest` e `UpdateCategoryRequest` sao claras, simples e aderem ao PascalCase.
3. **Cobertura de testes adequada**: Os 6 testes cobrem todas as 5 operacoes CRUD + tratamento de erro, com mocks bem estruturados.
4. **Tratamento de HTTP 204**: O servico trata corretamente respostas sem conteudo (204) no `deleteCategory`.
5. **Integracao limpa no ManualEntryPage**: A substituicao de categorias hardcoded por dados do backend foi feita de forma coesa, usando `useEffect` para carregar e `categoryId` (number) em vez de `category` (string).
6. **Funcoes de servico claras**: Cada funcao tem nome descritivo iniciando com verbo e responsabilidade unica.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | OK |
| React | Problemas (m1, m3 — reset e loading) |
| Testes | OK |

## Recomendacoes

1. **(Funcional)** Decidir se `categoryId` deve ser resetado apos submissao e aplicar a decisao de forma consistente (m1).
2. **(UX)** Adicionar tratamento de estado vazio/loading para a lista de categorias no formulario (m3).
3. **(Divida tecnica)** Em uma task futura, extrair `httpRequest` para um modulo compartilhado, eliminando a triplicacao de codigo (M1).
4. **(Organizacao)** Mover `ManualNotificationRequest` de `paymentMethodService.ts` para `src/types/paymentMethod.ts` (m2).

## Veredito

**APROVADO COM OBSERVACOES.** A implementacao atende todos os criterios de sucesso da task: tipos exportados, servico CRUD completo, `ManualNotificationRequest` atualizado, build sem erros e 21 testes passando. Os problemas encontrados sao menores (UX e consistencia) e a duplicacao de `httpRequest` e divida tecnica herdada, nao introduzida. A task pode seguir adiante sem bloqueio.
