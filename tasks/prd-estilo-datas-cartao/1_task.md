# Tarefa 1.0: Criar componente `CardPeriodBanner`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar o componente puro `CardPeriodBanner` que exibe o período de faturamento de um cartão em uma única linha compacta no formato `📅 DD/MM/YYYY  até  DD/MM/YYYY`. Este componente não possui estado interno — apenas recebe as datas e um callback de toque.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — seguir padrões de componentes Ionic; o banner usa classes CSS do design system do app
- `executar-task` — executar typecheck (`tsc --noEmit`), testes (`vitest run`) e lint (`eslint`) antes de marcar concluída
</skills>

<requirements>
- Exibir ícone de calendário + data início formatada + separador "até" + data fim formatada em uma linha
- Datas recebidas em ISO (`YYYY-MM-DD`) e exibidas em `DD/MM/YYYY`
- `aria-label` descrevendo o período completo por extenso (ex.: "Período de faturamento: 04 de junho a 03 de julho de 2026")
- Área de toque mínima de 44×44pt (min-height no CSS)
- Separador "até" com `opacity: 0.5` (peso visual menor)
- Border-radius apenas no topo (16px 16px 0 0) para composição com o card abaixo
- Callback `onTap` acionado ao clicar/tocar no banner
</requirements>

## Subtarefas

- [ ] 1.1 Criar `src/components/CardPeriodBanner.tsx` com as props `startDate`, `endDate` e `onTap`
- [ ] 1.2 Criar função utilitária de formatação ISO → DD/MM/YYYY (ou reusar a existente em `BudgetPeriodCard.tsx`)
- [ ] 1.3 Criar classes CSS do banner (`.period-banner-wrapper`, `.period-date-banner`, `.period-date-banner-icon`, `.period-date-banner-text`, `.period-date-banner-sep`) em `BudgetPage.css` ou arquivo CSS dedicado
- [ ] 1.4 Criar `src/components/CardPeriodBanner.test.tsx` com os casos de teste listados abaixo

## Detalhes de Implementacao

Ver `techspec.md` — seções:
- **Interfaces Principais** → `CardPeriodBannerProps`
- **Layout CSS — Efeito de Sobreposição** → classes e valores exatos
- **Considerações Técnicas** → decisão sobre `IonDatetime` e CSS overlap

## Criterios de Sucesso

- Componente renderiza as datas corretamente no formato DD/MM/YYYY a partir de strings ISO
- Ícone de calendário visível
- `aria-label` contém a descrição completa do período
- Clique/toque no banner dispara o callback `onTap`
- Todos os testes passam (`vitest run`)
- Sem erros de TypeScript (`tsc --noEmit`)
- Lint sem warnings (`eslint`)

## Testes da Tarefa

- [ ] Testes de unidade (`CardPeriodBanner.test.tsx`):
  - Renderiza as datas no formato DD/MM/YYYY a partir de ISO
  - Exibe o ícone de calendário
  - Chama `onTap` ao clicar
  - `aria-label` contém a descrição completa do período
- [ ] Testes de integração: N/A (componente puro sem dependências de serviço)
- [ ] Testes E2E: N/A nesta task

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/CardPeriodBanner.tsx` ← CRIAR
- `src/components/CardPeriodBanner.test.tsx` ← CRIAR
- `src/pages/BudgetPage.css` ← MODIFICAR (adicionar classes de banner)
- `src/components/BudgetPeriodCard.tsx` ← REFERÊNCIA (funções de formatação de data existentes)
- `tasks/prd-estilo-datas-cartao/techspec.md` ← LEITURA OBRIGATÓRIA
