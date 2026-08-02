# Review: Task 1.0 - Criar componente `CardPeriodBanner`

**Revisor**: AI Code Reviewer
**Data**: 2026-07-20
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

O componente `CardPeriodBanner` foi implementado com fidelidade ao escopo da task. A estrutura e prop types estao corretos, a formatacao de datas funciona, os quatro casos de teste obrigatorios passam, o TypeScript compila sem erros e o ESLint nao reporta warnings. O CSS foi adicionado ao `BudgetPage.css` com todas as classes exigidas pela Tech Spec.

Ha duas observacoes tecnicas que nao bloqueiam aprovacao mas merecem atencao: o handler `onKeyDown` nao trata o ativador de teclado `Space` (padrao WAI-ARIA para `role="button"`), e o inline comment do tipo de prop (`// ISO: 'YYYY-MM-DD'`) viola o padrao de codigo que exige codigo autoexplicativo sem comentarios.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/components/CardPeriodBanner.tsx` | Problemas | 2 |
| `src/components/CardPeriodBanner.test.tsx` | OK | 0 |
| `src/pages/BudgetPage.css` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

**[MINOR-1] `onKeyDown` nao trata tecla `Space`**
- **Arquivo**: `src/components/CardPeriodBanner.tsx`, linha 32
- **Descricao**: Elementos com `role="button"` devem responder a `Enter` e `Space` para conformidade WAI-ARIA. O handler atual dispara `onTap` apenas em `Enter`, deixando `Space` sem acao, o que afeta usuarios de teclado e switch control.
- **Codigo atual**:
  ```tsx
  onKeyDown={(e) => e.key === 'Enter' && onTap()}
  ```
- **Correcao sugerida** (alinhada com o padrao ja adotado em `PetalDistributionChart.tsx`):
  ```tsx
  onKeyDown={(e) => {
    if (e.key !== 'Enter' && e.key !== ' ') return;
    onTap();
  }}
  ```

**[MINOR-2] Inline comment na interface de props**
- **Arquivo**: `src/components/CardPeriodBanner.tsx`, linha 6
- **Descricao**: O padrao de codigo proibe comentarios — o codigo deve ser autoexplicativo. O comentario `// ISO: 'YYYY-MM-DD'` pode ser eliminado tornando o nome da prop mais descritivo ou usando um tipo alias.
- **Codigo atual**:
  ```tsx
  startDate: string; // ISO: 'YYYY-MM-DD'
  endDate: string;
  ```
- **Correcao sugerida**:
  ```tsx
  type IsoDateString = string; // ex.: '2026-06-04'

  interface CardPeriodBannerProps {
    startDate: IsoDateString;
    endDate: IsoDateString;
    onTap: () => void;
  }
  ```
  Alternativa minima (sem alias): remover o comentario e documentar o contrato no teste, o que ja ocorre implicitamente.

### Problemas Minor — Observacoes sem acao obrigatoria

**[OBS-1] `PT_MONTHS` e `toAriaDate` nao estao exportados — acoplamento implicito**
- **Arquivo**: `src/components/CardPeriodBanner.tsx`, linhas 11–19
- **Descricao**: A constante `PT_MONTHS` e a funcao `toAriaDate` sao privadas ao modulo, o que e correto para o escopo atual. Porem, tasks futuras (como `PeriodEditModal`) podem precisar de formatacao de data por extenso para o aria-label do modal. Se isso acontecer, considerar extrair para `src/utils/dateFormat.ts`. Nao e uma acao exigida nesta task.

**[OBS-2] Arquivos nao foram commitados**
- **Descricao**: `CardPeriodBanner.tsx` e `CardPeriodBanner.test.tsx` aparecem como `??` no `git status` (untracked). Apenas `BudgetPage.css` foi adicionado ao ultimo commit. Isso e aceitavel se o commit esta planejado ao final de um conjunto de tasks, mas vale registrar.

## Destaques Positivos

- **Reutilizacao de `toDisplay`**: a funcao de formatacao ISO → DD/MM/YYYY foi importada de `BudgetPeriodCard.tsx` em vez de duplicada, seguindo o principio DRY e o requisito explicito da subtarefa 1.2.
- **Cobertura de testes completa**: os quatro casos exigidos pela task foram implementados com clareza — renderizacao de datas, icone, callback e aria-label.
- **Acessibilidade basica presente**: `role="button"`, `tabIndex={0}` e `aria-label` descritivo foram implementados corretamente.
- **CSS fiel a Tech Spec**: todas as cinco classes listadas na Tech Spec (`.period-banner-wrapper`, `.period-date-banner`, `.period-date-banner-icon`, `.period-date-banner-text`, `.period-date-banner-sep`) foram criadas com os valores exatos especificados (`min-height: 44px`, `border-radius: 16px 16px 0 0`, `opacity: 0.5` via cor, `font-family: 'IBM Plex Mono'`).
- **Componente puro e enxuto**: 43 linhas totais, zero estado interno, zero efeitos colaterais — exatamente o que a task especificava.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas |
| TypeScript | OK |
| React | OK |
| Ionic/Design System | OK |
| Testes | OK |
| Acessibilidade | Problemas |

## Recomendacoes

1. **(Prioritario)** Adicionar `' '` (Space) ao handler `onKeyDown` para conformidade WAI-ARIA com `role="button"` — uma linha de mudanca, zero risco.
2. Remover o inline comment da interface de props (`// ISO: 'YYYY-MM-DD'`), ou converter para um tipo alias `IsoDateString` se outras tasks do PRD vierem a usar o mesmo tipo.
3. Incluir os arquivos `CardPeriodBanner.tsx` e `CardPeriodBanner.test.tsx` no proximo commit do ciclo de desenvolvimento da feature.
4. Avaliar, ao implementar `PeriodEditModal` (Task 2), se `toAriaDate` e `PT_MONTHS` devem ser extraidos para `src/utils/dateFormat.ts` para evitar duplicacao entre os dois componentes.

## Veredito

Task aprovada com observacoes. O componente esta funcional, testado e alinhado com o escopo. Os dois problemas minor encontrados nao bloqueiam o avanco para a proxima task. Recomenda-se corrigir o handler de teclado (`Space`) antes de considerar a feature completa, pois afeta acessibilidade — criterio listado explicitamente no PRD.
