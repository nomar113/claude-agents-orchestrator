# Tarefa 5.0: Atualizar CSS e integrar em `Tab1` e `BudgetPage`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Etapa final de integração: adicionar as classes CSS necessárias para o efeito de sobreposição do banner sobre o card, e remover de `Tab1.tsx` e `BudgetPage.tsx` todo o estado de edição de período (`editPeriods`, `periodErrors`, handlers) que agora é gerenciado internamente pelos componentes. As pages passam a fornecer apenas `budgetId` e `onPeriodSaved` ao `BudgetPeriodSection`.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — garantir que o efeito de sobreposição (margin-top negativo + z-index) funciona corretamente em iOS e Android
- `executar-task` — executar typecheck, testes e lint antes de marcar concluída; este é o ponto de integração final — todos os checks devem passar sem erros
</skills>

<requirements>
- Adicionar em `BudgetPage.css` (ou arquivo CSS correspondente):
  - `.period-banner-wrapper` — `position: relative`
  - `.period-date-banner` — `border-radius: 16px 16px 0 0`, `min-height: 44px`, `cursor: pointer`, `display: flex`, fundo `#1C2240`
  - `.period-date-banner-icon` — cor `#ffffff60`
  - `.period-date-banner-text` — `font-family: 'IBM Plex Mono'`
  - `.period-date-banner-sep` — `opacity: 0.5`
  - `.period-card` — adicionar `position: relative`, `z-index: 1`, `margin-top: -12px`
- Remover de `Tab1.tsx`: estado `editPeriods`, `periodErrors` e todos os handlers de período
- Remover de `BudgetPage.tsx`: idem
- Remover de ambas as pages o repasse das props antigas ao `BudgetPeriodSection`
- Passar `budgetId` e `onPeriodSaved` (recarregamento silencioso do budget) ao `BudgetPeriodSection` em ambas as pages
- Verificar `Tab1.css` para remover eventuais estilos de período "De/Até" obsoletos
</requirements>

## Subtarefas

- [ ] 5.1 Adicionar as classes CSS de banner e overlap em `BudgetPage.css` (ver seção "Layout CSS" da techspec)
- [ ] 5.2 Verificar `Tab1.css` e remover estilos de período obsoletos se existirem
- [ ] 5.3 Refatorar `Tab1.tsx`: remover `editPeriods`, `periodErrors`, handlers de período; passar `budgetId` e `onPeriodSaved` para `BudgetPeriodSection`
- [ ] 5.4 Refatorar `BudgetPage.tsx`: mesmas remoções que `Tab1.tsx`; remover período do `handleSaveAll` se aplicável
- [ ] 5.5 Executar teste de integração: renderizar `BudgetPeriodSection` com períodos reais e verificar que toque no banner do primeiro card abre `PeriodEditModal` com as datas corretas
- [ ] 5.6 Verificar visualmente o efeito de sobreposição (banner arredondado no topo, card sobreposto com margin-top negativo)

## Detalhes de Implementacao

Ver `techspec.md` — seções:
- **Layout CSS — Efeito de Sobreposição** → diagrama ASCII e lista de classes com valores exatos
- **Visão Geral dos Componentes** → linhas `Tab1.tsx` e `BudgetPage.tsx` e `BudgetPage.css`
- **Riscos Conhecidos** → IonDatetime e locale pt-BR (testar em dispositivo físico)

## Criterios de Sucesso

- Banner exibido acima do card com bordas arredondadas somente no topo
- Card sobrepõe o banner levemente (efeito de hierarquia visual com margin-top negativo)
- Nenhuma referência a `editPeriods`, `periodErrors` ou handlers de período em `Tab1.tsx` e `BudgetPage.tsx`
- Nenhuma tela do app exibe o estilo "De/Até" com campos separados
- TypeScript compila sem erros em todos os arquivos modificados (`tsc --noEmit`)
- Todos os testes passam (`vitest run`)
- Lint sem warnings (`eslint`)

## Testes da Tarefa

- [ ] Testes de integração:
  - `BudgetPeriodSection` renderizado com períodos reais: toque no banner do primeiro card abre `PeriodEditModal` com as datas corretas preenchidas
- [ ] Testes E2E (Playwright — se configurado):
  - Navegar até Tab1 → seção "PERIODO POR MEIO DE PAGAMENTO" → tocar no banner de um cartão → selecionar nova data no IonDatetime → confirmar → verificar que o banner reflete a nova data sem reload da página
- [ ] Testes de unidade: N/A (lógica removida das pages; componentes já testados nas tasks anteriores)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/BudgetPage.css` ← MODIFICAR (adicionar classes de banner e overlap)
- `src/pages/Tab1.css` ← VERIFICAR (remover estilos obsoletos se houver)
- `src/pages/Tab1.tsx` ← MODIFICAR (remover estado de período)
- `src/pages/BudgetPage.tsx` ← MODIFICAR (remover estado de período)
- `src/components/BudgetPeriodSection.tsx` ← DEPENDÊNCIA (task 4)
- `tasks/prd-estilo-datas-cartao/techspec.md` ← LEITURA OBRIGATÓRIA
