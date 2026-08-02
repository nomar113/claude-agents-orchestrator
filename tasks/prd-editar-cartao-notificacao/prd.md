# PRD — Edicao de Cartao em Notificacao de Pagamento

## Visao Geral

Hoje o ControlAI cria notificacoes de pagamento a partir de SMS/push do banco. Em muitos casos a heuristica de associacao identifica o cartao errado (ou nao identifica nenhum), por exemplo quando o titular usa um sub-cartao virtual, quando o SMS nao traz os ultimos digitos, ou quando o casal compartilha varios cartoes. Hoje o usuario nao tem como corrigir isso pela interface — a unica saida e excluir a notificacao e recadastrar manualmente, perdendo associacao com nota fiscal, parcelas e categoria.

Esta funcionalidade permite ao usuario editar, direto na tela de Detalhe da Notificacao, qual cartao (e qual sub-cartao) foi utilizado na compra. A mudanca se reflete imediatamente nos relatorios por cartao, no orcamento e nas parcelas associadas, mantendo o resto do registro intacto.

## Objetivos

- **Reduzir o atrito de correcao**: dar ao usuario um caminho direto para corrigir o cartao sem precisar excluir e recriar a compra.
- **Aumentar a precisao do gasto por cartao**: garantir que cada notificacao acabe atribuida ao cartao real, melhorando dashboards e orcamento por cartao.
- **Metrica primaria (sucesso)**: **Taxa de uso** — % de notificacoes que tiveram o cartao editado pelo usuario nos primeiros 7 dias apos o lancamento. Meta inicial: >= 10% das notificacoes recebidas no periodo.
- **Metricas secundarias de saude**:
  - Tempo mediano para concluir a edicao: <= 10s a partir do toque no campo Cartao.
  - Taxa de sucesso da operacao (sem erro): >= 99%.

## Historias de Usuario

- **Como** usuario com varios cartoes cadastrados, **eu quero** tocar no campo Cartao na tela de Detalhe da Notificacao **para que** eu possa trocar o cartao usado naquela compra sem ter que excluir o registro.
- **Como** usuario do mesmo cartao com sub-cartoes (fisico, virtual, wallet), **eu quero** que o app sempre me pergunte qual sub-cartao foi usado quando eu mudo o cartao **para que** o registro fique completo e os relatorios por sub-cartao estejam corretos.
- **Como** usuario com uma compra parcelada, **eu quero** que a troca de cartao atualize todas as parcelas (pagas e futuras) **para que** o historico reflita o cartao realmente utilizado na compra original.
- **Como** usuario, **eu quero** ver imediatamente o novo cartao na tela apos confirmar, **e que** a mudanca se reflita nas listas de compras e nos relatorios por cartao do mes.
- **Como** usuario, **eu quero** poder cancelar/fechar o fluxo de edicao a qualquer momento **sem** alterar o cartao original.
- **Como** usuario, **eu quero** ser impedido de editar o cartao em uma compra ja cancelada **para que** registros canceladados permanecam intocados.

## Funcionalidades Principais

### F1 — Affordance de edicao no Detalhe da Notificacao
A linha "Cartao" da secao "Informacoes" passa a ser tocavel e exibe um icone de lapis, igual ao padrao ja existente da linha "Categoria".

- **RF1**: A linha Cartao deve ser tocavel quando o tipo do registro for `notification` e a notificacao **nao estiver cancelada**.
- **RF2**: A linha exibe brand badge (quando houver), nome do cartao, ultimos 4 digitos do sub-cartao (quando houver) ou da notificacao, e um icone de edicao alinhado a direita.
- **RF3**: Em notificacoes canceladas, a linha permanece visivel mas **nao tocavel** e sem o icone de edicao.
- **RF4**: A funcionalidade nao se aplica ao tipo `invoice` (nota fiscal).

### F2 — Bottom sheet de selecao de cartao
Ao tocar na linha, abre um bottom sheet que lista os cartoes cadastrados.

- **RF5**: O sheet exibe um callout no topo destacando o "Cartao atual" (cartao + sub-cartao quando houver).
- **RF6**: Os cartoes sao listados agrupados por titular (Holder), seguindo a mesma logica do `PaymentMethodSelector` existente.
- **RF7**: Cada item do cartao deve mostrar: icone, nome do cartao, brand/tipo, ultimos 4 digitos e numero de sub-cartoes quando existirem.
- **RF8**: O cartao atualmente associado a notificacao deve aparecer com indicador visual de "selecionado" (check + borda destacada).
- **RF9**: O sheet deve oferecer um link/botao "Adicionar novo cartao" que leva ao fluxo existente de cadastro de cartao.
- **RF10**: Toque fora do sheet, no botao de fechar (X) ou no botao back nativo deve fechar sem alterar o cartao original.

### F3 — Selecao obrigatoria de sub-cartao
Quando o usuario seleciona um cartao no sheet, o fluxo de sub-cartao **sempre e solicitado** se o cartao escolhido tiver sub-cartoes cadastrados.

