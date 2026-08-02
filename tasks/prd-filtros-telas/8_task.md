# Tarefa 8.0: Frontend - Integracao de filtros na Tab2 (Notas Fiscais) + Range de Datas

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar `MonthSelector`, `CategoryFilterBar` e range de datas na Tab2 (Notas Fiscais), conectando ao `FilterContext`. Inclui toggle entre modo "Mes" e modo "Periodo", com dois campos de data (inicio/fim) no modo periodo usando `IonDatetime`.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-1.4: Alterar mes atualiza total e lista de notas.
- RF-2.1 a RF-2.7: Filtro por categoria com chips.
- RF-3.1: Toggle entre modo "Mes" e modo "Periodo".
- RF-3.2: Modo "Periodo" exibe campos data inicio e data fim.
- RF-3.3: Data inicio nao pode ser posterior a data fim.
- RF-3.4: Range atualiza lista e total.
- RF-3.5: Modo padrao e "Mes".
- Usar `getInvoices(params)` do service (task 6).
- Filtro de categoria aplicado localmente.
- Loading state ao trocar de mes ou periodo.
</requirements>

## Subtarefas

- [ ] 8.1 Consumir `useFilter()` na Tab2 para obter `tab2` state.
- [ ] 8.2 Adicionar `MonthSelector` abaixo do header (visivel no modo "Mes").
- [ ] 8.3 Criar toggle "Mes" / "Periodo" (botoes ou segmented control).
- [ ] 8.4 No modo "Periodo", exibir dois campos de data usando `IonDatetime` (data inicio e data fim).
- [ ] 8.5 Implementar validacao: startDate <= endDate (desabilitar botao ou mostrar alerta).
- [ ] 8.6 Refatorar `loadInvoices` para usar `getInvoices(params)` do service, passando month ou startDate/endDate conforme o modo.
- [ ] 8.7 Adicionar `CategoryFilterBar` abaixo do seletor de periodo, extraindo categorias unicas dos invoices.
- [ ] 8.8 Filtrar invoices localmente por categoria e recalcular total.
- [ ] 8.9 Adicionar CSS para o toggle e date pickers.
- [ ] 8.10 Escrever testes.

## Detalhes de Implementacao

Consultar `techspec.md` secoes:
- "Pontos de Integracao" — uso de `IonDatetime`.
- "Consideracoes Tecnicas" — dois campos separados para range (nao range picker unico).

**Toggle Mes/Periodo:** Pode usar `IonSegment` + `IonSegmentButton` do Ionic para consistencia visual, ou botoes custom com CSS.

**IonDatetime:** Usar `presentation="date"` para seletor de data sem hora. Formato de valor: `YYYY-MM-DD`.

**Fluxo de dados:**
- Modo "Mes": `getInvoices({ month: tab2.month, page: tab2.page })`
- Modo "Periodo": `getInvoices({ startDate: tab2.startDate, endDate: tab2.endDate, page: tab2.page })`

## Criterios de Sucesso

- Modo "Mes": trocar mes atualiza lista e total.
- Modo "Periodo": selecionar datas atualiza lista e total.
- Toggle entre modos funciona sem perder dados.
- Validacao impede startDate > endDate.
- Filtro de categoria funciona em ambos os modos.
- Loading state aparece ao trocar periodo.
- Estado vazio quando filtros nao retornam resultados.

## Testes da Tarefa

- [ ] Teste unitario: Tab2 renderiza MonthSelector no modo "Mes".
- [ ] Teste unitario: toggle para modo "Periodo" exibe campos de data.
- [ ] Teste unitario: validacao startDate > endDate mostra erro/desabilita.
- [ ] Teste unitario: filtro de categoria filtra lista e recalcula total.
- [ ] Teste de integracao: modo "Mes" chama getInvoices com month.
- [ ] Teste de integracao: modo "Periodo" chama getInvoices com startDate/endDate.
- [ ] Teste de integracao: toggle entre modos dispara nova chamada ao backend.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/pages/Tab2.tsx`
- `/controlai-frontend/src/pages/Tab1.css` (estilos compartilhados)
- `/controlai-frontend/src/components/MonthSelector.tsx` (task 4)
- `/controlai-frontend/src/components/CategoryFilterBar.tsx` (task 5)
- `/controlai-frontend/src/context/FilterContext.tsx` (task 3)
- `/controlai-frontend/src/services/purchaseService.ts` (task 6)
