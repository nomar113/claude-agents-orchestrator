# PRD — Sugestão de Nota Fiscal a partir da Notificação de Pagamento

## Visão Geral

Hoje o app ControlAI já permite associar uma Nota Fiscal a uma compra quando o usuário está dentro do detalhe da NF. Esta funcionalidade implementa o fluxo **inverso**: a partir do detalhe de uma `payment_notification`, o app exibe automaticamente sugestões de `purchase_invoice` compatíveis, permitindo que o usuário confirme ou descarte a associação sem sair da tela.

O problema central é que o usuário recebe uma notificação de cobrança no cartão e, se quiser vincular a NF correspondente, precisa hoje navegar para a aba de Notas Fiscais, encontrar a NF correta e executar o vínculo de lá. O novo fluxo elimina esse desvio: a sugestão aparece contextualmente dentro da mesma notificação, no momento em que o usuário já está revisando a compra.

---

## Objetivos

- Reduzir o esforço necessário para vincular uma NF a uma compra, trazendo a ação para o contexto onde o usuário já está.
- Aumentar a taxa de notas fiscais associadas a pagamentos no app.
- Não introduzir ruído: quando não houver sugestão relevante, a tela de detalhe permanece inalterada.

---

## Histórias de Usuário

- Como **usuário que recebeu uma notificação de débito no cartão**, quero ver se existe uma nota fiscal correspondente sem precisar sair da tela, para que eu possa confirmar ou vincular rapidamente.
- Como **usuário que já associou uma NF a uma notificação**, quero ver um resumo da NF vinculada dentro do detalhe da notificação, para que eu tenha contexto completo da compra em um só lugar.
- Como **usuário que quer rejeitar uma sugestão incorreta**, quero ignorar a NF sugerida para que ela não me atrapalhe, com a possibilidade de a sugestão reaparecer caso eu reabra a tela.

---

## Funcionalidades Principais

### 1. Seção de Sugestão de NF no Detalhe da Notificação

Quando a `payment_notification` ainda não possui uma `purchase_invoice` associada e o sistema identifica uma ou mais NFs candidatas, uma seção **"Nota Fiscal Sugerida"** é exibida no final da tela de detalhe.

**Requisitos funcionais:**

- **RF-01** — A seção aparece somente quando existem NFs candidatas para a notificação em questão.
- **RF-02** — As NFs candidatas são exibidas em lista, ordenadas por relevância (melhor correspondência primeiro).
- **RF-03** — Cada item da lista exibe: razão social, CNPJ, quantidade de itens e total da NF.
- **RF-04** — Cada item possui botão **"Associar"** e botão **"Ignorar"**.
- **RF-05** — Ao tocar em **"Associar"**, a tela atualiza in-place: a seção de sugestão é substituída pela seção **"Nota Fiscal Associada"** (estado verde), sem navegação.
- **RF-06** — Ao tocar em **"Ignorar"**, a sugestão é removida da tela na sessão atual. Reabre a tela: a sugestão pode reaparecer (dispensa temporária, não permanente).
- **RF-07** — Quando não há NFs candidatas, a seção não é renderizada e a tela de detalhe permanece como hoje.

### 2. Seção de NF Associada no Detalhe da Notificação

Quando a `payment_notification` já possui uma `purchase_invoice` vinculada, uma seção **"Nota Fiscal Associada"** é exibida no final da tela de detalhe.

**Requisitos funcionais:**

- **RF-08** — A seção exibe: razão social, CNPJ, badge de confirmação "Associada", quantidade de itens, data de emissão e total da NF.
- **RF-09** — Um link **"Ver detalhes da nota fiscal"** navega para a tela de detalhe completo da `purchase_invoice`.
- **RF-10** — O estado "Associada" é refletido imediatamente após o RF-05 (associação in-place), sem necessidade de recarregar a tela.

---

## Experiência do Usuário

**Fluxo principal (sugestão disponível):**
1. Usuário abre o detalhe de uma `payment_notification`.
2. Rola a tela para baixo — após a seção de Parcelas, vê a seção "Nota Fiscal Sugerida" com uma ou mais NFs listadas.
3. Toca em "Associar" na NF correta → seção vira "Nota Fiscal Associada" com confirmação visual (verde).

**Fluxo alternativo (ignorar sugestão):**
1. Usuário abre o detalhe — vê a sugestão.
2. Toca em "Ignorar" → sugestão desaparece para a sessão atual.
3. Ao reabrir a tela, a sugestão pode voltar a aparecer.

**Fluxo pós-associação (revisitar):**
1. Usuário reabre uma notificação já associada.
2. Vê diretamente a seção "Nota Fiscal Associada" — razão social, data de emissão, total e link para a NF completa.

**Referências de design (Paper — arquivo ControlAI):**
- Tela com sugestão: artboard **"Detalhe — Notificação / Sugestão de NF"**
- Tela pós-associação: artboard **"Detalhe — Notificação / NF Associada"**

**Considerações de UX:**
- A seção de NF (sugerida ou associada) é sempre o último bloco da tela, após Parcelas.
- Estados: sugestão usa borda âmbar sutil; associada usa borda e label verde.
- Quando há múltiplas sugestões, elas são listadas uma abaixo da outra dentro da seção.
- A ação de "Associar" deve ter feedback visual imediato (transição in-place) para não gerar dúvida se o toque foi registrado.

---

## Restrições Técnicas de Alto Nível

- O matching entre `payment_notification` e `purchase_invoice` é feito pelo backend — o app consome a lista de candidatos já rankeados via API existente ou nova.
- A associação deve ser persistida no servidor; o estado local só é atualizado após confirmação da API.
- A dispensa temporária ("Ignorar") não requer persistência no servidor — pode ser gerenciada em memória local ou cache de sessão.
- Dados fiscais (CNPJ, chave de acesso) são sensíveis e devem ser trafegados apenas via HTTPS.

---

## Fora de Escopo

- **Busca manual de NF**: o usuário não pode pesquisar uma NF pelo nome ou CNPJ nesta versão. Fluxo planejado para iteração futura.
- **Desassociação**: desfazer uma associação já confirmada não faz parte deste escopo.
- **Associação múltipla**: uma notificação vinculada a mais de uma NF não é contemplada.
- **Notificações sem NF candidata**: nenhum estado de "busque manualmente" é exibido; a seção simplesmente não aparece.
- **Push notification de sugestão**: notificar o usuário fora do app quando uma NF for encontrada está fora do escopo.
