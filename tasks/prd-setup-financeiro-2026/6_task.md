# Tarefa 6.0: Frontend — Servico e tipos de categorias

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o servico HTTP e os tipos TypeScript para comunicacao com a API de categorias no backend. Fundacao para todas as telas de frontend que usam categorias.

<skills>
### Conformidade com Skills Padroes

- **`ionic-design`**: Padrao de comunicacao HTTP (CapacitorHttp / fetch).
- **`clean-code`**: Funcoes puras, tipos bem definidos.
</skills>

<requirements>
- Interface TypeScript `Category` com `id: number` e `name: string`
- Interface `CreateCategoryRequest` com `name: string`
- Interface `UpdateCategoryRequest` com `name: string`
- Funcoes de servico: `listCategories()`, `getCategory(id)`, `createCategory(data)`, `updateCategory(id, data)`, `deleteCategory(id)`
- Usar padrao HTTP existente do projeto (CapacitorHttp nativo / fetch web)
- Atualizar `ManualNotificationRequest` — trocar `category: string` por `categoryId: number`
</requirements>

## Subtarefas

- [ ] 6.1 Criar `src/types/category.ts` com interfaces
- [ ] 6.2 Criar `src/services/categoryService.ts` com funcoes CRUD
- [ ] 6.3 Atualizar `ManualNotificationRequest` em `src/types/paymentMethod.ts` — `categoryId` em vez de `category`
- [ ] 6.4 Escrever testes unitarios do servico

## Detalhes de Implementacao

Consultar a secao **Tipo TypeScript (frontend)** e **Endpoints de API** da `techspec.md`.

Referencia de servico: `src/services/paymentMethodService.ts` (mesmo padrao de httpRequest).

## Criterios de Sucesso

- Tipos TypeScript definidos e exportados
- Servico com 5 funcoes cobrindo CRUD completo
- `ManualNotificationRequest` atualizado com `categoryId`
- Build (`npm run build`) passa sem erros de tipo

## Testes da Tarefa

- [ ] Teste unitario: funcoes de servico fazem chamadas HTTP corretas (mock de httpRequest)
- [ ] Verificacao: `npm run build` passa sem erros

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/services/paymentMethodService.ts` — Referencia de servico HTTP
- `controlai-frontend/src/types/paymentMethod.ts` — Onde atualizar ManualNotificationRequest
- `controlai-frontend/src/services/paymentMethodService.test.ts` — Referencia de testes
