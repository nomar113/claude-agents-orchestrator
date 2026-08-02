# Tarefa 4.0: Frontend — `PaymentMethodSelector` em modo `edit` com pre-selecao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Estender o componente `PaymentMethodSelector` para suportar um modo de edicao com callout do "Cartao atual", indicador visual de selecionado, pre-marcacao do sub-cartao atual e novo contrato de callback `onSelect(paymentMethodId, subCardId | null)`. Atualizar todos os chamadores existentes (modo `create`) para o novo contrato e manter o comportamento atual intacto.

<skills>
### Conformidade com Skills Padroes

- **ionic-design** — bottom sheet com drag handle, dim overlay, slide-up, fechamento por tap fora, back nativo.
- **frontend-design** / **ui-ux-pro-max** — callout, indicador "selecionado" (check + borda) e agrupamento por holder com consistencia visual do sistema "nocturnal" (navy + #FF4D6D + IBM Plex Sans).
- **clean-code** — props bem nomeadas, sem ifs aninhados; extrair `EditCardSheet` se a logica condicional crescer demais (decisao na implementacao).
- **vercel-react-best-practices** — usar `useMemo`/`useCallback` somente quando necessario; nao re-renderizar a arvore inteira no callout.
</skills>

<requirements>
- Adicionar props: `mode?: 'create' | 'edit'` (default `create`), `currentPaymentMethodId?: number | null`, `currentSubCardId?: number | null`.
- Modo `edit`: exibir callout no topo destacando o "Cartao atual" (cartao + sub-cartao quando houver).
- Modo `edit`: cartao atual aparece com indicador "selecionado" (check + borda destacada).
- Quando o usuario escolhe um cartao com >=1 sub-cards, navegar para a tela "Qual sub-cartao?".
- Se o `currentSubCardId` pertencer ao cartao escolhido, pre-marcar esse sub-card; caso contrario, nenhum sub-card vem pre-marcado.
- Opcao "Continuar sem sub-cartao" deve confirmar com `subCardId = null`.
- Cartoes sem sub-cards confirmam diretamente sem passar pela tela de sub-cartao.
- Botao/link "Adicionar novo cartao" leva ao fluxo existente de cadastro.
- Mudar o contrato de `onSelect` para sempre receber `(paymentMethodId: number, subCardId: number | null)`.
- Atualizar **todos os chamadores existentes** (modo `create`) para o novo contrato sem regressao.
- Fechamento por overlay tap, botao X e botao back nativo NAO altera o cartao original.
- Manter agrupamento por holder usando a mesma logica existente.
- Acessibilidade: labels VoiceOver/TalkBack ("Selecionar cartao", "Selecionar sub-cartao"), alvos >= 44x44 px, contraste AA.
</requirements>

## Subtarefas

- [x] 4.1 Estender `PaymentMethodSelectorProps` e os tipos correlatos para o novo contrato.
- [x] 4.2 Implementar callout "Cartao atual" condicionado a `mode === 'edit'`.
- [x] 4.3 Implementar indicador de selecionado (check + borda) no item correspondente ao `currentPaymentMethodId`.
- [x] 4.4 Implementar pre-marcacao do sub-cartao na 2a tela quando `currentSubCardId` pertencer ao cartao escolhido.
- [x] 4.5 Implementar opcao "Continuar sem sub-cartao".
- [x] 4.6 Garantir fluxo direto (sem 2a tela) para cartoes sem sub-cards.
- [x] 4.7 Atualizar chamadores existentes do componente para o novo contrato de `onSelect`.
- [x] 4.8 Atualizar `PaymentMethodSelector.test.tsx` cobrindo modo `edit` e regressao do modo `create`.

## Detalhes de Implementacao

Ver `techspec.md` secoes "Interfaces Principais" (assinatura das novas props), "Riscos Conhecidos" (regressao em modo create) e "Conformidade com Skills Padroes" (decisao sobre extrair `EditCardSheet` se necessario). Ver `prd.md` secoes F2 e F3 para o detalhamento do fluxo.

## Criterios de Sucesso

- Componente continua funcionando em modo `create` sem mudanca de comportamento percebida pelo usuario.
- Modo `edit` exibe callout, indicador "selecionado" e pre-marcacao corretamente.
- Toque fora/botao X/back nativo nunca altera o cartao original.
- Nenhum chamador existente quebra na CI/typecheck/test.

## Testes da Tarefa

- [ ] Testes de unidade — `PaymentMethodSelector.test.tsx`:
  - modo `edit` renderiza callout "Cartao atual" com cartao + sub-cartao
  - cartao atual aparece com indicador "selecionado"
  - selecao de cartao com sub-cards navega para 2a tela com sub-card atual pre-marcado (quando do mesmo cartao)
  - selecao de cartao com sub-cards e cartao diferente -> 2a tela sem pre-marcacao
  - "Continuar sem sub-cartao" dispara `onSelect(paymentMethodId, null)`
  - selecao de cartao sem sub-cards dispara `onSelect(paymentMethodId, null)` direto
  - fechar (overlay/X/back nativo) NAO dispara `onSelect`
  - modo `create` (regressao): mantem comportamento existente, dispara `onSelect` com mesmo contrato
- [ ] Testes de integracao — `PaymentMethodSelector` montado dentro de uma pagina de teste, validando que o callback chega ao chamador.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PaymentMethodSelector.tsx` (modificar)
- `src/components/PaymentMethodSelector.css` (possiveis ajustes para callout/indicador)
- `src/components/PaymentMethodSelector.test.tsx` (modificar)
- Chamadores existentes do componente (varredura no `src/` — atualizar contrato de `onSelect`)
- (Opcional) `src/components/EditCardSheet.tsx` (novo, somente se a logica condicional crescer demais)
