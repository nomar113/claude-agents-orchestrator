# Tarefa 8.0: Rota no App.tsx + Botao no PurchaseDetail

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Registrar a nova rota `/purchase/invoice/:id/suggestions` no `App.tsx` e adicionar o botao "Associar pagamento" na tela `PurchaseDetail` para invoices nao cancelados e nao associados. Este e o ponto de entrada do usuario para o fluxo de sugestoes.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir fluxo: implementar, rodar testes, typecheck, build, lint.
- `task-reviewer` — Review automatico ao concluir.
</skills>

<requirements>
- Adicionar rota `/purchase/invoice/:id/suggestions` no `App.tsx` apontando para `SuggestionsPage`
- Adicionar botao/link "Associar pagamento" na tela `PurchaseDetail` (tipo invoice)
- O botao deve aparecer APENAS para invoices nao cancelados e nao associados (RF24)
- Ao tocar no botao, navegar para `/purchase/invoice/:id/suggestions` passando via `location.state`: `{ invoiceId, invoiceTotal, invoiceDate, invoiceMerchantName }` (RF19, RF23)
- Usar `useHistory()` para navegacao (padrao do projeto com React Router v5)
</requirements>

## Subtarefas

- [x] 8.1 Adicionar rota no `App.tsx` para `SuggestionsPage`
- [x] 8.2 Adicionar botao "Associar pagamento" no `PurchaseDetail` com condicao de visibilidade (nao cancelado, nao associado)
- [x] 8.3 Implementar navegacao com `location.state` contendo dados do invoice
- [x] 8.4 Verificar typecheck e build

## Detalhes de Implementacao

Consultar a secao "F4. Ponto de Entrada na Tela de Detalhe do Invoice" do `prd.md` e "Arquitetura do Sistema > Frontend" da `techspec.md`.

**Rota:**
```tsx
<Route path="/purchase/invoice/:id/suggestions" component={SuggestionsPage} exact />
```

**Navegacao com state:**
```tsx
history.push(`/purchase/invoice/${invoiceId}/suggestions`, {
  invoiceId,
  invoiceTotal: invoice.total,
  invoiceDate: invoice.date,
  invoiceMerchantName: invoice.merchantName,
});
```

## Criterios de Sucesso

- Rota registrada e acessivel
- Botao visivel apenas para invoices elegiveis (nao cancelado, nao associado)
- Navegacao passa dados corretos via `location.state`
- TypeScript compila sem erros

## Testes da Tarefa

- [ ] Typecheck passa (`npx tsc --noEmit`)
- [ ] Build passa sem erros
- [ ] Verificacao visual: botao aparece para invoice elegivel
- [ ] Verificacao visual: botao NAO aparece para invoice cancelado

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/App.tsx` — rotas (controlai-frontend)
- `src/pages/PurchaseDetail.tsx` — tela de detalhe do invoice (controlai-frontend)
- `src/pages/PurchaseDetail.css` — estilos (controlai-frontend)
- `src/pages/SuggestionsPage.tsx` — pagina criada na tarefa 7.0
