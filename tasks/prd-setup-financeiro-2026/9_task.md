# Tarefa 9.0: Frontend — Exibir categoria na listagem e detalhe de compras

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar `PurchaseDetail.tsx` e `PurchaseList.tsx` para exibir o nome da categoria vindo do backend (`categoryName`). Remover o fallback `getCategoryLabel()` que faz auto-detecao por regex no nome do estabelecimento.

<skills>
### Conformidade com Skills Padroes

- **`ionic-design`**: Componentes Ionic nativos para exibicao.
- **`clean-code`**: Remover codigo morto (getCategoryLabel).
</skills>

<requirements>
- Atualizar tipos de compra para incluir `categoryName: string | null`
- PurchaseDetail: exibir `categoryName` do backend na secao de informacoes
- PurchaseDetail: remover funcao `getCategoryLabel()` e auto-detecao por regex
- PurchaseDetail: tratar compras sem categoria (`categoryName = null`) com texto "Sem categoria"
- PurchaseList: exibir categoria como badge/tag em cada item da lista (se aplicavel ao layout atual)
- Permitir atribuir categoria a compras importadas via nota fiscal na tela de detalhe
</requirements>

## Subtarefas

- [ ] 9.1 Atualizar tipos de compra para incluir `categoryName`
- [ ] 9.2 Atualizar `PurchaseDetail.tsx` — exibir `categoryName`, remover `getCategoryLabel()`
- [ ] 9.3 Atualizar `PurchaseList.tsx` — exibir categoria nos itens da lista
- [ ] 9.4 Adicionar seletor de categoria em PurchaseDetail para compras sem categoria (importadas via NF)
- [ ] 9.5 Escrever testes unitarios

## Detalhes de Implementacao

O `PurchaseDetail.tsx` atualmente usa (linhas 188-196) uma funcao `getCategoryLabel()` que faz regex matching no `merchantName` para auto-detectar categoria. Essa logica deve ser removida e substituida pelo campo `categoryName` vindo do backend.

Para compras importadas sem categoria, exibir um `CategoryChips` (task 8) para permitir atribuicao.

## Criterios de Sucesso

- Categoria exibida corretamente em detalhes e listagem
- Funcao `getCategoryLabel()` removida
- Compras sem categoria exibem "Sem categoria" ou seletor para atribuir
- Build passa sem erros

## Testes da Tarefa

- [ ] Teste unitario: PurchaseDetail exibe categoryName quando presente
- [ ] Teste unitario: PurchaseDetail exibe "Sem categoria" quando categoryName e null
- [ ] Teste unitario: PurchaseList exibe categoria nos itens
- [ ] Verificacao: getCategoryLabel nao existe mais no codigo

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/PurchaseDetail.tsx` — Sera modificado
- `controlai-frontend/src/pages/PurchaseDetail.css` — Estilos
- `controlai-frontend/src/components/PurchaseList.tsx` — Sera modificado
- `controlai-frontend/src/components/CategoryChips.tsx` — Componente reutilizavel (task 8)
