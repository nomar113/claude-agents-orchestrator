# Tarefa 5.0: Frontend — Integracao em `PurchaseDetail` (linha tocavel, sheet, callback, erro)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar o fluxo de edicao na pagina `PurchaseDetail`: tornar a linha "Cartao" tocavel nas condicoes corretas, abrir o `PaymentMethodSelector` em modo `edit`, chamar `updatePaymentNotificationCard` e atualizar a UI sem reload. Tratar erro de rede preservando o estado anterior e oferecendo retry.

<skills>
### Conformidade com Skills Padroes

- **ionic-design** — uso correto de `useIonViewWillEnter`, `IonSpinner`/`IonLoading` para o estado de submissao.
- **frontend-design** / **ui-ux-pro-max** — feedback visual (loading, sucesso, erro) consistente com o padrao do app.
- **clean-code** — handler unico claro, sem mistura de logica de UI e transport.
- **vercel-react-best-practices** — minimizar re-renders, sem efeitos colaterais desnecessarios.
</skills>

<requirements>
- Linha "Cartao" tocavel **apenas** quando `type === 'notification'` E `!cancelledAt`. Em outros casos, permanece visivel e nao tocavel, sem icone de edicao.
- Quando tocavel, exibir icone de lapis alinhado a direita (mesmo padrao da linha "Categoria").
- Toque abre o `PaymentMethodSelector` em modo `edit` com `currentPaymentMethodId` e `currentSubCardId` da notificacao.
- Apos confirmacao do sheet, chamar `updatePaymentNotificationCard(id, paymentMethodId, subCardId)`.
- Atualizar estado local (`brand badge`, `nome do cartao`, `ultimos digitos`) com o response do servico, **sem** pull-to-refresh.
- Exibir loading visivel durante a operacao.
- Em caso de erro:
  - manter o estado anterior (cartao nao muda)
  - exibir mensagem clara de erro (toast/alert consistente com o app)
  - oferecer opcao de tentar novamente sem reabrir o sheet do zero (manter selecao do usuario quando viavel)
- Tipo `invoice` nao recebe a affordance (RF4 do PRD).
- Idempotencia: confirmar o mesmo cartao nao deve gerar feedback de erro nem registros duplicados.
</requirements>

## Subtarefas

- [x] 5.1 Criar estado `isCardSheetOpen` e handler `handleEditCard` em `PurchaseDetail.tsx`.
- [x] 5.2 Tornar a linha "Cartao" tocavel apenas nas condicoes corretas, exibindo o icone de lapis.
- [x] 5.3 Renderizar `PaymentMethodSelector` em modo `edit` passando os ids atuais da notificacao.
- [x] 5.4 No callback de `onSelect`, chamar `updatePaymentNotificationCard`, gerenciar loading e atualizar o estado local com o response.
- [x] 5.5 Tratar erro com mensagem clara e opcao de retry, preservando o estado anterior.
- [x] 5.6 Escrever testes em `PurchaseDetail.test.tsx`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Fluxo de Dados" e "Riscos Conhecidos" (cache em outras paginas; este sera tratado na Tarefa 6.0). Ver `prd.md` F1, F4 e F5 para regras de affordance, persistencia e visibilidade.

## Criterios de Sucesso

- Linha tocavel **somente** em `notification` && `!cancelledAt`.
- Atualizacao reflete imediatamente no Detalhe sem pull-to-refresh.
- Erro de rede mantem estado anterior e exibe mensagem.
- Idempotencia visivel para o usuario (re-confirmar mesmo cartao volta ao Detalhe sem erro).

## Testes da Tarefa

- [ ] Testes de unidade — `PurchaseDetail.test.tsx`:
  - linha Cartao **e** tocavel quando `type === 'notification'` && `!cancelledAt`
  - linha Cartao **nao e** tocavel quando `cancelledAt != null`
  - linha Cartao **nao e** tocavel quando `type === 'invoice'`
  - tocar abre o sheet (`isCardSheetOpen === true`)
  - confirmar sheet chama `updatePaymentNotificationCard` com os ids corretos
  - sucesso atualiza display (brand badge, nome do cartao, ultimos digitos)
  - erro de rede mantem estado anterior e exibe mensagem
  - idempotencia: re-confirmar mesmo cartao nao gera mensagem de erro nem duplica chamadas alem da prevista
- [ ] Testes de integracao — montagem da pagina com `PaymentMethodSelector` real (sem mockar o componente filho) validando o fluxo completo.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/PurchaseDetail.tsx` (modificar)
- `src/pages/PurchaseDetail.css` (possivel ajuste no estilo da linha Cartao)
- `src/pages/PurchaseDetail.test.tsx` (modificar)
- `src/services/purchaseService.ts` (dependencia — funcao da Tarefa 3.0)
- `src/components/PaymentMethodSelector.tsx` (dependencia — componente da Tarefa 4.0)
