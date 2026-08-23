# Tarefa 5.0: Frontend — Modulo unico de utilitarios de data (src/utils/date.ts)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar `src/utils/date.ts` como unico ponto de logica de parsing/formatacao/comparacao de data no frontend, usando `dayjs` com os plugins `utc`/`timezone`/`localizedFormat` e locale `pt-br`. Este modulo e isolado e testavel independentemente da migracao dos componentes (Tarefa 6.0).

**Nao depende de nenhuma tarefa de backend para ser desenvolvido e testado de forma isolada.** O formato ISO assumido pelas funcoes deve, no entanto, ser validado contra o contrato final definido na Tarefa 4.0 antes da integracao com os componentes (Tarefa 6.0).

<skills>
### Conformidade com Skills Padroes

- `clean-code`: consolida toda logica de data duplicada em um unico modulo com responsabilidade unica.
- `vercel-react-best-practices`: nenhuma mudanca de padrao de data fetching e introduzida por este modulo.
</skills>

<requirements>
- Deve existir um unico ponto de logica (compartilhado) responsavel por formatar datas para exibicao, substituindo as implementacoes duplicadas hoje presentes em multiplos componentes (PRD requisito 7).
- Toda conversao de data recebida da API para exibicao deve produzir o mesmo resultado visual independentemente do timezone do navegador/dispositivo do usuario (PRD requisito 8).
- Toda data/hora enviada da interface para a API deve preservar o valor exatamente como inserido pelo usuario, sem deslocamento por conversao de timezone (PRD requisito 9).
- A comparacao de datas de vencimento de parcela com a data/hora atual deve usar a mesma logica de interpretacao usada na exibicao dessas mesmas datas (PRD requisito 10).
- Datas e horas exibidas devem continuar em formato pt-BR (dd/MM/yyyy, mes abreviado em portugues, hora 24h) — PRD, Experiencia do Usuario.
</requirements>

## Subtarefas

- [x] 5.1 Adicionar dependencia `dayjs` (+ `dayjs/plugin/utc`, `dayjs/plugin/timezone`, `dayjs/plugin/localizedFormat`, `dayjs/locale/pt-br`) ao `package.json`.
- [x] 5.2 Implementar `parseApiInstant(iso: string): Dayjs` — parseia timestamp ISO da API em `America/Sao_Paulo`.
- [x] 5.3 Implementar `formatDateTime(iso: string, fmt?: string): string` — ex: `"23 ago, 10:00"` (pt-BR).
- [x] 5.4 Implementar `formatCalendarDate(dateOnly: string, fmt?: string): string` — trata `"YYYY-MM-DD"` sem conversao de timezone.
- [x] 5.5 Implementar `isPastDueDate(dateOnly: string): boolean` — compara `dueDate` vs "hoje" por string de calendario, sem depender de horario do navegador.
- [x] 5.6 Implementar `toApiInstant(dateStr: string, timeStr: string): string` — monta ISO com offset de `America/Sao_Paulo` para enviar a API.
- [x] 5.7 Garantir que `import 'dayjs/locale/pt-br'` esteja presente (mitigacao do risco descrito na techspec.md de fallback silencioso para ingles).
- [x] 5.8 Escrever testes de unidade (ver secao de Testes).

## Detalhes de Implementacao

Ver bloco de codigo TypeScript em "Interfaces Principais" da `techspec.md` para a assinatura exata de cada funcao, e a secao "Riscos Conhecidos" quanto ao risco do locale `pt-br` nao importado.

## Criterios de Sucesso

- Todas as 5 funcoes da interface (`parseApiInstant`, `formatDateTime`, `formatCalendarDate`, `isPastDueDate`, `toApiInstant`) implementadas e exportadas por `src/utils/date.ts`.
- Nenhum componente ainda foi migrado para usar o modulo (isso ocorre na Tarefa 6.0) — esta tarefa entrega o modulo isolado e testado.
- Saida de `formatDateTime`/`formatCalendarDate` sempre em portugues, mesmo se o navegador do usuario estiver com locale diferente.

## Testes da Tarefa

- [x] Testes de unidade (Vitest): casos de borda para `parseApiInstant`/`formatDateTime` (meia-noite, troca de mes/ano) e `isPastDueDate` (parcela vencendo exatamente "hoje" perto de 00:00 em `America/Sao_Paulo`), conforme "Abordagem de Testes" da techspec.md.
- [x] Teste de unidade especifico: verificar que o texto de saida de `formatDateTime` esta em portugues (mitigacao do risco de locale nao importado).
- [x] Teste de unidade: `toApiInstant` produz string ISO com offset `-03:00` correto para o mesmo instante independentemente do timezone do ambiente de teste.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/utils/date.ts` (novo)
- `package.json` (nova dependencia `dayjs`)
