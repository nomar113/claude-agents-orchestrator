# PRD — Badge de Gastos Antecipados no Navegador de Mês

## Visão Geral

No ControlAI, o usuário navega entre meses pelo seletor de mês da tela de **Orçamento Mensal** (setas `<` / `>` ao redor do rótulo do mês). Por causa de **datas de fechamento diferentes entre cartões**, compras feitas nos últimos dias do mês corrente já podem cair na fatura do **mês seguinte**. Hoje essas despesas ficam "escondidas": o usuário só as percebe se navegar manualmente para o próximo mês.

Esta funcionalidade adiciona um **indicador visual (bolinha vermelha)** na seta de avançar mês (`>`) sempre que existirem lançamentos recentes já alocados na fatura do mês seguinte. O objetivo é dar **visibilidade de gastos antecipados** sem exigir que o usuário descubra o problema por conta própria.

Público: o casal que usa o ControlAI para substituir a planilha de gastos e gerencia múltiplos cartões com fechamentos distintos.

## Objetivos

- **Visibilidade de gastos antecipados**: reduzir a chance de o usuário "esquecer" despesas já lançadas no mês seguinte por diferença de fechamento de cartão.
- **Descoberta sem custo de navegação**: comunicar a existência desses gastos sem que o usuário precise avançar o mês para descobri-los.
- **Sinalização discreta**: indicar "há algo" de forma leve, sem poluir a interface nem competir com o conteúdo principal do orçamento.
- **Métrica de sucesso**: aumento na taxa de navegação para o mês seguinte quando o badge está presente (proxy de que o sinal foi percebido e gerou ação).

## Histórias de Usuário

- **Como** pessoa que controla os gastos do casal, **eu quero** ver um alerta na seta de próximo mês quando já houver compras lançadas na fatura seguinte, **para que** eu não seja surpreendido por despesas que não apareciam no mês corrente.
- **Como** usuário com vários cartões de fechamentos diferentes, **eu quero** que o app me avise quando uma compra recente "pulou" para a fatura do mês que vem, **para que** eu entenda para onde foi aquele gasto.
- **Caso extremo — Como** usuário no mês corrente sem nenhum lançamento recente no mês seguinte, **eu quero** que a seta apareça limpa (sem badge), **para que** o indicador só signifique algo quando de fato houver novidade.

## Funcionalidades Principais

### Indicador de gastos no mês seguinte

Bolinha vermelha exibida sobre a seta de avançar mês (`>`) do seletor de mês, indicando que há lançamentos recentes na fatura do mês imediatamente seguinte ao mês exibido.

**Requisitos funcionais:**

1. O sistema DEVE exibir um indicador visual (bolinha vermelha) sobreposto à seta de avançar mês (`>`) quando existir ao menos um lançamento que satisfaça a regra de gatilho (RF-2).
2. O gatilho do indicador é: existir ao menos um lançamento (`payment_notification`) cuja fatura/competência seja o **mês imediatamente seguinte** ao mês atualmente exibido **E** que tenha sido **criado nos últimos 3 dias**.
3. O indicador DEVE ser apenas uma bolinha (sem número/contagem).
4. O indicador DEVE aparecer **somente na seta direita** (avançar mês). A seta esquerda (mês anterior) nunca exibe o indicador.
5. Quando o usuário avançar para o mês seguinte, o indicador NÃO DEVE permanecer "preso" ao novo mês: a presença do badge é sempre reavaliada em relação ao **mês exibido** e ao seu mês seguinte.
6. Se não houver lançamentos que satisfaçam o gatilho, a seta DEVE ser exibida sem qualquer indicador (estado padrão).
7. A avaliação do gatilho DEVE ocorrer ao carregar/atualizar a tela de Orçamento Mensal e ao mudar o mês exibido.

## Experiência do Usuário

- **Fluxo principal**: usuário abre o Orçamento Mensal no mês corrente → vê a bolinha vermelha na seta `>` → toca para avançar → encontra os gastos antecipados na fatura do mês seguinte.
- **Posicionamento**: o indicador fica no canto superior direito da seta, sem deslocar o layout do seletor de mês.
- **Estilo visual**: bolinha vermelha com anel da cor do fundo para separação e leve brilho (glow), seguindo o protótipo no Paper.
- **Estado padrão**: seta sem qualquer adorno quando o gatilho não é atendido.
- **Acessibilidade**:
  - A seta de avançar mês DEVE expor um rótulo acessível que comunique o estado (ex.: "Próximo mês, há gastos recentes na fatura seguinte") quando o badge estiver presente.
  - O indicador NÃO DEVE depender apenas da cor para transmitir significado quando houver tecnologia assistiva (uso do rótulo acessível como reforço).
  - O contraste do indicador sobre o fundo escuro DEVE permanecer alto e legível.

## Restrições Técnicas de Alto Nível

- A funcionalidade depende dos dados de **`payment_notification`** já existentes, incluindo data de criação do registro e a fatura/competência (mês) à qual pertence.
- A regra de "mês seguinte" depende da lógica de fechamento de cartões já existente no ControlAI (que define em qual fatura uma compra cai).
- A janela de "recente" (3 dias) é uma regra de negócio fixa neste escopo (não configurável pelo usuário).
- O indicador é puramente client-side/visual; não cria novos tipos de notificação nem novas entidades.

## Fora de Escopo

- **Contagem numérica** de lançamentos dentro do badge.
- **Indicador na seta esquerda** (mês anterior) ou em qualquer outro componente além da seta de avançar mês.
- **Configuração da janela "recente"** pelo usuário (fixa em 3 dias).
- **Notificações push / e-mail** sobre gastos antecipados — aqui o escopo é apenas o indicador visual na tela de Orçamento.
- **Mudanças na lógica de fechamento de cartões** ou em como um lançamento é alocado a uma fatura.

## Referência de Design (Paper)

O design desta funcionalidade está prototipado no Paper:

- **Arquivo Paper**: `ControlAI`
- **Artboard base**: `Orçamento Mensal` — seletor de mês com a bolinha vermelha aplicada na seta `>` (componente "Month Selector", nó `15F-0`; seta direita `15L-0`; badge `2C1-0`).
- **Artboard de estados**: `Orçamento — Estados do Badge` (nó `2C2-0`) — documenta lado a lado o **estado padrão** (sem badge) e o **estado com badge**, ambos clonados do componente real.

Especificações visuais detalhadas (cores, tamanho, posicionamento, glow) serão extraídas desses artboards na Tech Spec.
