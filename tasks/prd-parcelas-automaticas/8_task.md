# Tarefa 8.0: Frontend — InstallmentBadge + integracao no PurchaseList e Tab2

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar componente `InstallmentBadge` que exibe "3/10" para compras parceladas e integra-lo nas listagens existentes (PurchaseList na Tab1 e lista de notas na Tab2).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Criar componente `InstallmentBadge` que recebe `currentInstallment` e `totalInstallments`
- Renderiza badge textual "3/10" com estilo visual distinguivel (cor, borda, tamanho pequeno)
- Nao renderizar nada quando `totalInstallments <= 1`
- Integrar no `PurchaseList` (Tab1) — exibir badge ao lado do nome/categoria
- Integrar no `Tab2` (lista de notas fiscais) — exibir badge quando aplicavel
- Backend ja retorna `numberOfInstallments` no response de notificacoes — usar esse campo
- Para exibir a parcela atual, buscar da API de installments ou calcular baseado na data
</requirements>

## Subtarefas

- [ ] 8.1 Criar componente `InstallmentBadge.tsx` com CSS
- [ ] 8.2 Integrar no `PurchaseList.tsx` — exibir badge quando `numberOfInstallments > 1`
- [ ] 8.3 Integrar no `Tab2.tsx` — exibir badge nas notas fiscais parceladas
- [ ] 8.4 Testes

## Detalhes de Implementacao

Consultar secao "RF02 - Visualizacao de Parcelas do Mes" do `prd.md`.

O badge deve ser pequeno, com texto "3/10" em cor contrastante (ex: pill badge com background semi-transparente). Seguir o estilo existente das classes `ctrl-*`.

Para determinar a parcela atual: o backend ja retorna `numberOfInstallments`. Para a parcela corrente, pode-se fazer uma chamada a `/installments?parentId={id}` ou incluir a info na response do notification. A abordagem mais simples e exibir apenas "Nx" (ex: "10x") usando `numberOfInstallments` ja disponivel.

## Criterios de Sucesso

- Badge renderiza corretamente "10x" para compras parceladas
- Badge nao aparece para compras avulsas (1 parcela)
- Integrado nas duas listagens (Tab1 e Tab2)
- Visual consistente com o design system existente
- Build e testes passam

## Testes da Tarefa

- [ ] Testes de unidade: `InstallmentBadge` renderiza "10x" quando totalInstallments=10
- [ ] Testes de unidade: `InstallmentBadge` nao renderiza quando totalInstallments=1
- [ ] Testes de integracao (componente): `PurchaseList` exibe badge para notificacao parcelada

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/InstallmentBadge.tsx` (novo)
- `src/components/InstallmentBadge.css` (novo)
- `src/components/PurchaseList.tsx` (modificar)
- `src/pages/Tab2.tsx` (modificar)
