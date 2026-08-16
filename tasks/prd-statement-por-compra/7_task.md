# Tarefa 7.0: Frontend — eliminar fallback de valor bruto e corrigir "Total Filtrado"

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Com o backend sempre retornando `installmentAmount`/`installmentNumberForMonth` preenchidos (apos Tarefas 1, 3 e 4), esta tarefa remove o fallback `installmentAmount ?? amount` do frontend e corrige diretamente o bug do card "Total Filtrado" em `Tab1.tsx`, que hoje soma `n.amount` bruto sem nenhum fallback. Os tipos `installmentAmount`/`installmentNumberForMonth` em `purchaseService.ts` deixam de ser opcionais/nulos.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices`: mudancas sao simplificacao de tipos e remocao de fallback condicional em componentes de exibicao ja existentes, sem novo estado/fetch.
</skills>

<requirements>
- PRD 3.1, 3.2 (nenhuma tela soma/exibe valor bruto para "gasto do mes"; elimina a logica condicional de fallback).
- PRD "Historias de Usuario": total da tela Inicio bate exatamente com a soma dos itens individuais listados logo abaixo.
- Ver Tech Spec, secao "Frontend Tab1.tsx, PurchaseList.tsx, CategoryDetailSheet.tsx, purchaseService.ts" em Visao Geral dos Componentes e "Modelos de Dados".
</requirements>

## Subtarefas

- [ ] 7.1 Corrigir `filteredTotal` em `Tab1.tsx` (linha ~106) para somar `n.installmentAmount` em vez de `n.amount`.
- [ ] 7.2 Remover o fallback `installmentAmount ?? amount` em `CategoryDetailSheet.tsx` (linha ~301) e `PurchaseList.tsx` (linha ~259), usando `installmentAmount` diretamente.
- [ ] 7.3 Atualizar o tipo `PaymentNotification` em `purchaseService.ts`: `installmentAmount`/`installmentNumberForMonth` passam de `number | null` (opcional) para `number` (obrigatorio).
- [ ] 7.4 Ajustar os testes existentes (`PurchaseList.test.tsx`, `purchaseService.test.ts`, `Tab1.test.tsx`) para refletir o novo contrato sem fallback.
- [ ] 7.5 Confirmar visualmente (dev server) que a tela Inicio, o detalhe por categoria e a listagem principal mostram o mesmo valor para uma compra parcelada e para uma compra a vista/Pix/dinheiro no mesmo mes.

## Detalhes de Implementacao

Ver Tech Spec, secao "Modelos de Dados": tipo TypeScript simplificado de `number | null` para `number` como parte da limpeza da Funcionalidade 3.2.

## Criterios de Sucesso

- O card "Total Filtrado" da tela Inicio bate exatamente com a soma dos itens listados logo abaixo, para qualquer combinacao de compras parceladas/a vista/Pix/dinheiro no mes.
- Nenhum componente do frontend usa `?? amount`/`?? n.amount` como fallback para exibir "gasto do mes".
- O tipo `PaymentNotification.installmentAmount`/`installmentNumberForMonth` nao e mais opcional.

## Testes da Tarefa

- [ ] Testes de unidade: `PurchaseList.test.tsx`, `purchaseService.test.ts`, `Tab1.test.tsx` (ou equivalentes) atualizados e passando com o novo contrato.
- [ ] Verificacao manual no dev server: comparar "Total Filtrado" com a soma da listagem para um mes com compras mistas (parcelada + a vista + Pix + dinheiro).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/Tab1.tsx`
- `src/components/CategoryDetailSheet.tsx`
- `src/components/PurchaseList.tsx`
- `src/services/purchaseService.ts`
- `src/pages/Tab1.test.tsx`, `src/components/PurchaseList.test.tsx`, `src/services/purchaseService.test.ts`
