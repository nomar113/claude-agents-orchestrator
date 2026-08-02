# PRD — Cancelamento de Compra

## Visao Geral

O ControlAI permite registrar compras via notificacoes de cartao (SMS) e notas fiscais (NF-e). Atualmente, quando uma compra e criada por engano, duplicada ou cancelada pelo lojista, a unica opcao disponivel e **excluir permanentemente** o registro, perdendo todo o historico.

Esta funcionalidade introduz o conceito de **cancelamento de compra** — um status que marca a compra como cancelada sem remove-la do sistema. Compras canceladas permanecem visiveis na listagem com distincao visual clara, e seus valores **nao sao contabilizados** nos totais de gastos do mes.

O cancelamento e uma acao **definitiva**: uma vez cancelada, a compra nao pode ser reativada. Caso o usuario tenha cancelado por engano, a unica opcao e excluir e recriar a compra.

## Objetivos

1. **Preservar historico**: Manter o registro de compras canceladas para referencia futura, em vez de perde-las com exclusao permanente.
2. **Refletir a realidade**: Representar no app situacoes reais como estornos, cancelamentos de pedido e compras duplicadas.
3. **Precisao financeira**: Garantir que valores de compras canceladas nao distorcam os totais de gastos mensais e o orcamento.
4. **Clareza visual**: Tornar imediatamente obvio na listagem quais compras foram canceladas, sem poluir a experiencia.

## Historias de Usuario

- **HU-1**: Como usuario, quero cancelar uma compra pela tela de detalhe para que ela nao conte mais nos meus gastos, mas eu mantenha o registro.
- **HU-2**: Como usuario, quero cancelar uma compra com swipe na lista para agir rapidamente sem abrir o detalhe.
- **HU-3**: Como usuario, quero cancelar uma compra com long press na lista para ter uma opcao de menu de contexto.
- **HU-4**: Como usuario, quero ver claramente na listagem quais compras foram canceladas para distingui-las das compras ativas.
- **HU-5**: Como usuario, quero ver os detalhes de uma compra cancelada com indicacao clara do status para entender que aquele valor nao esta sendo contabilizado.
- **HU-6**: Como usuario, quero que o total de gastos do mes exclua compras canceladas para que meu orcamento reflita a realidade.

## Funcionalidades Principais

### F1. Cancelar Compra

A funcionalidade de cancelar uma compra marca o registro com status "cancelada" sem remove-lo do sistema.

**Requisitos funcionais:**

- **RF-01**: O sistema deve permitir cancelar uma compra a partir da tela de detalhe via botao "Cancelar compra".
- **RF-02**: O sistema deve permitir cancelar uma compra via swipe na lista de compras.
- **RF-03**: O sistema deve permitir cancelar uma compra via long press na lista de compras (menu de contexto).
- **RF-04**: Antes de efetivar o cancelamento, o sistema deve exibir um dialog de confirmacao com a mensagem: "Cancelar esta compra? A compra sera marcada como cancelada e o valor nao sera contabilizado nos seus gastos."
- **RF-05**: O dialog de confirmacao deve oferecer as opcoes "Voltar" (cancela a acao) e "Cancelar" (confirma o cancelamento).
- **RF-06**: O cancelamento e uma acao definitiva — compras canceladas nao podem ser reativadas.
- **RF-07**: Compras de qualquer tipo (notificacao ou nota fiscal) podem ser canceladas.

### F2. Visualizacao na Lista

Compras canceladas devem ser visualmente distintas das compras ativas na listagem.

**Requisitos funcionais:**

- **RF-08**: Compras canceladas devem ser exibidas com opacidade reduzida (55%) em relacao as compras ativas.
- **RF-09**: O icone de categoria deve ser substituido por um icone neutro (circulo com linha diagonal) em tom cinza.
- **RF-10**: Um badge "CANCELADA" em cor amber deve ser exibido ao lado do nome do estabelecimento.
- **RF-11**: O valor da compra deve ser exibido com line-through (tachado).
- **RF-12**: Compras canceladas devem manter sua posicao cronologica na lista (nao devem ser movidas para o final).

