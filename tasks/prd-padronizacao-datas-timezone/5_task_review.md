# Review: Task 5.0 - Frontend — Módulo único de utilitários de data (src/utils/date.ts)

**Revisor**: AI Code Reviewer
**Data**: 2026-08-23
**Arquivo da task**: 5_task.md
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

A Tarefa 5.0 entrega `src/utils/date.ts`, o módulo único de parsing/formatação/comparação de data do frontend, usando `dayjs` + plugins `utc`/`timezone`/`localizedFormat` + locale `pt-br`, conforme mandado pelo PRD (requisitos 7-10) e pela Tech Spec. As 5 funções da interface (`parseApiInstant`, `formatDateTime`, `formatCalendarDate`, `isPastDueDate`, `toApiInstant`) estão implementadas com assinaturas idênticas às definidas em "Interfaces Principais" da techspec.md, e a lógica de timezone foi verificada linha a linha — está correta:

- `parseApiInstant`/`formatDateTime` interpretam o instante ISO (UTC) recebido da API e o exibem em `America/Sao_Paulo` via `dayjs.utc(iso).tz(...)`, cobrindo corretamente viradas de dia e de mês/ano (validado nos testes).
- `formatCalendarDate` usa `dayjs(dateOnly)` sem `.utc()`/`.tz()`. Isso é intencional e correto: o parser nativo do dayjs para strings `YYYY-MM-DD` (sem sufixo `Z`) constrói o `Date` a partir dos componentes ano/mês/dia interpretados como horário local (não UTC), e a formatação de volta usa os mesmos componentes locais — o resultado é estável independentemente do timezone do host, sem o bug clássico de `new Date("YYYY-MM-DD")` (que usa UTC-meia-noite e pode exibir o dia anterior).
- `isPastDueDate` compara strings de calendário (`dateOnly < today`, ambas `YYYY-MM-DD`) em vez de comparar horários/objetos `Date`, evitando divergência de classificação perto da virada do dia — exatamente o requisito 10 do PRD.
- `toApiInstant` usa `dayjs.tz(`${dateStr}T${timeStr}:00`, APP_TIMEZONE).format()`, que interpreta a string como horário de parede em `America/Sao_Paulo` (não no timezone do processo/navegador) e produz ISO-8601 com offset `-03:00`, validado nos testes para 3 timezones de ambiente diferentes (`UTC`, `America/Los_Angeles`, `Asia/Tokyo`).

Os testes cobrem exatamente os casos exigidos na seção "Testes da Tarefa" do 5_task.md (viradas de dia/mês/ano, locale pt-BR, independência do timezone de ambiente, `isPastDueDate` nos limites da meia-noite) e adicionam casos extras de valor (formato customizado com nome de mês por extenso, meia-noite UTC cruzando ano). As 17 execuções passam, `tsc --noEmit` e `eslint` não acusam problemas — resultados reproduzidos de forma independente nesta revisão.

O módulo é curto (52 linhas), sem duplicação de lógica, sem `any`, sem parâmetros booleanos de flag, sem aninhamento de condicionais, e cada função é pura (query, sem mutação) e nomeada com verbo. Nenhum componente consumidor foi tocado, conforme escopo da tarefa — a duplicação de `new Date(...)` em `ManualEntryPage.tsx`, `PurchaseDetail.tsx` e `PurchaseList.tsx` permanece, como esperado, para a Tarefa 6.0.

