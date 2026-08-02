# PRD — Novo Estilo de Exibição de Datas do Período de Fatura do Cartão

## Visão Geral

O ControlAI exibe em diversas telas o período de faturamento de cada cartão (data de início e data de fim do ciclo). Atualmente, esse período é mostrado com dois campos independentes empilhados ("De" e "Até") abaixo das informações do cartão, o que consome espaço vertical, fragmenta a leitura e não comunica de forma imediata que se trata de um ciclo de fatura contínuo.

A proposta é substituir esse componente por um banner compacto posicionado acima do card do cartão, exibindo o intervalo de datas de forma linear e contextualizada (ex.: `📅 04/06/2026  até  03/07/2026`). O banner funciona também como ponto de entrada para edição manual do período ao toque. A mudança deve ser aplicada de forma consistente em todas as telas do app que exibem período de fatura de cartão.

## Objetivos

- Reduzir a altura visual do componente de período em pelo menos 30% comparado ao design atual, liberando espaço para outras informações na tela.
- Eliminar inconsistência visual: todas as telas do app devem exibir o período de fatura com o mesmo componente e estilo.
- Tornar o período de fatura imediatamente legível em uma única linha, sem necessidade de varredura vertical.
- Manter a capacidade do usuário de editar o período manualmente quando necessário.

## Histórias de Usuário

- Como **usuário do app**, quero ver o período de faturamento do meu cartão em uma linha compacta e clara, para entender de relance quando começa e termina meu ciclo sem ter de ler dois campos separados.
- Como **usuário do app**, quero tocar na área de datas para editar o período manualmente, para corrigir casos em que o ciclo real do meu cartão difere do padrão calculado.
- Como **usuário que gerencia múltiplos cartões**, quero que o estilo de período seja idêntico em todas as telas (lista, detalhe, orçamento), para ter uma experiência visual coerente ao navegar entre contextos.
- Como **usuário com vários cartões de ciclos diferentes**, quero que cada cartão exiba claramente seu próprio intervalo de datas, para não confundir os ciclos de fatura entre cartões.

## Funcionalidades Principais

### 1. Componente Banner de Período

O período de faturamento deve ser apresentado em um banner horizontal acima do card do cartão.

**Requisitos funcionais:**

1.1. O banner deve exibir, em uma única linha: ícone de calendário + data de início formatada + separador "até" + data de fim formatada.

1.2. As datas devem seguir o formato `DD/MM/YYYY`.

1.3. O banner deve ser visualmente integrado ao card abaixo dele, com bordas arredondadas apenas na parte superior (topo-esquerda e topo-direita), formando uma composição com o card.

1.4. O card do cartão (com badge, nome e valor) deve sobrepor levemente o banner por baixo, criando um efeito de hierarquia visual entre as duas camadas.

1.5. O estilo visual do banner (cor de fundo, tipografia, ícone) deve seguir os tokens do design system do app.

### 2. Interação de Edição de Período

O banner deve permitir que o usuário edite o período quando necessário.

**Requisitos funcionais:**

2.1. Ao tocar no banner de datas, o app deve abrir um seletor de período para o usuário definir nova data de início e data de fim para aquele cartão.

2.2. Após confirmar a edição, o banner deve refletir imediatamente as novas datas sem recarregar a tela.

2.3. A edição de período em uma tela não deve impactar exibições do mesmo cartão em outras telas até que o usuário confirme a alteração.

### 3. Consistência entre Telas

O novo componente deve substituir todos os estilos anteriores de exibição de período de fatura no app.

**Requisitos funcionais:**

3.1. O componente banner de período deve ser aplicado nas seguintes telas: Orçamento Mensal (seção "Período por Pagamento"), Detalhe do Cartão e Lista de Cartões.

3.2. Nenhuma tela do app deve exibir o estilo antigo ("De" / "Até" com campos separados) após a implementação.

3.3. O componente deve se comportar da mesma forma em todas as telas onde aparece (mesmo layout, mesma interação de toque).

## Experiência do Usuário

**Fluxo principal — visualização:**
O usuário acessa qualquer tela com cartões e vê o período de fatura de cada cartão exibido acima do respectivo card, em formato compacto. A leitura do período é feita em uma passada de olho, sem scroll adicional.

**Fluxo de edição:**
O usuário toca no banner de datas → um seletor de período é exibido → o usuário ajusta as datas de início e fim → confirma → o banner é atualizado na tela.

**Considerações de UI/UX:**
- O banner deve ter contraste suficiente para as datas serem legíveis sem esforço, inclusive em ambientes com iluminação variada.
- A área de toque do banner deve ser grande o suficiente para evitar toques acidentais e seguir as diretrizes de tamanho mínimo de touch target (mínimo 44×44pt).
- O ícone de calendário deve ser visualmente consistente com o restante da iconografia do app.
- O separador "até" deve ter peso visual menor que as datas para não competir com a informação principal.

**Acessibilidade:**
- O banner deve ter label acessível descrevendo o período completo (ex.: "Período de faturamento: 04 de junho a 03 de julho de 2026").
- O toque para edição deve ser acessível por teclado/switch control.

## Restrições Técnicas de Alto Nível

- O período de fatura de cada cartão já é um dado existente no sistema; a mudança é exclusivamente de apresentação — nenhum novo campo de dado é necessário.
- O componente deve funcionar nos sistemas operacionais iOS e Android suportados atualmente pelo app (Capacitor/Ionic).
- A edição do período deve persistir localmente e/ou sincronizar com o backend conforme o fluxo já estabelecido para edição de cartões.

## Fora de Escopo

- Criação de um novo fluxo de configuração de ciclo de fatura (o período já existe no cadastro do cartão).
- Cálculo automático do próximo período (lógica de recorrência do ciclo) — esse comportamento permanece inalterado.
- Redesign das demais informações do card do cartão (badge, nome, valor).
- Alterações no backend para armazenamento de datas — apenas a camada de apresentação é afetada.
- Suporte a múltiplos formatos de data regionais nesta versão.