### F3. Visualizacao no Detalhe

A tela de detalhe de uma compra cancelada deve comunicar claramente o status.

**Requisitos funcionais:**

- **RF-13**: Um banner amber com icone e texto "Esta compra foi cancelada" deve ser exibido abaixo do header.
- **RF-14**: O valor principal deve ser exibido com line-through e opacidade reduzida.
- **RF-15**: O icone principal deve ser substituido pelo icone neutro (circulo com linha diagonal).
- **RF-16**: A secao de informacoes deve incluir um campo "Status" exibindo "Cancelada" com indicador amber.
- **RF-17**: O botao "Cancelar compra" nao deve ser exibido para compras ja canceladas.
- **RF-18**: O botao "Excluir registro" deve continuar disponivel para compras canceladas (permite remocao permanente).

### F4. Impacto nos Calculos

Compras canceladas nao devem afetar os totais financeiros.

**Requisitos funcionais:**

- **RF-19**: O total de gastos do mes nao deve incluir valores de compras canceladas.
- **RF-20**: O calculo de orcamento utilizado nao deve contabilizar compras canceladas.
- **RF-21**: Os totais por cartao nao devem incluir compras canceladas.
- **RF-22**: Os totais por categoria nao devem incluir compras canceladas.

## Experiencia do Usuario

### Personas

- **Usuario primario**: Ramon e esposa — casal que gerencia gastos pessoais e compartilhados via app mobile (iOS).

### Fluxos principais

1. **Cancelar pelo detalhe**: Lista > Toca na compra > Detalhe > Botao "Cancelar compra" > Dialog de confirmacao > Confirma > Compra atualizada com status cancelada.
2. **Cancelar por swipe**: Lista > Swipe para esquerda > Opcao "Cancelar" > Dialog de confirmacao > Confirma.
3. **Cancelar por long press**: Lista > Long press no item > Menu de contexto > "Cancelar compra" > Dialog de confirmacao > Confirma.

### Diretrizes de UI/UX

- **Referencia visual**: Artboards criados no Paper (arquivo "ControlAI"): "Cancelamento — Lista", "Cancelamento — Detalhe", "Cancelamento — Acao + Confirmacao".
- **Cor do status**: Amber (#F59E0B) para diferenciar de exclusao (vermelho) e estados ativos.
- **Hierarquia de acoes**: "Cancelar compra" (amber, acao moderada) aparece acima de "Excluir registro" (vermelho, acao destrutiva).
- **Feedback imediato**: Apos confirmar o cancelamento, a lista deve refletir o novo status instantaneamente.

### Acessibilidade

- O badge "CANCELADA" deve ser acessivel via screen reader.
- O dialog de confirmacao deve ser navegavel por teclado/VoiceOver.
- O contraste do texto amber sobre fundo escuro deve atender WCAG AA.

## Restricoes Tecnicas de Alto Nivel

- As tabelas `payment_notifications` e `purchase_invoices` atualmente nao possuem campo de status — usam apenas `deleted_at` para soft delete. Sera necessario um novo campo para representar o cancelamento.
- A query unificada de listagem (`UNION` entre as duas tabelas) precisara considerar o novo status.
- Os calculos de totais (gastos do mes, orcamento, totais por cartao/categoria) precisam filtrar compras canceladas.

## Fora de Escopo

- **Cancelamento de parcelas**: Compras parceladas nao terao tratamento especial de cancelamento neste MVP. O cancelamento se aplica apenas a compras simples (sem parcelas) ou ao registro principal.
- **Reativacao de compra cancelada**: O cancelamento e definitivo. Nao havera funcionalidade de "desfazer cancelamento".
- **Cancelamento em lote**: Nao sera possivel cancelar multiplas compras de uma vez.
- **Notificacoes de cancelamento**: O sistema nao enviara notificacoes quando uma compra for cancelada.
- **Integracao com banco/operadora**: O cancelamento e apenas no app — nao se comunica com instituicoes financeiras.
- **Filtro por status**: Filtrar a lista por "canceladas" / "ativas" sera tratado em uma iteracao futura.