Não foram encontrados problemas críticos ou major. As observações abaixo são todas de natureza menor/opcional e não bloqueiam a aprovação.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/utils/date.ts` | OK | 0 críticos / 0 major / 2 minor |
| `src/utils/date.test.ts` | OK | 0 |
| `package.json` (dep. `dayjs`) | OK | 0 |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`src/utils/date.ts:22,32` — chamada redundante de `.locale('pt-br')` por função.** O locale global já é fixado uma única vez no topo do módulo (`dayjs.locale('pt-br')`, linha 10), tornando as chamadas `.locale('pt-br')` dentro de `formatDateTime` e `formatCalendarDate` desnecessárias na prática (o `Dayjs` retornado por `parseApiInstant`/`dayjs(dateOnly)` já herda o locale global). Não é um bug — é uma redundância defensiva inofensiva (protege contra algum código externo que troque o locale global antes da chamada) — mas duplica a mesma instrução em dois lugares. Sugestão: manter apenas a fixação global no topo do arquivo e remover as duas chamadas redundantes, ou, se a defesa for intencional, documentar o motivo em um comentário curto.

2. **`localizedFormat` importado e registrado mas não utilizado ainda.** O plugin é adicionado conforme exigido pela subtarefa 5.1/techspec, mas nenhuma das duas strings de formato padrão (`'D MMM, HH:mm'`, `'DD/MM/YYYY'`) usa os tokens localizados que o plugin habilita (`L`, `LL`, `LLL`, etc.). Isso é esperado nesta tarefa (o plugin provavelmente será usado pelos componentes na Tarefa 6.0), mas vale confirmar no início da Tarefa 6.0 se ele de fato passa a ser consumido — caso contrário, é uma dependência morta.

## Destaques Positivos

- Assinaturas das 5 funções batem exatamente com o bloco `typescript` de "Interfaces Principais" da techspec.md, incluindo os parâmetros opcionais (`fmt?: string`) com defaults sensatos.
- Comentários JSDoc acima de cada função explicam o "porquê" da escolha de implementação (ex: por que `formatCalendarDate` não usa `.utc()`/`.tz()`, por que `isPastDueDate` compara strings em vez de horários) — exatamente o tipo de comentário que mitiga o risco documentado na techspec ("Riscos Conhecidos": locale `pt-br` silenciosamente cai para inglês se não importado) e evita que um futuro mantenedor "corrija" a lógica por engano, reintroduzindo os bugs que a tarefa corrige.
- Cobertura de teste de `toApiInstant` variando `process.env.TZ` entre `UTC`, `America/Los_Angeles` e `Asia/Tokyo` é uma verificação forte e direta do requisito 9 do PRD (preservar exatamente o valor digitado, sem deslocamento pelo timezone do navegador/ambiente).
- Testes de `isPastDueDate` cobrem precisamente a fronteira mais arriscada (23:59:59 do dia do vencimento → `false`; 00:00:01 do dia seguinte → `true`), validando o requisito 10 do PRD e a mitigação do bug de classificação perto da virada do dia.
- Nenhuma dependência nova além da explicitamente prevista (`dayjs`); `package-lock.json` mostra que `dayjs` já existia como dependência transitiva (`dev`, v1.11.19) e foi corretamente promovida a dependência direta de produção (v1.11.23) — sem inflar a árvore de dependências.
- Zero duplicação de lógica de data introduzida; o módulo é a única fonte de verdade preparada para a migração dos consumidores na Tarefa 6.0.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Padrões de Código | OK |
| TypeScript/Node.js | OK |
| REST/HTTP | N/A |
| Logging | N/A |
| React | N/A (módulo não-React) |
| Testes | OK |

## Recomendações

1. (Minor, opcional) Remover as chamadas redundantes de `.locale('pt-br')` em `formatDateTime`/`formatCalendarDate`, ou documentar em uma linha por que a redundância é intencional.
2. (Observação, não bloqueante) Ao iniciar a Tarefa 6.0, confirmar que `localizedFormat` passa a ser efetivamente usado por algum componente consumidor; caso contrário, considerar removê-lo do módulo.
3. (Fora do escopo desta tarefa, mas relevante para o commit) O `git status` do repositório mostra alterações não commitadas em `src/pages/PurchaseDetail.tsx`, `src/pages/PurchaseDetail.css` e `src/services/purchaseService.ts` (feature de edição inline de valor da compra) que **não pertencem à Tarefa 5.0** e não foram revisadas aqui. Recomenda-se commitar `src/utils/date.ts`, `src/utils/date.test.ts` e a mudança em `package.json`/`package-lock.json` isoladamente, sem misturar com essa feature não relacionada, para manter o histórico do PRD de datas/timezone limpo e rastreável.

## Veredito

**APROVADO COM OBSERVAÇÕES.** A implementação da Tarefa 5.0 está correta, testada e isolada conforme o design da Tech Spec. A lógica de timezone (UTC→`America/Sao_Paulo`, montagem de ISO com offset `-03:00`, comparação de calendário sem depender do relógio do navegador) foi verificada e está correta em todos os casos de borda relevantes. Nenhum problema crítico ou major impede o avanço para a Tarefa 6.0 (migração dos componentes consumidores). As duas observações minor (redundância de `.locale()` e uso ainda não confirmado de `localizedFormat`) podem ser tratadas a qualquer momento, inclusive durante a própria Tarefa 6.0, sem necessidade de retrabalho nesta tarefa. Recomenda-se apenas cuidado no momento do commit para não misturar esta entrega com as alterações não relacionadas já presentes no working tree.
