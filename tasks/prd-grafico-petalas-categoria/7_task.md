# Tarefa 7.0: Integracao do `PetalDistributionChart` na `ByCategoryPage`

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Integrar o componente `PetalDistributionChart` (da feature `prd-grafico-petalas-distribuicao`) na `ByCategoryPage`, parametrizado pelo mes selecionado, com titulo "DISTRIBUICAO", indicador "Limite = 100%" e legenda. Toque em petala ou item da legenda abre o `CategoryDetailSheet`.

**Dependencia externa:** requer o `PetalDistributionChart` implementado (techspec da distribuicao). Se ainda nao estiver disponivel, esta tarefa fica bloqueada — as demais (1.0–6.0) nao dependem dela.

<skills>
### Conformidade com Skills Padroes

- `vercel-react-best-practices` — componente puro alimentado por `items` derivados via `useMemo` (mesmo array filtrado da lista).
- `frontend-design` / `ionic-design` — continuidade visual com o widget da Tab1; cores identicas entre petala, legenda e lista.
- `clean-code` — reuso do contrato de props da techspec de distribuicao, sem acoplamento a Tab1.
</skills>

<requirements>
- PRD 2.1: mesmas regras de renderizacao, calculo e destaque de estouro do PRD `prd-grafico-petalas-distribuicao`, aplicadas ao mes selecionado.
- PRD 2.2: titulo "DISTRIBUICAO", indicador "Limite = 100%" e legenda com nome e cor.
- PRD 2.3: toque em petala ou legenda abre o `CategoryDetailSheet` da categoria.
- Consistencia: grafico e lista alimentados pelo mesmo array filtrado (`EXPENSE && expected > 0 && actual > 0`) — cores e categorias identicas entre as duas superficies.
- Estado vazio (PRD 7.1) continua substituindo o bloco do grafico quando nao ha dados.
</requirements>

## Subtarefas

- [x] 7.1 Renderizar `PetalDistributionChart` na `ByCategoryPage` com os itens do mes selecionado (mesmo array da lista) e bloco completo (titulo, indicador, legenda).
- [x] 7.2 Conectar callbacks de petala/legenda ao `CategoryDetailSheet` (mesmo handler das linhas da lista).
- [x] 7.3 Testes de unidade/integracao na `ByCategoryPage`: grafico recebe os itens do mes; clique em petala e em item da legenda abre o sheet da categoria correta; troca de mes atualiza o grafico; estado vazio oculta o grafico.

## Detalhes de Implementacao

Ver techspec.md, secoes "Fluxo de dados" e "Riscos Conhecidos" (manter o contrato de props da techspec de distribuicao — componente puro por `items` — para evitar divergencia visual Tab1 vs. tela).

**Decisao de implementacao:** o `onViewDetailsClick` (obrigatorio no contrato do componente) faz scroll suave ate a lista de categorias na propria pagina — a lista e o proprio detalhamento, e o padrao espelha o handler da Tab1 (scroll ate a secao de detalhes). A techspec nao definia o comportamento desse botao dentro da tela.

## Criterios de Sucesso

- Grafico da tela identico em regras/cores ao widget da Tab1 para o mesmo mes.
- Petala/legenda/linha — os tres caminhos abrem o mesmo sheet.
- Testes verdes.

## Testes da Tarefa

- [x] Testes de unidade
- [x] Testes de integracao (pagina + grafico + sheet)
- [ ] Testes E2E (nao aplicavel nesta tarefa — smoke na Tarefa 9.0)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/ByCategoryPage.tsx` (integracao, + teste)
- `controlai-frontend/src/components/PetalDistributionChart.tsx` (da feature de distribuicao, consultado — NAO alterar o contrato)
