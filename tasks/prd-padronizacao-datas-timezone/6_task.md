# Tarefa 6.0: Frontend — Migracao dos componentes consumidores + correcao dos bugs conhecidos

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Migrar todos os componentes que hoje implementam logica propria de parsing/formatacao de data (`new Date(...)` espalhado) para consumir exclusivamente `src/utils/date.ts`. Esta migracao inclui, como parte do proprio trabalho (nao como patches isolados), a correcao dos dois bugs conhecidos: deslocamento de horario em `ManualEntryPage.tsx` e comparacao inconsistente de `dueDate` em `PurchaseDetail.tsx`.

**Depende das Tarefas 4.0 e 5.0** — precisa do contrato de API final (formato `Instant`/`LocalDate` nativo definido na Tarefa 4.0) e do modulo de utilitarios (Tarefa 5.0) para migrar os componentes.

<skills>
### Conformidade com Skills Padroes

- `clean-code`: remove duplicacao de logica de data em ~8 componentes, centralizando em `src/utils/date.ts`.
- `vercel-react-best-practices`: a migracao deve preservar os padroes de memoizacao/effects ja existentes nos arquivos tocados, sem introduzir novo padrao de data fetching.
- `ionic-design`: uso de `IonDatetime` em `PeriodEditModal.tsx`/`DuplicateMonthModal.tsx` nao muda de componente, apenas o tratamento do valor retornado passa a usar `src/utils/date.ts`.
</skills>

<requirements>
- O fluxo de registro manual de compra nao deve mais introduzir deslocamento de horario entre o valor informado pelo usuario e o valor persistido (PRD requisito 11).
- A logica que determina se uma parcela esta vencida deve usar interpretacao de data consistente com a usada para exibi-la, eliminando divergencia perto da virada do dia (PRD requisito 12).
- Toda conversao de data recebida da API para exibicao deve produzir o mesmo resultado visual independentemente do timezone do navegador/dispositivo do usuario (PRD requisito 8).
- Toda data/hora enviada da interface para a API deve preservar o valor exatamente como inserido pelo usuario (PRD requisito 9).
- Formato visual pt-BR (dd/MM/yyyy, mes abreviado em portugues, hora 24h) deve ser preservado (PRD, Experiencia do Usuario) — a padronizacao corrige o valor, nao o layout.
</requirements>

## Subtarefas

- [ ] 6.1 `ManualEntryPage.tsx`: corrigir o bug de deslocamento de horario, usando `toApiInstant` de `src/utils/date.ts` ao enviar a API.
- [ ] 6.2 `PurchaseDetail.tsx`: corrigir a comparacao inconsistente de `dueDate`, usando `isPastDueDate`/`parseApiInstant` de `src/utils/date.ts`.
- [ ] 6.3 `PurchaseList.tsx`: migrar formatacao de data para `src/utils/date.ts`.
- [ ] 6.4 `AssociatePage.tsx`: migrar formatacao/parsing de data para `src/utils/date.ts`.
- [ ] 6.5 `SuggestionsPage.tsx`: migrar formatacao de data para `src/utils/date.ts`.
- [ ] 6.6 `CategoryDetailSheet.tsx`: migrar formatacao de data para `src/utils/date.ts`.
- [ ] 6.7 `Tab2.tsx`: migrar formatacao/comparacao de data para `src/utils/date.ts`.
- [ ] 6.8 `FilterContext.tsx`: migrar logica de data usada nos filtros para `src/utils/date.ts`.
- [ ] 6.9 `PeriodEditModal.tsx`: migrar tratamento do valor retornado por `IonDatetime` para `src/utils/date.ts`.
- [ ] 6.10 `DuplicateMonthModal.tsx`: migrar tratamento do valor retornado por `IonDatetime` para `src/utils/date.ts`.
- [ ] 6.11 `MonthSelector.tsx`: migrar formatacao de data para `src/utils/date.ts`.
- [ ] 6.12 `ProfilePage.tsx`: migrar formatacao de data para `src/utils/date.ts`.
- [ ] 6.13 Confirmar que `src/services/purchaseService.ts` e `src/types/installment.ts` mantem tipos `string` sem mudanca estrutural (apenas consumidos corretamente pelos componentes acima).
- [ ] 6.14 Escrever testes de unidade/componente (ver secao de Testes).

## Detalhes de Implementacao

Ver secao "Visao Geral dos Componentes" (Frontend) e "Fluxo de dados" da `techspec.md` para o caminho completo API → `src/utils/date.ts` → exibicao, e o caminho inverso (entrada manual → `toApiInstant` → API).

## Criterios de Sucesso

- Nenhum componente listado contem `new Date(...)` ou logica propria de parsing/formatacao de data — toda chamada passa por `src/utils/date.ts`.
- Compra registrada manualmente informando data/hora especifica exibe exatamente o mesmo valor no detalhe da compra (bug de deslocamento eliminado).
- Parcela com `dueDate` igual a data atual e classificada corretamente como vencida/nao vencida, inclusive perto da virada de dia.

## Testes da Tarefa

- [ ] Testes de unidade/componente: cobertura dos componentes migrados garantindo que a formatacao exibida bate com o valor esperado em pt-BR.
- [ ] Teste de regressao especifico para `ManualEntryPage.tsx`: valor informado no formulario == valor persistido == valor exibido no detalhe (sem deslocamento).
- [ ] Teste de regressao especifico para `PurchaseDetail.tsx`: parcela com `dueDate` = hoje classificada de forma consistente entre exibicao e logica de vencimento.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/ManualEntryPage.tsx`
- `src/pages/PurchaseDetail.tsx`
- `src/pages/AssociatePage.tsx`
- `src/pages/SuggestionsPage.tsx`
- `src/pages/Tab2.tsx`
- `src/pages/ProfilePage.tsx`
- `src/context/FilterContext.tsx`
- `src/components/PurchaseList.tsx`
- `src/components/CategoryDetailSheet.tsx`
- `src/components/PeriodEditModal.tsx`
- `src/components/DuplicateMonthModal.tsx`
- `src/components/MonthSelector.tsx`
- `src/services/purchaseService.ts`, `src/types/installment.ts`
