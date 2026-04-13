# Tarefa 9.0: Frontend — Detalhes de parcelas no PurchaseDetail

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar secao de detalhes de parcelas na tela `PurchaseDetail`. Quando a compra for parcelada, exibir lista de todas as parcelas com status (paga/futura/cancelada) e botao para cancelar parcelas futuras.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Quando a compra tem `numberOfInstallments > 1`, buscar parcelas via `listInstallments(parentId)`
- Exibir secao "Parcelas" com lista mostrando: numero (1/10), valor, data de vencimento, status
- Status visual: parcela passada (verde/checkmark), parcela futura (cinza/pendente), cancelada (vermelho/riscado)
- Botao "Cancelar parcelas futuras" com confirmacao (ConfirmDialog)
- Apos cancelamento, atualizar lista de parcelas na tela
- Exibir resumo: valor total da compra, parcelas restantes, data da ultima parcela
</requirements>

## Subtarefas

- [ ] 9.1 Buscar parcelas via `installmentService.listInstallments()` quando `numberOfInstallments > 1`
- [ ] 9.2 Renderizar secao "Parcelas" com lista e status visual
- [ ] 9.3 Implementar botao "Cancelar parcelas futuras" com confirmacao
- [ ] 9.4 Exibir resumo (valor total, parcelas restantes, ultima parcela)
- [ ] 9.5 Testes

## Detalhes de Implementacao

Consultar secao "Visualizacao no mes" do `prd.md` e secao "Endpoints de API" da `techspec.md`.

O `PurchaseDetail.tsx` ja tem secoes para exibir dados do notification. Adicionar uma nova secao abaixo dos dados existentes, condicional a `numberOfInstallments > 1`.

Para determinar se uma parcela e "passada" ou "futura", comparar `dueDate` com a data atual.

## Criterios de Sucesso

- Secao de parcelas aparece apenas para compras parceladas
- Lista exibe todas as parcelas com status visual correto
- Cancelamento funciona e atualiza a UI
- Compras avulsas nao mostram secao de parcelas
- Build e testes passam

## Testes da Tarefa

- [ ] Testes de unidade: secao de parcelas renderiza quando numberOfInstallments > 1
- [ ] Testes de unidade: secao nao renderiza quando numberOfInstallments = 1
- [ ] Testes de integracao (componente): mock de listInstallments, verifica lista renderizada com status

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/PurchaseDetail.tsx` (modificar)
- `src/pages/PurchaseDetail.css` (modificar, se existir)
- `src/services/installmentService.ts` (da tarefa 6)
- `src/types/installment.ts` (da tarefa 6)
