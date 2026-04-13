# Tarefa 7.0: Frontend — Campo de parcelas no ManualEntryPage

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar campo de numero de parcelas no formulario de entrada manual. Quando o usuario selecionar mais de 1 parcela, exibir um preview com o calculo (ex: "10x de R$58,99 — ultima parcela em jan/2027"). Enviar `numberOfInstallments` no POST.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Adicionar campo numerico "Parcelas" no formulario (default 1, min 1, max 60)
- Quando parcelas > 1, exibir preview: "Nx de R$X,XX — ultima parcela em mes/ano"
- O valor informado no campo "Valor" e o valor da parcela (nao o total)
- Opcionalmente exibir o valor total: "Total: R$X.XXX,XX"
- Enviar `numberOfInstallments` no payload do POST (substituir o hardcode `1`)
- Toast de sucesso deve indicar parcelas: "Compra parcelada registrada — N parcelas criadas"
- Reset do campo apos salvar (voltar para 1)
</requirements>

## Subtarefas

- [ ] 7.1 Adicionar state `installments` (default 1) e campo numerico no formulario
- [ ] 7.2 Implementar preview de parcelamento (calculo de valor e data da ultima parcela)
- [ ] 7.3 Enviar `numberOfInstallments` no payload do POST
- [ ] 7.4 Ajustar toast de sucesso para indicar parcelas quando > 1
- [ ] 7.5 Testes

## Detalhes de Implementacao

Consultar secao "Experiencia do Usuario" do `prd.md` para o fluxo esperado.

O campo de parcelas pode ser um input numerico simples ou um conjunto de botoes rapidos (1x, 2x, 3x, 6x, 10x, 12x) + input customizado. Seguir o estilo visual existente do ManualEntryPage (classes `me-*`).

## Criterios de Sucesso

- Campo de parcelas visivel e funcional no formulario
- Preview calcula corretamente valor e data da ultima parcela
- POST envia `numberOfInstallments` correto
- Compra com 1 parcela continua funcionando como antes
- Build e testes passam

## Testes da Tarefa

- [ ] Testes de unidade: preview calcula "3x de R$100,00" para valor 100 e 3 parcelas
- [ ] Testes de unidade: preview calcula data da ultima parcela corretamente
- [ ] Testes de integracao (componente): renderiza campo de parcelas, simula selecao de 3x, verifica preview

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/ManualEntryPage.tsx` (modificar)
- `src/pages/ManualEntryPage.css` (modificar)
- `src/services/paymentMethodService.ts` (referencia — `createManualNotification`)