- **RF11**: Apos selecionar um cartao com 1 ou mais sub-cartoes, o sheet **deve** navegar para a tela "Qual sub-cartao?".
- **RF12**: A tela de sub-cartao exibe link de voltar para a lista de cartoes, titulo "Qual sub-cartao?" e a lista de sub-cartoes do cartao escolhido com tipo (FISICO, VIRTUAL, VIRTUAL TEMPORARIO, DIGITAL WALLET).
- **RF13**: Se o sub-cartao anterior pertencer ao mesmo cartao recem-selecionado, ele deve vir pre-marcado; caso contrario nenhum sub-cartao vem marcado por padrao.
- **RF14**: O usuario pode usar a opcao "Continuar sem sub-cartao" para confirmar a troca sem associar sub-cartao.
- **RF15**: Se o cartao selecionado **nao** tiver sub-cartoes, a troca e confirmada imediatamente, sem passar pela tela de sub-cartao.

### F4 — Confirmacao e persistencia
Apos a confirmacao do usuario, a edicao e persistida.

- **RF16**: A operacao atualiza, na notificacao: `paymentMethodId`, `subCardId` (pode ser null) e a representacao dos ultimos 4 digitos exibida.
- **RF17**: Se a notificacao for parcelada (numberOfInstallments > 1), **todas** as parcelas associadas (pagas, pendentes e canceladas) devem ser atualizadas para refletir o novo cartao.
- **RF18**: O orcamento por cartao do mes da compra deve refletir a mudanca imediatamente.
- **RF19**: Em caso de sucesso, a tela de Detalhe deve atualizar visualmente o brand badge, o nome do cartao e os ultimos digitos sem precisar de pull-to-refresh.
- **RF20**: Em caso de falha de rede ou erro do servidor, o app deve manter o estado anterior, exibir um feedback claro de erro e oferecer a opcao de tentar novamente.
- **RF21**: A operacao deve ser idempotente: confirmar repetidamente o mesmo cartao nao gera registros duplicados nem alteracoes adicionais.

### F5 — Visibilidade no historico e relatorios
A troca deve refletir no resto do app sem necessidade de acao manual.

- **RF22**: A proxima vez que a lista de compras (Tab1) for aberta ou recarregada (ou via pull-to-refresh, quando disponivel), os itens devem mostrar o novo cartao.
- **RF23**: O relatorio mensal por cartao e o orcamento mensal por cartao do mes da compra devem recalcular automaticamente o total atribuido a cada cartao.

## Experiencia do Usuario

A experiencia foi prototipada no arquivo Paper ControlAI nos artboards:

- **Detalhe — Editar Cartao (Affordance)**: tela de Detalhe com a nova affordance de edicao na linha Cartao.
- **Editar Cartao — Bottom Sheet**: sheet de selecao de cartao com callout do cartao atual e agrupamento por titular.
- **Editar Cartao — Sub-cartoes**: segunda etapa para selecao do sub-cartao, com link de voltar e opcao de continuar sem sub-cartao.

Diretrizes de UX:

- Visual consistente com o sistema dark "nocturnal" ja consolidado (fundo navy, accent rosa #FF4D6D, fonte IBM Plex Sans).
- Manter padrao do `CategoryBottomSheet` para abrir/fechar (drag handle, overlay escuro, animacao slide-up).
- Reutilizar o componente `PaymentMethodSelector` existente como base, ajustando para o caso de edicao (inclui o callout de "Cartao atual" e indicador de selecionado).
- Acessibilidade: todos os toques alvo devem ter no minimo 44x44 px, contraste de texto AA (>= 4.5:1), suporte a VoiceOver/TalkBack com labels claros ("Editar cartao", "Selecionar cartao", "Selecionar sub-cartao") e suporte ao botao back nativo do Android/iOS.
- Feedback de loading visivel enquanto a operacao esta em andamento; sucesso retorna ao Detalhe atualizado, falha mantem o sheet aberto com mensagem de erro.

## Restricoes Tecnicas de Alto Nivel

- Plataforma alvo: app mobile React + Ionic + Capacitor existente; chamadas a API devem usar a estrategia dual `CapacitorHttp` (nativo) / `fetch` (web) ja aplicada no projeto.
- Backend base URL: `https://api.opencod3.com.br` (mesma do projeto).
- A operacao deve ser executada em uma unica transacao no backend, cobrindo notificacao + parcelas associadas.
- Nao deve haver mudanca no schema dos cartoes (`PaymentMethod`, `SubCard`, `Holder`).
- Disponibilidade da funcionalidade nao depende de novas permissoes nativas (sem camera, sem notificacao, etc).
- Operacao deve concluir em ate 2s na rede 4G tipica brasileira.
- Conformidade LGPD: nenhum dado sensivel novo e coletado; apenas vinculacoes entre registros existentes mudam.

## Fora de Escopo

- **Edicao de cartao em compras tipo `invoice` (nota fiscal)**: nao incluida nesta entrega.
- **Edicao de cartao em compras canceladas**: explicitamente bloqueada.
- **Edicao em massa**: nao ha selecao multipla para trocar cartao de varios registros de uma vez.
- **Swipe action na lista de compras**: nao incluida; a edicao acontece apenas no Detalhe.
- **Criacao de cartao no meio do fluxo de edicao**: o botao "Adicionar novo cartao" reaproveita o fluxo existente, sem novo onboarding embutido.
- **Edicao do titular (Holder), brand ou bandeira**: edita-se apenas a vinculacao entre notificacao e cartao/sub-cartao, nao os dados do cartao em si.
- **Historico de alteracoes**: nao sera exibida uma timeline de quem trocou o cartao quando.
- **Notificacoes ao parceiro/co-titular**: nenhuma notificacao push e disparada quando o cartao e editado.

(Nota: riscos de implementacao tecnica, modelagem da rota, contrato da API e estrategia de invalidacao de cache serao detalhados na Tech Spec.)
